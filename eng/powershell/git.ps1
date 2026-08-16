function feature {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $false)]
        [string]$Prefix = "feature"
    )

    if ([string]::IsNullOrWhiteSpace($Prefix)) {
        $Prefix = "feature"
    }

    $Prefix = $Prefix.ToLowerInvariant().Replace(' ', '-')
    $Name = $Name.ToLowerInvariant().Replace(' ', '-')
    $BranchName = $Name.StartsWith("$Prefix/") ? $Name : "$Prefix/$Name"

    Write-Host "Creating feature branch: " -NoNewline
    Write-Host $BranchName -ForegroundColor Cyan

    $result = git switch -c $BranchName 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ " -NoNewline -ForegroundColor Green
        Write-Host "Successfully created and switched to branch " -NoNewline
        Write-Host $BranchName -ForegroundColor Cyan
    }
    else {
        Write-Host "✗ " -NoNewline -ForegroundColor Red
        Write-Host "Failed to create branch: " -NoNewline -ForegroundColor Red
        Write-Host $result
    }
}

function finish {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$BaseBranch = "main",
        [Parameter(Mandatory = $false)]
        [switch]$KeepBranch,
        [Parameter(Mandatory = $false)]
        [switch]$Stash
    )

    # Check if there are uncommitted changes
    $status = git status --porcelain
    $hasChanges = [bool]$status
    if ($hasChanges) {
        if (-not $Stash) {
            Write-Host "✗ " -NoNewline -ForegroundColor Red
            Write-Host "You have uncommitted changes. Please commit or stash them before finishing the feature, or use -Stash to stash automatically." -ForegroundColor Red
            return
        }

        Write-Host "Stashing uncommitted changes..." -ForegroundColor Yellow
        git stash push --include-untracked -m "finish: auto-stash before merge"
        if ($LASTEXITCODE -ne 0) {
            Write-Host "✗ " -NoNewline -ForegroundColor Red
            Write-Host "Failed to stash uncommitted changes." -ForegroundColor Red
            return
        }
        Write-Host "✓ " -NoNewline -ForegroundColor Green
        Write-Host "Stashed uncommitted changes."
    }

    # Get the current branch name
    $currentBranch = git rev-parse --abbrev-ref HEAD
    Write-Host "Finishing feature branch: " -NoNewline
    Write-Host $currentBranch -ForegroundColor Cyan

    # Check if remote branch exists and compare with local
    $remoteBranches = git branch -r 2>&1
    if ($LASTEXITCODE -eq 0 -and $remoteBranches) {
        $remoteExists = $remoteBranches | Where-Object { $_ -match "origin/$currentBranch$" }
        if ($remoteExists) {
            # Get commit hashes for local and remote branches
            $localCommit = git rev-parse $currentBranch 2>&1
            $remoteCommit = git rev-parse "origin/$currentBranch" 2>&1

            if ($LASTEXITCODE -eq 0 -and $localCommit -ne $remoteCommit) {
                Write-Host "✗ " -NoNewline -ForegroundColor Red
                Write-Host "Local and remote branches are out of sync." -ForegroundColor Red
                Write-Host "  Local:  " -NoNewline
                Write-Host $localCommit.Substring(0, 7) -ForegroundColor Yellow
                Write-Host "  Remote: " -NoNewline
                Write-Host $remoteCommit.Substring(0, 7) -ForegroundColor Yellow
                Write-Host "Please push or pull to synchronize before finishing." -ForegroundColor Red
                return
            }
        }
    }

    # Check if the base branch exists
    git show-ref --verify --quiet "refs/heads/$BaseBranch"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "✗ " -NoNewline -ForegroundColor Red
        Write-Host "Base branch '$BaseBranch' does not exist." -ForegroundColor Red
        return
    }

    # Switch to the base branch
    git switch $BaseBranch
    if ($LASTEXITCODE -ne 0) {
        Write-Host "✗ " -NoNewline -ForegroundColor Red
        Write-Host "Failed to switch to base branch '$BaseBranch'." -ForegroundColor Red
        return
    }

    # Merge the feature branch into the base branch
    git merge --no-ff -m "Merge branch '$currentBranch' into $BaseBranch" $currentBranch
    if ($LASTEXITCODE -ne 0) {
        Write-Host "✗ " -NoNewline -ForegroundColor Red
        Write-Host "Merge failed. Please resolve conflicts manually." -ForegroundColor Red
        return
    }

    Write-Host "✓ " -NoNewline -ForegroundColor Green
    Write-Host "Successfully merged branch " -NoNewline
    Write-Host $currentBranch -NoNewline -ForegroundColor Cyan
    Write-Host " into " -NoNewline
    Write-Host $BaseBranch -ForegroundColor Cyan

    # Restore stashed changes if we stashed them earlier
    if ($hasChanges -and $Stash) {
        Write-Host "Restoring stashed changes..." -ForegroundColor Yellow
        git stash pop
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ " -NoNewline -ForegroundColor Green
            Write-Host "Restored stashed changes."
        }
        else {
            Write-Host "✗ " -NoNewline -ForegroundColor Red
            Write-Host "Failed to restore stashed changes. Run 'git stash pop' manually." -ForegroundColor Red
        }
    }

    # Delete the feature branch unless KeepBranch is specified
    if (-not $KeepBranch) {
        git branch -d $currentBranch
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ " -NoNewline -ForegroundColor Green
            Write-Host "Deleted local branch " -NoNewline
            Write-Host $currentBranch -ForegroundColor Cyan
        }
        else {
            Write-Host "✗ " -NoNewline -ForegroundColor Red
            Write-Host "Failed to delete local branch " -NoNewline
            Write-Host $currentBranch -ForegroundColor Red
        }

        # Check if remote branch exists and delete it
        $remoteExists = $remoteBranches | Where-Object { $_ -match "origin/$currentBranch$" }
        if ($remoteExists) {
            Write-Host "Deleting remote branch: " -NoNewline
            Write-Host "origin/$currentBranch" -ForegroundColor Cyan
            git push origin --delete $currentBranch 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✓ " -NoNewline -ForegroundColor Green
                Write-Host "Deleted remote branch " -NoNewline
                Write-Host "origin/$currentBranch" -ForegroundColor Cyan
            }
            else {
                Write-Host "✗ " -NoNewline -ForegroundColor Red
                Write-Host "Failed to delete remote branch " -NoNewline
                Write-Host "origin/$currentBranch" -ForegroundColor Red
            }
        }
    }
}