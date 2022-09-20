import 'dart:developer' as dev;

import 'package:flutter/material.dart';

import 'esp_file.dart';
import 'home.dart';
import 'http_client.dart';
import 'image_upload.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EPaper Station',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      // home: const FileEditor(),
      // home: const TagOverview(),
      home: const Home(),
    );
  }
}

class FileEditor extends StatefulWidget {
  final String host;
  const FileEditor({Key? key, required this.host}) : super(key: key);

  @override
  State<FileEditor> createState() => _FileEditorState();
}

class _FileEditorState extends State<FileEditor> {
  late final Future<List<ESPFile>> files;

  @override
  void initState() {
    files = getFiles(widget.host);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Editor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload),
            onPressed: () => ImageUpload.fromDevice(context, widget.host, null),
          ),
        ],
      ),
      body: FutureBuilder<List<ESPFile>>(
        future: files,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final ESPFile file = snapshot.data![index];
                return ListTile(
                  title: Text(file.name),
                  subtitle: Text('${file.type} (${file.size.toString()} b)'),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FileDetail(fileName: file.name),
                      )),
                );
              },
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class FileDetail extends StatefulWidget {
  final String fileName;
  const FileDetail({Key? key, required this.fileName}) : super(key: key);

  @override
  State<FileDetail> createState() => _FileDetailState();
}

class _FileDetailState extends State<FileDetail> {
  @override
  void initState() {
    getFile('', widget.fileName).then((value) => dev.log(value));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Editor'),
      ),
      body: const CircularProgressIndicator(),
    );
  }
}
