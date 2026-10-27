import 'dart:io';

import 'package:verfwork/const/env.dart';
import 'package:verfwork/response/CartillaQrResponse.dart';
import 'package:verfwork/response/detalleCartilla.dart';
import 'package:verfwork/response/qrcartilla_response.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBProvider extends ChangeNotifier {
  GlobalKey<FormState> formkey = new GlobalKey<FormState>();
  static Database? _database;
  static final DBProvider db = DBProvider._();
  DBProvider._();

  Future<Database> get database async => _database ??= await initDB();

  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'VerfrutContratista.db');

    return await openDatabase(
      path,
      version: Env.dbversion,
      onOpen: (db) async {
        final columns = await db.rawQuery('PRAGMA table_info(ENTREGAS)');
        if (!columns.any(
          (column) => column['name'] == 'SW_EXTRANJERO_SIN_DOCUMENTO',
        )) {
          await db.execute(
            'ALTER TABLE ENTREGAS ADD COLUMN '
            'SW_EXTRANJERO_SIN_DOCUMENTO INTEGER NOT NULL DEFAULT 1',
          );
        }
        for (final table in ['ENTREGAS', 'TRABAJADORESXCONTRATISTA']) {
          for (final operation in ['INSERT', 'UPDATE OF Rut']) {
            final suffix = operation == 'INSERT' ? 'insert' : 'update';
            await db.execute('''
              CREATE TRIGGER IF NOT EXISTS validar_rut_${table}_$suffix
              BEFORE $operation ON $table
              WHEN NEW.Rut IS NULL
                OR typeof(NEW.Rut) <> 'text'
                OR length(NEW.Rut) NOT BETWEEN 1 AND 8
                OR NEW.Rut GLOB '*[^0-9]*'
                OR instr(NEW.Rut, char(0)) > 0
              BEGIN
                SELECT RAISE(ABORT, 'Rut debe contener de 1 a 8 digitos numericos');
              END;
            ''');
          }
        }
      },
      onCreate: (Database db, int version) async {
        await db.execute(''' CREATE TABLE CONTADOR_BINS(
              _id INTEGER PRIMARY KEY AUTOINCREMENT,
              IdAndroidCartilla TEXT,
              CANT REAL                            
              ) ''');

        await db.execute(''' CREATE TABLE BINS(
              _id INTEGER PRIMARY KEY AUTOINCREMENT,
              IdAndroidCartilla TEXT,
              COD_BINS TEXT,
              CANT REAL,
              COD_ENV TEXT,
              SW_SINCRONIZADO TEXT
              
              ) ''');

        await db.execute('''
            CREATE TABLE CARTILLAS(
            IdAndroidCartilla TEXT,
            IdEmpresa TEXT,
            IdFamilia TEXT,
            IdActividad TEXT,
            IdContratista TEXT,
            IdZona TEXT,
            IdEspecie TEXT,
            IdVariedad TEXT,
            IdCuartel TEXT,
            HORAINICIO TEXT,
            HORATERMINO TEXT,
            FECHAINICIO TEXT,
            FECHATERMINO TEXT,
            IDUSUARIO TEXT,
            SwUnoaUno TEXT,
            SwCartillaCierre TEXT,
            FECHASYS TEXT,
            COD_ENV TEXT,
            COD_ENV_CONTENEDOR TEXT,
            CantMaxEnv TEXT,
            NomEspecie TEXT,
            NomVariedad TEXT,
            NomZon TEXT,
            NomCuartel TEXT,
            NomContratista TEXT,
            NomFamilia TEXT, 
            NomActividad TEXT,
            SwSincronizado TEXT            
            
            )
            ''');

        await db.execute('''
            CREATE TABLE TRABAJADORESXCONTRATISTA(              
              IdEmpresa TEXT,
              Rut TEXT,
              Digito TEXT,
              Nombre TEXT,
              Qr TEXT,
              Fecha TEXT,
              IdTrabXContratista TEXT
            )
            ''');

        await db.execute('''
            CREATE TABLE ENTREGAS(
              IdEntrega integer primary key,
              IdAndroidCartilla TEXT,
              Qr TEXT,
              Cantidad REAL,
              Fecha TEXT,
              Hora TEXT,
              IdTrabXContratista TEXT,
              IdEmpresa TEXT,
              Rut TEXT,
              Digito TEXT,
              Nombre TEXT,
              SwSincronizado TEXT,
              SW_EXTRANJERO_SIN_DOCUMENTO INTEGER NOT NULL DEFAULT 1
            )

          
          ''');
        await db.execute('''
            CREATE TABLE CONFIG(
              FechaSincronizacion TEXT,
              TiempoDelay TEXT
              
            )

          
          ''');
      },
      onUpgrade: (Database db, int olversion, int newverion) async {
        if (olversion < newverion) {
          final result1 = await db.rawQuery("PRAGMA table_info(CARTILLAS);");
          final hasMAXENV = result1.any(
            (column) => column['name'] == 'MAX_ENV',
          );

          final hasCodEnvContenedor = result1.any(
            (column) => column['name'] == 'COD_ENV_CONTENEDOR',
          );

          final hasCantMaxEnv = result1.any(
            (column) => column['name'] == 'CantMaxEnv',
          );

          if (!hasCodEnvContenedor) {
            await db.execute(
              "ALTER TABLE CARTILLAS ADD COLUMN COD_ENV_CONTENEDOR TEXT",
            );
          }

          if (!hasMAXENV) {
            hasCantMaxEnv
                ? null
                : await db.execute(
                  "ALTER TABLE CARTILLAS ADD COLUMN CantMaxEnv TEXT",
                );
          } else {
            await db.execute("ALTER TABLE CARTILLAS DROP COLUMN MAX_ENV");
            hasCantMaxEnv
                ? null
                : await db.execute(
                  "ALTER TABLE CARTILLAS ADD COLUMN CantMaxEnv TEXT",
                );
          }

          await db.execute(''' DROP TABLE IF EXISTS CUARTELES ''');
          await db.execute(''' DROP TABLE IF EXISTS MAESTRO_LABORES ''');
          await db.execute(''' DROP TABLE IF EXISTS ENVASE ''');
          await db.execute(''' CREATE  TABLE IF NOT EXISTS BINS(
              _id INTEGER PRIMARY KEY AUTOINCREMENT,
              IdAndroidCartilla TEXT,
              COD_BINS TEXT,
              CANT REAL,
              COD_ENV,
              SW_SINCRONIZADO TEXT
              
              ) ''');
          await db.execute(''' CREATE TABLE IF NOT EXISTS CONTADOR_BINS(
              _id INTEGER PRIMARY KEY AUTOINCREMENT,
              IdAndroidCartilla TEXT,
              CANT INTEGER                            
              ) ''');

          if (olversion < 5) {
            newverion == 5 ? await db.execute(''' DROP TABLE BINS ''') : null;
            newverion == 5
                ? await db.execute(''' DROP TABLE CONTADOR_BINS ''')
                : null;

            await db.execute(''' CREATE TABLE IF NOT EXISTS CONTADOR_BINS(
                      _id INTEGER PRIMARY KEY AUTOINCREMENT,
                      IdAndroidCartilla TEXT,
                      CANT REAL                            
                      ) ''');
            await db.execute(''' CREATE TABLE IF NOT EXISTS BINS(
                      _id INTEGER PRIMARY KEY AUTOINCREMENT,
                      IdAndroidCartilla TEXT,
                      COD_BINS TEXT,
                      CANT REAL,
                      COD_ENV TEXT,
                      SW_SINCRONIZADO TEXT
                      
                      ) ''');
          }

          final entregaColumns = await db.rawQuery(
            'PRAGMA table_info(ENTREGAS)',
          );
          final extranjeroColumn =
              entregaColumns.any(
                    (column) => column['name'] == 'SW_EXTRANJERO_SIN_DOCUMENTO',
                  )
                  ? 'SW_EXTRANJERO_SIN_DOCUMENTO'
                  : '1';
          await db.transaction((txn) async {
            await txn.execute('''
                  CREATE TABLE ENTREGAS_tmp(
                    IdEntrega INTEGER PRIMARY KEY,
                    IdAndroidCartilla TEXT,
                    Qr TEXT,
                    Cantidad REAL,            
                    Fecha TEXT,
                    Hora TEXT,
                    IdTrabXContratista TEXT,
                    IdEmpresa TEXT,
                    Rut TEXT,
                    Digito TEXT,
                    Nombre TEXT,
                    SwSincronizado TEXT,
                    SW_EXTRANJERO_SIN_DOCUMENTO INTEGER NOT NULL DEFAULT 1
                  );
                ''');

            // 2) Copiar datos (con CAST por si acaso)
            await txn.execute('''
                  INSERT INTO ENTREGAS_tmp (
                    IdEntrega, IdAndroidCartilla, Qr, Cantidad, Fecha, Hora,
                    IdTrabXContratista, IdEmpresa, Rut, Digito, Nombre, SwSincronizado,
                    SW_EXTRANJERO_SIN_DOCUMENTO
                  )
                  SELECT
                    IdEntrega, IdAndroidCartilla, Qr, CAST(Cantidad AS REAL), Fecha, Hora,
                    IdTrabXContratista, IdEmpresa, Rut, Digito, Nombre, SwSincronizado,
                    $extranjeroColumn
                  FROM ENTREGAS;
                ''');

            // 3) Borrar tabla vieja
            await txn.execute('DROP TABLE ENTREGAS;');

            // 4) Renombrar la temporal
            await txn.execute('ALTER TABLE ENTREGAS_tmp RENAME TO ENTREGAS;');
          });
        }
      },
    );
  }

  Future<List<QrCartillaResponse>> consultaqr(String idcartilla) async {
    final db = await database;
    final List<Map<String, dynamic>> res = await db.rawQuery('''
      SELECT * FROM CARTILLAS WHERE IdAndroidCartilla='$idcartilla'  and HORATERMINO is null
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

  Future<int> insertarqr(QrCartilla qrcartilla) async {
    final db = await database;
    final res = await db.insert('CARTILLAS', qrcartilla.toMap());
    return res;
  }

  Future<List<Cartillaqr>> getcartillasdisponibles() async {
    final now = DateTime.now();

    var fecha = DateFormat('dd/MM/yyyy').format(now);
    final db = await database;
    String sql =
        "SELECT * FROM CARTILLAS WHERE FechaInicio='$fecha' and HoraTermino='null'";
    final List<Map<String, dynamic>> res = await db.rawQuery('''
      $sql
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
}
