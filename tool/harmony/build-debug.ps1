param(
  [switch]$SkipPub, [switch]$Sign,
  [ValidateSet('debug', 'profile', 'release')][string]$BuildMode = 'debug',
  [string]$ProjectRoot = 'E:\pilinara-workspace\PiliNara-upstream',
  [string]$SdkRoot = 'E:\deveco-26',
  [string]$FlutterRoot = 'E:\pilinara-workspace\flutter-ohos-windows-sdk',
  [string]$PubCache = 'E:\pilinara-workspace\.pub-cache-ohos'
)

$ErrorActionPreference = 'Stop'
$flutterBat = Join-Path $FlutterRoot 'bin/flutter.bat'
if (!(Test-Path -LiteralPath $projectRoot) -or !(Test-Path -LiteralPath $flutterBat)) { throw 'English workspace entry or Flutter SDK is missing.' }
$sourceRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../..')).Path
if ($sourceRoot -ne $projectRoot) {
  foreach ($folder in @('lib', 'packages', 'test', 'assets', 'tool')) {
    $sourceFolder = Join-Path $sourceRoot $folder
    if (Test-Path -LiteralPath $sourceFolder) {
      & robocopy $sourceFolder (Join-Path $projectRoot $folder) /E /XJ /XD .dart_tool build oh_modules node_modules .hvigor /R:1 /W:1 /NFL /NDL /NP /NJH /NJS
      if ($LASTEXITCODE -ge 8) { throw "Source synchronization failed: $folder" }
    }
  }
  & robocopy (Join-Path $sourceRoot 'ohos/AppScope') (Join-Path $projectRoot 'ohos/AppScope') /E /XJ /R:1 /W:1 /NFL /NDL /NP /NJH /NJS
  if ($LASTEXITCODE -ge 8) { throw 'AppScope synchronization failed.' }
  foreach ($file in @('pubspec.yaml', 'pubspec.lock')) {
    Copy-Item -LiteralPath (Join-Path $sourceRoot $file) -Destination (Join-Path $projectRoot $file)
  }
  & robocopy (Join-Path $sourceRoot 'ohos/entry/src/main') (Join-Path $projectRoot 'ohos/entry/src/main') /E /XJ /XF GeneratedPluginRegistrant.ets /R:1 /W:1 /NFL /NDL /NP /NJH /NJS
  if ($LASTEXITCODE -ge 8) { throw 'OHOS source synchronization failed.' }
}
$env:FLUTTER_STORAGE_BASE_URL = 'https://storage.flutter-io.cn'
$env:PUB_HOSTED_URL = 'https://pub.flutter-io.cn'
$env:PUB_CACHE = $PubCache
$env:DEVECO_SDK_HOME = "$sdkRoot\sdk"
$env:JAVA_HOME = "$sdkRoot\jbr"
$env:NODE_HOME = "$sdkRoot\tools\node"
$env:PATH = "$sdkRoot\jbr\bin;$sdkRoot\tools\node;$sdkRoot\tools\ohpm\bin;$sdkRoot\tools\hvigor\bin;" + $env:PATH
Push-Location -LiteralPath $projectRoot
try {
  if (!$SkipPub) {
    & $flutterBat pub get --offline --no-example
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
  }
  $buildArgs = @('build', 'hap', "--$BuildMode", '--no-pub', '--no-tree-shake-icons')
  if (!$Sign) { $buildArgs += '--no-codesign' }
  & $flutterBat @buildArgs
  exit $LASTEXITCODE
} finally { Pop-Location }
