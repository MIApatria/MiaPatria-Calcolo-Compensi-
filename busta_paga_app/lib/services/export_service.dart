import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/busta_paga.dart';

/// Esporta lo storico delle buste paga in un file JSON, per un backup
/// manuale che l'utente può salvare dove preferisce (nessun caricamento
/// automatico su servizi cloud).
class ExportService {
  Future<File> esportaJson(List<BustaPaga> buste) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/backup_buste_paga.json');
    final data = buste
        .map((b) => {
              ...b.toMap(),
              'voci': b.voci.map((v) => v.toMap()).toList(),
            })
        .toList();
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(data),
    );
    return file;
  }

  Future<void> condividiBackup(List<BustaPaga> buste) async {
    final file = await esportaJson(buste);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Backup buste paga CIRFOOD',
      ),
    );
  }
}
