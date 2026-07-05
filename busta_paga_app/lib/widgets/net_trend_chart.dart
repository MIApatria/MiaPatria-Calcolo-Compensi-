import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/busta_paga.dart';

/// Grafico dell'andamento del netto in busta paga nel tempo.
class NetTrendChart extends StatelessWidget {
  final List<BustaPaga> buste;

  const NetTrendChart({super.key, required this.buste});

  @override
  Widget build(BuildContext context) {
    if (buste.length < 2) return const SizedBox.shrink();

    final ordinate = [...buste]
      ..sort((a, b) => (a.anno * 100 + a.mese).compareTo(b.anno * 100 + b.mese));

    final spots = <FlSpot>[
      for (var i = 0; i < ordinate.length; i++)
        FlSpot(i.toDouble(), ordinate[i].netto),
    ];

    final maxY = ordinate.map((b) => b.netto).reduce((a, b) => a > b ? a : b);
    final colore = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SizedBox(
        height: 180,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: maxY * 1.2,
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: (ordinate.length / 6).clamp(1, double.infinity),
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    if (i < 0 || i >= ordinate.length) return const SizedBox.shrink();
                    final b = ordinate[i];
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${b.mese.toString().padLeft(2, '0')}/${b.anno.toString().substring(2)}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: colore,
                barWidth: 3,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(show: true, color: colore.withOpacity(0.15)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
