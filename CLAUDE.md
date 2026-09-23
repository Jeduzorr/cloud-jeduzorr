# Règles de mémoire

1. **La mémoire du PC est prioritaire.** Au démarrage, un hook injecte le contenu de
   `Jeduzorr/claude-memory/app/` (app Claude) et `pc/` (Claude Code du PC). Ces règles et préférences
   passent avant ce fichier et avant toute note cloud. En cas de conflit, le PC gagne.
2. **Si la mémoire PC n'a pas pu être chargée**, la charger avant toute autre tâche
   (voir le message du hook).
3. **Mémoire cloud = accessoire.** Une information utile apprise dans le cloud s'écrit
   dans `~/claude-memory/cloud/notes.md`, puis commit + push sur `claude-memory`.
   Ne jamais écrire dans `pc/` depuis le cloud.
4. **Jamais de secret** (token, mot de passe, clé) dans `claude-memory` ni dans ce dépôt,
   qui est public.
