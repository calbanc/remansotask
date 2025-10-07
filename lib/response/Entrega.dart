import 'dart:convert';

class Entrega {
  int? identrega;
  String? idcartilla;
  String? qr;
  int? cantidad;
  String? fecha;
  String? hora;
  String? idempresa;
  String rut;
  String? digito;
  String nombre;
  String? IdTrabXContratista;
  String? swsincronizado;

  Entrega({
    this.identrega,
    this.idcartilla,
    this.qr,
    this.cantidad,
    this.fecha,
    this.hora,
    this.idempresa,
    required this.nombre,
    required this.rut,
    this.digito,
    this.IdTrabXContratista,
    this.swsincronizado,
  });

  factory Entrega.fromJson(Map<String, dynamic> json) => Entrega(
        identrega: json["IdEntrega"],
        idcartilla: json["IdAndroidCartilla"],
        qr: json["Qr"],
        cantidad: json["Cantidad"],
        fecha: json["Fecha"],
        hora: json["Hora"],
        rut: json["Rut"],
        digito: json["Digito"],
        nombre: json["Nombre"],
        idempresa: json["IdEmpresa"],
        IdTrabXContratista: json["IdTrabXContratista"],
        swsincronizado: json["SwSincronizado"],
      );

  Map<String, dynamic> toJson() => {
        "IdEntrega": identrega,
        "IdAndroidCartilla": idcartilla,
        "Qr": qr,
        "Cantidad": cantidad,
        "Fecha": fecha,
        "Hora": hora,
        "Rut": rut,
        "Digito": digito,
        "Nombre": nombre,
        "IdEmpresa": idempresa,
        "IdTrabXContratista": IdTrabXContratista,
        "SwSincronizado": swsincronizado,
      };
}
