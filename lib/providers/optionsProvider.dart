import 'dart:convert';
import 'dart:io';

import 'package:verfwork/providers/db_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../const/env.dart';
import '../response/CartillaQrResponse.dart';
import '../response/EnvaseResponse.dart';
import '../response/TrabajadorxContratista.dart';
import '../response/excel.dart';
import 'package:http/http.dart' as http;

class optionsProvider extends ChangeNotifier {
  static Database? _database;
  Future<Database> get database async => _database ??= await initDB();
  List<Excelreport> _listaexcel = [];
  List<Excelreport> get listaexcel => _listaexcel;
  String? idempresa;
  String? idcontratista;
  String? idzona;
  List<String> list = <String>['Masculino', 'Femenino'];
  List<Trabajadorxcontratista> _listatrabajadoresfilter = [];
  List<Trabajadorxcontratista> _listatrabajadores = [];
  List<Trabajadorxcontratista> get listatrabajadores => _listatrabajadores;
  List<Trabajadorxcontratista> get listatrabajadoresfilter =>
      _listatrabajadoresfilter;
  GlobalKey<FormState> formaddkey = GlobalKey<FormState>();
  TextEditingController nombrectrl = new TextEditingController(text: '');
  TextEditingController rutctrl = new TextEditingController(text: '');
  TextEditingController filterctrl = new TextEditingController(text: '');
  String sexo = '';
  bool _isloading = false;
  bool get isloading => _isloading;

  set isloading(value) {
    _isloading = value;
    notifyListeners();
  }

  bool isValidateForm() {
    return formaddkey.currentState?.validate() ?? false;
  }

  set listatrabajadores(value) {
    _listatrabajadores = value;
    notifyListeners();
  }

  set listatrabajadoresfilter(value) {
    _listatrabajadoresfilter = value;
    notifyListeners();
  }

  optionsProvider() {
    getcartillasdisponibles();
  }

  Future<List<Envase>> getenvases() async {
    final Map<String, dynamic> data = {'IdEmpresa': idempresa};

    String parametros = json.encode(data);
    var url = Uri.parse('${Env.baseUrl}/envase/getenvasesbyempremu');
    final response = await http.post(url, body: {"json": parametros});
    final respuesta = EnvaseResponse.fromJson(response.body);

    return respuesta.envase!;
  }

  getworkersbycontratista() async {
    var url = Uri.parse(
      '${Env.baseUrl}/trabajadorxcontratista/getworkersempcontrazona',
    );

    final Map<String, dynamic> data = {
      'IdEmpresa': idempresa,
      'IdContratista': idcontratista,
      'IdZona': idzona,
    };
    String parametros = json.encode(data);

    Map<String, String> header = new Map();
    header["content-type"] = "application/x-www-form-urlencoded";
    final response = await http.post(url, body: {"json": parametros});
    final responsetrabajador = trabajadorxContratistaFromJson(response.body);
    listatrabajadores = responsetrabajador.trabajadorxcontratista;
    listatrabajadoresfilter = listatrabajadores;
  }

  Future<http.Response> savetrabxcontratista(
    String rut,
    String nombre,
    String sexo,
  ) async {
    var url = Uri.parse(
      Env.baseUrl + '/trabajadorxcontratista/savetrabxcontratista',
    );

    final Map<String, dynamic> data = {
      'IdEmpresa': idempresa,
      'IdContratista': idcontratista,
      'IdZona': idzona,
      'Rut': rut,
      'Nombre': nombre,
      'Sexo': sexo,
    };
    String parametros = json.encode(data);
    Map<String, String> header = new Map();
    header["content-type"] = "application/x-www-form-urlencoded";
    return await http.post(url, body: {"json": parametros});
  }

