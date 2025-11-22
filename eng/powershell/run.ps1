function run {
    [CmdletBinding()]
    param(
        [ValidateSet('help', 'rider', 'dev')]
        [string]$command = 'dev',

        [Parameter(ValueFromRemainingArguments)]
        [string[]]$remainingArgs
    )

    $originalLocation = Get-Location

    try {
        switch ($command) {
            "help" {
                _print_help
            }
            "rider" {
                _run_rider
            }
            "dev" {
                _run_rider
            }
            default {
                Write-Error "Invalid command: $command"
                Write-Host "Use 'run help' to see available options."
            }
        }
    }
    finally {
        # Return to the original location
        Set-Location -Path $originalLocation
    }
}

function _print_help {
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  run <command> [options]" -ForegroundColor White
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor Yellow
    Write-Host "  Development:" -ForegroundColor Green
    Write-Host "    dev           " -NoNewline; Write-Host "Open the Rider project " -NoNewline; Write-Host "[default]" -ForegroundColor DarkGray
    Write-Host "    rider         " -NoNewline; Write-Host "Open the Rider project"
    Write-Host ""
    Write-Host "  Information:" -ForegroundColor Green
    Write-Host "    help          " -NoNewline; Write-Host "Show this help message"
    Write-Host ""
}

function _run_rider {
    # Find `Rider.cmd` in the path
    $riderPath = Get-Command "Rider.cmd" -ErrorAction SilentlyContinue
    if (-not $riderPath) {
        Write-Error "Rider.cmd not found in the path."
        return
    }

    $srcPath = Resolve-Path "$env:PROJECT_NAME_SRC_DIR/src"
    if (-not $srcPath) {
        Write-Error "PROJECT_NAME_SRC_DIR environment variable not set. Make sure to run the activate script first."
        return
    }

    # Find a solution file in the root of the project
    $solutionFile = Get-ChildItem -Path $srcPath -Filter "*.slnx" -ErrorAction SilentlyContinue
    if (-not $solutionFile) {
        $solutionFile = Get-ChildItem -Path $srcPath -Filter "*.sln" -ErrorAction SilentlyContinue
    }

    if (-not $solutionFile) {
        Write-Error "No solution file found in the project."
        return
    }

    $solutionPath = $solutionFile.FullName
    $relativePath = $solutionPath.Replace($srcPath, "").TrimStart('\\')

    Write-Host ""
    Write-Host "Solution: " -NoNewline
    Write-Host $relativePath -ForegroundColor Yellow
    Write-Host "Starting Rider..." -ForegroundColor Green
    & "Rider.cmd" "$solutionPath"
}
