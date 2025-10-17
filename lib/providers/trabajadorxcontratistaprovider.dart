import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:verfwork/const/env.dart';
import 'package:verfwork/providers/provider.dart';
import 'package:verfwork/response/CartillaQrResponse.dart';
import 'package:verfwork/response/CuartelResponse.dart';
import 'package:verfwork/response/response.dart';
import 'package:dropdown_search/dropdown_search.dart';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

import '../response/ActividadesResponse.dart';
import '../response/EnvaseResponse.dart';
import '../response/excel.dart';
import '../response/qrcartilla_response.dart';

class TrabajadorxContratistaProvider extends ChangeNotifier {
  final MobileScannerController controller = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
  );

  TextEditingController maxenvController = TextEditingController(text: '');
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  GlobalKey<FormState> formkey2 = GlobalKey<FormState>();
  GlobalKey<FormState> formalert = GlobalKey<FormState>();
  GlobalKey<FormState> formkeyaddcartilla = GlobalKey<FormState>();
  GlobalKey<DropdownSearchState> formkeylabor =
      GlobalKey<DropdownSearchState>();
  GlobalKey<DropdownSearchState> formkeylistacartilla =
      GlobalKey<DropdownSearchState>();

  static Database? _database;

  Future<Database> get database async => _database ??= await initDB();
  List<Actividade>? _listalabores;

  List<Actividade>? get listalabores => _listalabores;
  String IdFamilia = '';
  String _IdActividad = '';
  String cod_env = '';
  String max_env = '';

  String get IdActividad => _IdActividad;
  bool _swunoauno = false;

  double _totalcantidadentregas = 0;

  int _contador = 0;
  int get contador => _contador;
  set contador(value) {
    _contador = value;
    notifyListeners();
  }

  double get totalcantidadentregas => _totalcantidadentregas;

  set totalcantidadentregas(value) {
    _totalcantidadentregas = value;
    notifyListeners();
  }

  bool get swunoauno => _swunoauno;

  set swunoauno(bool value) {
    String uno = value ? '1' : '0';

    _swunoauno = value;
    updateswunoauno(cartillaseleccionada!.idAndroidCartilla!, uno);

    notifyListeners();
  }

  set IdActividad(value) {
    _IdActividad = value;
    //obtenerlaboresporactividad(_IdActividad);
    notifyListeners();
  }

  set listalabores(value) {
    _listalabores = value;
    notifyListeners();
  }

  bool _iscosecha = false;

  bool get iscosecha => _iscosecha;

  set iscosecha(value) {
    _iscosecha = value;
    notifyListeners();
  }

  String IdEmpresa = '';
  String Rut = '';
  String Digito = '';
  String Nombre = '';
  String Qr = '';
  String _IdCartilla = '';
  int cantidad = 0;

  //List<QrCartillaResponse> _listacartillas=[];
  //List<QrCartillaResponse> get listacartillas=>_listacartillas;
  int _cantidadentregas = 0;

  String get IdCartilla => _IdCartilla;

  int get CantidadEntregas => _cantidadentregas;
  String _fechaultimaactualizacion = '';

  String get FechaUltimaactualizacion => _fechaultimaactualizacion;
  List<Cartillaqr> _cartilasdisponibles = [];

  List<Cartillaqr> get cartillasdisponibles => _cartilasdisponibles;
  Cartillaqr? _cartillaseleccionada;

  Cartillaqr? get cartillaseleccionada => _cartillaseleccionada;

  List<ListadoEntregaResponse> _listaentregas = [];

  List<ListadoEntregaResponse> get listaentregas => _listaentregas;

  set listaentregas(value) {
    if (value == null) {
      _listaentregas = [];
    } else {
      _listaentregas = value;
    }

    notifyListeners();
  }

  set cartillaseleccionada(Cartillaqr? value) {
    if (value != null) {
      _cartillaseleccionada = value;
      value.swUnoaUno == '1' ? swunoauno = true : swunoauno = false;
      listadoentregas(value.idAndroidCartilla!);
      notifyListeners();
    }
  }

  set cartillasdisponibles(value) {
    _cartilasdisponibles = value;
    notifyListeners();
  }

  Cuarteles? cuartelseleccionado;

  List<Cuarteles>? _listazonas;
  List<Cuarteles>? get listazonas => _listazonas;
  set listazonas(value) {
    _listazonas = value;
    notifyListeners();
  }

  List<Cuarteles>? _listacuartel;
  List<Cuarteles>? get listacuartel => _listacuartel;
  set listacuartel(value) {
    _listacuartel = value;
    notifyListeners();
  }

  set FechaUltimaactualizacion(String value) {
    _fechaultimaactualizacion = value;
    notifyListeners();
  }

  set setidcartilla(String idcartilla) {
    _IdCartilla = idcartilla;
    notifyListeners();
  }

  List<Actividade> _listalaboreslocal = [];
  List<Actividade> get listalaboreslocal => _listalaboreslocal;
  set listalaboreslocal(value) {
    _listalaboreslocal = value;
    notifyListeners();
  }

  List<Envase> _listaenvase = [];
  List<Envase> get listaenvase => _listaenvase;
  set listaenvase(value) {
    _listaenvase = value;
    notifyListeners();
  }

  bool isValidateFormcartilla() {
    return formkeyaddcartilla.currentState?.validate() ?? false;
  }

  bool isValidateFormalert() {
    return formalert.currentState?.validate() ?? false;
  }

  Future<List<Actividade>> obtenerlaboresporactividad(String idlabor) async {
    final db = await database;
    final List<Map<String, dynamic>> res = await db.rawQuery('''
        SELECT IdActividad,Nombre,ControldeUnidades,SwCosecha FROM MAESTRO_LABORES WHERE IdFamilia='$idlabor'        
    ''');
    List<Actividade> listalocal = List.generate(
      res.length,
      (index) => Actividade(
        idActividad: res[index]['IdActividad'],
        nombre: res[index]['Nombre'],
        controldeunidades: res[index]['ControldeUnidades'],
        swcosecha: res[index]['SwCosecha'],
      ),
    );
    return listalocal;
  }

  set setCantidadEntregas(int entrega) {
    _cantidadentregas = entrega;
    notifyListeners();
  }

  bool isValidateForm() {
    return formkey.currentState?.validate() ?? false;
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  final String defaultLanguage = 'es-ES';

  FlutterTts _flutterTts = FlutterTts();

  double volume = 1; // Range: 0-1
  double rate = 1.0; // Range: 0-2
  double pitch = 1.0; // Range: 0-2

  String? language;
  String? languageCode;
  List<String> languages = <String>[];
  List<String> languageCodes = <String>[];
  String? voice;

  Future<void> initLanguages() async {
    /// populate lang code (i.e. en-US)
    _flutterTts.setLanguage('es-ES');
    _flutterTts.setVolume(1.0);
  }

  TrabajadorxContratistaProvider() {
    DBProvider.db.initDB();
    initLanguages();
    getcartillasdisponibles();

  }

  void speak(String text) {
    _flutterTts.setVolume(volume);

    _flutterTts.speak(text);
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

  Future<List<Envase>> getenvase(int idempresa) async {
    final Map<String, dynamic> data = {'IdEmpresa': idempresa};

    String parametros = json.encode(data);
    var url = Uri.parse('${Env.baseUrl}/envase/getenvasesbyempremu');
    final response = await http.post(url, body: {"json": parametros});
    final respuesta = EnvaseResponse.fromJson(response.body);

    return respuesta.envase!;
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



  Future<List<Actividade>> getlabores() async {
    final db = await database;
    final List<Map<String, dynamic>> res = await db.rawQuery('''
        SELECT DISTINCT IdFamilia,NOOMBRE_FAMILIA
        FROM MAESTRO_LABORES Z
       
    ''');

    return List.generate(
      res.length,
      (index) => Actividade(
        idFamilia: res[index]['IdFamilia'],
        noombreFamilia: res[index]['NOOMBRE_FAMILIA'],
      ),
    );
  }

  Future<List<Trabajador>> getlistado(String IdCartilla) async {
    var url = Uri.parse(
      Env.baseUrl + '/trabajadorxcontratista/gettrabajadoresbycontratista',
    );

    final Map<String, dynamic> data = {'IdCartilla': IdCartilla};
    String parametros = json.encode(data);

    Map<String, String> header = new Map();
    header["content-type"] = "application/x-www-form-urlencoded";
    final response = await http.post(url, body: {"json": parametros});
    final respuesta = trabajadorcontratistaFromJson(response.body);
    return respuesta.trabajador;
  }

  Future<http.Response> getcuarteles(String idAndroidCartilla) async {
    final Map<String, dynamic> data = {'IdAndroidCartilla': idAndroidCartilla};
    String parametros = json.encode(data);
    var url = Uri.parse(Env.baseUrl + '/cuartelremu/getcuartelbyidcartilla');

    Map<String, String> header = new Map();
    header["content-type"] = "application/x-www-form-urlencoded";

    final response = await http.post(url, body: {"json": parametros});
    return response;
  }

  Future<String> sync(EntregaResponse entrega) async {
    final Map<String, dynamic> data = {
      'IdCartilla': entrega.idcartilla,
      'Qr': entrega.qr,
      "Fecha": entrega.fecha,
      "Cantidad": entrega.cantidad,
      "Nombre_trabajador": entrega.nombre_trabajador,
      "IdEntrega": entrega.identrega,
      "Rut": entrega.rut,
      "IdTrabajadorXContratista": entrega.idtrabajadorxcontratista,
      "Digito": entrega.digito,
    };
    String parametros = json.encode(data);
    var url = Uri.parse(Env.baseUrl + '/androidcartilladetalle/save');
    Map<String, String> header = new Map();
    header["content-type"] = "application/x-www-form-urlencoded";
    final response = await http.post(url, body: {"json": parametros});
    final respuesta = SyncEntregasResponse.fromJson(response.body);
    if (response.statusCode == 200) {
      await updateSync(entrega.identrega.toString()!);
      return 'ok';
    } else {
      return 'error';
    }
  }

 Future<void> getcartillasdisponibles() async {
    final now = DateTime.now();

    var fecha = DateFormat('dd/MM/yyyy').format(now);
    final db = await database;

    final List<Map<String, dynamic>> res = await db.rawQuery('''
      SELECT C.*,(SELECT COUNT(_id) FROM BINS WHERE IdAndroidCartilla=C.IdAndroidCartilla ) as CANT_BINS,C.COD_ENV as 'NOM_ENV'
      FROM CARTILLAS C
      WHERE C.FechaInicio='$fecha' and C.HORATERMINO in ('null' ,'00')
      order by C.IdAndroidCartilla desc
      ''');

    cartillasdisponibles = List.generate(
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
        nomEnv: res[index]["NOM_ENV"],
        maxEnv: res[index]["MAX_ENV"],
        cantBins: res[index]["CANT_BINS"],
        nomActividad: res[index]["NomActividad"],
      ),
    );
    cartillasdisponibles.isNotEmpty
        ? cartillaseleccionada = cartillasdisponibles[0]
        : null;
  }

  Future<String> redirect() async {
    if (_cartilasdisponibles.length > 0) {
      return 'Si';
    }
    return 'No';
  }

  Future<List<Actividade>> getmaestroactividades(String idEmpresa) async {
    final Map<String, dynamic> data = {'IdEmpresa': idEmpresa};
    String parametros = json.encode(data);
    var url = Uri.parse(Env.baseUrl + '/actividades/getactividadesempresa');

    Map<String, String> header = new Map();
    header["content-type"] = "application/x-www-form-urlencoded";

    final response = await http.post(url, body: {"json": parametros});
    final respuesta = ActividadesResponse.fromJson(response.body);

    return respuesta.actividades;
  }

  Future<void> insertmaestrolavores(List<Actividade> actividad) async {
    final db = await database;
    final res = await db.delete('MAESTRO_LABORES');

    actividad.forEach((element) {
      db.insert('MAESTRO_LABORES', element.toMap());
    });
  }

  Future<void> insertcuarteles(List<Cuarteles> cuarteles) async {
    final db = await database;
    await db.delete('CUARTELES');

    cuarteles.forEach((element) async {
      final res = await db.insert('CUARTELES', element.toJson());
    });
  }

  Future<int> insertcontador(Contador_bins contador) async {
    final db = await database;
    final res;
    if (contador.cant! > 1) {
      res = await db.update(
        'CONTADOR_BINS',
        {'CANT': contador.cant},
        where: 'IdAndroidCartilla=?',
        whereArgs: [contador.idAndroidCartilla],
      );
    } else {
      res = await db.insert('CONTADOR_BINS', contador.toMap());
    }
    return res;
  }

  Future<int> getcountentrybyid(String IdCartilla) async {
    final db = await database;
    final List<Map<String, dynamic>> res = await db.rawQuery(
      ''' SELECT IFNULL(MAX( CAST(CANT AS INTEGER)),0) AS CANT FROM CONTADOR_BINS WHERE IdAndroidCartilla='$IdCartilla' ''',
    );
    print(res[0]['CANT']);
    return res[0]['CANT'];
  }

  Future<List<Cartillaqr>> getcartillabyid(String IdCartilla) async {
    final db = await database;
    final List<Map<String, dynamic>> res = await db.rawQuery('''
      	SELECT * FROM CARTILLAS WHERE IdCartilla='$IdCartilla'
      ''');
    notifyListeners();
    return List.generate(
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
  }

  ultimasincronizacion() async {
    final db = await database;
    final List<Map<String, dynamic>> res = await db.rawQuery('''
      SELECT FechaSincronizacion,TiempoDelay FROM CONFIG ORDER BY FechaSincronizacion DESC
      ''');
    final lista = List.generate(
      res.length,
      (index) => ConfigResponse(
        TiempoDelay: res[index]['TiempoDelay'],
        FechaSincronizacion: res[index]['FechaSincronizacion'],
      ),
    );
    FechaUltimaactualizacion = lista[0].FechaSincronizacion;
    notifyListeners();
  }

  Future<String> synccartillashoras(Cartillaqr cartilla) async {
    var url = Uri.parse(Env.baseUrl + '/androidcartilla/update');

    final Map<String, dynamic> data = {
      'IdCartilla': cartilla.idAndroidCartilla,
      'HoraInicio': cartilla.horainicio,
      'HoraTermino': cartilla.horatermino,
    };
    String parametros = json.encode(data);

    Map<String, String> header = new Map();
    header["content-type"] = "application/x-www-form-urlencoded";
    final response = await http.post(url, body: {"json": parametros});
    if (response.statusCode == 200) {
      await updatecartillafinaltime(cartilla.idAndroidCartilla!);
      return 'ok';
    } else {
      return 'error';
    }
  }

  Future<int> updatecartillafinaltime(String idcartilla) async {
    final db = await database;

    final res = await db.rawUpdate('''
      UPDATE CARTILLAS SET SwSincronizado='1' WHERE IdAndroidCartilla='$idcartilla'
    ''');
    return res;
  }

  Future<int> insertultimasincronizacion(ConfigResponse config) async {
    final db = await database;
    DateTime ahora = DateTime.now();
    final res = await db.insert('CONFIG', config.toMap());
    ultimasincronizacion();
    return res;
  }

  Future<List<Cartillaqr>> getcartillastosync(bool local) async {
    final db = await database;
    List<Map<String, dynamic>> res;

    if (local) {
      res = await db.rawQuery(
        ''' SELECT * FROM CARTILLAS WHERE SwSincronizado<>'1' and IdAndroidCartilla like 'L%' ''',
      );
    } else {
      res = await db.rawQuery(
        ''' SELECT * FROM CARTILLAS WHERE SwSincronizado<>'1' and IdAndroidCartilla not like 'L%' ''',
      );
    }

    return List.generate(
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
  }

  Future<List<Cartillaqr>> getfechainiciobyidcartilla(String idcartilla) async {
    final db = await database;
    final List<Map<String, dynamic>> res = await db.rawQuery('''
      SELECT * FROM CARTILLAS WHERE IdAndroidCartilla='$idcartilla' and HoraInicio is null
      ''');

    return List.generate(
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
  }

  Future<List<QrCartillaResponse>> gethoraterminobyidcartilla(
    String idcartilla,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> res = await db.rawQuery('''
      SELECT * FROM CARTILLAS WHERE IdCartilla='$idcartilla' and HoraTermino is null
      ''');

    return List.generate(
      res.length,
      (index) => QrCartillaResponse(
        idcartilla: res[index]['IdCartilla'],
        cuartel: res[index]['Cuartel'],
        labor: res[index]['Labor'],
        fechainicio: res[index]['FechaInicio'],
        fechatermino: res[index]['FechaTermino'],
        swunoauno: res[index]['SwUnoaUno'],
        swSincronizado: res[index]['SwSincronizado'],
        contratista: res[index]['Contratista'],
      ),
    );
  }

  Future<int> insertatrabajadorescontratista(Trabajador trabajador) async {
    final db = await database;
    final res = await db
        .delete(
          'TRABAJADORESXCONTRATISTA',
          where: 'Qr=?',
          whereArgs: [trabajador.qr],
        )
        .then(
          (value) => db.insert('TRABAJADORESXCONTRATISTA', trabajador.toJson()),
        );
    return res;
  }

  Future<List<Trabajador>?> gettrabajadorbyqr(
    String qr,
    String cartilla,
  ) async {
    final today = DateTime.now();
    final date = DateFormat('dd/MM/yyyy').format(today);
    final db = await database;


    final List<Map<String, dynamic>> res = await db.rawQuery('''
      SELECT *
      FROM ENTREGAS T
      WHERE Qr='$qr' 
      Order by IdEntrega desc
	    LIMIT 1
      ''');
    return List.generate(
      res.length,
      (index) => Trabajador(
        idempresa: res[index]['IdEmpresa'],
        rut: res[index]['Rut'],
        digito: res[index]['Digito'],
        nombre: res[index]['Nombre'],
        qr: res[index]['Qr'],
        idtrabxcontratista: res[index]['IdTrabXContratista'],
      ),
    );
  }

  Future<List<Entrega>?> entrega(Entrega entrega) async {
    final db = await database;
    final res = await db.query(
      'ENTREGAS',
      distinct: true,
      where: 'Qr=? AND IdAndroidCartilla=? AND Fecha=? ',
      whereArgs: [entrega.qr, entrega.idcartilla, entrega.fecha],
    );

    return res.isNotEmpty ? res.map((e) => Entrega.fromJson(e)).toList() : null;
  }

  Future<int> insertentry(Entrega entry) async {
    final db = await database;
    final res = await db.insert('ENTREGAS', entry.toJson());
    return res;
  }

  Future<int> updateentry(Entrega entry) async {
    final db = await database;
    double cantidad = entry.cantidad!;
    int? identrega = entry.identrega;
    String? hora = entry.hora;
    String? idempresa = entry.idempresa == null ? null : entry.idempresa!;
    String? digito = entry.digito == null ? null : entry.digito!;
    String nombre = entry.nombre;
    String qr = entry.qr!;
    final res = await db.rawUpdate('''
      UPDATE ENTREGAS SET CANTIDAD= '$cantidad' ,
      Nombre='$nombre',Digito='$digito',
       SwSincronizado='0',Hora='$hora' WHERE IdEntrega='$identrega'
    ''');

    return res;
  }

  Future<int> updatetrabajador(Entrega entry) async {
    final db = await database;
    double cantidad = entry.cantidad!;
    int? identrega = entry.identrega;
    String? hora = entry.hora;
    String? idempresa = entry.idempresa == null ? null : entry.idempresa!;
    String? digito = entry.digito == null ? null : entry.digito!;
    String nombre = entry.nombre;
    String qr = entry.qr!;
    final today = DateTime.now();
    final date = DateFormat('dd/MM/yyyy').format(today);

    final res2 = await db.rawUpdate(
      ''' UPDATE ENTREGAS SET Nombre='$nombre',Digito='$digito',
       SwSincronizado='0'  Where Qr='$qr' and Fecha='$date'  ''',
    );

    return res2;
  }

  Future<int> updateentrycant(ListadoEntregaResponse entrega) async {
    int identrega = entrega.identrega!;
    double cantidad = entrega.cantidad!;
    double nuevacantidad = cantidad - 1;

    final db = await database;
    final res = await db.rawUpdate('''
      UPDATE ENTREGAS SET  SwSincronizado='0' , Cantidad='$nuevacantidad'  WHERE IdEntrega='$identrega'
    ''');

    return res;
  }

  Future<int> deleteentregas(ListadoEntregaResponse entrega) async {
    int identrega = entrega.identrega!;

    final db = await database;
    final res = await db.rawUpdate('''
      UPDATE ENTREGAS SET  SwSincronizado='0' , Cantidad='0'  WHERE IdEntrega='$identrega'
    ''');

    return res;
  }

  Future<int> updatehorainicio(String idCartilla) async {
    final hora = DateTime.now();
    final db = await database;
    final res = await db.rawUpdate('''
      UPDATE CARTILLAS SET HORAINICIO= '$hora' , SwSincronizado='0' WHERE IdAndroidCartilla='$idCartilla'
    ''');
    return res;
  }

  updatehoratermino(String idCartilla) async {
    final hora = DateTime.now();
    final db = await database;
    final res = await db.rawUpdate('''
      UPDATE CARTILLAS SET HORATERMINO= '$hora' , SwSincronizado='0' WHERE IdAndroidCartilla='$idCartilla'
    ''');

    await getcartillasdisponibles();

    cartillasdisponibles.isNotEmpty ?  cartillaseleccionada = cartillasdisponibles[0]:null;
    notifyListeners();
  }

  updateswunoauno(String idCartilla, String uno) async {
    final db = await database;
    final res = await db.rawUpdate('''
      UPDATE CARTILLAS  SET SwUnoaUno='$uno'  WHERE IdAndroidCartilla='$idCartilla'
     ''');
  }

  Future<int> updateSync(String identrega) async {
    final db = await database;

    final res = await db.rawUpdate('''
      UPDATE ENTREGAS SET   SwSincronizado='1' WHERE IdEntrega='$identrega'
    ''');
    return res;
  }

  Future<List<EntregaResponse>?> listentregas(String idcartilla) async {
    final db = await database;
    final res = await db.rawQuery('''
      
      SELECT SUM(Cantidad) as 'Cantidad'
      FROM ENTREGAS
      WHERE IdAndroidCartilla='$idcartilla' 
    ''');

    return res.isNotEmpty
        ? res.map((e) => EntregaResponse.fromJson(e)).toList()
        : null;
  }

  listadoentregas(String idcartilla) async {
    final db = await database;
    final res = await db.rawQuery('''
      
    SELECT C.NomCuartel,C.NomActividad,E.Nombre,SUM(E.CANTIDAD) AS 'Cantidad',E.IdAndroidCartilla,e.IdEntrega,E.Qr,E.IdTrabXContratista,E.Digito,E.Rut
      FROM ENTREGAS E
      INNER JOIN CARTILLAS C ON E.IdAndroidCartilla=C.IdAndroidCartilla
     
     
      where e.IdAndroidCartilla='$idcartilla' and e.Cantidad>0
               GROUP by C.NomCuartel,C.NomActividad,E.Nombre,e.IdAndroidCartilla,E.IdEntrega
    ''');

    final res2 = await db.rawQuery(
      '''   SELECT  IFNULL( SUM(E.CANTIDAD) ,0)AS 'Cantidad'
      FROM ENTREGAS E
      INNER JOIN CARTILLAS C ON E.IdAndroidCartilla=C.IdAndroidCartilla
      where e.IdAndroidCartilla='$idcartilla' and e.Cantidad>0 ''',
    );

    listaentregas =
        res.isNotEmpty
            ? res.map((e) => ListadoEntregaResponse.fromJson(e)).toList()
            : null;

    final res3 = await db.rawQuery('''
      SELECT CANT FROM CONTADOR_BINS WHERE IdAndroidCartilla='$idcartilla' 
    ''');

    contador = res3.length > 0 ? res3.first['CANT'] as int : 0;

    var kd = res2.first;
    totalcantidadentregas = kd['Cantidad'] as double;
  }

  Future<List<Trabajador>?> gettrabajadorbyrut(String rut) async {
    final db = await database;
    final res = await db.rawQuery(
      ''' SELECT * FROM TRABAJADORESXCONTRATISTA WHERE Rut='$rut' ''',
    );
    return res.isNotEmpty
        ? res.map((e) => Trabajador.fromJson(e)).toList()
        : null;
  }

  Future<List<EntregaResponse>> getentryforsync(bool local) async {
    final db = await database;
    final List<Map<String, dynamic>> res;

    if (local) {
      res = await db.rawQuery('''
      
        SELECT E.*
        FROM ENTREGAS E
        INNER JOIN  CARTILLAS C ON C.IdAndroidCartilla=E.IdAndroidCartilla
        WHERE C.IdAndroidCartilla  like 'L%' and e.SwSincronizado='0'
    ''');
    } else {
      res = await db.rawQuery('''
          
          SELECT E.*
          FROM ENTREGAS E
          INNER JOIN  CARTILLAS C ON C.IdAndroidCartilla=E.IdAndroidCartilla
          WHERE C.IdAndroidCartilla not like 'L%' and e.SwSincronizado='0'


        ''');
    }

    return List.generate(
      res.length,
      (index) => EntregaResponse(
        identrega: res[index]['IdEntrega'],
        idcartilla: res[index]['IdAndroidCartilla'],
        qr: res[index]['Qr'],
        cantidad: res[index]['Cantidad'],
        fecha: res[index]['Fecha'],
        hora: res[index]['Hora'],
        swsincronizado: res[index]['SwSincronizado'],
        nombre_trabajador: res[index]['Nombre'],
        idtrabajadorxcontratista: res[index]['IdTrabXContratista'],
        digito: res[index]['Digito'],
        rut: res[index]['Rut'],
      ),
    );
  }

  Future<int> updateenvcartilla(Cartillaqr cartilla) async {
    final db = await database;
    final res = await db.update(
      'CARTILLAS',
      {'COD_ENV': cartilla.codEnv, 'MAX_ENV': cartilla.maxEnv},
      where: 'IdAndroidCartilla=?',
      whereArgs: [cartilla.idAndroidCartilla],
    );
    return res;
  }

  Future<List<Cartillaqr>> consultaqr(Cartillaqr qrcartilla) async {
    String idcartilla = qrcartilla.idAndroidCartilla!;

    final db = await database;
    final List<Map<String, dynamic>> res = await db.rawQuery('''
      SELECT * FROM CARTILLAS WHERE IdAndroidCartilla='$idcartilla'  
      ''');

    return List.generate(
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
  }

  Future<int> insertarqr(Cartillaqr qrcartilla) async {
    final db = await database;
    final res = await db.insert('CARTILLAS', qrcartilla.toMap());

    await getcartillasdisponibles();
    cartillaseleccionada = qrcartilla;
    return res;
  }
  Future<bool>dataavailabletosync()async{
    final db=await database;
    final res=await db.query('ENTREGAS',where: 'SwSincronizado=?',whereArgs: ['0']);
    if(res.isNotEmpty){
      return true;
    }else{
      return false;
    }
  }
  Future<int> cambiartipolectura(Cartillaqr cartilla, bool valor) async {
    try {
      final db = await database;
      String valor2 = valor ? '1' : '0';

      // Update the local state first
      _swunoauno = valor;
      if (cartillaseleccionada != null) {
        cartillaseleccionada!.swUnoaUno = valor2;
      }

      // Update the database
      final res = await db.update(
          'CARTILLAS',
          {'SwUnoaUno': valor2},
          where: 'IdAndroidCartilla = ?',
          whereArgs: [cartilla.idAndroidCartilla]
      );

      notifyListeners();
      return res;
    } catch (e) {
      print('Error en cambiartipolectura: $e');
      rethrow;
    }
  }
  }
