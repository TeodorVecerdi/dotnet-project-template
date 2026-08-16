$scriptsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$scriptFiles = @(
    "$scriptsDir/powershell/env.ps1",
    "$scriptsDir/powershell/locations.ps1",
    "$scriptsDir/powershell/run.ps1",
    "$scriptsDir/powershell/git.ps1"
)

foreach ($script in $scriptFiles) {
    if (Test-Path $script) {
        . $script
    }
    else {
        Write-Error "Script not found: $script"
    }
}

Write-Host "Project profile successfully loaded." 