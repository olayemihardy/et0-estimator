import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/eto_provider.dart';
import '../widgets/read_only_field.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch after the first frame so notifyListeners is not called in build.
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<EtoProvider>().loadWeather());
  }

  void _showEtoDialog(double eto) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Result'),
        content: Text('Your evapotranspiration for your location: '
            '${eto.toStringAsFixed(2)} mm/day'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<EtoProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: switch (p.status) {
        LoadStatus.idle || LoadStatus.loading =>
          const Center(child: CircularProgressIndicator()),
        LoadStatus.error => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 64),
                  const SizedBox(height: 12),
                  Text(p.weatherError ?? 'Something went wrong.',
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                      onPressed: p.loadWeather, child: const Text('Retry')),
                ],
              ),
            ),
          ),
        LoadStatus.success => _buildResults(p),
      },
    );
  }

  Widget _buildResults(EtoProvider p) {
    final r = p.result!;
    final w = p.weather!;
    String f(double v, [int d = 2]) => v.toStringAsFixed(d);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Date: ${w.date.toIso8601String().substring(0, 10)}  |  '
            'Elevation: ${f(w.elevation, 0)} m'),
        const SizedBox(height: 8),
        ReadOnlyField(label: 'Tmax', value: f(r.tmax), unit: '°C'),
        ReadOnlyField(label: 'Tmin', value: f(r.tmin), unit: '°C'),
        ReadOnlyField(label: 'Tmean', value: f(r.tmean), unit: '°C'),
        ReadOnlyField(label: 'Mean relative humidity', value: f(r.rhMean, 1), unit: '%'),
        ReadOnlyField(label: 'Wind speed at 2 m (u2)', value: f(r.u2), unit: 'm/s'),
        ReadOnlyField(label: 'Solar radiation (Rs)', value: f(r.rs), unit: 'MJ/m²/day'),
        ReadOnlyField(label: 'Net radiation (Rn)', value: f(r.rn), unit: 'MJ/m²/day'),
        ReadOnlyField(label: 'Soil heat flux (G)', value: f(r.g), unit: 'MJ/m²/day'),
        ReadOnlyField(label: 'Saturation vapor pressure (es)', value: f(r.es, 3), unit: 'kPa'),
        ReadOnlyField(label: 'Actual vapor pressure (ea)', value: f(r.ea, 3), unit: 'kPa'),
        ReadOnlyField(label: 'Slope of vapor pressure curve (Δ)', value: f(r.delta, 4), unit: 'kPa/°C'),
        ReadOnlyField(label: 'Psychrometric constant (γ)', value: f(r.gamma, 4), unit: 'kPa/°C'),
        ReadOnlyField(
            label: 'Reference check: Open-Meteo ET0',
            value: w.openMeteoEt0 == null ? 'n/a' : f(w.openMeteoEt0!),
            unit: 'mm/day'),
        const SizedBox(height: 16),
        FilledButton.icon(
          icon: const Icon(Icons.calculate),
          label: const Text('Calculate'),
          onPressed: () => _showEtoDialog(r.eto),
        ),
      ],
    );
  }
}
