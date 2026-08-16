# failed-logins

Parses an SSH authentication log and reports failed login attempts as CSV.

## What it does
Reads an auth.log, extracts every failed SSH password attempt, and outputs
`ip,username,count` sorted by attempt count descending.

## Usage
    ./failed-logins.sh /var/log/auth.log

Root-owned logs require sudo:

    sudo ./failed-logins.sh /var/log/auth.log

## Example output
    ip,username,count
    192.168.64.5,admin,3
    192.168.64.5,root,2

## Error handling
- Wrong number of arguments -> usage message on stderr, exit 1
- File does not exist -> error on stderr, exit 1
- File not readable -> error on stderr, exit 1
- No failures in log -> message on stderr, exit 0

## What I learned
`sort` has to run before `uniq -c` — uniq only collapses duplicates that are
adjacent, so unsorted input silently undercounts. I also learned `grep`
returns exit code 1 when it finds nothing, which crashes a script running
under `set -e` unless you catch it explicitly with `|| true`. The regex
looks intimidating but it's just two landmarks (`for` and `from`) with the
username and IP captured between them.
