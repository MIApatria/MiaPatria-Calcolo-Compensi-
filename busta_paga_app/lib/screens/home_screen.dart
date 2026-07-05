import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/buste_paga_provider.dart';
import '../widgets/net_trend_chart.dart';
import '../widgets/payslip_card.dart';
import 'calendar_screen.dart';
import 'payslip_capture_screen.dart';
import 'payslip_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BustePagaProvider>().carica();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BustePagaProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Busta Paga CIRFOOD'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: 'Calendario turni',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CalendarScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Impostazioni',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: provider.inCaricamento
          ? const Center(child: CircularProgressIndicator())
          : provider.buste.isEmpty
              ? _statoVuoto(context)
              : RefreshIndicator(
                  onRefresh: provider.carica,
                  child: ListView(
                    children: [
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Andamento del netto',
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                      NetTrendChart(buste: provider.buste),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                        child: Text('Storico cedolini',
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                      ...provider.buste.map(
                        (b) => PayslipCard(
                          bustaPaga: b,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PayslipDetailScreen(bustaPaga: b),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nuovo cedolino'),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PayslipCaptureScreen()),
        ),
      ),
    );
  }

  Widget _statoVuoto(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Nessun cedolino ancora salvato',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Tocca "Nuovo cedolino" per importarne uno da foto, PDF oppure a mano.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
