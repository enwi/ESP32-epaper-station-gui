import 'package:epaper_station/ipaddress_formatter.dart';
import 'package:epaper_station/tag_overview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'http_client.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController ipController = TextEditingController();
  bool _connecting = false;

  void connect(final BuildContext context, final String ip) {
    setState(() {
      _connecting = true;
    });
    getFiles(ip).then((value) {
      SharedPreferences.getInstance()
          .then((value) => value.setString('ip', ip));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TagOverview(ip),
        ),
      );
    })
        // .timeout(const Duration(seconds: 5))
        .whenComplete(() => setState(() {
              _connecting = false;
            }));
  }

  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs) {
      final ip = prefs.getString('ip');
      if (ip != null) {
        ipController.text = ip;
        connect(context, ip);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          height: 150,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Connect to BaseStation'),
                  TextField(
                    autofocus: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                      LengthLimitingTextInputFormatter(15),
                      IpAddressInputFormatter(),
                    ],
                    controller: ipController,
                    enabled: !_connecting,
                    textAlign: TextAlign.center,
                  ),
                  _connecting
                      ? const CircularProgressIndicator()
                      : TextButton(
                          child: const Text('CONNECT'),
                          onPressed: () =>
                              connect(context, ipController.value.text),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
