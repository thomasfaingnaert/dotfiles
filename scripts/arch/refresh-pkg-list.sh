#!/usr/bin/env bash
set -Eeuo pipefail

cd "$( dirname "${BASH_SOURCE[0]}" )"

# Get list of packages/groups to exclude.
items=$(grep -v '^#' pkg-list.exclude)

# Start with list of all explicitly installed packages, and remove:
pacman -Qeq | grep -vxFf <(
    {
        # Packages and groups in exclusion list.
        echo "$items"

        # Expand group names to the list of packages that are contained in
        # them.
        pacman -Sgq $items 2>/dev/null || true
    } | sort -u
) >pkg-list.txt
