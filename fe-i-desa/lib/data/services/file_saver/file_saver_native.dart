import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String?> saveStringFile(String content, String filename) async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/$filename';
    await File(path).writeAsString(content);
    return path;
  } catch (e) {
    return null;
  }
}

Future<String?> saveBytesFile(List<int> bytes, String filename) async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/$filename';
    await File(path).writeAsBytes(bytes);
    return path;
  } catch (e) {
    return null;
  }
}
