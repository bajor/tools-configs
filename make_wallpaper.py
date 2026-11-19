#!/usr/bin/env python3
"""Generate the iPad lock-screen wallpaper of Rex and Neovim shortcuts.

    uv run --no-project --with pillow==11.3.0 python3 make_wallpaper.py
    uv run --no-project --with pillow==11.3.0 python3 make_wallpaper.py --check

Every row draws the Ferris Sweep with the keys to press, so the picture says
which letters to hold rather than naming modifiers that this keyboard has no
keys for. The home row carries them instead (config/cradio.keymap in
zmk-config-ferris): hold A/S/D/F for Shift/Alt/Ctrl/GUI on the left and
J/K/L/' for GUI/Ctrl/Alt/Shift on the right. A modifier and its letter have to
be on opposite hands, which is why Alt+n holds S and Alt+f holds L.

The rows are written by hand, so the script checks every Rex shortcut it draws
is really bound in rex/init.lua. --check fails when the committed PNG differs
from a fresh build. Pillow is pinned because its version changes the bytes.
Needs the DejaVu fonts: fonts-dejavu-core on Debian, font-dejavu on macOS.
"""
import argparse
import re
import tempfile
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

REPO = Path(__file__).resolve().parent
WALLPAPER = REPO / 'ferris-sweep-ipad-wallpaper.png'
ENCODING = 'utf-8'
# iPad Pro 13", the largest common panel; smaller iPads scale this down.
W, H = 2048, 2732
MARGIN, GAP = 96, 64
# Debian and Ubuntu ship the fonts here; the macOS font-dejavu cask puts the
# same files in the user's font directory.
FONT_DIRS = (Path('/usr/share/fonts/truetype/dejavu'), Path.home() / 'Library/Fonts')

BG = '#000000'
INK, MUTED, FAINT = '#f2f2f2', '#8b8b8b', '#3a3a3a'
KEY_BG, KEY_EDGE, KEY_TEXT = '#131313', '#2b2b2b', '#565656'
REX, NVIM, HOLD, STEP = '#e8824a', '#4aa6e8', '#f5f5f5', '#c7a24a'

ROWS = ['qwertyuiop', "asdfghjkl'", 'zxcvbnm,./']
# Column stagger, in key widths, matching the physical Ferris Sweep.
STAGGER = [.75, .3, 0, .2, .4, .4, .2, 0, .3, .75]
THUMBS = [('tab', 3.0), ('enter', 4.05), ('space', 6.65), ('back', 7.7)]
THUMB_LABELS = {'tab': 'TAB', 'enter': 'ENT', 'space': 'SPC', 'back': 'BSP'}

# held: letters held down, with the modifier they produce.
# step:  keys tapped first, in order.  tap: the key that runs the action.
REX_ROWS = [
    ('Alt + h j k l', 'focus pane  ← ↓ ↑ →', {'s': 'Alt'}, '', 'h j k l'),
    ('Alt + p', 'pick a file, open it', {'s': 'Alt'}, '', 'p'),
    ('Alt + b', 'pick an open buffer', {'l': 'Alt'}, '', 'b'),
    ('Alt + n', 'next buffer', {'s': 'Alt'}, '', 'n'),
    ('Alt + f', 'search the project', {'l': 'Alt'}, '', 'f'),
    ('Ctrl+A  e', 'floating terminal', {'k': 'Ctrl'}, 'a', 'e'),
    ('Ctrl+A  c', 'Claude pane, right', {'k': 'Ctrl'}, 'a', 'c'),
    ('Ctrl+A  z', 'zoom pane', {'k': 'Ctrl'}, 'a', 'z'),
]
NVIM_ROWS = [
    ('SPC  f f', 'find files', {}, 'space', 'f'),
    ('SPC  f g', 'find in file contents', {}, 'space f', 'g'),
    ('g d', 'go to definition', {}, 'g', 'd'),
    ('K', 'hover documentation', {'a': 'Shift'}, '', 'k'),
    ('SPC  c a', 'code action', {}, 'space c', 'a'),
    ('SPC  c r', 'rename symbol', {}, 'space c', 'r'),
    ('SPC  r t', 'run pytest on file', {}, 'space r', 't'),
    ('SPC  a a', 'toggle agent pane', {}, 'space', 'a'),
]


