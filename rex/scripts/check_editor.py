#!/usr/bin/env python3
"""Check the editor actions on a throwaway Rex server, never the running one.

    python3 rex/scripts/check_editor.py

Starts `rex server run` on a private socket with this repository's config and
drives the edit, buffers and buffer_cycle actions through the CLI. Each action
is given its argument, so no prompt is shown and the check needs no Rex app.
Needs rex, nvim and git on PATH.
"""
import json
import os
import subprocess
import tempfile
import time
from pathlib import Path

CONFIG = Path(__file__).resolve().parent.parent / "init.lua"
READY_TIMEOUT_S, EDITOR_TIMEOUT_S = 10, 20
SETTLE_S = 0.2
# Rex panes inherit these; a stale value would point the CLI at the live server.
REX_ENV = ("REX_SERVER", "REX_SESSION", "REX_BLOCK")
FILES = {"one.py": "value = 1\n", "two.py": "value = 2\n"}


def main():
    with tempfile.TemporaryDirectory() as tmp:
        tmp = Path(tmp)
        sockets = tmp / "sockets"
        env = {k: v for k, v in os.environ.items() if k not in REX_ENV}
        env["REX_NVIM_SOCKET_DIR"] = str(sockets)
        socket = f"unix://{tmp}/rex.sock"
        server = subprocess.Popen(
            ["rex", "server", "run", "--listen", socket, "--config", str(CONFIG),
             "--state-dir", f"{tmp}/state", "--restore=false"],
            env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        try:
            check(Rex(socket=socket, env=env), project=make_project(tmp), sockets=sockets)
        finally:
            server.terminate()
            server.wait()
    print("Rex editor: open, reuse, buffer list and cycle checks passed")


def make_project(tmp):
    project = tmp / "project"
    project.mkdir()
    for name, body in FILES.items():
        (project / name).write_text(body)
    subprocess.run(["git", "init", "-q"], cwd=project, check=True)
    subprocess.run(["git", "add", "-A"], cwd=project, check=True)
    # git rev-parse resolves symlinks, so the Lua side sees the real path.
    return project.resolve()


class Rex:
    def __init__(self, *, socket, env):
        self.base, self.env = ["rex", "--autostart=false", "-S", socket], env

    def __call__(self, *args, check=True):
        return subprocess.run(self.base + list(args), env=self.env,
                              capture_output=True, text=True, check=check)

    def view(self):
        return json.loads(self("api", "call", "-s", "check", "session.view").stdout)

    def do(self, block, *args):
        return self("do", "-s", "check", "-b", block, *args)


def labels(view):
    """Every block label in the session."""
    return [b["label"] for w in view["windows"] for layer in w["layers"]
            for b in layer["blocks"]]


def editor_socket(sockets, project):
    """Mirrors project_socket() in init.lua."""
    slug = "".join(c if c.isalnum() else "_" for c in str(project))
    return sockets / f"{slug}.sock"


def remote_expr(socket, expression):
    done = subprocess.run(["nvim", "--server", str(socket), "--remote-expr", expression],
                          capture_output=True, text=True)
    return done.stdout if done.returncode == 0 else None


def await_editor(socket):
    deadline = time.monotonic() + EDITOR_TIMEOUT_S
    while time.monotonic() < deadline:
        if socket.exists() and remote_expr(socket, "1") is not None:
            return
        time.sleep(SETTLE_S)
    raise AssertionError(f"Neovim never answered on {socket}")


def current_file(socket):
    shown = remote_expr(socket, 'fnamemodify(bufname("%"), ":t")')
    assert shown is not None, "editor stopped answering"
    return shown.strip()


def listed_files(socket):
    listing = remote_expr(
        socket,
        'join(map(getbufinfo({"buflisted":1}), {_, b -> fnamemodify(bufname(b.bufnr), ":t")}), ",")')
    assert listing is not None, "editor stopped answering"
    return sorted(name for name in listing.strip().split(",") if name)


def check(rex, *, project, sockets):
    deadline = time.monotonic() + READY_TIMEOUT_S
    while rex("server", "status", check=False).returncode != 0:
        assert time.monotonic() < deadline, "throwaway Rex server did not start"
        time.sleep(0.1)
    session = json.loads(rex("new", "check", "--json").stdout)
    shell = session["initial_windows"][0]["block_ids"][0]
    socket = editor_socket(sockets, project)

    # Given a shell, When edit opens a file, Then Rex adds one editor pane.
    rex.do(shell, "edit", "path=one.py", f"cwd={project}")
    await_editor(socket)
    editors = [label for label in labels(rex.view()) if label.startswith("editor:")]
    assert editors == [f"editor:{project.name}"], editors
    assert current_file(socket) == "one.py", current_file(socket)

    # Given that editor, When edit opens a second file, Then it is reused
    # rather than split again, and both files are listed.
    rex.do(shell, "edit", "path=two.py", f"cwd={project}")
    reused = [label for label in labels(rex.view()) if label.startswith("editor:")]
    assert reused == editors, f"edit split a second editor pane: {reused}"
    assert current_file(socket) == "two.py", current_file(socket)
    assert listed_files(socket) == ["one.py", "two.py"], listed_files(socket)

    # Given two buffers, When buffer_cycle runs, Then the shown file changes
    # and comes back after cycling the other way.
    rex.do(shell, "buffer_cycle", "direction=next", f"cwd={project}")
    assert current_file(socket) == "one.py", current_file(socket)
    rex.do(shell, "buffer_cycle", "direction=prev", f"cwd={project}")
    assert current_file(socket) == "two.py", current_file(socket)

    # Given a pattern with no match, When search runs, Then it returns without
    # asking anything, so scripted callers never block.
    done = rex.do(shell, "search", "pattern=no-such-text-anywhere", f"cwd={project}")
    assert done.returncode == 0, done.stderr


if __name__ == "__main__":
    main()
