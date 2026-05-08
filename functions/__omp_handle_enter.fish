# omp-fish enter key handler for : commands
# Note: fish automatically makes functions in functions/ available by name

function __omp_enable -d "Enable : command interception"
    bind \r __omp_handle_enter
end

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
