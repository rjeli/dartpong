all:
	dart2js web/client.dart -o web/client.dart.js --show-package-warnings

run:
	dart bin/server.dart
