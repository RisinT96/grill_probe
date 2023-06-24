import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:grill_probe/probes/probe.dart';

class ProbeWidget extends StatelessWidget {
  final Probe state;

  const ProbeWidget(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Color background, foreground;

    if (state.isConnected) {
      background = colorScheme.primaryContainer;
      foreground = colorScheme.onPrimaryContainer;
    } else if (!state.isTimedOut) {
      background = colorScheme.secondaryContainer;
      foreground = colorScheme.onSecondaryContainer;
    } else {
      background = colorScheme.surfaceVariant;
      foreground = colorScheme.onSurfaceVariant;
    }

    final nameStyle = theme.textTheme.titleMedium!.copyWith(color: foreground);
    final temperatureStyle =
        theme.textTheme.titleSmall!.copyWith(color: foreground);

    if (!state.isConnected) {
      // Disconnected
      return Card(
        color: background,
        child: TextButton(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              state.device.name.isEmpty ? state.device.id : state.device.name,
              style: nameStyle,
            ),
          ),
          onPressed: () {
            if (state.connectionState == DeviceConnectionState.connected) {
              state.disconnect();
              return;
            }
            state.connect();
          },
        ),
      );
    }

    // Connected
    return Card(
      color: background,
      child: Column(
        children: [
          TextButton(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                state.device.name.isEmpty ? state.device.id : state.device.name,
                style: nameStyle,
              ),
            ),
            onPressed: () {
              if (state.connectionState == DeviceConnectionState.connected) {
                state.disconnect();
                return;
              }
              state.connect();
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  state.innerTemperature.toString(),
                  style: temperatureStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  state.outerTemperature.toString(),
                  style: temperatureStyle,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
