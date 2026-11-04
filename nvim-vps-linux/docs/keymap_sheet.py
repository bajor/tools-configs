#!/usr/bin/env python3
"""Generate the Ferris Sweep cheat sheet (SVG, PDF) and the README key table.

The Neovim maps are the only source. scripts/keymaps.lua exports them as JSON;
this script lays them out on the Sweep and exits nonzero when a label does not
fit its key or a map would be dropped or drawn twice.

    python3 nvim-vps-linux/docs/keymap_sheet.py           write SVG, PDF, README table
    python3 nvim-vps-linux/docs/keymap_sheet.py --check   fail when the SVG or table is stale
    python3 nvim-vps-linux/docs/keymap_sheet.py --json F  use an existing export

Set NVIM to choose the Neovim binary. The PDF needs cairosvg or rsvg-convert.
"""
import argparse
import html
import json
import os
import shutil
import subprocess
import tempfile
from pathlib import Path

DOCS = Path(__file__).resolve().parent
CONFIG = DOCS.parent
REPO = CONFIG.parent
SVG_PATH = DOCS / "ferris-sweep-nvim.svg"
PDF_PATH = DOCS / "ferris-sweep-nvim.pdf"
README_PATH = CONFIG / "README.md"
TABLE_START = "<!-- keymaps:start -->"
TABLE_END = "<!-- keymaps:end -->"
EXPORT_TIMEOUT_S = 120

# Layout from bajor/zmk-config-ferris (base layer). Home-row letters are
# hold-taps: hold for Shift, Alt, Ctrl or Gui.
BASE_ROWS = ["QWERTYUIOP", "ASDFGHJKL'", "ZXCVBNM,./"]
HOLD_MODS = {"A": "Sft", "S": "Alt", "D": "Ctl", "F": "Gui",
             "J": "Gui", "K": "Ctl", "L": "Alt", "'": "Sft"}
# Left outer, left inner, right inner, right outer thumb: tap label, hold label.
THUMBS = [("Tab", "hold Sym"), ("Enter", ""), ("Space", ""), ("Bksp", "hold Num")]
THUMB_COLUMNS = (3, 4, 5, 6)
LEADER = "<Space>"
GROUP_NAMES = {"a": "AI", "c": "Code", "d": "Debug", "f": "Find", "g": "Git", "r": "Run"}
ACCENT_ORDER = ("blue", "green", "yellow", "red", "magenta", "cyan")
MODE_LEGEND = "n normal, i insert, x visual, s select, o operator, t terminal"

# Millimetres on an A4 landscape page.
PAGE_W, PAGE_H = 297, 210
MARGIN_X, MARGIN_TOP = 7.5, 6
HEADER_H = 14
KEY_W, KEY_H = 13.5, 11.2
HALF_GAP = 3
PANEL_W = 10 * KEY_W + HALF_GAP
PANEL_GAP = 6
ROW_GAP = 4
TITLE_H = 6.5
PAD = 0.8
LEGEND_SIZE = 2.4
TEXT_TOP = 4.0
TAG_SIZE = 1.5
GROUP_PANEL_SLOTS = 6

# Labels use a monospace font, so a line is exactly characters * em * size wide.
FONT = "'DejaVu Sans Mono', Menlo, Consolas, monospace"
CHAR_EM = 0.602
LINE_EM = 1.18
FONT_SIZES = (2.2, 2.0, 1.8, 1.7)

INK, MUTED = "#1b2b30", "#66767c"
KEY_FILL, KEY_STROKE = "#f4f6f7", "#b9c2c6"
TINT_STRENGTH, SHADE_STRENGTH = 0.22, 0.55
TABLE_ROW_H = 3.25
TABLE_SIZE = 2.0
TABLE_COLUMN_W = 66
TABLE_MODE_W, TABLE_KEY_W = 8, 10


def mix(color, target, amount):
    channels = [int(color[i:i + 2], 16) for i in (1, 3, 5)]
    return "#" + "".join(f"{round(target + (c - target) * amount):02x}" for c in channels)


def tint(color):
    return mix(color, target=255, amount=TINT_STRENGTH)