def font_dir():
    for directory in FONT_DIRS:
        if (directory / 'DejaVuSans.ttf').is_file():
            return directory
    raise SystemExit('DejaVu fonts not found in: '
                     + ', '.join(str(d) for d in FONT_DIRS))


def load_fonts():
    base = font_dir()
    def at(file, size):
        return ImageFont.truetype(str(base / file), size)
    return {'title': at('DejaVuSans-Bold.ttf', 76), 'sub': at('DejaVuSans.ttf', 34),
            'section': at('DejaVuSans-Bold.ttf', 46), 'keys': at('DejaVuSansMono-Bold.ttf', 40),
            'desc': at('DejaVuSans.ttf', 31), 'legend': at('DejaVuSans.ttf', 27),
            'cap': at('DejaVuSansMono-Bold.ttf', 22), 'small': at('DejaVuSansMono-Bold.ttf', 17)}


def key_positions(x, y, width):
    """The 34 key boxes: five staggered columns a hand, two thumbs a hand."""
    pitch = width / 11.6
    spots = {char: (x + (col + (1.6 if col >= 5 else 0)) * pitch,
                    y + (row + STAGGER[col]) * pitch)
             for row, chars in enumerate(ROWS) for col, char in enumerate(chars)}
    for name, col in THUMBS:
        drop = .22 * pitch if name in ('tab', 'back') else 0
        spots[name] = (x + col * pitch, y + 4.0 * pitch + drop)
    return spots, pitch, pitch * .88


def draw_keyboard(draw, fonts, *, x, y, width, held, step, tap, accent):
    """One Ferris Sweep with the keys for a single shortcut lit up."""
    spots, pitch, side = key_positions(x, y, width)
    # Space separated, so a named thumb key such as "space" stays one key
    # instead of becoming five letters.
    stepped = set(step.split())
    for key, (kx, ky) in spots.items():
        if key in held:
            fill, edge, text = HOLD, HOLD, '#000000'
        elif key in tap.split():
            fill, edge, text = accent, accent, '#000000'
        elif key in stepped:
            fill, edge, text = KEY_BG, STEP, STEP
        else:
            fill, edge, text = KEY_BG, KEY_EDGE, KEY_TEXT
        draw.rounded_rectangle([kx, ky, kx + side, ky + side], radius=side * .22,
                               fill=fill, outline=edge, width=2)
        label = THUMB_LABELS.get(key, key.upper())
        font = fonts['cap'] if len(label) == 1 else fonts['small']
        draw.text((kx + side / 2, ky + side / 2), label, font=font, fill=text, anchor='mm')
    # Name the modifier on the key that produces it; the letter alone is a lie.
    for key, name in held.items():
        kx, ky = spots[key]
        draw.text((kx + side / 2, ky + side + 20), name.upper(), font=fonts['small'],
                  fill=HOLD, anchor='ma')
    return 4.22 * pitch + side


def draw_entry(draw, fonts, *, x, y, width, row, accent):
    keys, desc, held, step, tap = row
    board = width * .52
    height = draw_keyboard(draw, fonts, x=x, y=y, width=board,
                           held=held, step=step, tap=tap, accent=accent)
    text_x = x + board + 56
    draw.text((text_x, y + height * .30), keys, font=fonts['keys'], fill=accent, anchor='lm')
    draw.text((text_x, y + height * .62), desc, font=fonts['desc'], fill=MUTED, anchor='lm')
    return height


def draw_column(draw, fonts, *, x, y, width, title, rows, accent):
    draw.text((x, y), title, font=fonts['section'], fill=accent, anchor='la')
    draw.line([x, y + 66, x + width, y + 66], fill=accent, width=3)
    top = y + 112
    for row in rows:
        top += draw_entry(draw, fonts, x=x, y=top, width=width, row=row, accent=accent) + 54
    return top


def draw_legend(draw, fonts, *, x, y):
    marks = [(HOLD, 'hold this letter'), (STEP, 'tap first, in order'),
             (REX, 'tap to run it')]
    for colour, label in marks:
        draw.rounded_rectangle([x, y, x + 30, y + 30], radius=7, fill=colour)
        draw.text((x + 46, y + 15), label, font=fonts['legend'], fill=MUTED, anchor='lm')
        x += 46 + draw.textlength(label, font=fonts['legend']) + 60


