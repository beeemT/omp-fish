#!/usr/bin/env zsh

# Key bindings and widget registration for omp plugin

# Register ZLE widgets
zle -N omp-accept-line

# Rebind Enter to our custom widget
bindkey '^M' omp-accept-line
bindkey '^J' omp-accept-line
