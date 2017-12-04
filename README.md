# Advent of Code 2017 in Pony

I've never used [Pony](https://www.ponylang.org) before, but it seems cool. Thus
I decided to solve some of the [Advent of Code](http://adventofcode.com/2017/)
problems with it. Coding puzzles aren't exactly where a programming language
with actor model and capabilities gets to shine, but hey, you have to start
somewhere.


## Running

The solutions do not have any coherent interface, but in general, they take an
input file as a command-line parameter:

```bash
cd 4.2
ponyc
./4.2 input-of-the-day.txt
```

If you're using zsh, you can use the `=()` syntax for ad-hoc testing:

```bash
./4.2 =(echo abcde blarg ebcad)
```