def build(path):
    image = Image.new(mode='RGB', size=(W, H), color=BG)
    draw = ImageDraw.Draw(im=image)
    fonts = load_fonts()
    draw.text((MARGIN, 128), 'FERRIS SWEEP', font=fonts['title'], fill=INK, anchor='la')
    draw.text((MARGIN, 222), 'Rex moves between panes and files.  Neovim only edits text.',
              font=fonts['sub'], fill=MUTED, anchor='la')
    draw.text((MARGIN, 276), 'No modifier keys: the home row holds them.  '
                             'A S D F = Shift Alt Ctrl Cmd   ·   J K L \' = Cmd Ctrl Alt Shift',
              font=fonts['sub'], fill=STEP, anchor='la')
    draw_legend(draw, fonts, x=MARGIN, y=348)
    column = (W - 2 * MARGIN - GAP) // 2
    top = 452
    bottom = max(
        draw_column(draw, fonts, x=MARGIN, y=top, width=column,
                    title='REX  ·  PANES & FILES', rows=REX_ROWS, accent=REX),
        draw_column(draw, fonts, x=MARGIN + column + GAP, y=top, width=column,
                    title='NEOVIM  ·  EDITING', rows=NVIM_ROWS, accent=NVIM))
    draw.line([MARGIN, bottom + 20, W - MARGIN, bottom + 20], fill=FAINT, width=2)
    draw.text((MARGIN, bottom + 52), 'A modifier and its letter sit on opposite hands.  '
                                     'Hold K for Ctrl+A, because A is Shift when held.',
              font=fonts['legend'], fill=FAINT, anchor='la')
    image.save(path, format='PNG', optimize=True)
    # A row may light several keys at once, as Alt+h/j/k/l does.
    return {key for _, _, _, _, tap in REX_ROWS for key in tap.split()}


def configured_rex_keys():
    """Ctrl+A sequences without the prefix, and Alt keys, from rex/init.lua."""
    source = (REPO / 'rex' / 'init.lua').read_text(encoding=ENCODING)
    keys = {prefix.replace('ctrl+a>', '') + rest for prefix, rest in
            re.findall(pattern=r'rex\.bind\("(ctrl\+a>|alt\+)([^"]+)"', string=source)}
    directions = re.findall(pattern=r'(\w) = "(?:left|down|up|right)"', string=source)
    for prefix in re.findall(pattern=r'rex\.bind\("(ctrl\+a>|alt\+)" \.\. key', string=source):
        keys.update(prefix.replace('ctrl+a>', '') + key for key in directions)
    return keys


def verify(drawn, path):
    configured = configured_rex_keys()
    # A drawn Alt row names the key twice over: once bare for Ctrl+A> and once
    # with the prefix, so accept either spelling.
    missing = {key for key in drawn if key not in configured and 'alt+' + key not in configured}
    if missing:
        raise SystemExit(f'wallpaper check failed: not bound in rex/init.lua: {sorted(missing)}')
    with Image.open(path) as check:
        if check.size != (W, H):
            raise SystemExit(f'wallpaper check failed: {check.size} instead of {(W, H)}')


def main():
    parser = argparse.ArgumentParser(description='Generate the Ferris Sweep iPad wallpaper.')
    parser.add_argument('--check', action='store_true', help='fail if the committed PNG is stale')
    check = parser.parse_args().check
    with tempfile.TemporaryDirectory() as tmp:
        path = Path(tmp) / WALLPAPER.name
        verify(build(path), path)
        if check:
            if path.read_bytes() != WALLPAPER.read_bytes():
                raise SystemExit(f'{WALLPAPER.name} is stale; run make_wallpaper.py without --check')
        else:
            WALLPAPER.write_bytes(path.read_bytes())
    print(f'{"Checked" if check else "Wrote"} {WALLPAPER.name}: {W}x{H}, '
          f'{len(REX_ROWS)} Rex and {len(NVIM_ROWS)} Neovim shortcuts.')


if __name__ == '__main__':
    main()
