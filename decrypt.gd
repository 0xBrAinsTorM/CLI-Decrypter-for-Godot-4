# decrypt.gd ? CLI-Decrypter für Godot 4 (headless)
# Beispiele:
#   godot4 --headless --script decrypt.gd --key res://resources/encryption/key.key --vars res://resources/encryption/vars/vars.tres --all
#   godot4 --headless --script decrypt.gd --key res://.../key.key --vars res://.../vars.tres --name API_TOKEN --name PASSWORD
#   godot4 --headless --script decrypt.gd --all --json

extends SceneTree

func _initialize() -> void:
	var key_path  : String = "res://resources/encryption/key.key"
	var vars_path : String = "res://resources/encryption/vars/vars.tres"

	var names     : Array[String] = []
	var dump_all  : bool = false
	var json_out  : bool = false

	# simpler CLI-Parser
	var args := OS.get_cmdline_args()
	for i in args.size():
		match args[i]:
			"--key":
				if i + 1 < args.size(): key_path = args[i + 1]
			"--vars":
				if i + 1 < args.size(): vars_path = args[i + 1]
			"--name":
				if i + 1 < args.size(): names.append(args[i + 1])
			"--all":
				dump_all = true
			"--json":
				json_out = true
			"--help", "-h":
				_print_usage_and_quit(0)

	# Validierung
	if not FileAccess.file_exists(key_path):
		_printerr_and_quit("Key file not found: %s" % key_path, 2)
	if not FileAccess.file_exists(vars_path):
		_printerr_and_quit("Vars resource not found: %s" % vars_path, 3)

	# Laden
	var crypto := Crypto.new()
	var key := CryptoKey.new()
	var load_ok := key.load(key_path)
	if load_ok != OK:
		_printerr_and_quit("Failed to load key: %s (code %d)" % [key_path, load_ok], 4)

	var storage := ResourceLoader.load(vars_path)
	if storage == null:
		_printerr_and_quit("Failed to load vars resource: %s" % vars_path, 5)

	# Erwartet ein Dictionary-Feld 'encrypted_variables_dict'
	var dict: Dictionary = storage.get("encrypted_variables_dict") as Dictionary
	if not (dict is Dictionary):
		_printerr_and_quit("Resource does not contain 'encrypted_variables_dict' as Dictionary.", 6)

	# Welche Keys?
	var keys: Array[String] = []
	if dump_all:
		for k in dict.keys():
			keys.append(String(k))
	else:
		if names.is_empty():
			_print_usage_and_quit(1)
		keys = names

	# Entschlüsseln
	var results: Dictionary = {}
	for k in keys:
		if not dict.has(k):
			results[k] = ""
			continue
		var enc_val = dict[k]
		if not (enc_val is PackedByteArray):
			results[k] = ""
			continue
		var dec_bytes: PackedByteArray = Crypto.new().decrypt(key, enc_val)
		if dec_bytes.is_empty():
			results[k] = ""
		else:
			results[k] = dec_bytes.get_string_from_utf8()

	# Ausgabe
	if json_out:
		print(JSON.stringify(results, "  "))
	else:
		for k in results.keys():
			print("%s = %s" % [String(k), String(results[k])])

	quit()

func _print_usage_and_quit(code: int) -> void:
	var msg := """
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
"""
	print(msg.strip_edges())
	quit(code)

func _printerr_and_quit(msg: String, code: int) -> void:
	push_error(msg)
	quit(code)
