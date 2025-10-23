import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:verfwork/providers/dataServerProvider.dart';
import 'package:verfwork/response/CartillaQrResponse.dart';
import 'package:verfwork/util/VerfrutApp.dart';
import 'package:http/http.dart' as http;

import 'package:path/path.dart';

import '../response/DataserverResponse.dart';

class DataServerScreen extends StatelessWidget {
  Cartillaqr cartilla;
  DataServerScreen({super.key, required this.cartilla});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => dataServerProvider(),
      child: _dataServerScreen(cartillaqr: cartilla),
    );
  }
}

class _dataServerScreen extends StatelessWidget {
  Cartillaqr cartillaqr;
  _dataServerScreen({super.key, required this.cartillaqr});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<dataServerProvider>(context);

    Future<void> createreportexcel(List<Entregas> listaexcel) async {
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

      var cellrut = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: 0),
      );
      cellrut.value = TextCellValue("Rut");
      var celldigito = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: 0),
      );
      celldigito.value = TextCellValue("Digito");
      var cellnombre = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: 0),
      );
      cellnombre.value = TextCellValue("Nombre");
      var cellcantidad = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: 0),
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
        cellcontratista.value = TextCellValue(cartillaqr.nomContratista!);

        var cellespecie = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: j),
        );
        cellespecie.value = TextCellValue(cartillaqr.nomEspecie!);

        var cellvariedad = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: j),
        );
        cellvariedad.value = TextCellValue(cartillaqr.nomVariedad!);

        var cellcuartel = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: j),
        );
        cellcuartel.value = TextCellValue(cartillaqr.nomCuartel!);

        var celllabor = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: j),
        );
        celllabor.value = TextCellValue(cartillaqr.nomActividad!);

        var cellenvase = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: j),
        );
        cellenvase.value = TextCellValue(
          cartillaqr.codEnv == null ? '-' : cartillaqr.codEnv!,
        );

        var cellqr = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: j),
        );
        cellqr.value = TextCellValue(listaexcel[i].qr!);

        var cellfecha = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: j),
        );
        cellfecha.value = TextCellValue(cartillaqr.fechainicio!);

        var cellrut = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: j),
        );
        cellrut.value = TextCellValue(listaexcel[i].rut!);

        var celldigito = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: j),
        );
        celldigito.value = TextCellValue(listaexcel[i].dv ?? '-');

        var cellnombre = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: j),
        );
        cellnombre.value = TextCellValue(listaexcel[i].nombre!);

        var cellcantidad = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: j),
        );
        cellcantidad.value = TextCellValue(
          listaexcel[i].unidadProducida.toString()!,
        );

        j++;
      }

      var fileBytes = excel.save();

      var directory = (await getApplicationDocumentsDirectory()).path;
      if (fileBytes != null) {
        File(('$directory/Informe_labores.xlsx'))
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);
      }
    }

    return Scaffold(
      appBar: VerfrutApp.Verfrutapp(
        title: 'Datos de Cartilla',
        action: IconButton(
          onPressed: () async {
            var directory = (await getApplicationDocumentsDirectory()).path;
            Share.shareXFiles([
              XFile('$directory/Informe_labores.xlsx'),
            ], text: 'Compartir informe');
          },
          icon: Icon(Icons.share, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.18,
            width: 190,
            child: Card(
              color: Color.fromRGBO(36, 99, 174, 1),
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  width: 1,
                  color: Color.fromRGBO(195, 195, 195, 1),
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(210, 172, 130, 0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            height: 50,
                            width: 50,
                            child: Image.asset('assets/cuartel.png'),
                          ),
                        ),
                      ],
                    ),

                    Text(
                      cartillaqr.nomCuartel!,
                      style: TextStyle(
                        fontFamily: 'MontserratR',
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      cartillaqr.nomVariedad!,
                      style: TextStyle(
                        fontFamily: 'MontserratR',
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      cartillaqr.nomActividad!,
                      style: TextStyle(
                        fontFamily: 'MontserratR',
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          FutureBuilder(
            future: provider.getentregasbycartilla(cartillaqr),
            builder: (context, AsyncSnapshot<http.Response> snapshot) {
              if (snapshot.hasData) {
                http.Response respuesta = snapshot.data!;
                if (respuesta.statusCode == 200) {
                  final response = dataserverResponseFromMap(respuesta.body);
                  List<Entregas> lista = response.entregas ?? [];

                  createreportexcel(lista);
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        columnSpacing: 20,
                        columns: const [
                          DataColumn(
                            label: Text(
                              'N°',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'QR',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'RUT',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'DV',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Nombre',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Unidad Producida',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        rows:
                            lista
                                .map(
                                  (entrega) => DataRow(
                                    cells: [
                                      DataCell(Text(entrega.qr ?? '')),
                                      DataCell(Text(entrega.qr ?? '')),
                                      DataCell(Text(entrega.rut ?? '')),
                                      DataCell(Text(entrega.dv ?? '')),
                                      DataCell(Text(entrega.nombre ?? '')),
                                      DataCell(
                                        Text(entrega.unidadProducida ?? ''),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  );
                } else {
                  return Center(child: Text(snapshot.data!.body));
                }
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ],
      ),
    );
  }
}
