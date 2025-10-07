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
    bool _validarut(String? rut) {
      if (rut == null) return false;
      dynamic regExp;
      provider.validarut
          ? regExp = RegExp(r'(^(\d{1,2}(?:[\.]?\d{3}){2}-[\dkK])$)')
          : regExp = RegExp(r'^\d+$');
      return regExp.hasMatch(rut);
    }

    return Scaffold(
      appBar: VerfrutApp.Verfrutapp(title: 'Agregar Trabajador'),
      body: SingleChildScrollView(
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
                    return (value == null || value.isEmpty || value.length > 50)
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
                              (value) => {provider.cantidad = int.parse(value)},
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
      bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width,
        height: 120,
        padding: const EdgeInsets.symmetric(vertical: 30),
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
                      int cantidad = 1;
                      if (idcartilla.swUnoaUno == '0') {
                        cantidad = int.parse(
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

                      int contador = await TrabajadorxContratistaProvider()
                          .getcountentrybyid(idcartilla.idAndroidCartilla!);
                      if (idcartilla.idFamilia == '105' &&
                          idcartilla.codEnv != "null") {
                        Contador_bins contadorbins = Contador_bins(
                          idAndroidCartilla: idcartilla.idAndroidCartilla!,
                          cant: contador + 1,
                        );
                        if (int.parse(idcartilla.maxEnv!) >= contador + 1) {
                          try {
                            await provider.insertentry(entrega);
                            await TrabajadorxContratistaProvider()
                                .insertcontador(contadorbins);
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

                            Future.microtask(
                              () => {
                                Navigator.pushReplacement(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (_, __, ___) => MainDashboard(),
                                    transitionDuration: const Duration(
                                      seconds: 3,
                                    ),
                                  ),
                                ),
                              },
                            );
                          } catch (e) {
                            print(e);
                          }
                        } else {
                          TrabajadorxContratistaProvider().speak(
                            'Debe cerrar el envase antes',
                          );
                        }
                      } else {
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

                        Future.microtask(
                          () => {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) => MainDashboard(),
                                transitionDuration: const Duration(seconds: 3),
                              ),
                            ),
                          },
                        );
                      }
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
    );
  }
}
