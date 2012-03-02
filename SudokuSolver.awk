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

function check(isSet) { # local isSet
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
        for (i=1; i<10; i++)
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
        for (i=1; i<10; i++)
            isSet[i] = FALSE;
    }

    # Check square-wise whether the grid is valid.
    for (i=1; i<=3; i++) { # where i is the major row (one of three) number
        for (j=1; j<=3; j++) { # where j is the major column number
            for (row=3*i; row<=3*(i+1); row++) {
                for (col=3*j; col<=3*(j+1); col++) {
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

function set(row, col, value) {
    oldValue = grid[row,column];
    grid[row,column] = value;

    if (!check()) {
        grid[row,column] = oldValue;
        return FALSE;
    } else {
        return TRUE;
    }
}

function hasUnset() {
    for (row=1; row<=9; row++) {
        for (col=0; col<=9; col++) {
            if (grid[row,col] == UNSET_CELL_FLAG)
                return TRUE;
        }
    }

    return FALSE;
}

function setNextUnset(grid, value) {
    for (row=1; row<=9; row++) {
        for (col=1; col<=9; col++) {
            if (grid[row,col] == UNSET_CELL_FLAG) {
                set(row,col,value);
                return;
            }
        }
    }
}

BEGIN {
    USAGE = "[-h|--help] [-v|--version] [<infile>|-]";
    VERSION = 0.1;
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
            print PROGRAM ": ERROR: Unrecognized argument '" ARGV[i] "'."; > STDERR;
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

    # TODO: Solve puzzle here.
}
