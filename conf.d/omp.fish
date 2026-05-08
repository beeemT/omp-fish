# omp-fish auto-loader
# Defines : commands as native fish functions — no bind handler needed.
# Fish handles execution, output, history, and prompt cycling naturally.

if type -q omp
    function ':' --description "Start/continue omp session"
        if test (count $argv) -gt 0
            __omp_exec_session (string join ' ' $argv)
        else
            __omp_exec_session ""
        end
    end

    function ':s' --description "Stateless omp command with auto-context"
        if test (count $argv) -gt 0
            __omp_exec_stateless (string join ' ' $argv)
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
        echo "  :stats            - Show usage stats"
    end
end
