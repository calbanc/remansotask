import 'dart:convert';

class SyncEntregasResponse {
    int code;
    String status;
    String message;
    Cartilladetalle cartilladetalle;

    SyncEntregasResponse({
        required this.code,
        required this.status,
        required this.message,
        required this.cartilladetalle,
    });

    factory SyncEntregasResponse.fromJson(String str) => SyncEntregasResponse.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory SyncEntregasResponse.fromMap(Map<String, dynamic> json) => SyncEntregasResponse(
        code: json["code"],
        status: json["status"],
        message: json["message"],
        cartilladetalle: Cartilladetalle.fromJson(json["cartilladetalle"]),
    );

    Map<String, dynamic> toMap() => {
        "code": code,
        "status": status,
        "message": message,
        "cartilladetalle": cartilladetalle.toJson(),
    };
}

class Cartilladetalle {
    String idCartilla;
    String qr;
    String fecha;
    int cantidad;
    String nombreTrabajador;
    int idEntrega;

    Cartilladetalle({
        required this.idCartilla,
        required this.qr,
        required this.fecha,
        required this.cantidad,
        required this.nombreTrabajador,
        required this.idEntrega,
    });


    factory Cartilladetalle.fromJson(Map<String, dynamic> json) => Cartilladetalle(
        idCartilla: json["IdCartilla"],
        qr: json["Qr"],
        fecha: json["Fecha"],
        cantidad: json["Cantidad"],
        nombreTrabajador: json["Nombre_trabajador"],
        idEntrega: json["IdEntrega"],
    );

    Map<String, dynamic> toJson() => {
        "IdCartilla": idCartilla,
        "Qr": qr,
        "Fecha": fecha,
        "Cantidad": cantidad,
        "Nombre_trabajador": nombreTrabajador,
        "IdEntrega": idEntrega,
    };
}
