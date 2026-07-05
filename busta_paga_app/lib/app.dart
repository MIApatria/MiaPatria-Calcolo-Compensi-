import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/buste_paga_provider.dart';
import 'providers/calendario_provider.dart';
import 'providers/impostazioni_provider.dart';
import 'screens/home_screen.dart';

class BustaPagaApp extends StatelessWidget {
  const BustaPagaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BustePagaProvider()),
        ChangeNotifierProvider(create: (_) => CalendarioProvider()),
        ChangeNotifierProvider(create: (_) => ImpostazioniProvider()..carica()),
      ],
      child: MaterialApp(
        title: 'Busta Paga CIRFOOD',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF2E7D32),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorSchemeSeed: const Color(0xFF2E7D32),
          brightness: Brightness.dark,
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
