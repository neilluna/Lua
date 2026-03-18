# build.ps1

[CmdletBinding()]
param(
    # Optional override. If omitted, script auto-detects best Visual Studio generator.
    [string]$Generator,

    # If set, do not modify the filesystem or invoke external commands; log actions only.
    [switch]$DryRun,

    # Optional override for CI log path. If not provided, defaults to .\logs\<project-name>.jsonl
    [string]$CiLogPath
)

$ErrorActionPreference = "Stop"
$originalLocation = Get-Location

$Config   = "Release"
$Arch     = "x64"
$BuildDir = "build"

function Write-CiLog {
    param(
        [Parameter(Mandatory=$true)][ValidateSet("debug","info","warn","error")][string]$Level,
        [Parameter(Mandatory=$true)][string]$Message,
        [hashtable]$Data
    )

    $evt = [ordered]@{
        ts      = (Get-Date).ToString("o")
        level   = $Level
        message = $Message
    }

    if ($null -ne $Data) {
        foreach ($k in $Data.Keys) { $evt[$k] = $Data[$k] }
    }

    $json = ($evt | ConvertTo-Json -Compress)

    Write-Output $json

    if ($script:CiLogPathFinal -and $script:CiLogPathFinal.Trim().Length -gt 0) {
        $logDir = Split-Path -Parent $script:CiLogPathFinal
        if ($logDir -and -not (Test-Path $logDir)) {
            New-Item -ItemType Directory -Path $logDir | Out-Null
        }
        Add-Content -Path $script:CiLogPathFinal -Value $json
    }
}

function Invoke-External {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [string]$WorkingDirectory,
        [switch]$DryRun
    )

    $wd = if ($WorkingDirectory) { $WorkingDirectory } else { (Get-Location).Path }

    Write-CiLog -Level "info" -Message "Running command" -Data @{
        cmd    = $FilePath
        args   = $Arguments
        cwd    = $wd
        dryRun = [bool]$DryRun
    }

    if ($DryRun) { return }

    Push-Location $wd
    try {
        & $FilePath @Arguments
        if ($LASTEXITCODE -ne 0) {
            Write-CiLog -Level "error" -Message "Command failed" -Data @{
                cmd      = $FilePath
                args     = $Arguments
                cwd      = $wd
                exitCode = $LASTEXITCODE
            }
            throw "Command failed with exit code $($LASTEXITCODE): $FilePath $($Arguments -join ' ')"
        }
    }
    finally {
        Pop-Location
    }
}

function Get-BestVisualStudioGenerator {
    $help = & cmake --help 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to run 'cmake --help'. Ensure CMake is installed and on PATH."
    }

    $gens = @()
    foreach ($line in $help) {
        $m = [regex]::Match($line, '^\s*\*?\s*(Visual Studio)\s+(\d+)\s+(\d{4})\b')
        if ($m.Success) {
            $major = [int]$m.Groups[2].Value
            $year  = [int]$m.Groups[3].Value
            $gens += [pscustomobject]@{
                Name  = "Visual Studio $major $year"
                Major = $major
                Year  = $year
            }
        }
    }

    if ($gens.Count -eq 0) {
        throw "No 'Visual Studio' CMake generators found. Install Visual Studio C++ build tools and try again."
    }

    ($gens | Sort-Object Major, Year -Descending | Select-Object -First 1).Name
}

function Resolve-FullPathSafe {
    param([Parameter(Mandatory=$true)][string]$Path)

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }
    return [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $Path))
}

try {
    if (-not (Test-Path "CMakeLists.txt")) {
        throw "CMakeLists.txt not found. Run this script from the project root."
    }

    if (-not (Get-Command cmake -ErrorAction SilentlyContinue)) {
        throw "CMake not found on PATH. Install CMake (or VS CMake tools) and reopen your shell."
    }

    $selectedGenerator = if ($Generator -and $Generator.Trim().Length -gt 0) {
        $Generator.Trim()
    } else {
        Get-BestVisualStudioGenerator
    }

    # Default CI log: .\logs\<project>.jsonl (sibling to build\)
    $projectName = Split-Path -Leaf (Get-Location).Path
    if (-not $PSBoundParameters.ContainsKey("CiLogPath") -or -not $CiLogPath -or $CiLogPath.Trim().Length -eq 0) {
        $CiLogPath = Join-Path "logs" "$projectName.jsonl"
    }

    $buildDirFull = Resolve-FullPathSafe (Join-Path (Get-Location).Path $BuildDir)
    $ciLogFull    = Resolve-FullPathSafe $CiLogPath

    # Guard: log path must not be inside build\
    if ($ciLogFull.StartsWith($buildDirFull, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "CiLogPath must not be inside the build directory (build='$buildDirFull'). Provided CiLogPath='$ciLogFull'."
    }

    $script:CiLogPathFinal = $ciLogFull

    Write-CiLog -Level "info" -Message "Selected build settings" -Data @{
        generator = $selectedGenerator
        arch      = $Arch
        config    = $Config
        buildDir  = $buildDirFull
        ciLogPath = $script:CiLogPathFinal
        dryRun    = [bool]$DryRun
    }

    if (Test-Path $BuildDir) {
        Write-CiLog -Level "info" -Message "Removing build directory" -Data @{
            buildDir = $buildDirFull
            dryRun   = [bool]$DryRun
        }
        if (-not $DryRun) {
            Remove-Item $BuildDir -Recurse -Force
        }
    }

    Write-CiLog -Level "info" -Message "Creating build directory" -Data @{
        buildDir = $buildDirFull
        dryRun   = [bool]$DryRun
    }

    if (-not $DryRun) {
        New-Item -ItemType Directory -Path $BuildDir -Force | Out-Null
        Set-Location $BuildDir

        Invoke-External -FilePath "cmake" -Arguments @("..", "-G", $selectedGenerator, "-A", $Arch) -DryRun:$DryRun
        Invoke-External -FilePath "cmake" -Arguments @("--build", ".", "--config", $Config) -DryRun:$DryRun

        Write-CiLog -Level "info" -Message "Build completed successfully" -Data @{
            buildDir = (Get-Location).Path
            config   = $Config
        }
    }
    else {
        Invoke-External -FilePath "cmake" -Arguments @("..", "-G", $selectedGenerator, "-A", $Arch) -WorkingDirectory $buildDirFull -DryRun:$DryRun
        Invoke-External -FilePath "cmake" -Arguments @("--build", ".", "--config", $Config) -WorkingDirectory $buildDirFull -DryRun:$DryRun

        Write-CiLog -Level "info" -Message "Dry run completed (no changes made)" -Data @{
            buildDir = $buildDirFull
            config   = $Config
        }
    }
}
finally {
    Set-Location $originalLocation
}
