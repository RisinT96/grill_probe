import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:grill_probe/Probes/ble_probe.dart';
import 'package:grill_probe/log.dart' show logger;

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var devices = <String, BleProbe>{};
  final flutterReactiveBle = FlutterReactiveBle();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(child: BleProbeList()),
      ),
    );
  }
}
