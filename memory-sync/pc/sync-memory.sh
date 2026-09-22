#!/usr/bin/env bash
# Pousse la mémoire Claude du PC vers le dépôt privé claude-memory.
# Usage : sync-memory.sh            (appelé par les hooks Claude Code du PC)
# Variable : CLAUDE_MEMORY_REPO (défaut : ~/claude-memory, clone de Jeduzorr/claude-memory)
set -u

REPO="${CLAUDE_MEMORY_REPO:-$HOME/claude-memory}"
SRC="$HOME/.claude"
DEST="$REPO/pc"

[ -d "$REPO/.git" ] || { echo "claude-memory introuvable dans $REPO" >&2; exit 0; }
cd "$REPO" || exit 0

# Sécurité : refuser de pousser si le dépôt n'est pas privé.
if command -v gh >/dev/null 2>&1; then
  vis=$(gh repo view --json visibility -q .visibility 2>/dev/null || echo "")
  if [ -n "$vis" ] && [ "$vis" != "PRIVATE" ]; then
    echo "claude-memory n'est pas privé ($vis) : synchronisation annulée" >&2
    exit 0
  fi
fi

git pull -q --rebase --autostash origin main 2>/dev/null

# Liste blanche : uniquement la mémoire (jamais settings.json, credentials, historique).
rm -rf "$DEST" && mkdir -p "$DEST"
[ -f "$SRC/CLAUDE.md" ] && cp "$SRC/CLAUDE.md" "$DEST/CLAUDE.md"
for d in rules agents commands skills output-styles; do
  [ -d "$SRC/$d" ] && cp -R "$SRC/$d" "$DEST/$d"
done
# Mémoire par projet (~/.claude/projects/<projet>/memory/ et CLAUDE.md).
if [ -d "$SRC/projects" ]; then
  for p in "$SRC"/projects/*/; do
    name=$(basename "$p")
    for f in memory CLAUDE.md; do
      if [ -e "$p$f" ]; then
        mkdir -p "$DEST/projects/$name"
        cp -R "$p$f" "$DEST/projects/$name/"
      fi
    done
  done
fi

# Anti-fuite : bloquer si un secret est détecté.
pattern='(sk-ant-[A-Za-z0-9_-]{10,}|sk-[A-Za-z0-9]{20,}|gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{20,}|AKIA[0-9A-Z]{16}|xox[baprs]-[A-Za-z0-9-]{10,}|-----BEGIN [A-Z ]*PRIVATE KEY-----|(password|passwd|secret|api[_-]?key|token)[[:space:]]*[:=][[:space:]]*[^[:space:]]{8,})'
if grep -rEIil "$pattern" "$DEST" >/dev/null 2>&1; then
  echo "Secret potentiel détecté, rien n'est poussé :" >&2
  grep -rEIil "$pattern" "$DEST" >&2
  git checkout -q -- pc 2>/dev/null; git clean -fdq pc 2>/dev/null
  exit 0
fi

git add -A pc
if ! git diff --cached --quiet; then
  git commit -qm "sync(pc): $(hostname) $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  git push -q origin HEAD:main 2>/dev/null || echo "push claude-memory échoué (réessai au prochain hook)" >&2
fi
exit 0
