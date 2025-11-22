function src {
    $fullPath = Resolve-Path $env:PROJECT_NAME_SRC_DIR
    Set-Location -Path $fullPath
    Write-Host "→ " -NoNewline -ForegroundColor Cyan
    Write-Host $fullPath -ForegroundColor Gray
}
