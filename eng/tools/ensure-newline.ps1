# Script to ensure files end with a newline
# Usage: .\ensure-newline.ps1 file1.txt file2.txt ...

param(
    [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
    [string[]]$Files
)

# Function to display usage information
function Show-Usage {
    Write-Host "Usage: .\ensure-newline.ps1 <file1> [file2] [file3] ..."
    Write-Host "Ensures each specified file ends with a newline character."
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\ensure-newline.ps1 file.txt"
    Write-Host "  .\ensure-newline.ps1 *.txt"
    Write-Host "  .\ensure-newline.ps1 file1.txt file2.txt file3.txt"
}

# Check if any files were provided
if ($Files.Count -eq 0) {
    Write-Host "Error: No files specified" -ForegroundColor Red
    Show-Usage
    exit 1
}

# Expand globs and collect all files
$expandedFiles = @()
foreach ($pattern in $Files) {
    $resolved = Resolve-Path -Path $pattern -ErrorAction SilentlyContinue
    if ($resolved) {
        $expandedFiles += $resolved | Where-Object { Test-Path -Path $_ -PathType Leaf }
    } else {
        Write-Host "Warning: Pattern '$pattern' did not match any files, skipping..." -ForegroundColor Yellow
    }
}

# Check if we have any files to process
if ($expandedFiles.Count -eq 0) {
    Write-Host "Error: No valid files to process" -ForegroundColor Red
    exit 1
}

# Process each file
foreach ($file in $expandedFiles) {
    # Convert to string in case it's a PathInfo object
    $filePath = $file.ToString()
    
    # Check if file is readable
    try {
        $null = Get-Content -Path $filePath -TotalCount 1 -ErrorAction Stop
    } catch {
        Write-Host "Warning: File '$filePath' is not readable, skipping..." -ForegroundColor Yellow
        continue
    }
    
    # Check if file ends with newline
    $fileInfo = Get-Item -Path $filePath
    if ($fileInfo.Length -gt 0) {
        # Read the last byte of the file
        $lastByte = Get-Content -Path $filePath -AsByteStream -Tail 1
        # Check if last byte is not a newline (LF = 10)
        if ($lastByte -ne 10) {
            Write-Host "Adding newline to '$filePath'"
            Add-Content -Path $filePath -Value "`n" -NoNewline
        } else {
            Write-Host "File '$filePath' already ends with newline"
        }
    } else {
        Write-Host "File '$filePath' is empty"
    }
}

Write-Host "Done!" -ForegroundColor Green
