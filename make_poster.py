#!/usr/bin/env python3
"""Generate the printable Ferris Sweep poster for Neovim and Rex (4 x A4).

    uv run --no-project --with reportlab --with pypdf python3 make_poster.py
    uv run --no-project --with reportlab --with pypdf python3 make_poster.py --check

The layout and its Polish labels are written by hand, so the script checks
that the poster shows exactly the Neovim maps in the generated table of
nvim/README.md and the Ctrl+A and Alt bindings in rex/init.lua. --check
builds into a temporary file and fails when a shortcut was added, removed or
renamed without updating the poster. Fonts come from DejaVu in
/usr/share/fonts/truetype/dejavu. First written 2026-11-17 as a one-off
script outside the repository; kept here so the poster can be rebuilt.
"""
import argparse
import re
import tempfile
from pathlib import Path

from pypdf import PdfReader
from reportlab.lib.colors import HexColor
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfgen import canvas

REPO = Path(__file__).resolve().parent
POSTER = REPO / 'ferris-sweep-nvim-rex-4xA4.pdf'
ENCODING = 'utf-8'
TABLE_START, TABLE_END = '<!-- keymaps:start -->', '<!-- keymaps:end -->'
W, H = 297, 210  # A4 landscape, millimetres
EDGE = 9  # nothing is drawn closer than this to the paper edge, in mm
INK, MUTED, LINE = '#142126', '#46545a', '#b8c2c4'
BLUE, GREEN, PURPLE, RUST = '#005c85', '#176449', '#70438d', '#a13f21'
FONTS = Path('/usr/share/fonts/truetype/dejavu')
COLS, CW = [10, 104, 198], 89  # column x positions and width, mm
THUMB_LABELS = {'tab': 'Tab', 'enter': 'Ent', 'space': 'SPC', 'back': 'Bk'}
CORNERS = ['LEWY GÓRNY', 'PRAWY GÓRNY', 'LEWY DOLNY', 'PRAWY DOLNY']


