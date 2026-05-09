#!/usr/bin/env zsh

# Terminal context capture for omp plugin
#
# Provides ring buffer of recent commands + exit codes for :c command

# Pending command state
typeset -g _OMP_TERM_PENDING_CMD=""

# Called before each command executes.
# Records the command text for later context capture.
function _omp_context_preexec() {
    [[ "$_OMP_TERM" != "true" ]] && return
    _OMP_TERM_PENDING_CMD="$1"
}

# Called after each command completes, before the next prompt is drawn.
# Captures exit code and pushes to ring buffer.
function _omp_context_precmd() {
    local last_exit=$?  # MUST be first line to capture exit code

    [[ "$_OMP_TERM" != "true" ]] && return

    # Only record if we have a pending command from preexec
    if [[ -n "$_OMP_TERM_PENDING_CMD" ]]; then
        # Skip recording if the command was an omp command
        if [[ ! "$_OMP_TERM_PENDING_CMD" =~ ^: ]]; then
            _OMP_TERM_COMMANDS+=("$_OMP_TERM_PENDING_CMD")
            _OMP_TERM_EXIT_CODES+=("$last_exit")

            # Trim ring buffer to max size
            while (( ${#_OMP_TERM_COMMANDS} > _OMP_TERM_MAX_COMMANDS )); do
                shift _OMP_TERM_COMMANDS
                shift _OMP_TERM_EXIT_CODES
            done
        fi

        _OMP_TERM_PENDING_CMD=""
    fi
}

# Hook registration
if [[ "$_OMP_TERM" == "true" ]]; then
    preexec_functions+=(_omp_context_preexec)
    precmd_functions=(_omp_context_precmd "${precmd_functions[@]}")
fi
