import 'package:flutter/material.dart';

class Blob extends StatelessWidget {
  const Blob({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!
        .copyWith(color: theme.colorScheme.onPrimary);

    return Row(
      children: [
        Expanded(
          child: Card(
            color: theme.colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Text(
                text,
                style: style,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
