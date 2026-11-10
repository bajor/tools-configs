#!/usr/bin/env python3
"""Enable the repository's retry setup without changing models or credentials."""

import argparse
import json
import os
from pathlib import Path
import shutil
import time

ROOT = Path(__file__).resolve().parent


def read_json(*, path):
    if not path.exists():
        return {}
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as error:
        raise SystemExit(f"Cannot safely merge {path}: {error}. Merge manually using the README.") from error


def write_backed_up(*, path, content):
    if path.exists() and path.read_bytes() == content:
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists():
        backup = path.with_name(f"{path.name}.bak-{time.time_ns()}")
        shutil.copy2(src=path, dst=backup)
        print(f"Backup: {backup}")
    path.write_bytes(content)
    print(f"Installed: {path}")


def install_opencode():
    directory = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config")) / "opencode"
    configs = [path for path in (directory / "opencode.json", directory / "opencode.jsonc") if path.exists()]
    if len(configs) > 1:
        raise SystemExit("Both OpenCode config files exist. Merge the plugin manually using opencode/README.md.")
    path = configs[0] if configs else directory / "opencode.json"
    config = read_json(path=path)
    template = read_json(path=ROOT / "opencode/opencode.jsonc")
    plugin = template["plugins"][0]
    name = plugin.rsplit("@", 1)[0]
    plugins = config.get("plugins", [])
    if not isinstance(plugins, list) or any(not isinstance(item, str) for item in plugins):
        raise SystemExit("OpenCode uses plugin objects. Merge the retry plugin manually to preserve its options.")
    config["plugins"] = [item for item in plugins if item != name and not item.startswith(name + "@")]
    config["plugins"].append(plugin)
    config.setdefault("$schema", template["$schema"])
    fallback_path = directory / "rate-limit-fallback.json"
    fallback = read_json(path=fallback_path)
    fallback.update(read_json(path=ROOT / "opencode/rate-limit-fallback.json"))
    for destination, value in ((path, config), (fallback_path, fallback)):
        write_backed_up(path=destination, content=(json.dumps(obj=value, indent=2) + "\n").encode())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--target", choices=("all", "opencode", "pi"), default="all")
    target = parser.parse_args().target
    if target in ("all", "opencode"):
        install_opencode()
    if target in ("all", "pi"):
        agent_directory = Path(os.environ.get("PI_CODING_AGENT_DIR", Path.home() / ".pi/agent"))
        write_backed_up(path=agent_directory / "extensions/limit-retry.ts", content=(ROOT / "pi/limit-retry.ts").read_bytes())


if __name__ == "__main__":
    main()
