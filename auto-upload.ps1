$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $repoRoot

Write-Host "自動アップロードを開始しました。ファイルを保存するとGitHubへ送信します。" -ForegroundColor Cyan
Write-Host "終了するには Ctrl+C を押してください。" -ForegroundColor DarkGray

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $repoRoot
$watcher.Filter = '*'
$watcher.IncludeSubdirectories = $true
$watcher.NotifyFilter = [System.IO.NotifyFilters]'FileName, LastWrite, Size'

$action = {
  $path = $Event.SourceEventArgs.FullPath
  if ($path -match '\\.git(\\|$)' -or $path -match '\\auto-upload\.ps1$') { return }
  Start-Sleep -Milliseconds 700
  try {
    $changes = git status --short
    if (-not $changes) { return }
    git add -A
    $message = "Update travel guide " + (Get-Date -Format 'yyyy-MM-dd HH:mm')
    git commit -m $message | Out-Host
    git push origin main | Out-Host
    Write-Host "GitHubへのアップロードが完了しました。" -ForegroundColor Green
  } catch {
    Write-Host "アップロードに失敗しました: $($_.Exception.Message)" -ForegroundColor Red
  }
}

Register-ObjectEvent $watcher Changed -Action $action | Out-Null
Register-ObjectEvent $watcher Created -Action $action | Out-Null
Register-ObjectEvent $watcher Deleted -Action $action | Out-Null
Register-ObjectEvent $watcher Renamed -Action $action | Out-Null

try { while ($true) { Wait-Event -Timeout 5 | Out-Null } }
finally { $watcher.Dispose(); Get-EventSubscriber | Unregister-Event }
