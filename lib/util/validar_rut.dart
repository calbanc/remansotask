bool validarRut(String? rutIngresado) {
  if (rutIngresado == null) return false;

  var rut = rutIngresado.trim().toUpperCase();
  final patron = RegExp(
    r'^([0-9]{1,8}-?[0-9K]|[0-9]{1,2}(\.[0-9]{3}){1,2}-[0-9K])$',
  );
  if (!patron.hasMatch(rut)) return false;

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
