#!/usr/bin/env python3
"""Generate the Ferris Sweep cheat sheet (SVG, PDF) and the README key table.

The Neovim maps are the only source of shortcuts. scripts/keymaps.lua exports
them as JSON; this script lays them out on the Sweep and exits nonzero when a
label does not fit its key or a map would be dropped.

    python3 nvim-vps-linux/docs/keymap_sheet.py           write SVG, PDF, README table
    python3 nvim-vps-linux/docs/keymap_sheet.py --check   fail when the SVG or table is stale
    python3 nvim-vps-linux/docs/keymap_sheet.py --json F  use an existing export

Set VPS_NVIM to choose the Neovim binary (not NVIM: Neovim sets that to its
server address inside :terminal). Neovim runs with this repository's config,
whatever ~/.config/nvim holds. The PDF needs cairosvg or rsvg-convert.
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
ENCODING = "utf-8"

# Kept by hand on purpose: these describe the physical keyboard and name the
# leader groups. They are not shortcuts, so they cannot be read from Neovim.
# Layout from bajor/zmk-config-ferris (base layer). Home-row letters are
# hold-taps: hold for Shift, Alt, Ctrl or Gui.
BASE_ROWS = ["QWERTYUIOP", "ASDFGHJKL'", "ZXCVBNM,./"]
HOLD_MODS = {"A": "Sft", "S": "Alt", "D": "Ctl", "F": "Gui",
             "J": "Gui", "K": "Ctl", "L": "Alt", "'": "Sft"}
# Left outer, left inner, right inner, right outer thumb: tap label, hold label.
THUMBS = [("Tab", "hold Sym"), ("Enter", ""), ("Space", ""), ("Bksp", "hold Num")]
THUMB_COLUMNS = (3, 4, 5, 6)
LEADER = "<Space>"
# Leader group letter -> (name, palette color). A new group must be added here.
GROUPS = {"a": ("AI", "blue"), "c": ("Code", "green"), "d": ("Debug", "yellow"),
          "f": ("Find", "red"), "g": ("Git", "magenta"), "r": ("Run", "cyan")}
SPACE_COLOR = "#66767c"
MODE_LEGEND = ("n normal, i insert, x visual, s select, o operator, t terminal, "
               "c command line, l language")

# Millimetres on an A4 landscape page.
PAGE_W, PAGE_H = 297, 210
MARGIN_X, MARGIN_TOP = 7.5, 6
HEADER_H = 14
HEADER_TITLE_Y, HEADER_TITLE_SIZE = 5, 5.2
HEADER_NOTE_Y, HEADER_NOTE_SIZE = (9.0, 11.8), 1.9
KEY_W, KEY_H = 13.5, 11.2
KEY_INSET = 0.5
KEY_RADIUS = 1.2
STROKE_ACTIVE, STROKE_IDLE = 0.35, 0.25
HALF_GAP = 3
PANEL_W = 10 * KEY_W + HALF_GAP
PANEL_GAP = 6
ROW_GAP = 4
TITLE_H, TITLE_BASELINE, TITLE_SIZE = 6.5, 4.2, 3.6
PAD = 0.8
LEGEND_SIZE, LEGEND_BASELINE = 2.4, 3.0
TAG_SIZE, TAG_BASELINE = 1.5, 2.8
TEXT_TOP = 4.0
TEXT_ASCENT = 0.85
GROUP_PANEL_SLOTS = 6

# Labels use a monospace font, so a line is exactly characters * em * size wide.
FONT_FAMILY = "DejaVu Sans Mono"
FONT = f"'{FONT_FAMILY}', Menlo, Consolas, monospace"
CHAR_EM = 0.602
LINE_EM = 1.18
FONT_SIZES = (2.4, 2.2, 2.0, 1.8, 1.7)

INK, MUTED = "#1b2b30", "#66767c"
KEY_FILL, KEY_STROKE = "#f4f6f7", "#b9c2c6"
TINT_STRENGTH, SHADE_STRENGTH = 0.22, 0.55
TABLE_ROW_H = 3.25
TABLE_SIZE = 2.0
TABLE_COLUMN_W, TABLE_COLUMN_GAP = 66, 4
TABLE_MODE_W, TABLE_KEY_W, TABLE_CELL_GAP = 8, 10, 1
TABLE_FOOTER_SIZE, TABLE_FOOTER_RESERVE = 1.7, 3
LETTERS = {char.lower() for row in BASE_ROWS for char in row if char.isalpha()}


def mix(color, *, target, amount):
    channels = [int(color[i:i + 2], 16) for i in (1, 3, 5)]
    return "#" + "".join(f"{round(target + (c - target) * amount):02x}" for c in channels)


def tint(color):
    return mix(color, target=255, amount=TINT_STRENGTH)


def shade(color):
    return mix(color, target=0, amount=SHADE_STRENGTH)


def esc(content):
    return html.escape(content, quote=False)


def wrap(*, label, width):
    lines, line = [], ""
    for word in label.split():
        if len(word) > width:
            return None
        candidate = f"{line} {word}".strip()
        if len(candidate) <= width:
            line = candidate
        else:
            lines.append(line)
            line = word
    return lines + [line] if line else lines


def fit(*, labels, width, height):
    """Largest font size at which every label wraps and the lines fit a box."""
    for size in FONT_SIZES:
        wrapped = [wrap(label=label, width=int(width / (CHAR_EM * size))) for label in labels]
        if None not in wrapped and sum(map(len, wrapped)) * LINE_EM * size <= height:
            return size, wrapped
    raise SystemExit(f"label does not fit a {width:.1f} x {height:.1f} mm box: {labels}")


def text(*, x, y, content, size, fill=INK, weight="normal", anchor="start"):
    return (f'<text x="{x:.2f}" y="{y:.2f}" font-size="{size}" fill="{fill}" '
            f'font-weight="{weight}" text-anchor="{anchor}">{esc(content)}</text>')


def key_x(column):
    return column * KEY_W + (HALF_GAP if column >= 5 else 0)


def key_svg(*, x, y, legend, labels, accent=None, tag=""):
    face_w, face_h = KEY_W - KEY_INSET, KEY_H - KEY_INSET
    fill, stroke = (tint(accent), accent) if accent else (KEY_FILL, KEY_STROKE)
    stroke_width = STROKE_ACTIVE if accent else STROKE_IDLE
    parts = [f'<rect x="{x:.2f}" y="{y:.2f}" width="{face_w}" height="{face_h}" '
             f'rx="{KEY_RADIUS}" fill="{fill}" stroke="{stroke}" stroke-width="{stroke_width}"/>',
             text(x=x + PAD, y=y + LEGEND_BASELINE, content=legend, size=LEGEND_SIZE,
                  fill=shade(accent) if accent else MUTED, weight="bold")]
    if tag:
        parts.append(text(x=x + face_w - PAD, y=y + TAG_BASELINE, content=tag, size=TAG_SIZE,
                          fill=MUTED, anchor="end"))
    if labels:
        size, wrapped = fit(labels=labels, width=face_w - 2 * PAD, height=KEY_H - TEXT_TOP - KEY_INSET)
        row = 0
        for label_lines in wrapped:
            for line in label_lines:
                baseline = y + TEXT_TOP + size * TEXT_ASCENT + row * LINE_EM * size
                parts.append(text(x=x + PAD, y=baseline, content=line, size=size))
                row += 1
    return "\n".join(parts)


def keyboard(*, x, y, title, cells, accents, thumbs=False, tags=False):
    """cells: key character -> label strings; accents: key character -> color."""
    parts = [text(x=x, y=y + TITLE_BASELINE, content=title, size=TITLE_SIZE, weight="bold")]
    top = y + TITLE_H
    for row, letters in enumerate(BASE_ROWS):
        for column, char in enumerate(letters):
            parts.append(key_svg(x=x + key_x(column), y=top + row * KEY_H, legend=char.upper(),
                                 labels=cells.get(char.lower(), []), accent=accents.get(char.lower()),
                                 tag=HOLD_MODS.get(char.upper(), "") if tags else ""))
    if thumbs:
        for column, (tap, hold) in zip(THUMB_COLUMNS, THUMBS):
            parts.append(key_svg(x=x + key_x(column), y=top + 3 * KEY_H, legend="",
                                 labels=[tap] + ([hold] if hold else []),
                                 accent=accents.get("space") if tap == "Space" else None))
    return "\n".join(parts)


def leader_letter(char, *, row):
    if char not in LETTERS:
        raise SystemExit(f"{row['lhs']}: a leader group or single action must be a lowercase "
                         "letter on the base layer")
    return char


def classify(rows):
    singles, groups, others = {}, {}, []
    for row in rows:
        if not row["lhs"].startswith(LEADER):
            others.append(row)
            continue
        rest = row["lhs"][len(LEADER):]
        if len(rest) == 1 and rest not in singles:
            singles[leader_letter(rest, row=row)] = row
        elif len(rest) == 2:
            groups.setdefault(leader_letter(rest[0], row=row), {})[rest[1]] = row
        else:
            raise SystemExit(f"unsupported or duplicate leader map: {row['lhs']}")
    clash = set(singles) & set(groups)
    if clash:
        raise SystemExit(f"leader letters are both an action and a group prefix: {sorted(clash)}")
    unknown = sorted(set(groups) - set(GROUPS))
    if unknown or len(groups) > GROUP_PANEL_SLOTS:
        raise SystemExit(f"leader groups {unknown or sorted(groups)} need an entry in GROUPS "
                         f"(the sheet has {GROUP_PANEL_SLOTS} panels)")
    return singles, groups, others


def strip_group(desc, name):
    words = desc.split()
    return " ".join(words[1:]) if len(words) > 1 and words[0].lower() == name.lower() else desc


def action_cells(actions, name=""):
    """Map each physical key to its labels: the plain key first, then Shift."""
    cells = {}
    for char, row in sorted(actions.items(), key=lambda item: (item[0].isupper(), item[0])):
        if char.lower() not in LETTERS:
            raise SystemExit(f"{row['lhs']}: action key {char!r} is not a letter on the base layer")
        label = strip_group(row["desc"], name)
        cells.setdefault(char.lower(), []).append(("⇧ " if char.isupper() else "") + label)
    return cells


def key_name(lhs):
    if not lhs.startswith("<"):
        return lhs
    *modifiers, last = lhs.strip("<>").split("-")
    if last == "CR":
        last = "Enter"
    elif len(last) == 1:
        last = last.lower()
    return "-".join(modifiers + [last])


def check_cell(content, width, *, what):
    if len(content) * CHAR_EM * TABLE_SIZE > width:
        raise SystemExit(f"{what} too long for the side table: {content!r}")


def table_svg(*, x, y, rows):
    height = KEY_H * 4 + TITLE_H
    per_column = int((height - TITLE_H - TABLE_FOOTER_RESERVE) // TABLE_ROW_H)
    if len(rows) > 2 * per_column:
        raise SystemExit(f"{len(rows)} non-leader maps do not fit the side table ({2 * per_column})")
    desc_w = TABLE_COLUMN_W - TABLE_MODE_W - TABLE_KEY_W
    parts = [text(x=x, y=y + TITLE_BASELINE, content="Other keys", size=TITLE_SIZE, weight="bold")]
    for index, row in enumerate(rows):
        key = key_name(row["lhs"])
        check_cell(row["mode"], TABLE_MODE_W - TABLE_CELL_GAP, what="mode list")
        check_cell(key, TABLE_KEY_W - TABLE_CELL_GAP, what="key")
        check_cell(row["desc"], desc_w, what="description")
        column_x = x + (index // per_column) * (TABLE_COLUMN_W + TABLE_COLUMN_GAP)
        baseline = y + TITLE_H + (index % per_column) * TABLE_ROW_H + TABLE_SIZE
        parts += [text(x=column_x, y=baseline, content=row["mode"], size=TABLE_SIZE, fill=MUTED),
                  text(x=column_x + TABLE_MODE_W, y=baseline, content=key, size=TABLE_SIZE, weight="bold"),
                  text(x=column_x + TABLE_MODE_W + TABLE_KEY_W, y=baseline, content=row["desc"],
                       size=TABLE_SIZE)]
    parts.append(text(x=x, y=y + height - KEY_INSET, content=MODE_LEGEND, size=TABLE_FOOTER_SIZE, fill=MUTED))
    return "\n".join(parts)


def header():
    notes = ["Leader is Space (right inner thumb). QWERTY base layer. A coloured key starts a group; "
             "a Shift variant is marked with a raised arrow.",
             "Hold the left outer thumb for symbols, the right outer thumb for numbers and arrows "
             "(Esc is the left inner thumb there). Sft, Alt, Ctl, Gui: hold that home-row key."]
    parts = [text(x=MARGIN_X, y=MARGIN_TOP + HEADER_TITLE_Y, content="Neovim on the VPS: Ferris Sweep cheat sheet",
                  size=HEADER_TITLE_SIZE, weight="bold")]
    parts += [text(x=MARGIN_X, y=MARGIN_TOP + y, content=note, size=HEADER_NOTE_SIZE, fill=MUTED)
              for y, note in zip(HEADER_NOTE_Y, notes)]
    return "\n".join(parts)


def render(data):
    palette, rows = data["palette"], data["keymaps"]
    missing = sorted({color for _, color in GROUPS.values()} - set(palette))
    if missing:
        raise SystemExit(f"the export has no palette colors {missing}; update scripts/keymaps.lua")
    singles, groups, others = classify(rows)
    placed = len(singles) + sum(map(len, groups.values())) + len(others)
    if placed != len(rows):
        raise SystemExit(f"{len(rows) - placed} maps were not placed on the sheet")
    accents = {letter: palette[GROUPS[letter][1]] for letter in groups}
    column_x = (MARGIN_X, MARGIN_X + PANEL_W + PANEL_GAP)
    first_y = MARGIN_TOP + HEADER_H
    overview_h = TITLE_H + 4 * KEY_H
    group_h = TITLE_H + 3 * KEY_H
    cells = action_cells(singles)
    cells.update({letter: [GROUPS[letter][0]] for letter in groups})
    parts = [header(),
             keyboard(x=column_x[0], y=first_y, title="Space, then...", cells=cells,
                      accents={**accents, "space": SPACE_COLOR}, thumbs=True, tags=True),
             table_svg(x=column_x[1], y=first_y, rows=others)]
    for index, letter in enumerate(sorted(groups)):
        name = GROUPS[letter][0]
        y = first_y + overview_h + ROW_GAP + (index // 2) * (group_h + ROW_GAP)
        parts.append(keyboard(x=column_x[index % 2], y=y, title=f"Space {letter}: {name}",
                              cells=action_cells(groups[letter], name),
                              accents={char.lower(): accents[letter] for char in groups[letter]}))
    return svg_document(parts)


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


def require_font():
    matcher = shutil.which("fc-match")
    if not matcher:
        return
    chosen = subprocess.run([matcher, "-f", "%{family}", FONT_FAMILY], capture_output=True,
                            text=True, check=True).stdout
    if FONT_FAMILY not in chosen:
        raise SystemExit(f"{FONT_FAMILY} is not installed (fc-match chose {chosen!r}); "
                         "label widths would be wrong")


def convert_to_pdf(source, target):
    try:
        import cairosvg
    except (ImportError, OSError):  # OSError: cairosvg is installed but libcairo is not
        cairosvg = None
    if cairosvg:
        cairosvg.svg2pdf(url=str(source), write_to=str(target))
        return
    converter = shutil.which("rsvg-convert")
    if not converter:
        raise SystemExit("PDF needs cairosvg with libcairo (pip install cairosvg) "
                         "or rsvg-convert (apt install librsvg2-bin)")
    subprocess.run([converter, "-f", "pdf", "-o", str(target), str(source)], check=True)


def make_pdf(svg):
    with tempfile.TemporaryDirectory() as tmp:
        source, target = Path(tmp) / "sheet.svg", Path(tmp) / "sheet.pdf"
        source.write_text(svg, encoding=ENCODING)
        convert_to_pdf(source, target)
        return target.read_bytes()


def export_keymaps():
    """Run Neovim with this repository's config, not whatever ~/.config/nvim holds."""
    with tempfile.TemporaryDirectory() as tmp:
        config_home = Path(tmp) / "config"
        config_home.mkdir()
        (config_home / "nvim").symlink_to(CONFIG)
        target = Path(tmp) / "keymaps.json"
        binary = os.environ.get("VPS_NVIM", "nvim")
        try:
            subprocess.run(
                [binary, "--headless", f"+luafile {CONFIG / 'scripts' / 'keymaps.lua'}"],
                check=True, cwd=REPO, timeout=EXPORT_TIMEOUT_S,
                env={**os.environ, "XDG_CONFIG_HOME": str(config_home), "VPS_KEYMAP_JSON": str(target)})
        except FileNotFoundError:
            raise SystemExit(f"cannot run {binary!r}; set VPS_NVIM to the Neovim binary")
        except subprocess.TimeoutExpired:
            raise SystemExit(f"Neovim took longer than {EXPORT_TIMEOUT_S} s to export the maps")
        except subprocess.CalledProcessError:
            raise SystemExit("Neovim could not export the maps; its output is above. Install the "
                             "plugins and tools (README section 4) and fix any map the check rejects.")
        return json.loads(target.read_text(encoding=ENCODING))


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("--check", action="store_true", help="fail when the SVG or table is stale")
    parser.add_argument("--json", type=Path, help="use an existing keymaps.lua export")
    args = parser.parse_args()
    data = json.loads(args.json.read_text(encoding=ENCODING)) if args.json else export_keymaps()
    svg = render(data)
    readme = replace_table(README_PATH.read_text(encoding=ENCODING), readme_table(data["keymaps"]))
    if args.check:
        stale = [path.name for path, new in ((SVG_PATH, svg), (README_PATH, readme))
                 if not path.exists() or path.read_text(encoding=ENCODING) != new]
        if not PDF_PATH.exists():
            stale.append(PDF_PATH.name)
        raise SystemExit(f"stale: {', '.join(stale)}; run keymap_sheet.py" if stale else 0)
    require_font()
    pdf = make_pdf(svg)  # build everything before writing anything
    SVG_PATH.write_text(svg, encoding=ENCODING)
    README_PATH.write_text(readme, encoding=ENCODING)
    PDF_PATH.write_bytes(pdf)
    print(f"Wrote {SVG_PATH.name}, {PDF_PATH.name} and the README table ({len(data['keymaps'])} maps)")


if __name__ == "__main__":
    main()