def shade(color):
    return mix(color, target=0, amount=SHADE_STRENGTH)


def esc(text):
    return html.escape(text, quote=False)


def wrap(text, width):
    lines, line = [], ""
    for word in text.split():
        if len(word) > width:
            return None
        candidate = f"{line} {word}".strip()
        if len(candidate) <= width:
            line = candidate
        else:
            lines.append(line)
            line = word
    return lines + [line] if line else lines


def fit(labels, width, height):
    """Largest font size at which every label wraps and the lines fit a box."""
    for size in FONT_SIZES:
        wrapped = [wrap(label, int(width / (CHAR_EM * size))) for label in labels]
        if None not in wrapped and sum(map(len, wrapped)) * LINE_EM * size <= height:
            return size, wrapped
    raise SystemExit(f"label does not fit a {width:.1f} x {height:.1f} mm box: {labels}")


def text(x, y, content, size, fill=INK, weight="normal", anchor="start"):
    return (f'<text x="{x:.2f}" y="{y:.2f}" font-size="{size}" fill="{fill}" '
            f'font-weight="{weight}" text-anchor="{anchor}">{esc(content)}</text>')


def key_x(column):
    return column * KEY_W + (HALF_GAP if column >= 5 else 0)


def key_svg(x, y, legend, lines, accent=None, tag=""):
    fill, stroke = (tint(accent), accent) if accent else (KEY_FILL, KEY_STROKE)
    parts = [f'<rect x="{x:.2f}" y="{y:.2f}" width="{KEY_W - 0.5}" height="{KEY_H - 0.5}" '
             f'rx="1.2" fill="{fill}" stroke="{stroke}" stroke-width="{0.35 if accent else 0.25}"/>']
    legend_fill = shade(accent) if accent else MUTED
    parts.append(text(x + PAD, y + 3.0, legend, LEGEND_SIZE, legend_fill, "bold"))
    if tag:
        parts.append(text(x + KEY_W - 0.5 - PAD, y + 2.8, tag, TAG_SIZE, MUTED, anchor="end"))
    if lines:
        size, wrapped = fit(lines, KEY_W - 0.5 - 2 * PAD, KEY_H - TEXT_TOP - 0.5)
        row = 0
        for label_lines in wrapped:
            for line in label_lines:
                baseline = y + TEXT_TOP + size * 0.85 + row * LINE_EM * size
                parts.append(text(x + PAD, baseline, line, size))
                row += 1
    return "\n".join(parts)


def keyboard(x0, y0, title, cells, accents, thumbs=False, tags=False):
    """cells: key character -> list of label strings; accents: key -> color."""
    parts = [text(x0, y0 + 4.2, title, 3.6, INK, "bold")]
    top = y0 + TITLE_H
    for row, letters in enumerate(BASE_ROWS):
        for column, char in enumerate(letters):
            parts.append(key_svg(x0 + key_x(column), top + row * KEY_H, char.upper(),
                                 cells.get(char.lower(), []), accents.get(char.lower()),
                                 HOLD_MODS.get(char.upper(), "") if tags else ""))
    if thumbs:
        for column, (tap, hold) in zip(THUMB_COLUMNS, THUMBS):
            labels = [tap] + ([hold] if hold else [])
            accent = accents.get("space") if tap == "Space" else None
            parts.append(key_svg(x0 + key_x(column), top + 3 * KEY_H, "", labels, accent))
    return "\n".join(parts)


def classify(rows):
    singles, groups, others = {}, {}, []
    for row in rows:
        if not row["lhs"].startswith(LEADER):
            others.append(row)
            continue
        rest = row["lhs"][len(LEADER):]
        if len(rest) == 1 and rest not in singles:
            singles[rest] = row
        elif len(rest) == 2:
            groups.setdefault(rest[0], {})[rest[1]] = row
        else:
            raise SystemExit(f"unsupported or duplicate leader map: {row['lhs']}")
    clash = set(singles) & set(groups)
    if clash:
        raise SystemExit(f"leader letters are both an action and a group prefix: {sorted(clash)}")
    if len(groups) > GROUP_PANEL_SLOTS:
        raise SystemExit(f"{len(groups)} leader groups; the sheet has {GROUP_PANEL_SLOTS} panels")
    return singles, groups, others


