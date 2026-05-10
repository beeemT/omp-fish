#!/usr/bin/env zsh

# Core utility functions for omp plugin

# Helper function to execute omp commands consistently
# Usage: _omp_exec [args...]
function _omp_exec() {
    local -a cmd
    cmd=($_OMP_BIN "$@")
    "${cmd[@]}"
}

# Execute omp interactively. ZLE widgets take /dev/null as stdin,
# so we explicitly set stdin to the terminal.
function _omp_exec_interactive() {
    local -a cmd
    cmd=($_OMP_BIN "$@")
    echo
    "${cmd[@]}" < $TTY
    zle accept-line
}

# Reset the prompt state after action completion
function _omp_reset() {
    BUFFER=""
    CURSOR=0
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
