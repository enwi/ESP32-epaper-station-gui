import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:epaper_station/main.dart';
import 'package:epaper_station/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'http_client.dart';
import 'image_upload.dart';

enum TagType {
  /// Unknown type
  UNKNOWN,

  /// 1
  HW_TYPE_42_INCH_SAMSUNG,

  /// 2
  HW_TYPE_74_INCH_DISPDATA,

  /// 3
  HW_TYPE_74_INCH_DISPDATA_FRAME_MODE,

  /// 4
  HW_TYPE_ZBD_EPOP50,

  /// 5
  HW_TYPE_ZBD_EPOP900,

  /// 6
  HW_TYPE_29_INCH_DISPDATA,

  /// 7
  HW_TYPE_29_INCH_DISPDATA_FRAME_MODE,

  ///8
  HW_TYPE_29_INCH_ZBS_026,

  /// 9
  HW_TYPE_29_INCH_ZBS_026_FRAME_MODE,

  /// 10
  HW_TYPE_29_INCH_ZBS_025,

  /// 11
  HW_TYPE_29_INCH_ZBS_025_FRAME_MODE,

  /// 12
  HW_TYPE_154_INCH_ZBS_033,
}

extension EinkClutExtension on TagType {
  static TagType deserialize(final int type) {
    switch (type) {
      case 1:
        return TagType.HW_TYPE_42_INCH_SAMSUNG;
      case 2:
        return TagType.HW_TYPE_74_INCH_DISPDATA;
      case 3:
        return TagType.HW_TYPE_74_INCH_DISPDATA_FRAME_MODE;
      case 4:
        return TagType.HW_TYPE_ZBD_EPOP50;
      case 5:
        return TagType.HW_TYPE_ZBD_EPOP900;
      case 6:
        return TagType.HW_TYPE_29_INCH_DISPDATA;
      case 7:
        return TagType.HW_TYPE_29_INCH_DISPDATA_FRAME_MODE;
      case 8:
        return TagType.HW_TYPE_29_INCH_ZBS_026;
      case 9:
        return TagType.HW_TYPE_29_INCH_ZBS_026_FRAME_MODE;
      case 10:
        return TagType.HW_TYPE_29_INCH_ZBS_025;
      case 11:
        return TagType.HW_TYPE_29_INCH_ZBS_025_FRAME_MODE;
      case 12:
        return TagType.HW_TYPE_154_INCH_ZBS_033;

      default:
        return TagType.UNKNOWN;
    }
  }
}

// {"src":"22:00:00:00:00:00:00:01","state":{"batteryMv":2600,"hwType":8,"swVer":1172526071808},"lastPacketLQI":83,"lastPacketRSSI":-64,"rfu":"","temperature":148,"lastSeen":1663512547}
class TagState {
  double batteryVoltage;
  final TagType hardwareType;
  int softwareVersion;
  int lqi;
  int rssi;
  String rfu;
  int temperature;
  DateTime lastSeen;

  TagState(
      {required this.batteryVoltage,
      required this.hardwareType,
      required this.softwareVersion,
      required this.lqi,
      required this.rssi,
      required this.rfu,
      required this.temperature,
      required this.lastSeen});

  factory TagState.fromJson(final Map<String, dynamic> json) => TagState(
        batteryVoltage: (json['state']['batteryMv'] as int) / 1000,
        hardwareType: EinkClutExtension.deserialize(json['state']['hwType']),
        softwareVersion: json['state']['swVer'],
        lqi: json['lastPacketLQI'],
        rssi: json['lastPacketRSSI'],
        rfu: json['rfu'],
        temperature: json['temperature'],
        lastSeen: DateTime.fromMillisecondsSinceEpoch(json['lastSeen'] * 1000),
      );
}

class Tag {
  String name;

  int? imageFileVersion;
  Future<Image>? image;

  int? stateFileVersion;
  String? imageFilename;
  TagState? state;

  Tag({required this.name});
}

class TagOverview extends StatefulWidget {
  final String host;
  const TagOverview(this.host, {Key? key}) : super(key: key);

  @override
  State<TagOverview> createState() => _TagOverviewState();
}

class _TagOverviewState extends State<TagOverview> with WidgetsBindingObserver {
  // late Future<List<ESPFile>> files;
  Map<String, Tag> tags = {};
  Timer? _updateTimer = null;

