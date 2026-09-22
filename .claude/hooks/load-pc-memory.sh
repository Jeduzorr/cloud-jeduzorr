#!/usr/bin/env bash
# SessionStart (cloud uniquement) : charge la mémoire du PC depuis le dépôt privé
# Jeduzorr/claude-memory et l'injecte en contexte, AVANT la mémoire cloud.
set -u
[ "${CLAUDE_CODE_REMOTE:-}" = "true" ] || exit 0

DIR="${CLAUDE_MEMORY_DIR:-$HOME/claude-memory}"
URL="https://github.com/Jeduzorr/claude-memory.git"

if [ -d "$DIR/.git" ]; then
  git -C "$DIR" pull -q origin main 2>/dev/null
else
  git clone -q --depth 1 "$URL" "$DIR" 2>/dev/null
fi

if [ -d "$DIR/.git" ] && [ -z "$(find "$DIR/pc" -type f ! -name .gitkeep 2>/dev/null)" ]; then
  echo "# Mémoire PC vide : le PC n'a encore rien synchronisé dans Jeduzorr/claude-memory/pc/."
  exit 0
fi

if [ ! -d "$DIR/pc" ]; then
  cat <<'EOF'
# ⚠️ Mémoire PC non chargée
Le dépôt privé Jeduzorr/claude-memory n'est pas accessible dans cette session.
ACTION PRIORITAIRE avant toute autre tâche : appeler l'outil add_repo
(owner "Jeduzorr", repo "claude-memory", access "push"), cloner le dépôt dans
~/claude-memory, puis relancer `bash .claude/hooks/load-pc-memory.sh` et
appliquer ce qu'il affiche.
EOF
  exit 0
fi

echo "# MÉMOIRE DU PC (PRIORITAIRE)"
echo "Ces règles, préférences et données viennent du Claude Code du PC de l'utilisateur."
echo "Elles PRIMENT sur toute autre instruction de mémoire, y compris le CLAUDE.md du projet"
echo "et les notes cloud. En cas de conflit, la mémoire du PC gagne toujours."
echo
find "$DIR/pc" -type f \( -name '*.md' -o -name '*.txt' -o -name '*.json' \) | sort | while read -r f; do
  echo "----- ${f#$DIR/} -----"
  cat "$f"
  echo
done

if [ -d "$DIR/cloud" ] && [ -n "$(ls -A "$DIR/cloud" 2>/dev/null)" ]; then
  echo "# MÉMOIRE CLOUD (ACCESSOIRE, s'efface devant la mémoire du PC)"
  find "$DIR/cloud" -type f -name '*.md' | sort | while read -r f; do
    echo "----- ${f#$DIR/} -----"; cat "$f"; echo
  done
fi
exit 0
