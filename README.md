# ctob

**c**odepoint **to** **b**yte is a command line tool that converts hex unicode
codepoints into their byte representations that can be pasted into a string in
C/C++.
once you have launched ctob with the desired encoding

# requirements

1. make
3. git
2. g++

# build

```
make ctob
```

# usage

ctob is an interactive terminal program. type in unicode codepoints (in hex)
and press enter, it will print out each codepoint on a new line. ^D to exit.

```
$ ; will print help
$ ./ctob
```

```
$ ; convert codepoints to utf8
$ ./ctob utf8
ffef
\xEF\xBF\xAF
10ffff
\xF4\x8F\xBF\xBF
```
