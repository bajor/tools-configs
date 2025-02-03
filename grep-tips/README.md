`<some command> --help | grep "blabla"`

If you want to make it case-insensitive (matching "Timeout", "TIMEOUT", etc.), use -i:

`curl --help | grep -i "timeout"`

If you only want to match "timeout" as a whole word (not "timeouter" or "mytimeout"):

`curl --help | grep -w "timeout"`
