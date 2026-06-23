**Hoovernig terminal - <leader> j**

---

Close quick list fix `<Leader>q`

---

## Debugging (DAP)
`<Leader>dc`: Continue or start the debug session.
<br>
`<Leader>db`: Toggle breakpoint on the current line.
<br>
`<Leader>dB`: Set a conditional breakpoint.
<br>
`<Leader>di`: Step into the current function.
<br>
`<Leader>do`: Step over the current line.
<br>
`<Leader>dO`: Step out of the current function.
<br>
`<Leader>dr`: Toggle the DAP REPL.
<br>
`<Leader>du`: Toggle the DAP UI.
<br>
`<Leader>dt`: Terminate the debug session.

---

## Telescpe
`<Leader>ff`: Search for files in your current working directory.
<br>
`<C-p>`: Perform a live grep search across your project.
<br>
`<Leader>fb`: Show a list of open buffers.
<br>
`<Leader>fh`: Search through Neovim help tags.
<br>
`:Telescope git_files`: Search files in a Git repository (requires Git).
<br>
`Ctrl - V` - open in split tab

---

`gr` - go to refferences

- setup local git in the directory where init.vim is so I can easily revert if I mess config
- copy to wsl :set ff=unix

- `:PlugInstall`
- LSPs autocomplete - ctrl-p/n, enter - select previous/next suggestion, accept
- install newest neovim, not default

## go to defitiion (f.e. SparkSession):
`:lua vim.lsp.buf.definition()` TODO - make a shortcut alt l maybe

## Go to previosly visited locations
<C-o> (Ctrl + o) → Jump back to the previous location.
<C-i> (Ctrl + i) → Jump forward to the next location.

## isort python
MAKE SURE YOU HAVE `pip isort insall` ed


## In quickterminal
`alt + j/k` - go down/up through past commands




## Gruvbox color scheme for Windows Terminal
```
Name of the color scheme
"name": "Gruvbox Dark"

Background and foreground colors
"background": "#282828", " Background color (dark)
"foreground": "#ebdbb2", " Foreground color (light text)

Normal colors
"black": "#282828",      " Black
"red": "#cc241d",        " Red
"green": "#98971a",      " Green
"yellow": "#d79921",     " Yellow
"blue": "#458588",       " Blue
"purple": "#b16286",     " Magenta (Purple)
"cyan": "#689d6a",       " Cyan
"white": "#a89984",      " White

Bright colors
"brightBlack": "#928374",    " Bright Black (Gray)
"brightRed": "#fb4934",      " Bright Red
"brightGreen": "#b8bb26",    " Bright Green
"brightYellow": "#fabd2f",   " Bright Yellow
"brightBlue": "#83a598",     " Bright Blue
"brightPurple": "#d3869b",   " Bright Magenta (Pink)
"brightCyan": "#8ec07c",     " Bright Cyan
"brightWhite": "#ebdbb2",    " Bright White
```


## Exploring files
`:ex`


## Git - show staged changes
`git diff --cached`

## mvn
if JAVA_HOME not defined correctly
`sdk default java 17.0.8-tem`
`sdk env`


