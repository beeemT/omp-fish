#!/usr/bin/env zsh

# omp-zsh: OMP (oh-my-pi) shell integration for zsh
# Documentation in [README.md](./README.md)

# Modular omp plugin - sources all required modules in correct order

# Handle $0 according to the Zsh Plugin Standard:
# https://zdharma-continuum.github.io/Zsh-100-Commits-Club/Zsh-Plugin-Standard.html
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# Configuration variables and defaults
# Determine plugin root for extension and resource paths.
# Uses Zsh Plugin Standard $0 resolution so it works both from the
# repo tree and from the installed ~/.oh-my-zsh/custom/plugins/omp-zsh/
typeset -g _OMP_ZSH_ROOT="${0:A:h}"

source "${_OMP_ZSH_ROOT}/lib/config.zsh"

# Core utilities (includes logging, _omp_exec)
source "${0:A:h}/lib/helpers.zsh"

# Terminal context capture (preexec/precmd hooks)
source "${0:A:h}/lib/context.zsh"

# Completion widget
source "${0:A:h}/lib/completion.zsh"

# Action handlers
source "${0:A:h}/lib/actions/core.zsh"
source "${0:A:h}/lib/actions/session.zsh"
source "${0:A:h}/lib/actions/suggest.zsh"
source "${0:A:h}/lib/actions/commit.zsh"
source "${0:A:h}/lib/actions/stats.zsh"

# Main dispatcher and widget registration
source "${0:A:h}/lib/dispatcher.zsh"

# Key bindings and widget registration
source "${0:A:h}/lib/bindings.zsh"
