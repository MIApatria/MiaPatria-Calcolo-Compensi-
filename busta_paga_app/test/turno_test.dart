import 'package:busta_paga_cirfood/models/turno.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('oreNetteGiorno', () {
    test('turno singolo A: 4h45 lordi meno 15 min di pausa = 4h30', () {
      final ore = oreNetteGiorno([TipoTurno.a]);
      expect(ore, closeTo(4.5, 0.001));
    });

    test('turno singolo B: 4h45 lordi meno 15 min di pausa = 4h30', () {
      final ore = oreNetteGiorno([TipoTurno.b]);
      expect(ore, closeTo(4.5, 0.001));
    });

    test('doppio turno A+B: 9h30 lordi meno 45 min di pausa = 8h45', () {
      final ore = oreNetteGiorno([TipoTurno.a, TipoTurno.b]);
      expect(ore, closeTo(8.75, 0.001));
    });

    test('doppio turno B+U: 9h30 lordi meno 45 min di pausa = 8h45', () {
      final ore = oreNetteGiorno([TipoTurno.b, TipoTurno.u]);
      expect(ore, closeTo(8.75, 0.001));
    });

    test('nessun turno: 0 ore', () {
      expect(oreNetteGiorno([]), 0);
    });
  });

  group('isCombinazioneDoppioAmmessa', () {
    test('A+B è ammessa', () {
      expect(isCombinazioneDoppioAmmessa(TipoTurno.a, TipoTurno.b), isTrue);
    });

    test('B+U è ammessa', () {
      expect(isCombinazioneDoppioAmmessa(TipoTurno.b, TipoTurno.u), isTrue);
    });

    test('A+U non è ammessa', () {
      expect(isCombinazioneDoppioAmmessa(TipoTurno.a, TipoTurno.u), isFalse);
    });
  });
}