class Poster:
    """A ReportLab canvas in millimetres, measured from the top-left corner,
    that records which shortcuts the drawn pages mention."""

    def __init__(self, *, path):
        for name, file in [('sans', 'DejaVuSans.ttf'), ('bold', 'DejaVuSans-Bold.ttf'),
                           ('mono', 'DejaVuSansMono.ttf'), ('monob', 'DejaVuSansMono-Bold.ttf')]:
            pdfmetrics.registerFont(font=TTFont(name=name, filename=str(FONTS / file)))
        self.canvas = canvas.Canvas(filename=str(path), pagesize=(W * mm, H * mm),
                                    pageCompression=1, invariant=1)
        self.canvas.setTitle(title='Ferris Sweep | Neovim + Rex | plakat 4 × A4')
        self.canvas.setAuthor(author='Skróty z bajor/tools-configs; układ z bajor/zmk-config-ferris')
        self.canvas.setSubject(subject='A4 poziomo, 100%, jednostronnie. Złóż: 1 2 / 3 4. '
                                       'Plansza 594 × 420 mm.')
        self.nvim_keys, self.rex_keys = set(), set()

    def nvim(self, *keys):
        self.nvim_keys.update(keys)

    def rex(self, *keys):
        self.rex_keys.update(keys)

    def text(self, *, x, y, value, size=16.0, font='sans', color=INK, align='left', maxw=None):
        width = pdfmetrics.stringWidth(text=value, fontName=font, fontSize=size) / mm
        assert maxw is None or width <= maxw, (value, width, maxw)
        left = x - width if align == 'right' else x - width / 2 if align == 'center' else x
        assert left >= EDGE and left + width <= W - EDGE, (value, left, width)
        assert EDGE - 1 <= y <= H - EDGE + 1, (value, y)
        self.canvas.setFillColor(aColor=HexColor(val=color))
        self.canvas.setFont(psfontname=font, size=size)
        draw = {'right': self.canvas.drawRightString, 'center': self.canvas.drawCentredString}
        draw.get(align, self.canvas.drawString)(x=x * mm, y=(H - y) * mm, text=value)

    def box(self, *, x, y, w, h, fill, stroke=None, radius=2.0):
        self.canvas.setFillColor(aColor=HexColor(val=fill))
        self.canvas.setStrokeColor(aColor=HexColor(val=stroke or fill))
        self.canvas.setLineWidth(width=.35 * mm)
        self.canvas.roundRect(x=x * mm, y=(H - y - h) * mm, width=w * mm, height=h * mm,
                              radius=radius * mm, fill=1, stroke=int(stroke is not None))

    def line(self, *, x1, y1, x2, y2, color=LINE):
        self.canvas.setStrokeColor(aColor=HexColor(val=color))
        self.canvas.setLineWidth(width=.3 * mm)
        self.canvas.line(x1=x1 * mm, y1=(H - y1) * mm, x2=x2 * mm, y2=(H - y2) * mm)

    def keyboard(self, *, x, y, width, active=(), prefix=(), held=(), labels=None, color=BLUE):
        """34 keys: five staggered columns per hand, two inner thumbs per hand."""
        labels = labels or {}
        pitch = width / 11.6
        side = pitch * .88
        rows = ['qwertyuiop', "asdfghjkl'", 'zxcvbnm,./']
        offsets = [.75, .3, 0, .2, .4, .4, .2, 0, .3, .75]
        positions = {char: (x + (col + (1.6 if col >= 5 else 0)) * pitch, y + (row + offsets[col]) * pitch)
                     for row, chars in enumerate(rows) for col, char in enumerate(chars)}
        for name, col in [('tab', 3.0), ('enter', 4.05), ('space', 6.65), ('back', 7.7)]:
            drop = .22 * pitch if name in ('tab', 'back') else 0
            positions[name] = (x + col * pitch, y + 4.0 * pitch + drop)
        for key, (kx, ky) in positions.items():
            filled = key in held or key in active
            fill = INK if key in held else color if key in active else '#fff3d2' if key in prefix else '#f4f5f5'
            border = INK if key in held else color if key in active or key in prefix else LINE
            self.box(x=kx, y=ky, w=side, h=side, fill=fill, stroke=border, radius=.7)
            label = labels.get(key, THUMB_LABELS.get(key, key.upper()))
            size = min(12, pitch * 2.25) if len(label) == 1 else min(8.5, pitch * 1.35)
            self.text(x=kx + side / 2, y=ky + side * .69, value=label, size=size, font='monob',
                      color='#ffffff' if filled else INK, align='center')

    def header(self, *, page, title, subtitle, color=BLUE):
        self.text(x=10, y=14, value='FERRIS SWEEP  /  NVIM + REX', size=12, font='bold', color=color)
        self.text(x=287, y=14, value=f'{page}  ·  {CORNERS[page - 1]}', size=10, font='bold', align='right')
        self.text(x=10, y=28, value=title, size=30, font='bold', maxw=277)
        self.text(x=10, y=37, value=subtitle, size=13, color=MUTED, maxw=277)
        self.line(x1=10, y1=42, x2=287, y2=42, color=color)

    def footer(self, *, page, note):
        self.line(x1=10, y1=195, x2=287, y2=195)
        self.text(x=10, y=201, value=note, size=9, color=MUTED, maxw=248)
        self.text(x=287, y=201, value=f'{page}/4', size=10, font='bold', align='right')
        self.canvas.showPage()

    def group(self, *, x, title, sequence, active, prefix, color=BLUE):
        self.text(x=x, y=52, value=title, size=19, font='bold', color=color, maxw=CW)
        self.text(x=x, y=63, value=sequence, size=22, font='monob', maxw=CW)
        self.keyboard(x=x + 2, y=67, width=82, active=active, prefix=prefix, color=color)

    def rows(self, *, x, items, start=115, step=9.2, color=BLUE, keyw=18, keysize=22):
        for i, (key, label) in enumerate(items):
            y = start + i * step
            self.text(x=x, y=y, value=key, size=keysize, font='monob', color=color, maxw=keyw - 1)
            self.text(x=x + keyw, y=y - .5, value=label, size=17, maxw=CW - keyw)
            self.line(x1=x, y1=y + 2.7, x2=x + CW, y2=y + 2.7, color='#dce1e2')


