# Mémoire Claude partagée PC → cloud

La mémoire du PC est la référence. Le cloud la lit en priorité ; ses propres notes sont accessoires.

```
PC ~/.claude ──(hook, liste blanche + anti-secret)──▶ Jeduzorr/claude-memory (PRIVÉ) /pc
                                                                     │
Session cloud ◀──(hook SessionStart, injecté en premier)─────────────┘
```

## 1. Créer le dépôt privé (une fois)

Sur GitHub : **New repository** → nom `claude-memory` → **Private** → cocher *Add a README*.

## 2. Installer sur le PC (une fois)

```bash
git clone https://github.com/Jeduzorr/claude-memory.git ~/claude-memory
mkdir -p ~/claude-memory/bin
cp memory-sync/pc/sync-memory.sh memory-sync/pc/sync-memory.ps1 ~/claude-memory/bin/
chmod +x ~/claude-memory/bin/sync-memory.sh
```

Puis ajouter dans `~/.claude/settings.json` (fusionner avec l'existant).

**macOS / Linux :**
```json
{
  "hooks": {
    "SessionStart": [{ "hooks": [{ "type": "command", "command": "bash ~/claude-memory/bin/sync-memory.sh" }] }],
    "Stop":         [{ "hooks": [{ "type": "command", "command": "bash ~/claude-memory/bin/sync-memory.sh" }] }],
    "SessionEnd":   [{ "hooks": [{ "type": "command", "command": "bash ~/claude-memory/bin/sync-memory.sh" }] }]
  }
}
```

**Windows :** remplacer la commande par
`powershell -NoProfile -ExecutionPolicy Bypass -File %USERPROFILE%\claude-memory\bin\sync-memory.ps1`

Test : `bash ~/claude-memory/bin/sync-memory.sh` puis vérifier le dossier `pc/` sur GitHub.

## 3. Côté cloud

Déjà en place dans ce dépôt (`.claude/settings.json` + `.claude/hooks/load-pc-memory.sh`).
Pour que la session cloud accède au dépôt privé, ajouter `Jeduzorr/claude-memory` comme
dépôt de l'environnement / de la session (sinon Claude l'ajoute lui-même au démarrage via `add_repo`).
Pour d'autres projets : copier `.claude/` et `CLAUDE.md` dans le projet.

## Ce qui est synchronisé

| Synchronisé | Jamais synchronisé |
|---|---|
| `~/.claude/CLAUDE.md` | `settings.json`, `.credentials.json` |
| `rules/`, `agents/`, `commands/`, `skills/`, `output-styles/` | historique des conversations, `todos/`, caches |
| `projects/*/memory/`, `projects/*/CLAUDE.md` | tout fichier contenant un secret détecté (push bloqué) |

## Sécurité

- Dépôt **privé** ; le script refuse de pousser s'il détecte qu'il ne l'est pas (via `gh`).
- Liste blanche de fichiers, jamais de copie globale de `~/.claude`.
- Scan anti-secret (clés Anthropic/OpenAI/GitHub/AWS/Slack, clés privées, `password=`…) : push annulé si trouvé.
- Le cloud n'écrit jamais dans `pc/`, uniquement dans `cloud/`.
