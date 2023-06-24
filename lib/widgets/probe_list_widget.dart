import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:grill_probe/log.dart';
import 'package:grill_probe/probes/probe.dart';
import 'package:grill_probe/widgets/probe_widget.dart';

class ProbeListWidget extends StatefulWidget {
  const ProbeListWidget({super.key});

  @override
  State<ProbeListWidget> createState() => _ProbeListWidgetState();
}

class _ProbeListWidgetState extends State<ProbeListWidget> {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  final SplayTreeMap<String, Probe> _devices = SplayTreeMap();

  late final StreamSubscription<DiscoveredDevice> _scanStream;
  late final Timer _refreshTimer;

  @override
  void initState() {
    super.initState();

    _scanStream = _ble.scanForDevices(withServices: [
      Uuid.parse("0000fb00-0000-1000-8000-00805f9b34fb"),
    ]).listen(
      (device) {
        logger.i(
          "Found device: ${device.id} ${device.name} ${device.serviceUuids}",
        );

        setState(() {
          _devices.putIfAbsent(
            device.id,
            () => Probe(device, () {
              setState(() {});
            }),
          );
        });
      },
      onError: (Object error, StackTrace stackTrace) {
        logger.e(error);
      },
      onDone: () {
        logger.i("Done scanning!");
      },
    );

    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      // Update state if devices are invisible.
      setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    _scanStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
            for (var device in _devices.values.where((e) => e.isConnected))
              ProbeWidget(device)
          ] +
          [
            for (var device in _devices.values
                .where((e) => (!e.isConnected) && !(e.isTimedOut)))
              ProbeWidget(device)
          ] +
          [
            for (var device in _devices.values
                .where((e) => (!e.isConnected) && e.isTimedOut))
              ProbeWidget(device)
          ],
    );
  }
}
