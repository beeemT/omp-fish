#!/usr/bin/env zsh

# Configuration variables for omp plugin

# Path to OMP CLI binary
: ${OMP_BIN:=omp}
typeset -g _OMP_BIN="$OMP_BIN"

# Session state: true after :new (fresh session), false after first : prompt
typeset -g _OMP_FRESH_SESSION=false

# Internal: track if we've already processed the first : command in a session
typeset -g _OMP_SESSION_STARTED=false

# Ring buffer for terminal context capture (command + exit code for :c)
typeset -ga _OMP_TERM_COMMANDS=()
typeset -ga _OMP_TERM_EXIT_CODES=()

# Maximum number of commands to keep in the ring buffer
: ${_OMP_TERM_MAX_COMMANDS:=5}
typeset -g _OMP_TERM_MAX_COMMANDS

# Master switch for terminal context capture
: ${OMP_TERM:=true}
typeset -g _OMP_TERM="$OMP_TERM"
