// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';

Future<String?> saveStringFile(String content, String filename) async {
  try {
    final bytes = utf8.encode(content);
    return saveBytesFile(bytes, filename);
  } catch (e) {
    return null;
  }
}

Future<String?> saveBytesFile(List<int> bytes, String filename) async {
  try {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
    return filename;
  } catch (e) {
    return null;
  }
}
