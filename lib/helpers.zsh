#!/usr/bin/env zsh

# Core utility functions for omp plugin

# Helper function to execute omp commands consistently
# Usage: _omp_exec [args...]
function _omp_exec() {
    local -a cmd
    cmd=($_OMP_BIN "$@")
    "${cmd[@]}"
}

# Like _omp_exec but connects stdin/stdout to /dev/tty so that interactive
# prompts work correctly when omp is launched as a child of a ZLE widget.
# ZLE owns the terminal and replaces the process's stdin/stdout with its own
# pipes, so without this redirect any interactive input would fail.
function _omp_exec_interactive() {
    local -a cmd
    cmd=($_OMP_BIN "$@")
    "${cmd[@]}" </dev/tty >/dev/tty 2>&1
}

# Reset the prompt state after action completion
function _omp_reset() {
    # Clear buffer and reset cursor position
    BUFFER=""
    CURSOR=0
    # Force widget redraw and prompt reset
    zle -I
    zle reset-prompt
}

# Helper function to print messages with consistent formatting
# Usage: _omp_log <level> <message>
# Levels: error, info, success, warning
function _omp_log() {
    local level="$1"
    local message="$2"
    local timestamp="\033[90m[$(date '+%H:%M:%S')]\033[0m"

    case "$level" in
        error)
            echo "\033[31m⏺\033[0m ${timestamp} \033[31m${message}\033[0m"
            ;;
        info)
            echo "\033[37m⏺\033[0m ${timestamp} \033[37m${message}\033[0m"
            ;;
        success)
            echo "\033[33m⏺\033[0m ${timestamp} \033[37m${message}\033[0m"
            ;;
        warning)
            echo "\033[93m⚠️\033[0m ${timestamp} \033[93m${message}\033[0m"
            ;;
        *)
            echo "${message}"
            ;;
    esac
}

# Build context string from terminal context (for :c command)
# Returns formatted context with last command and exit code
function _omp_build_context() {
    local context=""

    # Get the most recent command and exit code
    if [[ ${#_OMP_TERM_COMMANDS} -gt 0 ]]; then
        local last_cmd="${_OMP_TERM_COMMANDS[-1]}"
        local last_exit="${_OMP_TERM_EXIT_CODES[-1]}"

        context="Last command: ${last_cmd}
Exit code: ${last_exit}"
    fi

    echo "$context"
}
