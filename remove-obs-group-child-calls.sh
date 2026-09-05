#!/bin/sh
# remove-obs-group-child-calls.sh
#
# Retires the obs-group child flat tables from the compiled Mamba ETL bundle.
#
# Why: the pinned mamba-core-api artifact still CALLs
# sp_mamba_flat_encounter_obs_group_table_create_all/_insert_all inside
# sp_mamba_data_processing_drop_and_flatten, which materializes one persistent
# child table per (flat form x obs-group) combo (96 tables in bombo, 112 -> 203
# total). Grouped obs are consumed instead by pivoting mamba_z_encounter_obs in
# the fact layer (see sp_fact_encounter_hts_card_v2_insert.sql). The child-table
# procedure DEFINITIONS are left in place; only the two flatten CALLs are
# stripped. When the module moves to an engine version without the calls, this
# script becomes a no-op.
#
# Usage: remove-obs-group-child-calls.sh [<path-to-sql-file>]
#   - With no arguments: processes all three main SQL files in mamba directory
#   - With one argument: processes only the specified file

set -eu

remove_from_file() {
    FILE="$1"

    if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
        printf 'error: file not found: %s\n' "$FILE" >&2
        return 1
    fi

    if ! grep -q "CALL sp_mamba_flat_encounter_obs_group_table_create_all" "$FILE" \
        && ! grep -q "CALL sp_mamba_flat_encounter_obs_group_table_insert_all" "$FILE"; then
        printf 'remove-obs-group-child-calls: no retired calls in %s, skipping\n' "$FILE"
        return 0
    fi

    TMP_FILE="$(mktemp)"
    grep -v "CALL sp_mamba_flat_encounter_obs_group_table_create_all;" "$FILE" \
        | grep -v "CALL sp_mamba_flat_encounter_obs_group_table_insert_all;" > "$TMP_FILE"
    mv "$TMP_FILE" "$FILE"

    printf 'remove-obs-group-child-calls: removed retired obs-group flatten calls from %s\n' "$FILE"
    return 0
}

# Main logic
if [ $# -eq 0 ]; then
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    MAMBA_DIR="$SCRIPT_DIR/api/src/main/resources/mamba"

    if [ ! -d "$MAMBA_DIR" ]; then
        printf 'error: mamba directory not found: %s\n' "$MAMBA_DIR" >&2
        exit 1
    fi

    for base_file in create_stored_procedures.sql jdbc_create_stored_procedures.sql liquibase_create_stored_procedures.sql; do
        FILE="$MAMBA_DIR/$base_file"
        if [ -f "$FILE" ]; then
            remove_from_file "$FILE"
        else
            printf 'remove-obs-group-child-calls: file not found, skipping: %s\n' "$FILE" >&2
        fi
    done
    exit 0
elif [ $# -eq 1 ]; then
    remove_from_file "$1"
    exit $?
else
    printf 'usage: %s [<path-to-sql-file>]\n' "$0" >&2
    exit 2
fi
