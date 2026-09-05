#!/bin/sh
# fix-drop-delimiters.sh
#
# Post-processes the Mamba-generated jdbc_create_stored_procedures.sql so that
# every `DROP PROCEDURE/FUNCTION IF EXISTS ...;` is followed by the `~-~-`
# statement delimiter that Mamba core splits the script on.
#
# A handful of DROP statements are generated WITHOUT a trailing `~-~-` (they are
# followed directly by a `-- comment` and then the `CREATE PROCEDURE/FUNCTION`).
# Because Mamba splits the file on lines equal to `~-~-`, those DROPs would
# otherwise merge with the following CREATE statement into one executed chunk.
# This script inserts a `~-~-` line after any such DROP that is missing one.
#
# NOTE: `~-~-` is Mamba's REQUIRED statement splitter (the working deployed copy
# keeps all of them) — this script does NOT strip `~-~-`; it only adds the
# missing ones after DROP statements.
#
# Usage: fix-drop-delimiters.sh <path-to-jdbc_create_stored_procedures.sql>
set -eu

FILE="${1:-}"
if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
    printf 'usage: %s <path-to-jdbc_create_stored_procedures.sql>\n' "$0" >&2
    exit 2
fi

tmp="$(mktemp)"

awk '
    { L[NR] = $0 }
END {
    n = NR
    for (i = 1; i <= n; i++) {
        print L[i]
        # If this is a DROP PROCEDURE/FUNCTION statement, make sure the next
        # non-blank line is the `~-~-` delimiter; if not, emit one here.
        if (L[i] ~ /^DROP[[:space:]]+(PROCEDURE|FUNCTION)[[:space:]]+IF[[:space:]]+EXISTS.*;[[:space:]]*$/) {
            j = i + 1
            while (j <= n && L[j] ~ /^[[:space:]]*$/) j++
            if (j > n || (L[j] != "~-~-")) {
                print "~-~-"
            }
        }
    }
}' "$FILE" > "$tmp"

mv "$tmp" "$FILE"

printf 'fix-drop-delimiters: ensured ~-~- delimiter after DROP PROCEDURE/FUNCTION statements in %s\n' "$FILE"
