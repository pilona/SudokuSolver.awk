#! /usr/bin/awk -f

# TODO: Handle multiple grids in one file.

function printGrid(row, col) {
    for (row=1; row<=9; row++) {
        for (col=1; col<=9; col++)
            # FIXME: Ugly hack to not print a newline.
            printf grid[row,col] " ";
        print "";
    }
}

function check(isSet, i, j, n, row, col) { # local isSet, i, j, n, row, col
    for (i=1; i<=9; i++)
        isSet[i] = FALSE;

    for (row=1; row<=9; row++) {
        for (col=1; col<=9; col++) {
            if (grid[row,col] == UNSET_CELL_FLAG)
                continue; # This is a valid value.
            else if (isSet[grid[row,col]])
                return FALSE;
            else
                isSet[grid[row,col]] = TRUE;
        }
        # Reset validity assumptions.
        for (i=1; i<=9; i++)
            isSet[i] = FALSE;
    }

    # Check column-wise whether the grid is valid.
    for (col=1; col<=9; col++) {
        for (row=1; row<=9; row++) {
            if (grid[row,col] == UNSET_CELL_FLAG)
                continue; # This is a valid value.
            else if (isSet[grid[row,col]])
                return FALSE;
            else
                isSet[grid[row,col]] = TRUE;
        }
        # Reset validity assumptions.
        for (i=1; i<=9; i++)
            isSet[i] = FALSE;
    }

    # Check square-wise whether the grid is valid.
    for (i=0; i<3; i++) { # where i is the major row (one of three) number
        for (j=0; j<3; j++) { # where j is the major column number
            for (row=(3*i)+1; row<=3*(i+1); row++) { # Ex: row 1-3, 4-6, or 7-9
                for (col=(3*j)+1; col<=3*(j+1); col++) { # Ex: col 1-3, 4-6, 7-9
                    if (grid[row,col] == UNSET_CELL_FLAG)
                        continue; # This is a valid value.
                    else if (isSet[grid[row,col]])
                        return FALSE;
                    else
                        isSet[grid[row,col]] = TRUE;
                }
            }
            # Reset validity assumptions.
            for (n=1; n<=9; n++)
                isSet[n] = FALSE;
        }
    }

    return TRUE; # Haven't found anything that violates the rules, so return true.
}

function findUnset(row, col) { # local row, col
    for (row=1; row<=9; row++) {
        for (col=1; col<=9; col++) {
            if (grid[row,col] == UNSET_CELL_FLAG)
                return row SUBSEP col;
        }
    }

    return UNSET_CELL_FLAG SUBSEP UNSET_CELL_FLAG;
}

function setNextUnset(value, unsetCoord, oldValue) {
    unsetCoord = findUnset();
    oldValue = grid[unsetCoord];
    grid[unsetCoord] = value

    if (!check()) {
        grid[unsetCoord] = oldValue;
        return FALSE;
    } else {
        return TRUE;
    }
}

function solve(unsetCoord, possibleValue) {
    unsetCoord = findUnset();
    if (unsetCoord != UNSET_CELL_FLAG SUBSEP UNSET_CELL_FLAG) {
        for (possibleValue=1; possibleValue<=9; possibleValue++) {
            if (setNextUnset(possibleValue)) {
                solve();
                # Backtrack
                grid[unsetCoord] = UNSET_CELL_FLAG;
            }
        }
    } else {
        printGrid();
    }
}

BEGIN {
    USAGE = "[-h|--help] [-v|--version] [<infile>|-]";
    VERSION = 0.2;
    #PROGRAM = ARGV[0];
    PROGRAM = "SudokuSolver.awk";

    TRUE = 1;
    FALSE = 0;

    EXIT_SUCCESS            = 0;
    EXIT_FAILURE            = 1; # Generic exit failure
    EXIT_EXTRANEOUS_FILES   = 2;
    EXIT_ILLEGAL_ARG        = 4; # Unrecognized command-line argument
    EXIT_EXTRANEOUS_LINES   = 8;
    EXIT_INSUFFICIENT_LINES = 16;
    EXIT_BAD_NF             = 32; # Bad number of columns in input.
    EXIT_NONDIGIT_COLUMN    = 64;

    UNSET_CELL_FLAG         = 0;

    STDERR                  = "/dev/stderr";

    for (i=1; i<ARGC; i++) {
        if (ARGV[i] == "-h" || ARGV[i] == "--help") {
            print PROGRAM ": USAGE: " USAGE;
            ignoreEnd = 1; # Ignore END section.
            exit 0;
        } else if (ARGV[i] == "-v" || ARGV[i] == "--version") {
            print PROGRAM ": VERSION: " VERSION;
            ignoreEnd = 1; # Ignore END section.
            exit 0;
        # If ARGV[i]ument starts with a dash but is not a lone dash.
        } else if (ARGV[i] ~ "^-.+") {
            print PROGRAM ": ERROR: Unrecognized argument '" ARGV[i] "'." > STDERR;
            ignoreEnd = 1; # Ignore END section.
            exit EXIT_ILLEGAL_ARG;
        } else if (ARGC > 2) {
            print PROGRAM ": ERROR: Extraneous inputs starting at '" ARGV[i] "'." > STDERR;
            ignoreEnd = 1; # Ignore END section.
            exit EXIT_EXTRANEOUS_FILES;
        }
    }

    numComments = 0;
}

{
    # Lines starting with '#' are comment lines. Ignore them.
    if (substr($0, 0, 1) == "#") {
        numComments++;
        next;
    }

    if (NR-numComments > 9) {
        print PROGRAM ": ERROR: Extraneous (more than nine) non-comment rows in input " \
              (FILENAME == "-" ? "<stdin>" : "'" FILENAME "'") " starting at line " \
              NR "." > STDERR;
        ignoreEnd = 1; # Ignore END section.
        exit EXIT_EXTRANEOUS_LINES;
    }

    for (i=1; i<=9; i++) {
        if (NF != 9) {
            print PROGRAM ": ERROR: Expected nine-column line but found " NF "-column line \"" $0 "\"." > STDERR;
            ignoreEnd = 1; # Ignore END section.
            exit EXIT_BAD_NF;
        } else if (!($i ~ "^[" UNSET_CELL_FLAG "1-9]+$")) {
            print PROGRAM ": ERROR: Non-decimal or non-digit \"" $i "\" in input " \
                  (FILENAME == "-" ? "<stdin>" : "'" FILENAME "'") " at row " \
                  NR ", column " i "." > STDERR;
            ignoreEnd = 1; # Ignore END section.
            exit EXIT_NONDIGIT_COLUMN;
        }
        grid[NR-numComments,i] = $i;
    }
}

END {
    if (NR-numComments < 9 && !ignoreEnd) {
        print PROGRAM ": ERROR: Insufficient (" NR-numComments " instead of 9) non-comment rows in input " \
              (FILENAME == "-" ? "<stdin>" : "'" FILENAME "'") "." > STDERR;
        exit EXIT_INSUFFICIENT_LINES;
    }

    solve();
}
