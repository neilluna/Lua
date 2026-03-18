$ErrorActionPreference = "Stop"

$root = $PSScriptRoot

$luaExe    = Join-Path $root "lua-5.4.8\build\Release\lua.exe"
$luaIncDir = Join-Path $root "lua-5.4.8\src"
$luaLibDir = Join-Path $root "lua-5.4.8\build\Release"

$luaRocksRoot = Join-Path $root "luarocks-3.13.0-windows-64"
$treeRoot     = Join-Path $luaRocksRoot "lua54"
$common       = Join-Path $root "lua-common.ps1"

. $common `
    -LuaExe $luaExe `
    -LuaVersion "5.4" `
    -LuaIncDir $luaIncDir `
    -LuaLibDir $luaLibDir `
    -LuaRocksRoot $luaRocksRoot `
    -TreeRoot $treeRoot
