import 'dart:convert';

class ListadoEntregaResponse {
  String? cuartel;
  String? labor;
  double? cantidad;
  String? nombre;
  String? idcartilla;
  int? identrega;
  String? qr;
  String? rut;
  String? digito;
  String? swsincronizado;
  int swExtranjeroSinDocumento;
  ListadoEntregaResponse({
    this.cuartel,
    this.labor,
    this.cantidad,
    this.nombre,
    this.idcartilla,
    this.identrega,
    this.qr,
    this.rut,
    this.digito,
    this.swsincronizado,
    this.swExtranjeroSinDocumento = 1,
  });

  factory ListadoEntregaResponse.fromJson(Map<String, dynamic> json) =>
      ListadoEntregaResponse(
        cuartel: json["NomCuartel"],
        labor: json["NomActividad"],
        nombre: json["Nombre"],
        cantidad: json["Cantidad"],
        idcartilla: json["IdAndroidCartilla"],
        identrega: json["IdEntrega"],
        qr: json["Qr"],
        rut: json["Rut"],
        digito: json["Digito"],
        swsincronizado: json["SwSincronizado"]?.toString(),
        swExtranjeroSinDocumento:
            int.tryParse('${json["SW_EXTRANJERO_SIN_DOCUMENTO"]}') ?? 1,
      );

  Map<String, dynamic> toJson() => {
    "NomCuartel": cuartel,
    "NomActividad": labor,
    "Nombre": nombre,
    "Cantidad": cantidad,
    "IdCartilla": idcartilla,
    "IdAndroidCartilla": identrega,
    "Qr": qr,
    "Rut": rut,
    "Digito": digito,
    "SwSincronizado": swsincronizado,
    "SW_EXTRANJERO_SIN_DOCUMENTO": swExtranjeroSinDocumento,
  };
}
