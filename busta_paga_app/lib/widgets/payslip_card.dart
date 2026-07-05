import 'package:flutter/material.dart';

import '../models/busta_paga.dart';
import '../utils/formatters.dart';

class PayslipCard extends StatelessWidget {
  final BustaPaga bustaPaga;
  final VoidCallback onTap;

  const PayslipCard({super.key, required this.bustaPaga, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final label =
        '${nomeMese(bustaPaga.mese)} ${bustaPaga.anno}'.trim();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            bustaPaga.mese.toString().padLeft(2, '0'),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(label.isEmpty ? bustaPaga.meseRiferimento : label),
        subtitle: Text(
          'Netto ${formattaEuro(bustaPaga.netto)}'
          '${bustaPaga.numeroDocumento.isNotEmpty ? ' · doc. ${bustaPaga.numeroDocumento}' : ''}',
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
