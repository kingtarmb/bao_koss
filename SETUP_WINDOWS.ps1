# JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010
$ErrorActionPreference = 'Stop'
Write-Host '=== BÂO-KOSS / préparation Windows ===' -ForegroundColor Green
flutter --version
if (Get-Command node -ErrorAction SilentlyContinue) { node --version }
if (Get-Command firebase -ErrorAction SilentlyContinue) { firebase --version }
if (Get-Command flutterfire -ErrorAction SilentlyContinue) { flutterfire --version } else { Write-Warning 'flutterfire absent du PATH. Utilisez: dart pub global activate flutterfire_cli' }
flutter pub get
flutterfire configure
flutter analyze
flutter test
Write-Host 'Préparation terminée. Pour générer l’APK : flutter build apk --release' -ForegroundColor Green
