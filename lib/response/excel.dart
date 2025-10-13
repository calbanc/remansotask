class Excelreport {
  String? idAndroidCartilla;
  String? codEnv;
  String? nomEspecie;
  String? nomVariedad;
  String? nomCuartel;
  String? nomContratista;
  String? nomActividad;

  String? qr;
  double? cantidad;
  String? fecha;
  String? hora;

  String rut;
  String? digito;
  String nombre;

  Excelreport({
    this.idAndroidCartilla,
    this.codEnv,
    this.nomEspecie,
    this.nomVariedad,
    this.nomCuartel,
    this.nomContratista,
    this.nomActividad,

    this.qr,
    this.cantidad,
    this.fecha,
    this.hora,

    required this.nombre,
    required this.rut,
    this.digito,
  });

  factory Excelreport.fromMap(Map<String, dynamic> json) => Excelreport(
    idAndroidCartilla: json["IdAndroidCartilla"],
    codEnv: json["COD_ENV"],
    nomEspecie: json["NomEspecie"],
    nomVariedad: json["NomVariedad"],
    nomCuartel: json["NomCuartel"],
    nomContratista: json["NomContratista"],
    nomActividad: json["NomActividad"],
    qr: json["Qr"],
    cantidad: json["Cantidad"],
    fecha: json["Fecha"],
    hora: json["Hora"],
    rut: json["Rut"],
    digito: json["Digito"],
    nombre: json["Nombre"],
  );

  Map<String, dynamic> toMap() => {
    "IdAndroidCartilla": idAndroidCartilla,
    "COD_ENV": codEnv,
    "NomEspecie": nomEspecie,
    "NomVariedad": nomVariedad,
    "NomCuartel": nomCuartel,
    "NomContratista": nomContratista,
    "NomActividad": nomActividad,
    "Qr": qr,
    "Cantidad": cantidad,
    "Fecha": fecha,
    "Hora": hora,
    "Rut": rut,
    "Digito": digito,
    "Nombre": nombre,
  };
}
