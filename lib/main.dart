import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:grill_probe/pages/main.dart';
import 'package:grill_probe/pages/request_permissions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:system_theme/system_theme.dart';

void main() async {
  await SystemTheme.accentColor.load();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<bool>> permissions;
  final _ble = FlutterReactiveBle();

  Future<bool> initBle() async {
    // First result is always unknown 🤷🏻‍♂️
    final status = await _ble.statusStream.elementAt(1);
    return (status == BleStatus.ready);
  }

  @override
  void initState() {
    super.initState();
    final futures = [
      Permission.location.isGranted,
      Permission.bluetoothScan.isGranted,
      Permission.bluetoothConnect.isGranted,
      initBle(),
    ];

    permissions = Future.wait(futures);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grill Probe',
      theme: ThemeData(
          colorSchemeSeed: SystemTheme.accentColor.accent,
          useMaterial3: true,
          brightness: Brightness.light),
      darkTheme: ThemeData(
          colorSchemeSeed: SystemTheme.accentColor.accent,
          useMaterial3: true,
          brightness: Brightness.dark),
      home: FutureBuilder<List<bool>>(
        future: permissions,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.contains(false)) {
              return const RequestPermissionsPage();
            }

            return const MainPage();
          }

          return const Scaffold();
        },
      ),
    );
  }
}
