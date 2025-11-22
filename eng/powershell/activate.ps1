$scriptsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$scriptFiles = @(
    "$scriptsDir/env.ps1",
    "$scriptsDir/locations.ps1",
    "$scriptsDir/run.ps1"
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