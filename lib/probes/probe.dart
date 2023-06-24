import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:grill_probe/log.dart';

class Probe {
  static const Duration _validityTimeout = Duration(seconds: 10);
  static const Duration _connectionTimeout = Duration(seconds: 3);
  static final Uuid _temperatureCharactestic =
      Uuid.parse("0000fb02-0000-1000-8000-00805f9b34fb");
  static final Uuid _temperatureService =
      Uuid.parse("0000fb00-0000-1000-8000-00805f9b34fb");

  static final FlutterReactiveBle _ble = FlutterReactiveBle();

  final DiscoveredDevice device;
  final Function _onStateChange;

  DeviceConnectionState connectionState = DeviceConnectionState.disconnected;

  StreamSubscription<ConnectionStateUpdate>? _connectionStateSubscription;
  StreamSubscription<List<int>>? _temperaturesSubscription;

  double _innerTemperature = 0;
  double _outerTemperature = 0;

  Probe(this.device, this._onStateChange);

  bool get isConnected => connectionState == DeviceConnectionState.connected;
  bool get isTimedOut => _ble.scanRegistry.deviceIsDiscoveredRecently(
      deviceId: device.id, cacheValidity: _validityTimeout);
  double get innerTemperature => _innerTemperature;
  double get outerTemperature => _outerTemperature;

  void dispose() {
    logger.d("[${device.id}] Disposing.");
    _temperaturesSubscription?.cancel();
    _temperaturesSubscription = null;
    _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;
  }

  void connect() {
    logger.d("[${device.id}] Connecting.");
    _connectionStateSubscription = _ble
        .connectToDevice(id: device.id, connectionTimeout: _connectionTimeout)
        .listen(
          _onConnectionStateUpdate,
          onError: _onConnectionStateError,
          cancelOnError: true,
          onDone: _onConnectionStateDone,
        );
    connectionState = DeviceConnectionState.connecting;
  }

  void disconnect() {
    logger.d("[${device.id}] Disconnecting.");
    _temperaturesSubscription?.cancel();
    _temperaturesSubscription = null;
    _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;
    connectionState = DeviceConnectionState.disconnected;
    _onStateChange();
  }

  void _onConnectionStateUpdate(ConnectionStateUpdate connectionStateUpdate) {
    logger.d(
      "[${device.id}] "
      "Got connection state update [${connectionStateUpdate.connectionState}]",
    );

    if (connectionStateUpdate.failure != null) {
      logger.e(
          "[${device.id}] Connection failed: [${connectionStateUpdate.failure!.message}]");
      disconnect();
      return;
    }

    final newConnectionState = connectionStateUpdate.connectionState;

    if (newConnectionState == DeviceConnectionState.disconnected ||
        newConnectionState == DeviceConnectionState.disconnecting) {
      logger.wtf("[${device.id}] Disconnecting?!?!?!");
      disconnect();
      return;
    }

    connectionState = newConnectionState;
    _onStateChange();

    if (connectionState == DeviceConnectionState.connected &&
        _temperaturesSubscription == null) {
      _temperaturesSubscription = _ble
          .subscribeToCharacteristic(
            QualifiedCharacteristic(
                characteristicId: _temperatureCharactestic,
                serviceId: _temperatureService,
                deviceId: device.id),
          )
          .listen(_onTemperatureRead,
              onError: _onTemperatureReadError,
              cancelOnError: true,
              onDone: _onTemperatureReadDone);
    }
  }

  void _onConnectionStateError(Object error) {
    logger.e("[${device.id}] Got connection error: $error");
    disconnect();
  }

  void _onConnectionStateDone() {
    logger.w("[${device.id}] Connection done.");
    disconnect();
  }

  void _onTemperatureRead(List<int> data) {
    final dataHex = data.map((e) {
      return "0x${e.toRadixString(16)}";
    });

    logger.v(
      "[${device.id}] Received temperature reading: $dataHex",
    );

    if (data.length != 7) {
      logger.e(
        "[${device.id}] "
        "Unexpected temperature data length: [${data.length}], "
        "(expected 7), "
        "data: [$dataHex]",
      );
    }

    var innerTemperature = _convertBytesToTemperature(data.sublist(2, 4));
    var outerTemperature = _convertBytesToTemperature(data.sublist(4, 6));

    logger.d(
      "[${device.id}] "
      "Inner temperature: $innerTemperature, "
      "Outer temperature: $outerTemperature",
    );

    _innerTemperature = innerTemperature;
    _outerTemperature = outerTemperature;

    _onStateChange();
  }

  void _onTemperatureReadError(Object error) {
    logger.e("[${device.id}] Got temperature read error: [$error]");
    disconnect();
  }

  void _onTemperatureReadDone() {
    logger.w("[${device.id}] Temperature read done.");
    disconnect();
  }

  static double _convertBytesToTemperature(List<int> data) {
    var uint8List = Uint8List.fromList(data);
    return ByteData.view(uint8List.buffer).getInt16(0, Endian.little) / 10.0 -
        40.0;
  }
}
