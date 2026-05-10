#!/usr/bin/env zsh

# Stats action handlers

# Action handler: Show OMP usage statistics
function _omp_action_stats() {
    echo
    $_OMP_BIN stats
    zle accept-line
}
