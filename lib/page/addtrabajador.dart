import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:verfwork/page/maindashboard.dart';
import 'package:verfwork/page/page.dart';
import 'package:verfwork/providers/provider.dart';
import 'package:verfwork/util/VerfrutApp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../response/CartillaQrResponse.dart';
import '../response/response.dart';
import 'mrz/scannrut.dart';

class AddTrabajador extends StatelessWidget {
  final qr;
  Cartillaqr idcartilla;

  AddTrabajador({super.key, required this.qr, required this.idcartilla});

  // const AddTrabajador({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AddTrabajadorContratistaProvider(),
        ),
        ChangeNotifierProvider(create: (context) => Connectivity_provider()),
      ],
      child: _addTrabajador(qr: this.qr, idcartilla: this.idcartilla),
    );
  }
}

class _addTrabajador extends StatelessWidget {
  String qr;
  Cartillaqr idcartilla;
  _addTrabajador({super.key, required this.qr, required this.idcartilla});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AddTrabajadorContratistaProvider>(context);
    provider.controlladorqr = TextEditingController(text: qr);
    final _picker = ImagePicker();
    bool _validarut(String? input) {
      if (input == null) return false;

      if (!provider.validarut) {
        final texto = input.trim();
        final soloNumeros = RegExp(r'^\d+$');
        bool re = soloNumeros.hasMatch(texto);

        return re;
      }
      final raw = input.toUpperCase().replaceAll(RegExp(r'[^0-9K]'), '');
      if (raw.length < 2) return false;

      // 2) Separa cuerpo y DV
      final body = raw.substring(0, raw.length - 1);
      final dv = raw.substring(raw.length - 1);

      // Cuerpo solo dígitos
      if (!RegExp(r'^\d+$').hasMatch(body)) return false;

      // 3) Calcula DV esperado (módulo 11, factores 2..7)
      int sum = 0;
      int factor = 2;
      for (int i = body.length - 1; i >= 0; i--) {
        sum += int.parse(body[i]) * factor;
        factor = (factor == 7) ? 2 : factor + 1;
      }
      final mod = 11 - (sum % 11);
      final expectedDv = switch (mod) {
        11 => '0',
        10 => 'K',
        _ => mod.toString(),
      };

      return dv == expectedDv;
    }

