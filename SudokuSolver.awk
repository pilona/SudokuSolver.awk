#! /usr/bin/awk -f

# TODO: Handle multiple grids in one file.

BEGIN {
	USAGE = "[-h|--help] [-v|--version] [<infile>|-]";
	VERSION = 0.1;
	#PROGRAM = ARGV[0];
	PROGRAM = "SudokuSolver.awk";

	for (i=1; i<ARGC; i++) {
		if (ARGV[i] == "-h" || ARGV[i] == "--help") {
			print PROGRAM ": USAGE: " USAGE;
			exit 0;
		} else if (ARGV[i] == "-v" || ARGV[i] == "--version") {
			print PROGRAM ": VERSION: " VERSION;
			exit 0;
		# If ARGV[i]ument starts with a dash but is not a lone dash.
		} else if (ARGV[i] ~ "^-.+") {
			print PROGRAM ": ERROR: Unrecognized argument '" ARGV[i] "'.";
			exit 1;
		} else if (ARGC > 2) {
			print PROGRAM ": ERROR: Extraneous inputs starting at '" ARGV[i] "'.";
			exit 1;
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
			  NR ".";
		exit 1;
	}

	for (i=1; i<=9; i++) {
		if (NF != 9) {
			print PROGRAM ": ERROR: Expected nine-column line but found " NF "-column line \"" $0 "\".";
			exit 1;
		} else if (!($i ~ "^[0-9]+$")) {
			print PROGRAM ": ERROR: Non-decimal or non-digit \"" $i "\" in input " \
			      (FILENAME == "-" ? "<stdin>" : "'" FILENAME "'") " at row " \
				  NR ", column " i ".";
			exit 1;
		}
		grid[NR,i] = $i;
	}
}

END {
	# TODO: Solve puzzle here.
}
