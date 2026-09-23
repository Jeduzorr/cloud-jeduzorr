"""À lancer UNE fois sur le PC : obtient le jeton de rafraîchissement Microsoft.

Usage : python get_token.py <MS_CLIENT_ID>
Copier la valeur affichée dans le secret GitHub MS_REFRESH_TOKEN. Ne jamais la committer.
"""

import sys

import msal

app = msal.PublicClientApplication(sys.argv[1], authority="https://login.microsoftonline.com/consumers")
flow = app.initiate_device_flow(scopes=["Mail.ReadWrite"])
if "user_code" not in flow:
    sys.exit(f"Erreur : {flow.get('error_description')}")
print(flow["message"])
result = app.acquire_token_by_device_flow(flow)
if "refresh_token" not in result:
    sys.exit(f"Erreur : {result.get('error_description')}")
print("\nMS_REFRESH_TOKEN =\n" + result["refresh_token"])
