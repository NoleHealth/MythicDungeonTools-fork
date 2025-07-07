# MDT Development Helper Script
# This script helps you quickly copy your changes to WoW for testing

param(
    [string]$WoWPath = "C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\MythicDungeonTools",
    [switch]$Watch,
    [switch]$Help
)

if ($Help) {
    Write-Host "MDT Development Helper Script" -ForegroundColor Green
    Write-Host ""
    Write-Host "Usage: .\dev-helper.ps1 [options]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Cyan
    Write-Host "  -WoWPath <path>  : Path to WoW AddOns folder (default: C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\MythicDungeonTools)"
    Write-Host "  -Watch           : Watch for changes and auto-copy (experimental)"
    Write-Host "  -Help            : Show this help message"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Cyan
    Write-Host "  .\dev-helper.ps1"
    Write-Host "  .\dev-helper.ps1 -WoWPath 'D:\Games\WoW\_retail_\Interface\AddOns\MythicDungeonTools'"
    Write-Host ""
    exit
}

$sourceDir = $PSScriptRoot
$targetDir = $WoWPath

Write-Host "MDT Development Helper" -ForegroundColor Green
Write-Host "Source: $sourceDir" -ForegroundColor Yellow
Write-Host "Target: $targetDir" -ForegroundColor Yellow

# Check if source directory exists
if (-not (Test-Path $sourceDir)) {
    Write-Host "Error: Source directory not found!" -ForegroundColor Red
    exit 1
}

# Check if target directory exists, create if not
if (-not (Test-Path $targetDir)) {
    Write-Host "Creating target directory..." -ForegroundColor Yellow
    New-Item -Path $targetDir -ItemType Directory -Force | Out-Null
}

function Copy-AddonFiles {
    Write-Host "Copying addon files..." -ForegroundColor Yellow

    # Files to copy (exclude development files)
    $excludePatterns = @(
        "*.git*",
        "*.vscode*",
        "*.md",
        "dev-helper.ps1",
        "*.log"
    )

    try {
        # Copy all files except excluded ones
        Get-ChildItem -Path $sourceDir -Recurse | Where-Object {
            $relativePath = $_.FullName.Substring($sourceDir.Length)
            $exclude = $false
            foreach ($pattern in $excludePatterns) {
                if ($relativePath -like "*$pattern*") {
                    $exclude = $true
                    break
                }
            }
            -not $exclude
        } | ForEach-Object {
            $targetPath = $_.FullName.Replace($sourceDir, $targetDir)
            $targetFolder = Split-Path -Path $targetPath -Parent

            if (-not (Test-Path $targetFolder)) {
                New-Item -Path $targetFolder -ItemType Directory -Force | Out-Null
            }

            if ($_.PSIsContainer -eq $false) {
                Copy-Item -Path $_.FullName -Destination $targetPath -Force
            }
        }

        Write-Host "Files copied successfully!" -ForegroundColor Green
        Write-Host "You can now test in WoW with /reload" -ForegroundColor Cyan
    }
    catch {
        Write-Host "Error copying files: $($_.Exception.Message)" -ForegroundColor Red
    }
}

if ($Watch) {
    Write-Host "Watching for changes... Press Ctrl+C to stop" -ForegroundColor Yellow

    # Initial copy
    Copy-AddonFiles

    # Watch for changes
    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = $sourceDir
    $watcher.IncludeSubdirectories = $true
    $watcher.EnableRaisingEvents = $true

    $action = {
        $path = $Event.SourceEventArgs.FullPath
        $changeType = $Event.SourceEventArgs.ChangeType
        $fileName = Split-Path -Path $path -Leaf

        # Skip non-addon files
        if ($fileName -like "*.git*" -or $fileName -like "*.md" -or $fileName -like "*.ps1") {
            return
        }

        Write-Host "Change detected: $fileName ($changeType)" -ForegroundColor Yellow
        Start-Sleep -Seconds 1  # Brief delay to ensure file is fully written
        Copy-AddonFiles
    }

    Register-ObjectEvent -InputObject $watcher -EventName "Changed" -Action $action
    Register-ObjectEvent -InputObject $watcher -EventName "Created" -Action $action
    Register-ObjectEvent -InputObject $watcher -EventName "Deleted" -Action $action
    Register-ObjectEvent -InputObject $watcher -EventName "Renamed" -Action $action

    try {
        while ($true) {
            Start-Sleep -Seconds 1
        }
    }
    finally {
        $watcher.Dispose()
    }
}
else {
    Copy-AddonFiles
}
