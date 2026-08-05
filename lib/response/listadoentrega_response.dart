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
  ListadoEntregaResponse(
      {this.cuartel,
      this.labor,
      this.cantidad,
      this.nombre,
      this.idcartilla,
      this.identrega,
      this.qr,
      this.rut,
      this.digito,
      this.swsincronizado});

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
          swsincronizado: json["SwSincronizado"]?.toString());

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
        "SwSincronizado": swsincronizado
      };
}
