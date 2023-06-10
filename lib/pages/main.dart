import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:grill_probe/main.dart';
import 'package:logger/logger.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var devices = <String, DiscoveredDevice>{};
  final flutterReactiveBle = FlutterReactiveBle();

  @override
  void initState() {
    super.initState();

    final stream = flutterReactiveBle.scanForDevices(withServices: [
      Uuid.parse("0000fb00-0000-1000-8000-00805f9b34fb"),
      Uuid.parse("0000fb02-0000-1000-8000-00805f9b34fb"),
      Uuid.parse("0000fb03-0000-1000-8000-00805f9b34fb"),
      Uuid.parse("0000fb05-0000-1000-8000-00805f9b34fb"),
    ]).listen(
      (device) {
        logger.i(
            "Found device: ${device.id} ${device.name} ${device.serviceUuids}");

        if (devices.containsKey(device.id)) {
          return;
        }

        setState(() {
          devices[device.id] = device;
        });
      },
      onError: (Object error, StackTrace stackTrace) {
        logger.e(error, stackTrace);
      },
      onDone: () {
        logger.i("Done scanning!");
      },
    );

    // Future.delayed(const Duration(seconds: 10), () => stream.cancel());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
            child: ListView(
          children: [
            for (var device in devices.entries)
              Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextButton(
                    child: Text(device.key),
                    onPressed: () {
                      flutterReactiveBle
                          .connectToDevice(
                        id: device.value.id,
                      )
                          .listen((event) {
                        logger.i("Got some event: ${event}");
                      });
                    },
                  ))
          ],
        )),
      ),
    );
  }
}