def page_gestures(p):
    """Page 1: the three gestures, larger than the group diagrams."""
    p.header(page=1, title='DWA PREFIKSY. JEDEN RUCH.',
             subtitle='SPC = spacja. Strzałka → oznacza: naciśnij, puść, potem następny klawisz.')
    p.text(x=10, y=54, value='SPC → NEOVIM', size=24, font='bold', color=BLUE)
    p.text(x=154, y=54, value='Ctrl+A → REX', size=24, font='bold', color=RUST)
    p.keyboard(x=12, y=59, width=116, active=['f'], prefix=['space'], color=BLUE)
    p.keyboard(x=156, y=59, width=116, active=['a', 'v'], held=['k'], color=RUST, labels={'k': 'Ctrl'})
    p.text(x=10, y=116, value='Przykład: SPC → f → f = szukaj pliku.', size=15, font='bold', maxw=133)
    p.text(x=154, y=116, value='Trzymaj K (Ctrl), stuknij A, puść oba.', size=14.5, font='bold', maxw=133)
    p.text(x=10, y=123, value='SPC: prawy kciuk, klawisz bliżej środka.', size=13, color=MUTED, maxw=133)
    p.text(x=154, y=123, value='Potem v = nowy panel terminala po prawej.', size=13, color=MUTED, maxw=133)
    p.line(x1=147, y1=48, x2=147, y2=185)
    p.text(x=10, y=132.5, value='RUCH · trzymaj S (Alt) + ...', size=16, font='bold', color=PURPLE, maxw=133)
    p.text(x=10, y=142, value='h ←    j ↓    k ↑    l →', size=21, font='monob')
    p.nvim('<M-h>', '<M-j>', '<M-k>', '<M-l>')
    p.rex('alt+h', 'alt+j', 'alt+k', 'alt+l')
    p.text(x=10, y=151, value='OKNA NVIM · SPC → ...', size=14, font='bold', color=BLUE)
    windows = [('v', 'podział |'), ('s', 'podział -'), ('x', 'zamknij okno'), ('o', 'tylko to okno'),
               ('e', 'drzewo plików'), ('t', 'terminal Rex'), ('q', 'zamknij quickfix'),
               ('n', 'zgaś szukanie')]
    for index, (key, label) in enumerate(windows):
        x, y = 10 + (index % 2) * 68, 160 + (index // 2) * 7.6
        p.text(x=x, y=y, value=key, size=19, font='monob', color=BLUE)
        p.text(x=x + 10, y=y - .5, value=label, size=13.5, maxw=57)
    p.nvim(*('<Space>' + key for key, _ in windows))
    p.text(x=154, y=135, value='EDYCJA · bez SPC', size=17, font='bold', color=BLUE)
    edit = [('s', 'skok Flash'), ('S', 'zaznacz kod'), ('r', 'ponów zmianę'), ('jk', 'NORMAL (a)'),
            ('gc', 'komentarz (b)'), ('gcc', 'komentarz linii'), ('o/q', 'otwórz / zamknij (c)'),
            ('i/u', 'pisz / cofnij (d)')]
    p.nvim('s', 'S', 'r', 'jk', 'gc', 'gcc', 'o', 'q')
    for i, (key, label) in enumerate(edit):
        x, y = 154 + (i % 2) * 68, 146 + (i // 2) * 10
        p.text(x=x, y=y, value=key, size=18.5, font='monob', color=BLUE, maxw=20)
        p.text(x=x + 21, y=y - .5, value=label, size=12.3, maxw=45)
    p.text(x=154, y=183, value='(a) INSERT  (b) też zaznaczenie  (c) w drzewie  (d) domyślne Vim',
           size=9, color=MUTED, maxw=133)
    p.text(x=10, y=190, value="Shift: trzymaj A lub '.   Esc: trzymaj Bksp, stuknij Enter.   "
                              "Kciuki: Tab/SYM · Enter · SPC · Bksp/NUM.", size=12.1, color=MUTED, maxw=277)
    p.footer(page=1, note='Alt+h/j/k/l: najpierw okna NVIM (też INSERT), na brzegu panele Rex. '
                          'Ctrl+A → h/j/k/l: zawsze panele Rex.')


def page_code(p):
    """Page 2: search, code, runner, completion and terminal mappings."""
    p.header(page=2, title='PLIKI, KOD I URUCHAMIANIE',
             subtitle='NEOVIM · NORMAL. Po SPC wpisz obie litery z tabeli: ff = SPC → f → f.')
    p.group(x=COLS[0], title='SZUKANIE', sequence='SPC → skrót', active='fbgdrsh', prefix=['space', 'f'])
    find = [('ff', 'pliki'), ('fg', 'pliki i treść'), ('fb', 'bufory'), ('fh', 'pomoc'),
            ('fr', 'ostatnie szukanie'), ('fs', 'symbole'), ('fd', 'diagnostyka')]
    p.rows(x=COLS[0], items=find)
    p.nvim(*('<Space>' + key for key, _ in find))
    p.text(x=10, y=186, value='Bufor = otwarty plik.', size=13, color=MUTED)
    p.group(x=COLS[1], title='KOD / LSP', sequence='SPC → skrót', active='ardfnp', prefix=['space', 'c'],
            color=GREEN)
    code = [('ca', 'akcja na kodzie'), ('cr', 'zmień nazwę'), ('cf', 'formatuj'),
            ('cd', 'błąd w linii'), ('cn', 'następny błąd'), ('cp', 'poprzedni błąd')]
    p.rows(x=COLS[1], items=code, start=111, step=8.6, color=GREEN)
    p.nvim(*('<Space>' + key for key, _ in code))
    p.text(x=104, y=167, value='Bez SPC:', size=12, font='bold', color=MUTED)
    for x, y, key, label in [(104, 177, 'gd', 'definicja'), (151, 177, 'gr', 'użycia'),
                             (104, 188, 'gi', 'implementacja'), (168, 188, 'K', 'opis')]:
        p.text(x=x, y=y, value=key, size=19, font='monob', color=GREEN)
        p.text(x=x + (11 if key != 'K' else 7), y=y - .5, value=label, size=11)
    p.nvim('gd', 'gr', 'gi', 'K')
    p.group(x=COLS[2], title='PYTHON', sequence='SPC → skrót', active='rtl', prefix=['space', 'r'], color=PURPLE)
    run = [('rr', 'uruchom plik'), ('rt', 'pytest: ten plik'), ('rl', 'powtórz polecenie')]
    p.rows(x=198, items=run, start=111, step=9, color=PURPLE)
    p.nvim(*('<Space>' + key for key, _ in run))
    p.text(x=198, y=140, value='INSERT · uzupełnianie', size=14.5, font='bold', color=PURPLE)
    for y, key, label in [(150, 'Tab / Ctrl+n', 'następna pozycja*'),
                          (161, 'Ctrl+p', 'poprzednia pozycja'), (172, 'Enter', 'zatwierdź / nowa linia')]:
        p.text(x=198, y=y, value=key, size=14, font='monob', color=PURPLE)
        p.text(x=198, y=y + 4.8, value=label, size=12.2, color=MUTED)
    p.nvim('<Tab>', '<C-N>', '<C-P>', '<CR>')
    p.text(x=198, y=185, value='TERMINAL: Ctrl+q → NORMAL', size=12, font='bold')
    p.text(x=198, y=191, value='Alt+h/j/k/l → okna, potem Rex', size=11.5, maxw=CW)
    p.nvim('<C-Q>')
    p.footer(page=2, note='* Tab bez menu wstawia tabulator. Ctrl: przytrzymaj D lub K. LSP = pomoc językowa. '
                          'Python: plik zapisany, sesja Rex.')


def page_tools(p):
    """Page 3: every AI, Git and debugging binding, including shifted variants."""
    p.header(page=3, title='AI, GIT I DEBUGOWANIE', color=PURPLE,
             subtitle='Po SPC wpisz obie litery z tabeli: ac = SPC → a → c. AI działa też na zaznaczeniu.')
    p.group(x=10, title='AI / AGENT', sequence='SPC → skrót', active='acosftvpd', prefix=['space', 'a'])
    ai = [('aa', 'pokaż / ukryj agenta'), ('ac', 'Claude'), ('ao', 'opencode'), ('as', 'wybierz agenta'),
          ('af', 'wyślij plik'), ('at', 'wyślij kontekst kursora'), ('av', 'wyślij zaznaczenie'),
          ('ap', 'wybierz prompt'), ('ad', 'odłącz agenta')]
    p.rows(x=10, items=ai, start=110, step=9.4)
    p.nvim(*('<Space>' + key for key, _ in ai))
    p.group(x=104, title='GIT / ZMIANY', sequence='SPC → skrót', active='npvsrbd', prefix=['space', 'g'],
            color=GREEN)
    git = [('gn', 'następna zmiana'), ('gp', 'poprzednia zmiana'), ('gv', 'podgląd zmiany'),
           ('gs', 'dodaj do indeksu'), ('gr', 'cofnij zmianę!'), ('gb', 'autor linii'),
           ('gB', 'autorzy w pliku'), ('gd', 'różnice pliku')]
    p.rows(x=104, items=git, start=110, step=9.4, color=GREEN)
    p.nvim(*('<Space>' + key for key, _ in git))
    p.group(x=198, title='DEBUG / KROKI', sequence='SPC → skrót', active='cbiorut', prefix=['space', 'd'],
            color=PURPLE)
    debug = [('dc', 'start / kontynuuj'), ('db', 'punkt zatrzymania'), ('dB', 'punkt z warunkiem'),
             ('di', 'wejdź do funkcji'), ('do', 'wykonaj krok'), ('dO', 'wyjdź z funkcji'),
             ('dr', 'konsola debug'), ('du', 'panele debug'), ('dt', 'zakończ debug')]
    p.rows(x=198, items=debug, start=110, step=9.4, color=PURPLE)
    p.nvim(*('<Space>' + key for key, _ in debug))
    p.footer(page=3, note='B / O = Shift + b / o, nie Caps Lock. Pełny klawisz = akcja; jasny obrys = prefiks. '
                          'Git: zmiana = fragment różnic.')


def page_rex(p):
    """Page 4: every Rex Ctrl+A binding and the resize mode."""
    p.header(page=4, title='REX: PANELE, AGENCI, SESJE', color=RUST,
             subtitle='Ctrl+A, puść oba klawisze, potem akcja. To panele terminala, nie okna Neovima.')
    for x, title, active in [(10, 'RUCH / ROZMIAR', 'hjklr'), (104, 'PANELE', 'vszxbfgae'),
                             (198, 'KARTY / AGENCI', 'tnpqcoi')]:
        p.group(x=x, title=title, sequence='Ctrl+A → ...', active=active, prefix=['a'], color=RUST)
    movement = [('h', 'fokus ←'), ('j', 'fokus ↓'), ('k', 'fokus ↑'), ('l', 'fokus →'),
                ('r', 'tryb rozmiaru'), ('Tab', 'poprzedni panel')]
    p.rows(x=10, items=movement, start=110, step=9.4, color=RUST, keyw=21, keysize=19.5)
    p.rex('h', 'j', 'k', 'l', 'r', 'tab')
    p.text(x=10, y=166, value='Tryb rozmiaru: h/j/k/l o 10,', size=12, color=MUTED, maxw=CW)
    p.text(x=10, y=172, value='Enter lub Esc kończy.', size=12, color=MUTED, maxw=CW)
    p.box(x=10, y=175, w=CW, h=17, fill='#fff3e9')
    p.text(x=13, y=182, value='Alt + h/j/k/l', size=15, font='bold', maxw=83)
    p.text(x=13, y=189, value='ten sam ruch bez Ctrl+A', size=12.5, maxw=83)
    panes = [('v', 'nowy panel →'), ('s', 'nowy panel ↓'), ('z', 'powiększ / przywróć'),
             ('x', 'zamknij panel!'), ('b', 'wyrównaj panele'), ('f', 'panel pływający'),
             ('g', 'wybierz panel'), ('a', 'aktywność paneli'), ('e', 'terminal: pokaż / ukryj')]
    p.rows(x=104, items=panes, start=110, step=9.4, color=RUST)
    p.rex(*(key for key, _ in panes))
    tabs = [('t', 'nowa karta'), ('n', 'następna karta'), ('p', 'poprzednia karta'), ('q', 'wybierz sesję'),
            ('c', 'agent Claude →'), ('o', 'agent opencode →'), ('i', 'agent pi →')]
    p.rows(x=198, items=tabs, start=110, step=9.4, color=RUST)
    p.rex(*(key for key, _ in tabs), 'ctrl+a')
    p.text(x=198, y=178, value='Ctrl+A → Ctrl+A', size=16, font='monob', color=RUST, maxw=CW)
    p.text(x=198, y=185, value='wyślij Ctrl+A do powłoki', size=13, maxw=CW)
    p.footer(page=4, note='DRUK: A4 poziomo · 100% / rozmiar rzeczywisty · jednostronnie · ułóż: 1 2 nad 3 4 · '
                          'całość 59,4 × 42 cm.')


def documented_nvim_maps():
    readme = (REPO / 'nvim' / 'README.md').read_text(encoding=ENCODING)
    table = readme.split(TABLE_START)[1].split(TABLE_END)[0]
    return set(re.findall(r'\| `([^`]+)` \|', table))


def configured_rex_keys():
    """Ctrl+A sequences without the prefix, and Alt keys, as rex/init.lua binds them."""
    source = (REPO / 'rex' / 'init.lua').read_text(encoding=ENCODING)
    keys = {prefix.replace('ctrl+a>', '') + rest
            for prefix, rest in re.findall(r'rex\.bind\("(ctrl\+a>|alt\+)([^"]+)"', source)}
    directions = re.findall(r'(\w) = "(?:left|down|up|right)"', source)
    for prefix in re.findall(r'rex\.bind\("(ctrl\+a>|alt\+)" \.\. key', source):
        keys.update(prefix.replace('ctrl+a>', '') + key for key in directions)
    return keys


def build(path):
    poster = Poster(path=path)
    for page in (page_gestures, page_code, page_tools, page_rex):
        page(poster)
    poster.canvas.save()
    return poster


def verify(poster, path):
    documented, configured = documented_nvim_maps(), configured_rex_keys()
    assert poster.nvim_keys == documented, {'missing': sorted(documented - poster.nvim_keys),
                                            'extra': sorted(poster.nvim_keys - documented)}
    assert poster.rex_keys == configured, {'missing': sorted(configured - poster.rex_keys),
                                           'extra': sorted(poster.rex_keys - configured)}
    pages = PdfReader(stream=str(path)).pages
    assert len(pages) == 4
    for page in pages:
        assert abs(float(page.mediabox.width) - W * mm) < .01
        assert abs(float(page.mediabox.height) - H * mm) < .01
        extracted = page.extract_text()
        assert '�' not in extracted and 'FERRIS SWEEP' in extracted


def main():
    parser = argparse.ArgumentParser(description='Generate the Ferris Sweep Neovim and Rex poster.')
    parser.add_argument('--check', action='store_true', help='verify without writing the poster')
    check = parser.parse_args().check
    with tempfile.TemporaryDirectory() as tmp:
        path = Path(tmp) / POSTER.name if check else POSTER
        poster = build(path)
        verify(poster, path)
    print(f'{"Checked" if check else "Wrote"} {POSTER.name}: {len(poster.nvim_keys)} Neovim and '
          f'{len(poster.rex_keys)} Rex shortcuts match the configuration.')


if __name__ == '__main__':
    main()
