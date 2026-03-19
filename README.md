# Lua
Version 1.0.0

My personal Lua environments on Microsoft Windows. This repository contains the following:
- Scripts to build Lua 5.1.5 and Lua 5.4.8 on Microsoft Windows.
- A script to launch an interactive Lua 5.1.5 enabled PowerShell sub-shell that includes Lua and LuaRocks.
- A script to launch an interactive Lua 5.4.8 enabled PowerShell sub-shell that includes Lua and LuaRocks.

Note: This is NOT a release of Lua. These are just my scripts to build Lua from the official sources, and provide a Lua environment to use Lua and LuaRocks. Lua can be found at [The Programming Language Lua](https://lua.org/).

## Installation

1. If you already have Microsoft Visual Studio installed, and if Visual Studio has the workload `Desktop development with C++`, then skip this step. Download and install [Build Tools for Visual Studio 2026](https://aka.ms/vs/stable/vs_BuildTools.exe).

1. Create an empty installation directory, for example `C:\Software\Lua`. This directory is referred to as the "installation directory" in this document. All references to subdirectories in this document refer to direct subdirectories of the installation directory.

1. Open a PowerShell terminal session and change to the installation directory.

1. Clone this repository into installation directory like so:

    `git clone https://github.com/neilluna/Lua.git .`

1. Open a new terminal session to `Developer PowerShell for VS xx`, where `xx` is probably the latest version of Visual Studio tools that you have installed. This can be done from the `Open a new tab` pulldown on the terminal window.

1. In the new terminal session, run the following command to enable the PowerShell scripts to execute:

    `powershell.exe -ExecutionPolicy RemoteSigned`

1. Download the Lua 5.1.5 source archive from [lua-5.1.5.tar.gz](https://www.lua.org/ftp/lua-5.1.5.tar.gz). Extract it into the installation directory. This should populate the `lua-5.1.5` subdirectory with the Lua 5.1.5 source files.

1. Download the Lua 5.4.8 source archive from [lua-5.4.8.tar.gz](https://www.lua.org/ftp/lua-5.4.8.tar.gz). Extract it into the installation directory. This should populate the `lua-5.4.8` subdirectory with the Lua 5.4.8 source files.

1. Download the LuaRocks 3.13.0 release archive from [luarocks-3.13.0-windows-64.zip](https://luarocks.github.io/luarocks/releases/luarocks-3.13.0-windows-64.zip). Extract it into the installation directory. This should create a subdirectory named `luarocks-3.13.0-windows-64`, and populate it with `luarocks.exe` and `luarocks-admin.exe`.

1. Change to the `lua-5.1.5` subdirectory.

1. Run `build.ps1` to build Lua 5.1.5. The build should complete successfully with a message `Build completed successfully`. Note that messages are in JSON format.

1. Change to the `lua-5.4.8` subdirectory.

1. Run `build.ps1` to build Lua 5.4.8. The build should complete successfully with a message `Build completed successfully`. Note that messages are in JSON format.

1. Add the installation directory to your PATH.

## Usage

### How to start an interactive PowerShell session with Lua 5.1.5 and LuaRocks

1. Open a PowerShell terminal session.

1. Open a new terminal session to `Developer PowerShell for VS xx`, where `xx` is probably the latest version of Visual Studio tools that you have installed. This can be done from the `Open a new tab` pulldown on the terminal window.

1. In the new terminal session, run the following command to enable the PowerShell scripts to execute:

    `powershell.exe -ExecutionPolicy RemoteSigned`

1. Run `lua51.ps1`. You now have an interactive PowerShell session with Lua 5.1.5 and LuaRocks. Note: The first time that this command is run, it may take a few minutes. Sometimes anti-virus may delay execution or ask for confirmation.

### How to start an interactive PowerShell session with Lua 5.4.8 and LuaRocks

1. Open a PowerShell terminal session.

1. Open a new terminal session to `Developer PowerShell for VS xx`, where `xx` is probably the latest version of Visual Studio tools that you have installed. This can be done from the `Open a new tab` pulldown on the terminal window.

1. In the new terminal session, run the following command to enable the PowerShell scripts to execute:

    `powershell.exe -ExecutionPolicy RemoteSigned`

1. Run `lua54.ps1`. You now have an interactive PowerShell session with Lua 5.4.8 and LuaRocks. Note: The first time that this command is run, it may take a few minutes. Sometimes anti-virus may delay execution or ask for confirmation.
