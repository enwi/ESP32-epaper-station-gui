import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:http_auth/http_auth.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'esp_file.dart';

final httpClient = BasicAuthClient('admin', 'admin');

Future<List<ESPFile>> getFiles(final String host) => httpClient
    .get(
      Uri(
        scheme: 'http',
        host: host,
        path: 'edit',
        queryParameters: {
          'list': '/',
        },
      ),
      headers: {HttpHeaders.accessControlAllowOriginHeader: '*'},
    )
    .then((response) => jsonDecode(response.body) as List<dynamic>)
    .then((json) => ESPFile.parseJsonList(json))
    .catchError((error, stackTrace) => log(error.toString()));

Future<String> getFile(final String host, final String filename) =>
    httpClient.get(
      Uri(
        scheme: 'http',
        host: host,
        path: 'edit',
        queryParameters: {
          'download': filename,
        },
      ),
      headers: {'Access-Control-Allow-Origin': '*'},
    ).then((response) => response.body);

Future<bool> uploadFile(
    final String host, final String filename, final Uint8List file) {
  final request = http.MultipartRequest(
      'POST',
      Uri(
        scheme: 'http',
        host: host,
        path: 'edit',
      ));
  request.headers['Access-Control-Allow-Origin'] = '*';
  request.files.add(http.MultipartFile.fromBytes(
    'data',
    file,
    filename: filename,
    contentType: MediaType('image', 'bmp'),
  ));
  return httpClient
      .send(request)
      .then((response) => response.statusCode == 200);
}