  getcartillasdisponibles() async {
    final now = DateTime.now();

    var fecha = DateFormat('dd/MM/yyyy').format(now);
    final db = await database;
    String sql =
        "SELECT * FROM CARTILLAS WHERE FechaInicio='$fecha'  order by IdAndroidCartilla desc";

    final List<Map<String, dynamic>> res = await db.rawQuery('''
      $sql
      ''');

    List<Cartillaqr> lista = List.generate(
      res.length,
      (index) => Cartillaqr(
        idAndroidCartilla: res[index]["IdAndroidCartilla"],
        idEmpresa: res[index]["IdEmpresa"],
        idFamilia: res[index]["IdFamilia"],
        idActividad: res[index]["IdActividad"],
        idContratista: res[index]["IdContratista"],
        idZona: res[index]["IdZona"],
        idEspecie: res[index]["IdEspecie"],
        idVariedad: res[index]["IdVariedad"],
        idCuartel: res[index]["IdCuartel"],
        horainicio: res[index]["HORAINICIO"],
        horatermino: res[index]["HORATERMINO"],
        fechainicio: res[index]["FECHAINICIO"],
        fechatermino: res[index]["FECHATERMINO"],
        idusuario: res[index]["IDUSUARIO"],
        swUnoaUno: res[index]["SwUnoaUno"],
        swCartillaCierre: res[index]["SwCartillaCierre"],
        fechasys: res[index]["FECHASYS"],
        codEnv: res[index]["COD_ENV"],
        nomEspecie: res[index]["NomEspecie"],
        nomVariedad: res[index]["NomVariedad"],
        nomZon: res[index]["NomZon"],
        nomCuartel: res[index]["NomCuartel"],
        nomContratista: res[index]["NomContratista"],
        nomFamilia: res[index]["NomFamilia"],
        nomActividad: res[index]["NomActividad"],
      ),
    );
    idempresa = lista.first.idEmpresa;
    idcontratista = lista.first.idContratista;
    idzona = lista.first.idZona;
    await getworkersbycontratista();
  }

  set listaexcel(value) {
    _listaexcel = value;
    notifyListeners();
  }

  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'VerfrutContratista.db');

    return await openDatabase(
      path,
      version: Env.dbversion,
      onUpgrade: (Database db, int olverion, int newverion) async {},
      onOpen: (db) => {},
    );
  }

  Future<int> insertenvases(List<Envase> envases) async {
    final db = await database;
    final cleantable = await db.delete('ENVASE');
    try {
      envases.forEach((element) async {
        final res = await db.insert('ENVASE', element.toMap());
      });

      return 1;
    } catch (e) {
      print(e.toString());
      return 0;
    }
  }

  Future<List<Excelreport>> getexcel() async {
    final today = DateTime.now();
    final tenDaysFromNow = today.add(const Duration(days: -10));
    var hasta = DateFormat('yyyyMMdd').format(today);
    var desde = DateFormat('yyyyMMdd').format(tenDaysFromNow);

    String sql =
        ''' SELECT CAR.IdAndroidCartilla,CAR.NomContratista,CAR.NomEspecie,CAR.NomVariedad,NomCuartel,CAR.NomActividad,CAR.COD_ENV,ENT.QR,ENT.Fecha,ENT.Hora,ENT.Rut,ENT.Digito,ENT.Nombre,ENT.Cantidad
      FROM CARTILLAS CAR
      INNER JOIN ENTREGAS ENT ON CAR.IdAndroidCartilla=ENT.IdAndroidCartilla
	  

      WHERE substr(CAR.FECHAINICIO,7)||substr(CAR.FECHAINICIO,4,2)||substr(CAR.FECHAINICIO,1,2)  >= '$desde' ''';

    final db = await database;
    final List<Map<String, dynamic>> res = await db.rawQuery(sql);

    return listaexcel = List.generate(
      res.length,
      (index) => Excelreport(
        idAndroidCartilla: res[index]["IdAndroidCartilla"],
        codEnv: res[index]["COD_ENV"],
        nomEspecie: res[index]["NomEspecie"],
        nomVariedad: res[index]["NomVariedad"],
        nomCuartel: res[index]["NomCuartel"],
        nomContratista: res[index]["NomContratista"],
        nomActividad: res[index]["NomActividad"],
        qr: res[index]["Qr"],
        cantidad: res[index]["Cantidad"],
        fecha: res[index]["Fecha"],
        hora: res[index]["Hora"],
        rut: res[index]["Rut"],
        digito: res[index]["Digito"],
        nombre: res[index]["Nombre"],
      ),
    );
  }
}
