param(
    [Parameter(Mandatory=$true)][string]$LuaExe,
    [Parameter(Mandatory=$true)][string]$LuaVersion,
    [Parameter(Mandatory=$true)][string]$LuaIncDir,
    [Parameter(Mandatory=$true)][string]$LuaLibDir,
    [Parameter(Mandatory=$true)][string]$LuaRocksRoot,
    [Parameter(Mandatory=$true)][string]$TreeRoot
)

$ErrorActionPreference = "Stop"

$luarocksExe = Join-Path $LuaRocksRoot "luarocks.exe"
$configDir   = Join-Path $LuaRocksRoot "configs"

if (-not (Test-Path $luarocksExe)) { throw "luarocks.exe not found: $luarocksExe" }
if (-not (Test-Path $LuaExe))      { throw "Lua executable not found: $LuaExe" }
if (-not (Test-Path $LuaIncDir))   { throw "Lua include dir not found: $LuaIncDir" }
if (-not (Test-Path $LuaLibDir))   { throw "Lua lib dir not found: $LuaLibDir" }

if (-not (Test-Path $configDir)) { New-Item -ItemType Directory -Path $configDir | Out-Null }
if (-not (Test-Path $TreeRoot))  { New-Item -ItemType Directory -Path $TreeRoot  | Out-Null }

function Escape-LuaString([string]$s) { $s -replace '\\', '\\\\' }

$configPath = Join-Path $configDir ("lua-{0}_{1}.lua" -f $LuaVersion, ([guid]::NewGuid().ToString("N")))

$config = @"
lua_interpreter = "$(Escape-LuaString $LuaExe)"
lua_version = "$LuaVersion"

rocks_trees = {
  { name = "$(Split-Path $TreeRoot -Leaf)", root = "$(Escape-LuaString $TreeRoot)" }
}

variables = {
  LUA = "$(Escape-LuaString $LuaExe)",
  LUA_INCDIR = "$(Escape-LuaString $LuaIncDir)",
  LUA_LIBDIR = "$(Escape-LuaString $LuaLibDir)"
}
"@

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($configPath, $config, $utf8NoBom)

$env:LUAROCKS_CONFIG = $configPath

& $luarocksExe path |
ForEach-Object {
    $line = $_.Trim()

    if ($line -match '^(?:@)?set\s+"?([^="]+)=([^"]*)"?\s*$') {
        $name  = $matches[1]
        $value = $matches[2]
        Set-Item -Path "Env:$name" -Value $value
    }
}

& $LuaExe -v
Write-Host "Lua:                       $LuaExe"
Write-Host "LuaRocks tree:             $TreeRoot"
Write-Host "Temporary LuaRocks config: $configPath"
Write-Host ""
Write-Host "Entering Lua $LuaVersion shell."
Write-Host ""

$startupScript = @"
Set-Alias lua '$($LuaExe.Replace("'", "''"))'
Set-Alias luarocks '$($luarocksExe.Replace("'", "''"))'
"@

try {
    powershell -NoExit -Command $startupScript
    Write-Host "Exiting Lua $LuaVersion shell."
}
finally {
    if (Test-Path $configPath) {
        Write-Host "Removing temporary LuaRocks config."
        Remove-Item $configPath -Force -ErrorAction SilentlyContinue
    }
}
