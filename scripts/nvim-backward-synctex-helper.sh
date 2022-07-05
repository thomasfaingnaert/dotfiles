#!/usr/bin/env bash
set -Eeuo pipefail

SERVER=$1
LINE=$2
FILE=$3

nvim --server "${SERVER}" --remote "${FILE}"
nvim --server "${SERVER}" --remote-send "${LINE}G"
