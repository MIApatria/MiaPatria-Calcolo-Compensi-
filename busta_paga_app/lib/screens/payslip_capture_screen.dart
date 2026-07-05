import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/ocr_service.dart';
import 'payslip_form_screen.dart';

/// Punto di ingresso per importare un nuovo cedolino: foto (fotocamera o
/// galleria) oppure file PDF, entrambi passati al servizio OCR.
class PayslipCaptureScreen extends StatefulWidget {
  const PayslipCaptureScreen({super.key});

  @override
  State<PayslipCaptureScreen> createState() => _PayslipCaptureScreenState();
}

class _PayslipCaptureScreenState extends State<PayslipCaptureScreen> {
  final OcrService _ocr = OcrService();
  bool _elaborazione = false;

  @override
  void dispose() {
    _ocr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Importa cedolino')),
      body: _elaborazione
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Riconoscimento del testo in corso...'),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text(
                  'Scegli come importare il cedolino. Potrai sempre correggere '
                  'a mano i valori riconosciuti prima di salvare.',
                ),
                const SizedBox(height: 24),
                _opzione(
                  icona: Icons.photo_camera_outlined,
                  titolo: 'Scatta una foto',
                  sottotitolo: 'Fotografa il cedolino cartaceo',
                  onTap: () => _daImmagine(ImageSource.camera),
                ),
                _opzione(
                  icona: Icons.photo_library_outlined,
                  titolo: 'Scegli dalla galleria',
                  sottotitolo: 'Usa una foto o uno screenshot già salvato',
                  onTap: () => _daImmagine(ImageSource.gallery),
                ),
                _opzione(
                  icona: Icons.picture_as_pdf_outlined,
                  titolo: 'Importa un PDF',
                  sottotitolo: 'Il cedolino ricevuto in formato PDF',
                  onTap: _daPdf,
                ),
                _opzione(
                  icona: Icons.edit_note,
                  titolo: 'Inserimento manuale',
                  sottotitolo: 'Compila tutti i campi a mano',
                  onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const PayslipFormScreen()),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _opzione({
    required IconData icona,
    required String titolo,
    required String sottotitolo,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icona, size: 32),
        title: Text(titolo),
        subtitle: Text(sottotitolo),
        onTap: onTap,
      ),
    );
  }

  Future<void> _daImmagine(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 95);
    if (file == null) return;

    setState(() => _elaborazione = true);
    try {
      final bozza = await _ocr.analizzaImmagine(file.path);
      _vaiAlForm(bozza, file.path);
    } finally {
      if (mounted) setState(() => _elaborazione = false);
    }
  }

  Future<void> _daPdf() async {
    final risultato = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    final path = risultato?.files.single.path;
    if (path == null) return;

    setState(() => _elaborazione = true);
    try {
      final bozza = await _ocr.analizzaPdf(path);
      _vaiAlForm(bozza, path);
    } finally {
      if (mounted) setState(() => _elaborazione = false);
    }
  }

  void _vaiAlForm(BozzaImportata bozza, String sorgentePath) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PayslipFormScreen(
          vociIniziali: bozza.voci,
          immaginePath: sorgentePath,
          origine: sorgentePath.toLowerCase().endsWith('.pdf') ? 'ocr_pdf' : 'ocr_foto',
        ),
      ),
    );
  }
}
