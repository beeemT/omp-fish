#!/usr/bin/env zsh

# Git integration action handlers

# Action handler: AI-assisted git commit
# Usage: :commit or :commit --dry-run
function _omp_action_commit() {
    local input_text="$1"
    local dry_run=false

    # Check for --dry-run flag
    if [[ "$input_text" =~ "--dry-run" ]]; then
        dry_run=true
    fi

    echo

    if [[ "$dry_run" == "true" ]]; then
        # Preview mode: get commit message and put git command in buffer
        local commit_message
        commit_message=$(CLICOLOR_FORCE=1 $_OMP_BIN commit --dry-run 2>&1)

        if [[ -n "$commit_message" ]]; then
            # Extract just the message part (first line typically)
            local msg_line
            msg_line=$(echo "$commit_message" | head -1)

            # Put git commit command in buffer
            BUFFER="git commit -m ${(qq)msg_line}"
            CURSOR=${#BUFFER}
            zle reset-prompt
        else
            _omp_reset
        fi
    else
        # Direct commit mode
        CLICOLOR_FORCE=1 $_OMP_BIN commit
        _omp_reset
    fi
}
