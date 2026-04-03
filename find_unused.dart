import 'dart:io';

void main() {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) return;

  final allFiles = libDir.listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  final allContents = <File, String>{};
  for (var f in allFiles) {
    allContents[f] = f.readAsStringSync();
  }

  final outPath = 'unused_files_list.txt';
  final outFile = File(outPath);
  if (outFile.existsSync()) outFile.deleteSync();

  for (var file in allFiles) {
    if (file.path.endsWith('main.dart')) continue;
    
    final filename = file.uri.pathSegments.last;
    if (filename.startsWith('_')) continue;

    bool isUsed = false;
    for (var other in allFiles) {
      if (file.path == other.path) continue;
      if (allContents[other]!.contains(filename)) {
        isUsed = true;
        break;
      }
    }
    
    if (!isUsed) {
      outFile.writeAsStringSync('UNUSED: ${file.path}\n', mode: FileMode.append);
    }
  }
}
