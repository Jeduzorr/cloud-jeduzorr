# Tri mails automatique

Chaque jour : mails de la Boîte de réception reçus il y a au moins 7 jours.
- Spam / phishing -> Courrier indésirable (jamais supprimé).
- Reste -> `Tri auto/` : Banque, Factures, Santé, Administratif, Achats, Newsletters, Perso, Autres.
- Hybride : `rules.json` (domaines sûrs) puis Claude Haiku 4.5 pour le reste. Max 500 appels Claude/jour.

## Installation (une fois)

1. **App Azure** : https://entra.microsoft.com -> App registrations -> New registration.
   - Nom : `tri-mails`. Comptes : « Personal Microsoft accounts only ».
   - Authentication -> Allow public client flows : **Yes**.
   - API permissions -> Microsoft Graph -> Delegated -> `Mail.ReadWrite`.
   - Copier l'**Application (client) ID**.
2. **Jeton** (sur le PC) :
   ```
   pip install msal
   python mail-sorter/get_token.py <CLIENT_ID>
   ```
   Ouvrir le lien, entrer le code, se connecter avec la boîte Hotmail.
3. **Clé Claude** : https://console.anthropic.com -> créditer 5 € -> API Keys -> créer. Fixer une limite de dépense.
4. **Secrets GitHub** (Settings -> Secrets and variables -> Actions) :
   - `MS_CLIENT_ID`, `MS_REFRESH_TOKEN`, `ANTHROPIC_API_KEY`.
   - Optionnel `EXTRA_RULES_JSON` : règles privées, ex. `{"Santé": ["mon-kine.fr"]}`.
5. **Test** : Actions -> Tri mails -> Run workflow (simulation cochée). Lire les compteurs.
   Puis relancer sans simulation. Ensuite automatique chaque jour.

## Sécurité
- Dépôt public : logs = compteurs uniquement, jamais d'objet ni d'expéditeur.
- Aucun secret dans le dépôt.
- Jeton expiré (inactivité > 90 j ou mot de passe changé) : refaire l'étape 2.