def check_position(char):
    if not any(char.lower() in row.lower() for row in BASE_ROWS):
        raise SystemExit(f"leader key {char!r} is not on the base layer")


def strip_group(desc, name):
    words = desc.split()
    return " ".join(words[1:]) if len(words) > 1 and words[0].lower() == name.lower() else desc


def action_cells(actions, name=""):
    """Map each physical key to its labels: the plain key first, then Shift."""
    cells = {}
    for char, row in sorted(actions.items(), key=lambda item: (item[0].isupper(), item[0])):
        check_position(char)
        label = strip_group(row["desc"], name)
        cells.setdefault(char.lower(), []).append(("⇧ " if char.isupper() else "") + label)
    return cells


def key_name(lhs):
    if not lhs.startswith("<"):
        return lhs
    *modifiers, last = lhs.strip("<>").split("-")
    names = {"CR": "Enter", "Tab": "Tab", "Up": "Up", "Down": "Down"}
    return "-".join(modifiers + [names.get(last, last.lower() if len(last) == 1 else last)])


def table_svg(x0, y0, rows):
    height = KEY_H * 4 + TITLE_H
    per_column = int((height - TITLE_H - 3) // TABLE_ROW_H)
    if len(rows) > 2 * per_column:
        raise SystemExit(f"{len(rows)} non-leader maps do not fit the side table ({2 * per_column})")
    parts = [text(x0, y0 + 4.2, "Other keys", 3.6, INK, "bold")]
    for index, row in enumerate(rows):
        x = x0 + (index // per_column) * (TABLE_COLUMN_W + 4)
        y = y0 + TITLE_H + (index % per_column) * TABLE_ROW_H + TABLE_SIZE
        if len(row["desc"]) * CHAR_EM * TABLE_SIZE > TABLE_COLUMN_W - TABLE_MODE_W - TABLE_KEY_W:
            raise SystemExit(f"description too long for the side table: {row['desc']}")
        parts += [text(x, y, row["mode"], TABLE_SIZE, MUTED),
                  text(x + TABLE_MODE_W, y, key_name(row["lhs"]), TABLE_SIZE, INK, "bold"),
                  text(x + TABLE_MODE_W + TABLE_KEY_W, y, row["desc"], TABLE_SIZE)]
    parts.append(text(x0, y0 + height - 0.5, MODE_LEGEND, 1.7, MUTED))
    return "\n".join(parts)


def render(data):
    palette, rows = data["palette"], data["keymaps"]
    missing = [name for name in ACCENT_ORDER if name not in palette]
    if missing:
        raise SystemExit(f"the export has no palette colors {missing}; update scripts/keymaps.lua")
    if len({(r["lhs"], r["mode"], r["desc"]) for r in rows}) != len(rows):
        raise SystemExit("the export lists a map twice")
    singles, groups, others = classify(rows)
    accents = {letter: palette[ACCENT_ORDER[i % len(ACCENT_ORDER)]]
               for i, letter in enumerate(sorted(groups))}
    column_x = (MARGIN_X, MARGIN_X + PANEL_W + PANEL_GAP)
    first_y = MARGIN_TOP + HEADER_H
    overview_h = TITLE_H + 4 * KEY_H
    group_h = TITLE_H + 3 * KEY_H
    cells = action_cells(singles)
    for letter in groups:
        cells[letter] = [GROUP_NAMES.get(letter, letter.upper())]
    placed = len(singles) + sum(map(len, groups.values())) + len(others)
    if placed != len(rows):
        raise SystemExit(f"{len(rows) - placed} maps were not placed on the sheet")
    parts = [header(),
             keyboard(column_x[0], first_y, "Space, then...", cells, {**accents, "space": palette["blue"]},
                      thumbs=True, tags=True),
             table_svg(column_x[1], first_y, others)]
    for index, letter in enumerate(sorted(groups)):
        name = GROUP_NAMES.get(letter, letter.upper())
        x = column_x[index % 2]
        y = first_y + overview_h + ROW_GAP + (index // 2) * (group_h + ROW_GAP)
        parts.append(keyboard(x, y, f"Space {letter}: {name}", action_cells(groups[letter], name),
                              {char.lower(): accents[letter] for char in groups[letter]}))
    return svg_document(parts)


def header():
    return "\n".join([
        text(MARGIN_X, MARGIN_TOP + 5, "Neovim on the VPS: Ferris Sweep cheat sheet", 5.2, INK, "bold"),
        text(MARGIN_X, MARGIN_TOP + 9.0,
             "Leader is Space (right inner thumb). QWERTY base layer. A coloured key starts a group; "
             "a Shift variant is marked with a raised arrow.", 1.9, MUTED),
        text(MARGIN_X, MARGIN_TOP + 11.8,
             "Hold the left outer thumb for symbols, the right outer thumb for numbers and arrows "
             "(Esc is the left inner thumb there). Sft, Alt, Ctl, Gui: hold that home-row key.",
             1.9, MUTED),
    ])


def svg_document(parts):
    body = "\n".join(parts)
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{PAGE_W}mm" height="{PAGE_H}mm" '
            f'viewBox="0 0 {PAGE_W} {PAGE_H}" font-family="{FONT}">\n'
            f'<title>Neovim on the VPS: Ferris Sweep cheat sheet</title>\n'
            f'<rect width="{PAGE_W}" height="{PAGE_H}" fill="#ffffff"/>\n{body}\n</svg>\n')


def readme_table(rows):
    lines = ["| Mode | Keys | Action |", "| --- | --- | --- |"]
    for row in rows:
        lines.append(f"| {row['mode']} | `{row['lhs']}` | {row['desc'].replace('|', '/')} |")
    return "\n".join(lines)


def replace_table(readme, table):
    if readme.count(TABLE_START) != 1 or readme.count(TABLE_END) != 1:
        raise SystemExit(f"README needs exactly one {TABLE_START} and one {TABLE_END}")
    head, rest = readme.split(TABLE_START)
    _, tail = rest.split(TABLE_END)
    return f"{head}{TABLE_START}\n{table}\n{TABLE_END}{tail}"


def write_pdf(svg_path, pdf_path):
    try:
        import cairosvg
        cairosvg.svg2pdf(url=str(svg_path), write_to=str(pdf_path))
    except ImportError:
        converter = shutil.which("rsvg-convert")
        if not converter:
            raise SystemExit("PDF needs cairosvg (pip install cairosvg) or rsvg-convert (librsvg2-bin)")
        subprocess.run([converter, "-f", "pdf", "-o", str(pdf_path), str(svg_path)], check=True)


def export_keymaps():
    with tempfile.TemporaryDirectory() as tmp:
        target = Path(tmp) / "keymaps.json"
        subprocess.run(
            [os.environ.get("NVIM", "nvim"), "--headless",
             f"+luafile {CONFIG / 'scripts' / 'keymaps.lua'}"],
            check=True, cwd=REPO, timeout=EXPORT_TIMEOUT_S,
            env={**os.environ, "VPS_KEYMAP_JSON": str(target)})
        return json.loads(target.read_text())


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("--check", action="store_true", help="fail when the SVG or table is stale")
    parser.add_argument("--json", type=Path, help="use an existing keymaps.lua export")
    args = parser.parse_args()
    data = json.loads(args.json.read_text()) if args.json else export_keymaps()
    svg = render(data)
    readme = replace_table(README_PATH.read_text(), readme_table(data["keymaps"]))
    if args.check:
        stale = [p.name for p, new in ((SVG_PATH, svg), (README_PATH, readme))
                 if not p.exists() or p.read_text() != new]
        if not PDF_PATH.exists():
            stale.append(PDF_PATH.name)
        raise SystemExit(f"stale: {', '.join(stale)}; run keymap_sheet.py" if stale else 0)
    SVG_PATH.write_text(svg)
    README_PATH.write_text(readme)
    write_pdf(SVG_PATH, PDF_PATH)
    print(f"Wrote {SVG_PATH.name}, {PDF_PATH.name} and the README table ({len(data['keymaps'])} maps)")


if __name__ == "__main__":
    main()
