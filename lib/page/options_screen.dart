import 'dart:io';

import 'package:verfwork/page/worker_screen.dart';
import 'package:verfwork/providers/optionsProvider.dart';
import 'package:verfwork/util/VerfrutApp.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../response/excel.dart';

class optionsScreen extends StatelessWidget {
  optionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => new optionsProvider(),
      child: _optionsScreen(),
    );
  }
}

class _optionsScreen extends StatelessWidget {
  const _optionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<optionsProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: VerfrutApp.Verfrutapp(title: 'Opciones'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: GestureDetector(
                  onTap: () async {
                    try {
                      await provider.getexcel().then(
                        (value) => createreportexcel(value),
                      );
                      var directory =
                          (await getApplicationDocumentsDirectory()).path;
                      await SharePlus.instance.share(
                        ShareParams(
                          files: [XFile('$directory/Informe_labores.xlsx')],
                          text: 'Compartir informe',
                        ),
                      );
                    } catch (e) {
                      debugPrint(e.toString());
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 70,

                    decoration: BoxDecoration(
                      color: Color.fromRGBO(126, 174, 36, 0.04),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 80,
                          height: 50,
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(78, 174, 36, 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: SvgPicture.asset('assets/informe.svg'),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Generar Informe',
                          style: TextStyle(
                            fontFamily: 'MontserratR',
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(width: 50),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 17),
              child: GestureDetector(
                onTap: () async {
                  await exportLocalDatabase(context);
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 70,

                  decoration: BoxDecoration(
                    color: Color.fromRGBO(46, 125, 50, 0.04),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 80,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(46, 125, 50, 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.storage_outlined,
                          color: Color.fromRGBO(46, 125, 50, 1),
                        ),
                      ),
                      Text(
                        'Enviar BD por WhatsApp',
                        style: TextStyle(
                          fontFamily: 'MontserratR',
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(width: 50),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 17),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder:
                          (_, __, ___) => workerScreen(provider: provider),
                      transitionDuration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 70,

                  decoration: BoxDecoration(
                    color: Color.fromRGBO(46, 125, 50, 0.04),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 80,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(46, 125, 50, 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: SvgPicture.asset(
                                'assets/trabajadores.svg',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Mis trabajadores',
                        style: TextStyle(
                          fontFamily: 'MontserratR',
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(width: 50),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 17),
              child: GestureDetector(
                onTap: () async {},
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 70,

                  decoration: BoxDecoration(
                    color: Color.fromRGBO(46, 125, 50, 0.04),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 80,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(46, 125, 50, 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add,
                          color: Color.fromRGBO(46, 125, 50, 1),
                        ),
                      ),
                      Text(
                        'Recomendaciones',
                        style: TextStyle(
                          fontFamily: 'MontserratR',
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(width: 50),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> exportLocalDatabase(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<optionsProvider>();

    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final databaseFile = File(
        '${documentsDirectory.path}/VerfrutContratista.db',
      );

      if (!await databaseFile.exists()) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('No se encontro la base de datos local'),
          ),
        );
        return;
      }

      final db = await provider.database;
      await db.rawQuery('PRAGMA wal_checkpoint(TRUNCATE)');

      final temporaryDirectory = await getTemporaryDirectory();
      final exportFileName =
          'VerfrutContratista_${_formatDateTimeForFile(DateTime.now())}.db';
      final exportFile = await databaseFile.copy(
        '${temporaryDirectory.path}/$exportFileName',
      );

      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile(
              exportFile.path,
              mimeType: 'application/octet-stream',
              name: exportFileName,
            ),
          ],
          text: 'Base de datos local $exportFileName',
          subject: exportFileName,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('No se pudo exportar la base de datos: $e')),
      );
    }
  }

  String _formatDateTimeForFile(DateTime dateTime) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');

    return '${dateTime.year}'
        '${twoDigits(dateTime.month)}'
        '${twoDigits(dateTime.day)}_'
        '${twoDigits(dateTime.hour)}'
        '${twoDigits(dateTime.minute)}'
        '${twoDigits(dateTime.second)}';
  }

  Future<void> createreportexcel(List<Excelreport> listaexcel) async {
    Excel excel = Excel.createExcel();
    excel.rename(excel.getDefaultSheet()!, "Informe Labores");
    Sheet sheet = excel['Informe Labores'];

    var cellandroidcartilla = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
    );
    cellandroidcartilla.value = TextCellValue("Android Cartilla");
    var cellcontratista = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0),
    );
    cellcontratista.value = TextCellValue("Contratista");
    var cellespecie = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0),
    );
    cellespecie.value = TextCellValue("Especie");
    var cellvariedad = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0),
    );
    cellvariedad.value = TextCellValue("Variedad");
    var cellcuartel = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0),
    );
    cellcuartel.value = TextCellValue("Cuartel");
    var celllabor = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0),
    );
    celllabor.value = TextCellValue("Labor");
    var cellenvase = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0),
    );
    cellenvase.value = TextCellValue("Envase");
    var cellqr = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 0),
    );
    cellqr.value = TextCellValue("Qr");

    var cellfecha = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: 0),
    );
    cellfecha.value = TextCellValue("Fecha");
    var cellhora = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: 0),
    );
    cellhora.value = TextCellValue("Hora");
    var cellrut = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: 0),
    );
    cellrut.value = TextCellValue("Rut");
    var celldigito = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: 0),
    );
    celldigito.value = TextCellValue("Digito");
    var cellnombre = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: 0),
    );
    cellnombre.value = TextCellValue("Nombre");
    var cellcantidad = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: 0),
    );
    cellcantidad.value = TextCellValue("Cantidad");

    var j = 1;
    for (int i = 0; i < listaexcel.length; i++) {
      var cellandroidcartilla = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: j),
      );
      cellandroidcartilla.value = TextCellValue(
        listaexcel[i].idAndroidCartilla!,
      );

      var cellcontratista = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: j),
      );
      cellcontratista.value = TextCellValue(listaexcel[i].nomContratista!);

      var cellespecie = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: j),
      );
      cellespecie.value = TextCellValue(listaexcel[i].nomEspecie!);

      var cellvariedad = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: j),
      );
      cellvariedad.value = TextCellValue(listaexcel[i].nomVariedad!);

      var cellcuartel = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: j),
      );
      cellcuartel.value = TextCellValue(listaexcel[i].nomCuartel!);

      var celllabor = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: j),
      );
      celllabor.value = TextCellValue(listaexcel[i].nomActividad!);

      var cellenvase = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: j),
      );
      cellenvase.value = TextCellValue(
        listaexcel[i].codEnv == null ? '-' : listaexcel[i].codEnv!,
      );

      var cellqr = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: j),
      );
      cellqr.value = TextCellValue(listaexcel[i].qr!);

      var cellfecha = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: j),
      );
      cellfecha.value = TextCellValue(listaexcel[i].fecha!);

      var cellhora = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: j),
      );
      cellhora.value = TextCellValue(listaexcel[i].hora!);

      var cellrut = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: j),
      );
      cellrut.value = TextCellValue(listaexcel[i].rut);

      var celldigito = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: j),
      );
      celldigito.value = TextCellValue(listaexcel[i].digito!);

      var cellnombre = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: j),
      );
      cellnombre.value = TextCellValue(listaexcel[i].nombre);

      var cellcantidad = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: j),
      );
      cellcantidad.value = TextCellValue(listaexcel[i].cantidad.toString());

      j++;
    }

    var fileBytes = excel.save();

    var directory = (await getApplicationDocumentsDirectory()).path;
    if (fileBytes != null) {
      File('$directory/Informe_labores.xlsx')
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
    }
  }
}
