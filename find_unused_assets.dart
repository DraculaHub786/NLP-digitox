import 'dart:io';

void main() {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) return;

  final allDartFiles = libDir.listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  final allDartContents = <File, String>{};
  for (var f in allDartFiles) {
    allDartContents[f] = f.readAsStringSync();
  }

  final assetsDir = Directory('assets');
  if (!assetsDir.existsSync()) return;

  final allAssetFiles = assetsDir.listSync(recursive: true)
      .whereType<File>()
      .toList();

  final outPath = 'unused_assets.txt';
  final outFile = File(outPath);
  if (outFile.existsSync()) outFile.deleteSync();

  for (var asset in allAssetFiles) {
    final filename = asset.uri.pathSegments.last;
    
    // Some assets are used by full path depending on the framework, but searching filename is usually enough.
    // Specially for flutter, it's typically "assets/images/logo.png" or just "logo.png"
    bool isUsed = false;
    for (var dart in allDartFiles) {
      if (allDartContents[dart]!.contains(filename)) {
        isUsed = true;
        break;
      }
    }
    
    if (!isUsed) {
      outFile.writeAsStringSync('UNUSED_ASSET: ${asset.path}\n', mode: FileMode.append);
    }
  }
}
