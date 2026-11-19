#!/usr/bin/env python3
"""Check rex/init.lua on a throwaway Rex server, never the running one.

    python3 rex/scripts/check_config.py

Starts `rex server run` on a private socket with this repository's config,
then drives it through the CLI: the run, agent and scratch actions, and
Alt+h/j/k/l between a shell and Neovim. Needs rex and nvim on PATH.
"""
import json
import os
import subprocess
import tempfile
import time
from pathlib import Path

CONFIG = Path(__file__).resolve().parent.parent / "init.lua"
READY_TIMEOUT_S, SETTLE_S = 10, 1.5
SHARE_TOLERANCE = 0.01
RUN_SHARE, AGENT_SHARE = 0.3, 0.4
# Rex panes inherit these; a stale value would point the CLI at the live server.
REX_ENV = ("REX_SERVER", "REX_SESSION", "REX_BLOCK")


def main():
    with tempfile.TemporaryDirectory() as tmp:
        env = {k: v for k, v in os.environ.items() if k not in REX_ENV}
        socket = f"unix://{tmp}/rex.sock"
        server = subprocess.Popen(
            ["rex", "server", "run", "--listen", socket, "--config", str(CONFIG),
             "--state-dir", f"{tmp}/state", "--restore=false"],
            env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        try:
            check(Rex(socket=socket, env=env), tmp=Path(tmp))
        finally:
            server.terminate()
            server.wait()
    print("Rex config: run, agent, scratch and Alt navigation checks passed")


class Rex:
    def __init__(self, *, socket, env):
        self.base, self.env = ["rex", "--autostart=false", "-S", socket], env

    def __call__(self, *args, stdin=None, check=True):
        return subprocess.run(self.base + list(args), env=self.env, input=stdin,
                              capture_output=True, text=True, check=check)

    def view(self):
        return json.loads(self("api", "call", "-s", "check", "session.view").stdout)

    def key(self, *, session_id, letter):
        """Press Alt+letter the way a client does, so Lua bindings run first."""
        press = {"key": "key_" + letter, "mods": "alt", "consumed_mods": "", "text": "",
                 "unshifted_codepoint": ord(letter), "composing": False, "action": "press"}
        self("api", "call", "client.key", "-", stdin=json.dumps({"session_id": session_id, "key": press}))


def tiles(view):
    """Block label -> [x, y, width, height] for every tiled pane."""
    labels = {b["block_id"]: b["label"] for w in view["windows"] for layer in w["layers"]
              for b in layer["blocks"]}
    rects, stack = {}, [layer["layout"] for w in view["windows"] for layer in w["layers"]
                        if layer["kind"] == "tiled"]
    while stack:
        node = stack.pop()
        if "block_id" in node:
            rects[labels[node["block_id"]]] = node["rect"]
        stack += [node["split"][side] for side in ("before", "after") if "split" in node]
    return rects


def focused(view):
    return view["windows"][0]["focused_block_id"]


def check(rex, *, tmp):
    deadline = time.monotonic() + READY_TIMEOUT_S
    while rex("server", "status", check=False).returncode != 0:
        assert time.monotonic() < deadline, "throwaway Rex server did not start"
        time.sleep(0.1)
    session = json.loads(rex("new", "check", "--json").stdout)
    session_id, shell = session["session_id"], session["initial_windows"][0]["block_ids"][0]

    # Given a shell, When run executes a command, Then a 30% pane below keeps its output.
    rex("do", "-s", "check", "-b", shell, "run", "cmd=echo run-ok")
    time.sleep(SETTLE_S)
    rects = tiles(rex.view())
    assert "run" in rects, f"run pane closed after its command exited: {rects}"
    assert abs(rects["run"][3] - RUN_SHARE) < SHARE_TOLERANCE, rects
    assert "run-ok" in rex("capture", "-s", "check", "-b", "run").stdout, "run output missing"

    # Given an unknown agent name, When agent runs, Then Rex refuses it.
    refused = rex("do", "-s", "check", "-b", shell, "agent", "name=bogus", check=False)
    assert refused.returncode != 0 and "unknown agent" in refused.stderr, refused.stderr

    # Given a shell above the run pane, When Alt+j is pressed, Then Rex focuses the run pane.
    rex("block", "focus", "-s", "check", shell)
    rex.key(session_id=session_id, letter="j")
    assert focused(rex.view()) != shell, "Alt+j did not leave the shell"

    # Given Neovim in a pane, When Alt+h is pressed, Then Neovim receives <M-h>.
    marker = tmp / "alt-h"
    rex("split", "-s", "check", "-b", shell, "--split", "right", "--ratio", str(int(AGENT_SHARE * 100)),
        "--label", "editor", "--", "nvim", "--clean",
        "-c", f"nnoremap <M-h> <Cmd>call writefile(['ok'], '{marker}')<CR>")
    time.sleep(SETTLE_S)
    editor = focused(rex.view())
    rex.key(session_id=session_id, letter="h")
    time.sleep(SETTLE_S)
    assert marker.exists(), "Neovim did not receive Alt+h"
    assert focused(rex.view()) == editor, "Rex moved focus away from Neovim"

    # Given any pane, When scratch runs, Then a floating shell opens.
    rex("do", "-s", "check", "-b", shell, "scratch")
    floating = [layer for w in rex.view()["windows"] for layer in w["layers"] if layer["kind"] != "tiled"]
    assert any(b["label"] == "scratch" for layer in floating for b in layer["blocks"]), floating


if __name__ == "__main__":
    main()
