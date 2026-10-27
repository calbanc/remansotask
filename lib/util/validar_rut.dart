String? validarDocumento(String? input, {required bool validarRutChile}) {
  if (input == null || input.trim().isEmpty) return 'Debe ingresar un rut';
  if (validarRutChile) {
    return validarRut(input) ? null : 'Debe ingresar un rut valido';
  }

  try {
    final documento = separarDocumento(input);
    if (documento.rut.length == 8) return null;
  } on FormatException {
    // El formato es obligatorio aunque no se compruebe el módulo chileno.
  }
  return 'Ingrese 8 dígitos y un DV (ej. 12345678-4)';
}

bool esRutParaGuardar(String? rut) =>
    rut != null &&
    rut.isNotEmpty &&
    rut.length <= 8 &&
    !RegExp(r'[^0-9]').hasMatch(rut);

void asegurarRutParaGuardar(String? rut) {
  if (!esRutParaGuardar(rut)) {
    throw const FormatException(
      'Rut debe contener entre 1 y 8 dígitos, sin puntos, guion ni letras.',
    );
  }
}

({String rut, String digito}) separarDocumento(String input) {
  final documento = input.trim().toUpperCase();
  if (!_formatoRut.hasMatch(documento)) {
    throw const FormatException('Ingrese un RUT de hasta 8 dígitos y su DV.');
  }

  final normalizado = documento
      .toUpperCase()
      .replaceAll('.', '')
      .replaceAll('-', '');
  final cuerpo = normalizado.substring(0, normalizado.length - 1);
  asegurarRutParaGuardar(cuerpo);
  return (rut: cuerpo, digito: normalizado.substring(normalizado.length - 1));
}

final _formatoRut = RegExp(
  r'^([0-9]{1,8}-?[0-9K]|[0-9]{1,2}(\.[0-9]{3}){1,2}-[0-9K])$',
);

bool validarRut(String? rutIngresado) {
  if (rutIngresado == null) return false;

  var rut = rutIngresado.trim().toUpperCase();
  if (!_formatoRut.hasMatch(rut)) return false;

  rut = rut.replaceAll('.', '').replaceAll('-', '');
  final cuerpo = rut.substring(0, rut.length - 1);
  final dvIngresado = rut.substring(rut.length - 1);
  if (cuerpo.isEmpty || cuerpo.length > 8 || int.parse(cuerpo) == 0) {
    return false;
  }

  var suma = 0;
  var multiplicador = 2;
  for (var posicion = cuerpo.length - 1; posicion >= 0; posicion--) {
    suma += int.parse(cuerpo[posicion]) * multiplicador;
    multiplicador = multiplicador == 7 ? 2 : multiplicador + 1;
  }

  final resultado = 11 - (suma % 11);
  final dvCalculado = switch (resultado) {
    11 => '0',
    10 => 'K',
    _ => resultado.toString(),
  };
  return dvIngresado == dvCalculado;
}
