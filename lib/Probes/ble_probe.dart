import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:grill_probe/log.dart' show logger;

class BleProbeList extends StatefulWidget {
  BleProbeList({super.key});

  @override
  State<BleProbeList> createState() => _BleProbeListState();
}

class _BleProbeListState extends State<BleProbeList> {
  final Map<String, BleProbe> devices = {};
  final FlutterReactiveBle _ble = FlutterReactiveBle();

  @override
  void initState() {
    super.initState();

    final stream = _ble.scanForDevices(withServices: [
      // Uuid.parse("0000fb00-0000-1000-8000-00805f9b34fb"),
      // Uuid.parse("0000fb02-0000-1000-8000-00805f9b34fb"),
      // Uuid.parse("0000fb03-0000-1000-8000-00805f9b34fb"),
      // Uuid.parse("0000fb05-0000-1000-8000-00805f9b34fb"),
    ]).listen(
      (device) {
        logger.i(
            "Found device: ${device.id} ${device.name} ${device.serviceUuids}");

        setState(() {
          devices.putIfAbsent(
            device.id,
            () => BleProbe(device),
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
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [for (var device in devices.values) device],
    );
  }
}

class BleProbe extends StatefulWidget {
  final DiscoveredDevice _device;

  BleProbe(this._device, {super.key});

  @override
  State<BleProbe> createState() => _BleProbeState();
}

class _BleProbeState extends State<BleProbe> {
  DeviceConnectionState _connectionState = DeviceConnectionState.disconnected;

  final FlutterReactiveBle _ble = FlutterReactiveBle();
  final Duration timeout = const Duration(seconds: 10);
  late Timer refreshTimer;

  late StreamSubscription<ConnectionStateUpdate> _connectionStreamSubscription;

  get connectionState => _connectionState;

  @override
  void initState() {
    super.initState();

    refreshTimer = Timer.periodic(const Duration(seconds: 5), (Timer t) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    refreshTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Color background, foreground;

    if (_connectionState == DeviceConnectionState.connected) {
      background = colorScheme.primaryContainer;
      foreground = colorScheme.onPrimaryContainer;
    } else if (_ble.scanRegistry.deviceIsDiscoveredRecently(
        deviceId: widget._device.id, cacheValidity: timeout)) {
      background = colorScheme.secondaryContainer;
      foreground = colorScheme.onSecondaryContainer;
    } else {
      background = colorScheme.surfaceVariant;
      foreground = colorScheme.onSurfaceVariant;
    }

    final textStyle = theme.textTheme.titleMedium!.copyWith(color: foreground);

    return Card(
      color: background,
      child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextButton(
            child: Text(
              widget._device.name.isEmpty
                  ? widget._device.id
                  : widget._device.name,
              style: textStyle,
            ),
            onPressed: () {
              if (_connectionState == DeviceConnectionState.connected) {
                disconnect();
                return;
              }
              connect();
            },
          )),
    );
  }

  void connect() {
    _connectionStreamSubscription = _ble
        .connectToDevice(id: widget._device.id)
        .listen(_onConnectionStateUpdate);
  }

  void disconnect() {
    _connectionStreamSubscription.cancel();
    setState(() {
      _connectionState = DeviceConnectionState.disconnected;
    });

    refreshTimer = Timer.periodic(const Duration(seconds: 5), (Timer t) {
      setState(() {});
    });
  }

  void _onConnectionStateUpdate(ConnectionStateUpdate connectionStateUpdate) {
    setState(() {
      _connectionState = connectionStateUpdate.connectionState;
    });

    if (_connectionState == DeviceConnectionState.connected) {
      refreshTimer.cancel();
    }
  }
}