  void updateTags() {
    getFiles(widget.host).then((files) {
      for (final file in files) {
        final parts = file.name.split('.');
        final name = parts.first;
        final type = parts.last.toLowerCase();
        switch (type) {
          case 'bmp':
            if (!tags.containsKey(name)) {
              tags[name] = Tag(name: name);
            }

            final tag = tags[name]!;

            if (file.version != tag.imageFileVersion) {
              log('Fetching image');
              tag.imageFileVersion = file.version;
              tag.imageFilename = file.name;
              tag.image =
                  getFile(widget.host, file.name).then((file) => Image.memory(
                        Uint8List.fromList(file.codeUnits),
                      ));
            }
            break;
          case 'json':
            if (name.startsWith('state_')) {
              final tagName = name.substring(6);
              if (!tags.containsKey(tagName)) {
                tags[tagName] = Tag(name: tagName);
              }

              final tag = tags[tagName]!;

              if (file.version != tag.stateFileVersion) {
                log('Fetching state');
                tag.stateFileVersion = file.version;
                getFile(widget.host, file.name)
                    .then((file) => TagState.fromJson(jsonDecode(file)))
                    .then((value) => setState(() => tag.state = value));
              }
            }
            break;
        }
      }
      setState(() {});
    });
  }

  void startUpdateTimer() {
    if (_updateTimer != null) {
      return;
    }
    _updateTimer = Timer.periodic(
      const Duration(seconds: 10),
      (timer) => updateTags(),
    );
  }

  void stopUpdateTimer() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  @override
  void initState() {
    updateTags();

    super.initState();
    WidgetsBinding.instance.addObserver(this);
    log(WidgetsBinding.instance.lifecycleState?.name ?? 'unknown');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        stopUpdateTimer();
        break;
      case AppLifecycleState.resumed:
        startUpdateTimer();
        break;

      default:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    stopUpdateTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceData = MediaQuery.of(context);
    final screenSize = deviceData.size;
    final count = calcCrossAxisCount(screenSize, 350);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tags'),
      ),
      body: MasonryGridView.count(
        key: ObjectKey(count),
        crossAxisCount: count,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        itemCount: tags.length,
        itemBuilder: (context, index) {
          final tag = tags.values.elementAt(index);
          return Card(
            clipBehavior: Clip.antiAlias,
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    children: [
                      ListTile(
                        title: Text(tag.name),
                        subtitle: Text(constraints.toString()),
                        // subtitle: Text(
                        //   '${tag.imageFileVersion != null ? 'img v${tag.imageFileVersion}' : ''}\n${tag.stateFileVersion != null ? 'sta  v${tag.stateFileVersion}' : ''}',
                        //   style: TextStyle(color: Colors.black.withOpacity(0.6)),
                        // ),
                        trailing: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: tag.state == null ||
                                    tag.state!.lastSeen
                                            .difference(DateTime.now())
                                            .inMinutes <
                                        -60
                                ? Colors.red
                                : Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      ExpansionTile(
                        // isExpanded: tag.expanded,
                        trailing: tag.state == null
                            ? const CircularProgressIndicator()
                            : null,
                        title: Text(tag.state == null
                            ? 'State unknown'
                            : 'Last seen ${timeago.format(tag.state!.lastSeen)}'),
                        expandedAlignment: Alignment.centerLeft,
                        expandedCrossAxisAlignment: CrossAxisAlignment.start,
                        childrenPadding: const EdgeInsets.only(
                            left: 16, right: 16, bottom: 16),
                        children: tag.state == null
                            ? []
                            : [
                                Text(tag.state!.hardwareType.name),
                                Text('v${tag.state!.softwareVersion}'),
                                Text('${tag.state!.batteryVoltage} V'),
                                Text('${tag.state!.temperature} °C'),
                                Text('LQI:  ${tag.state!.lqi}'),
                                Text('RSSI: ${tag.state!.rssi}'),
                                Text('RFU:  ${tag.state!.rfu}'),
                              ],
                      ),

                      // space for image
                      // Container(
                      //   height: 110,
                      // ),

                      SizedBox(
                        height: 110,
                        child: FutureBuilder<Image>(
                          future: tag.image,
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              return Transform.scale(
                                scale: 2,
                                child: Transform.rotate(
                                  angle: math.pi / 180 * -90,
                                  child: snapshot.data!,
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(snapshot.error.toString()),
                              );
                            }
                            return const Center(
                                child: CircularProgressIndicator());
                          },
                        ),
                      ),

                      ButtonBar(
                        alignment: MainAxisAlignment.start,
                        children: [
                          TextButton(
                            onPressed: () => ImageUpload.fromDevice(
                                context, widget.host, '/${tag.name}.bmp'),
                            child: const Text('CHANGE IMAGE'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Positioned(
                  //   // left: 200,
                  //   top: 145,
                  //   child: FutureBuilder<Image>(
                  //     future: tag.image,
                  //     builder: (context, snapshot) {
                  //       if (snapshot.hasData && snapshot.data != null) {
                  //         return Transform.rotate(
                  //           angle: math.pi / 180 * -90,
                  //           // origin: Offset(-42, -42),
                  //           child: snapshot.data!,
                  //         );
                  //       }
                  //       if (snapshot.hasError) {
                  //         return Center(
                  //           child: Text(snapshot.error.toString()),
                  //         );
                  //       }
                  //       return const Center(child: CircularProgressIndicator());
                  //     },
                  //   ),
                  // ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
