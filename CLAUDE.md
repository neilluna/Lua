# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal Windows Lua development environment. Provides CMake-based build scripts for Lua 5.1.5 and Lua 5.4.8 from official sources, and PowerShell scripts to launch interactive shells with Lua and LuaRocks pre-configured.

**Note:** This is NOT an official Lua release. Lua source: https://lua.org/

## Building

Run from within `Developer PowerShell for VS` with `RemoteSigned` execution policy. Build output goes to `<version>/build/Release/`.

```powershell
# Build Lua 5.1.5
cd lua-5.1.5
.\build.ps1

# Build Lua 5.4.8
cd lua-5.4.8
.\build.ps1

# Build script options
.\build.ps1 -Generator "Visual Studio 17 2022"  # override CMake generator
.\build.ps1 -DryRun                              # preview without building
.\build.ps1 -CiLogPath "C:\logs\build.jsonl"    # custom CI log path
```

Build messages are JSON-formatted. Success message: `Build completed successfully`.

## Usage

```powershell
# Start Lua 5.1.5 interactive shell with LuaRocks
.\lua51.ps1

# Start Lua 5.4.8 interactive shell with LuaRocks
.\lua54.ps1
```

## Architecture

### Build System
- **CMake 3.20+** with Visual Studio C++ generators (auto-detected by `build.ps1`)
- `lua-5.1.5/CMakeLists.txt` — builds `lua51.lib`, `lua.exe`, `luac.exe`
- `lua-5.4.8/CMakeLists.txt` — builds `lua54.lib`, `lua.exe`, `luac.exe`
- Build logs written as JSONL to `<version>/logs/<version>.jsonl`

### Shell Initialization
`lua51.ps1` / `lua54.ps1` → source `lua-common.ps1` with version-specific parameters → `lua-common.ps1` creates dynamic LuaRocks config, sets environment variables, launches nested PowerShell with Lua and LuaRocks on PATH.

### LuaRocks
Pre-packaged LuaRocks 3.13.0 at `luarocks-3.13.0-windows-64/`. Separate rocks trees for each Lua version: `lua51/` and `lua54/`.

## Claude Code Workflow Note

Claude Code runs in Git Bash and cannot execute PowerShell commands or scripts directly. When a PowerShell command is needed, display it for the user to run manually in a Developer PowerShell for VS session. The user will paste the output back.

## Prerequisites

- Visual Studio with "Desktop development with C++" workload, or Build Tools for Visual Studio
- CMake on PATH
- PowerShell `RemoteSigned` execution policy

## Git Workflow

`develop` → PR → `release/*` → `main`