    return Scaffold(
      appBar: VerfrutApp.Verfrutapp(title: 'Agregar Trabajador'),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: provider.formaddkey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                FutureBuilder(
                  future: provider.getlasttrabajadorbyqr(qr),
                  builder: (
                      BuildContext context,
                      AsyncSnapshot<List<Trabajador>> snapshot,
                      ) {
                    if (snapshot.data == null || !snapshot.hasData) {
                      return const CupertinoActivityIndicator();
                    }
                    if (snapshot.data!.isNotEmpty) {
                      List<Trabajador> data = snapshot.data!;

                      provider.controlladornombre = TextEditingController(
                        text: data[0].nombre,
                      );
                      provider.controlladorrut = TextEditingController(
                        text: data[0].rut,
                      );
                    }

                    return Container();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 16,
                  ),
                  child: TextFormField(
                    style: TextStyle(fontFamily: 'MontserratR'),
                    controller: provider.controlladorqr,
                    enabled: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                      labelText: 'Qr Trabajador',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListTile(
                    title: const Text(
                      'Validar Rut Chile',
                      style: TextStyle(fontFamily: 'MontserratR', fontSize: 12),
                    ),
                    contentPadding: EdgeInsets.all(8),
                    trailing: CupertinoSwitch(
                      value: provider.validarut,
                      onChanged: (bool value) {
                        provider.validarut = value;
                      },
                    ),
                  ),
                ),

                if (provider.validarut && provider.path == '')
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 16,
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        final image = await _picker.pickImage(
                          source: ImageSource.camera,
                        );
                        if (image != null) {
                          provider.path = image.path;
                          await provider.procesardatos(image.path);
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 220,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 16,
                          ),
                          child: Center(
                            child: Text(
                              'Toca aqui para tomar foto al reverso del Documento de Identidad ',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                provider.path == ''
                    ? Container()
                    : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 16,
                  ),
                  child: GestureDetector(
                    onTap: () async {
                      final image = await _picker.pickImage(
                        source: ImageSource.camera,
                      );
                      if (image != null) {
                        provider.path = image.path;
                        await provider.procesardatos(image.path);
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Image.file(File(provider.path)),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 16,
                  ),
                  child: TextFormField(
                    style: TextStyle(fontFamily: 'MontserratR'),
                    controller: provider.controlladorrut,
                    validator: (value) {
                      return (value == null || value.isEmpty)
                          ? 'Debe ingresar un rut'
                          : _validarut(value)
                          ? null
                          : 'Debe ingresar un rut valido';
                    },
                    inputFormatters: [
                      // Permite números, puntos, guion y k/K
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-kK]')),
                    ],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),

                      labelText: 'Rut/DNI Trabajador',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 16,
                  ),
                  child: TextFormField(
                    style: TextStyle(fontFamily: 'MontserratR'),
                    controller: provider.controlladornombre,
                    validator: (value) {
                      return (value == null ||
                          value.isEmpty ||
                          value.length > 50)
                          ? 'Debe ingresar un nombre valido'
                          : null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                      labelText: 'Nombre Trabajador ',
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  child:
                  idcartilla.swUnoaUno == "0"
                      ? TextFormField(
                    maxLines: 1,
                    controller: provider.controlladorcantidad,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged:
                        (value) => {
                      provider.cantidad = double.parse(value),
                    },
                    validator: (value) {
                      return (value == null || value.isEmpty)
                          ? 'Debe ingresar una cantidad valido'
                          : null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                      labelText: 'Ingrese cantidad de entregas',
                      prefix: const Icon(Icons.add_card),
                    ),
                  )
                      : Container(),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 80,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(36, 99, 174, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // <-- Radius
                ),
              ),
              onPressed:
              provider.isLoading
                  ? null
                  : () async {
                FocusScope.of(context).unfocus();
                if (!provider.isValidateForm()) return;
                provider.isLoading = true;

                if (provider.controlladorrut.text.contains("-")) {
                  var rut = provider.controlladorrut.text.split("-");
                  provider.controlladorrut.text = rut[0];
                  provider.controlladordigito.text = rut[1];
                }
                List<Trabajador>? trabajador = await provider
                    .gettrabajadorbyrut(provider.controlladorrut.text);
                String idempresa;
                if (trabajador != null) {
                  provider.controlladoridempresa.text =
                  trabajador![0].idempresa!;
                  provider.controlladorcodigotrabajador.text =
                  trabajador![0].idtrabxcontratista!;
                  provider.controlladordigito.text =
                  trabajador![0].digito!;
                }

                final today = DateTime.now();
                final date = DateFormat('dd/MM/yyyy').format(today);
                double cantidad = 1;
                if (idcartilla.swUnoaUno == '0') {
                  cantidad = double.parse(
                    provider.controlladorcantidad.text,
                  );
                }

                Entrega entrega = Entrega(
                  idcartilla: idcartilla.idAndroidCartilla,
                  qr: qr,
                  cantidad: cantidad,
                  fecha: date,
                  hora: today.toString(),
                  nombre: provider.controlladornombre.text,
                  rut: provider.controlladorrut.text,
                  digito: provider.controlladordigito.text,
                  idempresa: provider.controlladoridempresa.text,
                  IdTrabXContratista:
                  provider.controlladorcodigotrabajador.text,
                  swsincronizado: '0',
                );

                await provider.insertentry(entrega);

                await TrabajadorxContratistaProvider()
                    .getcartillasdisponibles();
                List<QrCartillaResponse>? fechainiciocartilla =
                await provider.getfechainiciobyidcartilla(
                  idcartilla.idAndroidCartilla!,
                );
                fechainiciocartilla == null ||
                    fechainiciocartilla.length == 0
                    ? provider.updatehorainicio(
                  idcartilla.idAndroidCartilla!,
                )
                    : null;

                TrabajadorxContratistaProvider().speak(
                  'Entrega Registrada',
                );
                Navigator.of(context).pop();
                /*   Future.microtask(
                            () => {
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) => MainDashboard(),
                                  transitionDuration: const Duration(seconds: 3),
                                ),
                              ),
                            },
                          ); */
                //}
              },
              child: const Text(
                'Agregar Trabajador',
                style: TextStyle(
                  fontFamily: 'MontserratB',
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}