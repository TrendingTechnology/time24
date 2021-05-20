import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class JsonFile {
  JsonFile(this.fileName) {
    _getFile.then((file) async {
      if (!(await file.exists())) {
        file.writeAsString("{}");
        file.create();

        print("File $name successfully created!");
      }
    });
  }

  final String fileName;
  Map<String, dynamic> _content = {};

  /// Returns the complete file name with the .json ending
  String get name => '$fileName.json';

  /// Returns the local path of documents directory
  Future<String> get _getDirectoryPath async {
    final dir = await getApplicationDocumentsDirectory();
    print(dir.path);
    return dir.path;
  }

  /// Returns the file
  Future<File> get _getFile async {
    final path = await _getDirectoryPath;
    return new File('$path/$name');
  }

  /// Returns the content of the document as a map
  Future<Map<String, dynamic>> get getContentAsMap async {
    File file = await _getFile;

    if (await file.exists()) {
      return jsonDecode(await file.readAsString());
    }

    return jsonDecode("{}");
  }

  void _write(String key, dynamic value) {
    Map<String, dynamic> content = {key: value};

    if (value == null) {
      this._content.remove(key);
      print("removed $key from the $name file.");
    } else {
      this._content.addAll(content);
      print("added $key to the $name file.");
    }
  }

  /// Adds something to the file. To delete something, simply make the value to
  /// null. The method returns a boolean, when something happens. It returns
  /// false when the file does not exists.
  Future<bool> write(String key, dynamic value) async {
    final file = await _getFile;

    if (await file.exists()) {
      this._content = await getContentAsMap;
      _write(key, value);
      file.writeAsString(jsonEncode(this._content));
      print("Finished editing the $name file.");
      return true;
    }

    return false;
  }

  /// Adds something to the file. To delete something, simply make the value to
  /// null. The method returns a boolean, when something happens. It returns
  /// false when the file does not exists.
  Future<bool> writeAll(Map<String, dynamic> content) async {
    final file = await _getFile;

    if (await file.exists()) {
      this._content = await getContentAsMap;
      content.forEach((key, value) => _write(key, value));
      file.writeAsString(jsonEncode(this._content));
      print("Finished editing the $name file.");
      return true;
    }

    return false;
  }
}
