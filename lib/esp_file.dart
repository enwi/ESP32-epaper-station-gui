// {"type":"file","name":"2200000000000001.bmp","size":151606}
class ESPFile {
  final String type;
  final String name;
  final int size;
  final int version;

  ESPFile(
      {required this.type,
      required this.name,
      required this.size,
      required this.version});

  factory ESPFile.fromJson(final Map<String, dynamic> json) => ESPFile(
      type: json['type'],
      name: json['name'],
      size: json['size'],
      version: json['ver']);

  static List<ESPFile> parseJsonList(final List<dynamic> json) {
    return json.map<ESPFile>((dynamic file) => ESPFile.fromJson(file)).toList();
  }
}
