#!/usr/bin/env zsh

# Main command dispatcher and widget registration

# Main widget to intercept : commands
function omp-accept-line() {
    # Save the original command for history
    local original_buffer="$BUFFER"

    # Parse the buffer
    local user_action=""
    local input_text=""

    # Check if the line starts with : followed by a command or space
    if [[ "$BUFFER" =~ "^:([a-zA-Z][a-zA-Z0-9_-]*)(( ).*)?$" ]]; then
        # Action with or without parameters: :foo or :foo bar baz
        user_action="${match[1]}"
        if [[ -n "${match[2]}" ]]; then
            # Remove the leading space from the captured group
            input_text="${match[2]# }"
        else
            input_text=""
        fi
    elif [[ "$BUFFER" =~ "^: (.*)$" ]]; then
        # Default action with space: : something
        user_action=""
        input_text="${match[1]}"
    else
        # For non-:commands, use normal accept-line
        zle accept-line
        return
    fi

    # Add the original command to history before transformation
    print -s -- "$original_buffer"


    # Move cursor to end so output doesn't overwrite
    CURSOR=${#BUFFER}
    zle redisplay

    # Dispatch to appropriate action handler
    case "$user_action" in
        new)
            _omp_action_new "$input_text"
            ;;
        c)
            _omp_action_continue "$input_text"
            ;;
        s)
            # :s intentionally modifies BUFFER - return early
            _omp_action_suggest "$input_text"
            return $?
            ;;
        commit)
            _omp_action_commit "$input_text"
            # commit --dry-run modifies BUFFER - return early if dry-run
            if [[ "$input_text" =~ "--dry-run" ]]; then
                return 0
            fi
            ;;
        stats)
            _omp_action_stats
            ;;
        help)
            _omp_action_help
            ;;
        *)
            # Default action: : <prompt> or :unknown <prompt>
            _omp_action_default "$user_action" "$input_text"
            ;;
    esac

    local action_status=$?

    # Reset prompt after action completes (not for buffer-modifying actions)
    _omp_reset
    return $action_status
}
