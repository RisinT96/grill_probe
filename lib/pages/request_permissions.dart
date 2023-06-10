import 'package:flutter/material.dart';
import 'package:grill_probe/pages/main.dart';
import 'package:permission_handler/permission_handler.dart';

class RequestPermissionsPage extends StatelessWidget {
  const RequestPermissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final textStyle = theme.textTheme.displaySmall!.copyWith(
      color: colorScheme.onBackground,
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'The following permissions are required:',
                style: textStyle,
              ),
            ),
            const ListTile(
              leading: Icon(Icons.circle),
              title: Text("Bluetooth"),
              subtitle: Text("Blah blah blach blach"),
            ),
            Card(
              color: colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () {
                    [
                      Permission.location,
                      Permission.bluetoothScan,
                      Permission.bluetoothConnect,
                    ].request().then(
                      (value) {
                        if (!value.containsValue(PermissionStatus.denied)) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MainPage()),
                          );
                        }
                      },
                    );
                  },
                  child: Text(
                    "Okay!",
                    style: textStyle.copyWith(color: colorScheme.onPrimary),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
