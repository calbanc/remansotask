import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../response/response.dart';

class CartillasProvider extends ChangeNotifier{

  static Database? _database;
  Future<Database> get database async=>_database ??= await initDB();

  
  String idcartilla='';
  String qr='';
  String _fechainicio='';
  String fechatermino='';
  String horainicio='';
  String horatermino='';


  TextEditingController ctrlhorainicio=TextEditingController();
  TextEditingController ctrlhoratermino=TextEditingController();
  String get fechainicio=>_fechainicio;

  set setfechainicio(String fechainicio){
    _fechainicio=fechainicio;
    notifyListeners();
  }

  Future<Database> initDB() async{

    Directory documentsDirectory=await getApplicationDocumentsDirectory();
    final path=join(documentsDirectory.path,'VerfrutContratista.db');

    return await openDatabase(
      path,
      version:1,
      onUpgrade: (Database db,int olverion,int newverion)async{
        
      },
      onOpen:(db)=>{},

    );
  }
Future<List<QrCartillaResponse>>getcartillasbydate(String date)async{
    
  //  final now=DateTime.now();
   // DateTime fecha = new DateTime(now.year, now.month, now.day);
  
    
    
    final db=await database;
    final List<Map<String,dynamic>>res=await db.rawQuery('''
      SELECT * FROM CARTILLAS WHERE FechaInicio='$date' 
      ''');
  
    return List.generate(res.length, (index) => QrCartillaResponse(
        idcartilla: res[index]['IdCartilla'],
        cuartel: res[index]['Cuartel'],
        labor:res[index]['Labor'],
        fechainicio: res[index]['FechaInicio'],
        fechatermino: res[index]['FechaTermino'],
        horainicio: res[index]['HoraInicio'],
        horatermino: res[index]['HoraTermino'],
        swunoauno: res[index]['SwUnoaUno'],
        swSincronizado: res[index]['SwSincronizado'],
        contratista: res[index]['Contratista']
    ));
  }
 Future<int> updatehorainicio(String idCartilla,DateTime hora)async{

   final db=await database;
   final res=await db.rawUpdate(''' 
      UPDATE CARTILLAS SET HoraInicio= '$hora' , SwSincronizado='0' WHERE IdCartilla='$idCartilla'
    ''');
   return res;
 }
 Future<int> abrircartilla(String idCartilla)async{

   final db=await database;
   final res=await db.rawUpdate(''' 
      UPDATE CARTILLAS SET HoraTermino=null, SwSincronizado='0' WHERE IdCartilla='$idCartilla'
    ''');
   return res;

 }
  Future<int> updatehoratermino(String idCartilla,DateTime hora)async{

    final db=await database;
    final res=await db.rawUpdate(''' 
      UPDATE CARTILLAS SET HoraTermino= '$hora' , SwSincronizado='0' WHERE IdCartilla='$idCartilla'
    ''');

    return res;
  }

}