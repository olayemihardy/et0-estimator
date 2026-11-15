import 'package:flutter/material.dart';

import '../location/location_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.water_drop, size: 96, color: scheme.primary),
              const SizedBox(height: 24),
              Text('ETo Estimator',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              const Text(
                'Estimates today\'s reference evapotranspiration (ETo) for your '
                'location using the FAO-56 Penman-Monteith equation and '
                'Open-Meteo weather data.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              FilledButton.icon(
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Get Started'),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const LocationScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
