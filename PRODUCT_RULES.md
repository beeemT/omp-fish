# omp-fish Product Rules

## Goal

Enable users to interact with OMP (OneMorePrompt) CLI tool directly from fish shell using `: ` commands.

## Core Commands

### `: <prompt>`
- **Purpose**: Start or continue an OMP session
- **Input**: User types `: <prompt>` and presses Enter
- **Output**: Sends prompt to OMP CLI and displays response
- **Behavior**: 
  - First invocation creates a new session
  - Subsequent invocations continue the existing session

### `:c <prompt>`
- **Purpose**: Continue session with last command context (command + exit code)
- **Input**: User types `:c <prompt>` and presses Enter
- **Output**: Prepends last executed command and its exit code to prompt (if possible also the stdout / stderr), sends to OMP

### `:s <prompt>`
- **Purpose**: Stateless command with automatic context, prompting to generate a command that executes the action requested by the user
- **Input**: User types `:s <prompt>` and presses Enter
- **Output**: The command string that gets prefilled into the commandline, ready for execution by the user (can be multiline)

### `:new`
- **Purpose**: Reset session context
- **Input**: User types `:new`
- **Output**: Clears session state for fresh start

### Other Commands
- `:commit` - AI-assisted git commit
- `:stats` - Show OMP usage stats
- `:help` - Display help

## Critical Requirement: Multiline Prompts

### Desired Behavior
Users can type multiline prompts:
```
: This is line 1
This is line 2
This is line 3
```
All three lines should be sent to OMP as a single multiline prompt.

## User Experience Goals

1. Seamless integration with the shell
2. Minimal friction - just type `: ` and press Enter
3. All standard shell features work normally (history, completion, etc.)
