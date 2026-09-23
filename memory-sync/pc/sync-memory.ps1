# Pousse la mémoire Claude du PC (Windows) vers le dépôt privé claude-memory.
# Variable : CLAUDE_MEMORY_REPO (défaut : $HOME\claude-memory)
$ErrorActionPreference = 'Continue'

$Repo = if ($env:CLAUDE_MEMORY_REPO) { $env:CLAUDE_MEMORY_REPO } else { Join-Path $HOME 'claude-memory' }
$Src  = Join-Path $HOME '.claude'
$Dest = Join-Path $Repo 'pc'

if (-not (Test-Path (Join-Path $Repo '.git'))) { Write-Host "claude-memory introuvable dans $Repo"; exit 0 }
Set-Location $Repo

# Sécurité : refuser de pousser si le dépôt n'est pas privé.
if (Get-Command gh) {
  $vis = gh repo view --json visibility -q .visibility 2>$null
  if ($vis -and $vis -ne 'PRIVATE') { Write-Host "claude-memory n'est pas privé ($vis)"; exit 0 }
}

git pull -q --rebase --autostash origin main

# Liste blanche : uniquement la mémoire (jamais settings.json, credentials, historique).
if (Test-Path $Dest) { Remove-Item -Recurse -Force $Dest }
New-Item -ItemType Directory -Force $Dest | Out-Null
$g = Join-Path $Src 'CLAUDE.md'; if (Test-Path $g) { Copy-Item $g $Dest }
foreach ($d in 'rules','agents','commands','skills','output-styles') {
  $p = Join-Path $Src $d; if (Test-Path $p) { Copy-Item -Recurse $p $Dest }
}
$projects = Join-Path $Src 'projects'
if (Test-Path $projects) {
  Get-ChildItem -Directory $projects | ForEach-Object {
    foreach ($f in 'memory','CLAUDE.md') {
      $s = Join-Path $_.FullName $f
      if (Test-Path $s) {
        $t = Join-Path $Dest "projects\$($_.Name)"
        New-Item -ItemType Directory -Force $t | Out-Null
        Copy-Item -Recurse $s $t
      }
    }
  }
}

# Anti-fuite : bloquer si un secret est détecté.
$pattern = '(sk-ant-[A-Za-z0-9_-]{10,}|sk-[A-Za-z0-9]{20,}|gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{20,}|AKIA[0-9A-Z]{16}|xox[baprs]-[A-Za-z0-9-]{10,}|-----BEGIN [A-Z ]*PRIVATE KEY-----|(password|passwd|secret|api[_-]?key|token)\s*[:=]\s*\S{8,})'
$hits = Get-ChildItem -Recurse -File $Dest | Select-String -Pattern $pattern -List
if ($hits) {
  Write-Host "Secret potentiel détecté, rien n'est poussé :"; $hits | ForEach-Object { Write-Host "  $($_.Path) : ligne $($_.LineNumber)" }
  git checkout -q -- pc; git clean -fdq pc
  exit 0
}

git add -A pc
git diff --cached --quiet
if ($LASTEXITCODE -ne 0) {
  git commit -qm "sync(pc): $env:COMPUTERNAME $((Get-Date).ToUniversalTime().ToString('s'))Z"
  git push -q origin HEAD:main
  if ($LASTEXITCODE -eq 0) { Write-Host "Mémoire synchronisée." } else { Write-Host "Échec du push." }
} else { Write-Host "Aucun changement." }
exit 0
