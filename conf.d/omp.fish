# omp-fish auto-loader

if type -q omp
    function ':' --description "Start/continue omp session"
        if test (count $argv) -gt 0
            # Strip leading ": " prefix from the buffer
            set -l raw $argv[1]
            set -l prompt (string replace -r '^: ?' '' -- $raw)
            
            if test -n "$prompt"
                __omp_exec_session "$prompt"
            else
                __omp_exec_session ""
            end
        else
            __omp_exec_session ""
        end
    end

    function ':s' --description "Stateless omp command with auto-context"
        if test (count $argv) -gt 0
            set -l raw $argv[1]
            set -l prompt (string replace -r '^:s ?' '' -- $raw)
            __omp_exec_stateless "$prompt"
        else
            echo "Usage: :s <prompt>"
            return 1
        end
    end

    function ':new' --description "Reset omp session context"
        set -g __omp_new_session 1
        echo "[omp] New session will start on next prompt."
    end

    function ':commit' --description "AI-assisted git commit"
        omp commit $argv
    end

    function ':stats' --description "Show omp usage stats"
        omp stats
    end

    function ':help' --description "Show omp-fish help"
        echo "omp-fish commands:"
        echo "  : <prompt>        - Continue or start session"
        echo "  :s <prompt>       - Stateless shell command (auto-context)"  
        echo "  :new              - Reset session context"
        echo "  :commit           - AI commit"
        echo "  :commit --dry-run - Preview commit"
        echo "  :stats            - Show omp usage stats"
    end
end
