SudokuSolver.awk
================

Description
-----------

* Command-line sudoku puzzle solver written in awk.
* Written as a learning exercise and a demonstration for my classmates.
* So far, works in Gawk, Nawk, and Plan 9 Awk.

Invocation
----------

* See `./SudokuSolver.awk -- -h`.
* `--` argument necessary to avoid having Awk treat options like `-h` as
  options for it to parse. GNU `--exec` is not portable, hence the reason why
  `--` is encouraged. You don't need to escape the input file by putting it
  after the `--`.
