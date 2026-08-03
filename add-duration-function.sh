#!/bin/sh
# add-duration-function.sh
#
# Appends fn_duration_to_days function to Mamba ETL SQL files
# This function is required by ARV Orders ETL but is not part of mamba-core-api
#
# Usage: add-duration-function.sh [<path-to-sql-file>]
#   - With no arguments: processes all three main SQL files in mamba directory
#   - With one argument: processes only the specified file
#
# Files processed (when no argument):
#   - create_stored_procedures.sql
#   - jdbc_create_stored_procedures.sql
#   - liquibase_create_stored_procedures.sql

set -eu

# The function definition to append
# Format: comments, then ~-~- separator, then DROP, then another ~-~- before CREATE
FUNCTION_SQL='
-- ============================================================================
-- Function: fn_duration_to_days (Added by Uganda Reports ETL)
-- ============================================================================
~-~-
DROP FUNCTION IF EXISTS fn_duration_to_days;
~-~-
CREATE FUNCTION fn_duration_to_days(
    duration_value INT,
    duration_units_concept_id INT
) RETURNS INT DETERMINISTIC
BEGIN
    DECLARE days INT;

    IF duration_units_concept_id = 1072 THEN
        SET days = duration_value;
    ELSEIF duration_units_concept_id = 1073 THEN
        SET days = duration_value * 7;
    ELSEIF duration_units_concept_id = 1074 THEN
        SET days = duration_value * 30;
    ELSEIF duration_units_concept_id = 1734 THEN
        SET days = duration_value * 365;
    ELSEIF duration_units_concept_id = 1822 THEN
        SET days = FLOOR(duration_value / 24);
    ELSEIF duration_units_concept_id = 1733 THEN
        SET days = FLOOR(duration_value / 1440);
    ELSEIF duration_units_concept_id = 162583 THEN
        SET days = FLOOR(duration_value / 86400);
    ELSE
        SET days = duration_value;
    END IF;

    RETURN days;
END;'

# Function to add the function definition to a single file
add_to_file() {
    FILE="$1"

    if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
        printf 'error: file not found: %s\n' "$FILE" >&2
        return 1
    fi

    # Check if function already exists in the file
    if grep -q "CREATE FUNCTION fn_duration_to_days" "$FILE"; then
        printf 'add-duration-function: already exists in %s, skipping\n' "$FILE"
        return 0
    fi

    # Append the function definition at the end of the file
    # Format: ~-~- separator, blank line, comments, then DROP + CREATE
    # Note: No trailing ~-~- after END; fix-drop-delimiters.sh will add ~-~- after DROP
    printf '\n%s\n' "$FUNCTION_SQL" >> "$FILE"

    printf 'add-duration-function: appended fn_duration_to_days to %s\n' "$FILE"
    return 0
}

# Main logic
if [ $# -eq 0 ]; then
    # No arguments - process all SQL files in mamba directory
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    MAMBA_DIR="$SCRIPT_DIR/api/src/main/resources/mamba"

    if [ ! -d "$MAMBA_DIR" ]; then
        printf 'error: mamba directory not found: %s\n' "$MAMBA_DIR" >&2
        exit 1
    fi

    # Process each main SQL file (skip mamba_main.sql which is just scheduler setup)
    for base_file in create_stored_procedures.sql jdbc_create_stored_procedures.sql liquibase_create_stored_procedures.sql; do
        FILE="$MAMBA_DIR/$base_file"
        if [ -f "$FILE" ]; then
            add_to_file "$FILE"
        else
            printf 'add-duration-function: file not found, skipping: %s\n' "$FILE" >&2
        fi
    done
    exit 0
elif [ $# -eq 1 ]; then
    # Single file argument
    add_to_file "$1"
    exit $?
else
    printf 'usage: %s [<path-to-sql-file>]\n' "$0" >&2
    exit 2
fi
