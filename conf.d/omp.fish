# omp-fish auto-loader
# This file is sourced automatically by fish on shell startup

if type -q omp
    # Bind Enter key to handle : commands
    function __omp_handle_enter -d "Handle Enter key for : commands"
        # commandline captures the entire input including multiline
        if commandline --search-match ":.*"
            set -l line (commandline)
            commandline -f clear
            __omp_dispatch $line
        else
            commandline -f execute
        end
    end

    bind \r __omp_handle_enter
end
