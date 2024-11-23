`gUw` - make the word upper case

`gU$` - convert to uppercase until the end of line

`<yank sth>` `/` `CTRL + r` `0` - copy word and look for similar (first from registry - 0)

`t<char>` - Moves the cursor to just before the first occurrence of the specified character <char> to the right of the cursor on the same line.

`T<char>` - Moves the cursor backward (to the left) to just after the specified character <char>.

`f<char>` - Moves the cursor to the first occurrence of the specified character <char> to the right of the cursor on the same line.

`ma` - Marks the current cursor position with the lowercase mark 'a' for use in the same file.

`Ma` - Marks the current cursor position with the uppercase mark 'A' for use across **all files**.

**Jumplist** - A history of cursor positions in Vim, tracking movements caused by certain commands, allowing navigation to previous or future locations in your editing session.

`Ctrl-o` - Jumps to the older position in the jumplist (moves backwards).

`Ctrl-i` - Jumps to the newer position in the jumplist (moves forwards).
