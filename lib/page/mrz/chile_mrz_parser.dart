class ChileIdMrz {
  final String rutDigits; // solo números, sin DV
  final String dv; // 0-9 o K (calculado o leído)
  final String rutFormateado; // 12.345.678-K
  final String apellidoPaterno;
  final String? apellidoMaterno;
  final List<String> nombres;

  final String linea1, linea2, linea3; // crudo (útil para depurar)

  ChileIdMrz({
    required this.rutDigits,
    required this.dv,
    required this.rutFormateado,
    required this.apellidoPaterno,
    this.apellidoMaterno,
    required this.nombres,
    required this.linea1,
    required this.linea2,
    required this.linea3,
  });

  /// Returns all names joined by spaces
  String get nombresCompletos => nombres.join(' ');

  @override
  String toString() =>
      'RUT: $rutFormateado\n'
      'Apellido paterno: $apellidoPaterno\n'
      'Apellido materno: ${apellidoMaterno ?? ""}\n'
      'Nombres: $nombresCompletos';
}

class ChileMrzParser {
  /// Intenta encontrar las 3 líneas MRZ dentro de un texto OCR completo.
  /// Devuelve null si no logra identificar un bloque de 3 líneas válidas.
  static ChileIdMrz? parseFromOcr(String rawText) {
    // Normaliza a mayúsculas y quita basura
    final normalized =
        rawText
            .toUpperCase()
            .replaceAll(RegExp(r'[^\nA-Z0-9<]'), '')
            .split('\n')
            .map((l) => l.trim())
            .where((l) => l.isNotEmpty)
            // Líneas MRZ suelen tener muchas "<" y longitud >= 20
            .where((l) => RegExp(r'^[A-Z0-9<]{20,}$').hasMatch(l))
            .toList();

    if (normalized.length < 3) return null;

    // Heurística: toma las 3 últimas líneas largas (suelen estar al final)
    final l1 = normalized[normalized.length - 3];
    final l2 = normalized[normalized.length - 2];
    final l3 = normalized[normalized.length - 1];

    // ---- Línea 2: RUT ----
    // Busca "CHL" + dígitos (RUT) hasta el próximo '<'
    final rutMatch = RegExp(r'CHL(\d{5,10})<([0-9K])?').firstMatch(l2);
    if (rutMatch == null) return null;

    final rutDigits = rutMatch.group(1)!; // p.ej. "12749625"
    final afterLt = rutMatch.group(2); // podría ser DV del RUT o dígito MRZ
    // Calcula el DV real por módulo 11
    final dvCalc = _dvRut(rutDigits);
    // Si viene un carácter tras '<' y es [0-9K], úsalo solo si coincide con el cálculo.
    final dv = (afterLt != null && afterLt == dvCalc) ? afterLt : dvCalc;

    final rutFmt = _formatRut(rutDigits, dv);

    // ---- Línea 3: Nombres y apellidos ----
    // Formato: APELLIDOP<APELLIDOM<<NOMBRE1<NOMBRE2...
    final parts = l3.split('<<');
    final apellidosRaw = parts.isNotEmpty ? parts[0] : '';
    final nombresRaw = parts.length > 1 ? parts[1] : '';

    final apParts = apellidosRaw
        .split('<')
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
    final apellidoPaterno = apParts.isNotEmpty ? apParts[0] : '';
    final apellidoMaterno = apParts.length > 1 ? apParts[1] : null;

    final nombres = nombresRaw
        .split('<')
        .where((s) => s.isNotEmpty)
        .toList(growable: false);

    return ChileIdMrz(
      rutDigits: rutDigits,
      dv: dv,
      rutFormateado: rutFmt,
      apellidoPaterno: apellidoPaterno,
      apellidoMaterno: apellidoMaterno,
      nombres: nombres,
      linea1: l1,
      linea2: l2,
      linea3: l3,
    );
  }

  // Calcula DV chileno por módulo 11 (0–9 o K)
  static String _dvRut(String digits) {
    int sum = 0, m = 2;
    for (int i = digits.length - 1; i >= 0; i--) {
      sum += int.parse(digits[i]) * m;
      m = (m == 7) ? 2 : (m + 1);
    }
    final r = 11 - (sum % 11);
    if (r == 11) return '0';
    if (r == 10) return 'K';
    return r.toString();
  }

  static String _formatRut(String digits, String dv) {
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      // agrega puntos desde el final cada 3
      final revIndex = digits.length - i;
      buffer.write(digits[i]);
      if (revIndex > 1 && revIndex % 3 == 1) buffer.write('.');
    }
    return '${buffer.toString()}-$dv';
  }
}
