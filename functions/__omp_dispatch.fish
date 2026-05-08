# omp-fish command parser and dispatcher
# Note: fish automatically makes functions in functions/ available by name

function __omp_dispatch -d "Parse and dispatch :commands"
    set -l input (string trim $argv)

    # Check if : is followed by space (prompt) or immediately by chars (subcommand)
    if string match -rq '^: ' -- $input
        # `: <prompt>` - it's a prompt, strip leading `: ` and pass to omp
        set -l prompt (string replace -r '^: \s*' '' -- $input)
        __omp_exec_session $prompt
    else if string match -rq '^:\w' -- $input
        # `:command` - it's a subcommand
        set -l cmd (string replace -r '^:(\w+).*' '$1' -- $input)

        switch $cmd
            case 's'
                set -l prompt (string replace -r '^:s\s+' '' -- $input)
                __omp_exec_stateless $prompt

            case 'new'
                __omp_exec_session "Please clear the conversation context and be ready for a fresh start."

            case 'commit'
                set -l args (string replace -r '^:commit\s*' '' -- $input)
                if test -n "$args"
                    omp commit $args
                else
                    omp commit
                end

            case 'stats'
                omp stats

            case 'help'
                echo "omp-fish commands:"
                echo "  : <prompt>        - Continue or start session"
                echo "  :s <prompt>       - Stateless shell command (auto-context)"
                echo "  :new              - Reset session context"
                echo "  :commit           - AI commit"
                echo "  :commit --dry-run - Preview commit"
                echo "  :stats            - Show usage stats"

            case '*'
                echo "Unknown command: :$cmd"
                echo "Try :help for available commands"
                return 1
        end
    else
        # Just `:`, treat as empty prompt
        __omp_exec_session ""
    end
end
