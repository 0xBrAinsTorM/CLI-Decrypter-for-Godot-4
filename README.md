# CLI-Decrypter-for-Godot-4
Godot 4 Headless Decrypter für verschlüsselte Variablen

Nutzung:
  godot4 --headless --script decrypt.gd --key <res://pfad/zum/key.key> --vars <res://pfad/zu/vars.tres> (--all | --name NAME [--name NAME2 ...]) [--json]

Optionen:
  --key    Pfad zur CryptoKey-Datei (.key).        (Default: res://resources/encryption/key.key)
  --vars   Pfad zur Variablen-Resource (.tres).    (Default: res://resources/encryption/vars/vars.tres)
  --all    Alle Einträge ausgeben.
  --name   Nur bestimmte Namen entschlüsseln (mehrfach nutzbar).
  --json   Ausgabe als JSON.
  --help   Diese Hilfe.
