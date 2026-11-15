import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/location_service.dart';
import '../confirm/confirm_dialog.dart';
import '../results/results_screen.dart';
import '../state/eto_provider.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  Future<void> _onGetLocation(BuildContext context) async {
    final provider = context.read<EtoProvider>();
    final navigator = Navigator.of(context);
    final ok = await provider.locate();
    if (!ok || !context.mounted) return;

    final proceed = await showConfirmLocationDialog(
        context, provider.latitude!, provider.longitude!);
    if (proceed && context.mounted) {
      navigator.push(MaterialPageRoute(builder: (_) => const ResultsScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EtoProvider>();
    final error = provider.locationError;
    return Scaffold(
      appBar: AppBar(title: const Text('Your Location')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.my_location, size: 72),
            const SizedBox(height: 16),
            const Text('Tap the button to detect your current location.',
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            if (provider.locating)
              const CircularProgressIndicator()
            else
              FilledButton.icon(
                icon: const Icon(Icons.location_searching),
                label: const Text('Get Location'),
                onPressed: () => _onGetLocation(context),
              ),
            if (error != null) ...[
              const SizedBox(height: 24),
              Text(error.message,
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.error)),
              if (error.problem == LocationProblem.serviceDisabled)
                TextButton(
                    onPressed: provider.locationService.openLocationSettings,
                    child: const Text('Open location settings')),
              if (error.problem == LocationProblem.deniedForever)
                TextButton(
                    onPressed: provider.locationService.openAppSettings,
                    child: const Text('Open app settings')),
            ],
          ],
        ),
      ),
    );
  }
}
