#!/usr/bin/env bash
set -euo pipefail

# Usage guard
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <path-to-auth.log>" >&2
    exit 1
fi

LOGFILE="$1"

# Missing-file guard
if [ ! -f "$LOGFILE" ]; then
    echo "Error: file not found: $LOGFILE" >&2
    exit 1
fi

# Unreadable-file guard
if [ ! -r "$LOGFILE" ]; then
    echo "Error: cannot read $LOGFILE (try sudo)" >&2
    exit 1
fi

# grep exits 1 on no match, which set -e would treat as a crash.
# || true keeps the script alive so we can report "no failures" properly.
FAILURES=$(grep "Failed password" "$LOGFILE" || true)

if [ -z "$FAILURES" ]; then
    echo "No failed login attempts found in $LOGFILE" >&2
    exit 0
fi

echo "ip,username,count"

printf '%s\n' "$FAILURES" \
    | sed -E 's/.*Failed password for (invalid user )?([^ ]+) from ([0-9.]+) port.*/\3,\2/' \
    | sort \
    | uniq -c \
    | sort -rn \
    | awk '{print $2 "," $1}'
