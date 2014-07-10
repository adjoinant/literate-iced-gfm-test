Just a small test of displaying literate coffeescript files with GFM.

~~Files ending in .md are displayed nicely by Github, but the `iced` compiler will need to be called 
with the `-l` flag in order for these files to run happily.~~ 
Not true - iced can handle iced.md files just fine.

Files ending in .liticed are **not** displayed nicely by Github, but the `iced` compiler will happily
run without passing the `-l` flag.
