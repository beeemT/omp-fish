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

    # Dispatch to appropriate action handler
    case "$user_action" in
        new)
            _omp_action_new "$input_text"
            ;;
        c)
            _omp_action_continue "$input_text"
            ;;
        s)
            # Clear buffer before running suggest
            BUFFER=""
            CURSOR=0
            zle -I
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
        "")
            # : <prompt> - default action with prompt text
            if [[ -n "$input_text" ]]; then
                _omp_action_default "" "$input_text"
            else
                echo
                _omp_log warning "Usage: : <prompt>"
                BUFFER=""
                CURSOR=0
                zle accept-line
            fi
            ;;
        *)
            # Unknown command - check if it has prompt text
            if [[ -n "$input_text" ]]; then
                # Treat as prompt with command prefix
                _omp_action_default "$user_action" "$input_text"
            else
                # Unknown command with no prompt - print error
                echo
                _omp_log warning "Unknown command: :$user_action"
                BUFFER=""
                CURSOR=0
                zle accept-line
            fi
            ;;
    esac

    return 0
}
