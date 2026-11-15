import 'package:flutter/material.dart';

/// Asks the user to confirm the detected coordinates. Returns true on "Yes".
Future<bool> showConfirmLocationDialog(
    BuildContext context, double lat, double lon) async {
  final ok = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text('Confirm location'),
      content: Text('Your exact location has latitude ${lat.toStringAsFixed(5)} '
          'and longitude ${lon.toStringAsFixed(5)}. Do you wish to continue?'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
        FilledButton(
            onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes')),
      ],
    ),
  );
  return ok ?? false;
}
