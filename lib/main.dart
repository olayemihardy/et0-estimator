import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'presentation/state/eto_provider.dart';
import 'presentation/welcome/welcome_screen.dart';

void main() => runApp(const EtoApp());

class EtoApp extends StatelessWidget {
  const EtoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EtoProvider(),
      child: MaterialApp(
        title: 'ETo Estimator',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            secondary: Colors.blue,
          ),
        ),
        home: const WelcomeScreen(),
      ),
    );
  }
}
