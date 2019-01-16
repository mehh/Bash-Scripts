#!/bin/bash
# Run the below snippet to get a printout of the largest directories from the current location
du -hxa --max-depth=1 | awk '{printf "%s %08.2f\t%s\n", index("KMG", substr($1, length($1))), substr($1, 0, length($1) -1), $0}' | sort -r|cut -f2,3