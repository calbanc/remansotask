import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:verfwork/providers/provider.dart';
import 'package:verfwork/util/VerfrutApp.dart';
import 'package:verfwork/util/validar_rut.dart';
import 'package:verfwork/widgets/rut_otp_field.dart';
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
    if (provider.controlladorqr.text != qr) {
      provider.controlladorqr.text = qr;
    }
    final _picker = ImagePicker();

    return Scaffold(
      appBar: VerfrutApp.Verfrutapp(title: 'Agregar Trabajador'),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: provider.formaddkey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              children: [
                FutureBuilder(
                  future: provider.loadLastWorkerByQr(qr),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<void> snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CupertinoActivityIndicator();
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
                  child: RutOtpField(
                    validarRutChile: provider.validarut,
                    style: TextStyle(fontFamily: 'MontserratR'),
                    controller: provider.controlladorrut,
                    validator: (value) {
                      return (value == null || value.isEmpty)
                          ? 'Debe ingresar un rut'
                          : !provider.validarut || validarRut(value)
                          ? null
                          : 'Debe ingresar un rut valido';
                    },
                    labelText: 'Rut/DNI Trabajador',
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
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    inputFormatters: [LengthLimitingTextInputFormatter(50)],
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
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (value) {
                              provider.cantidad = double.tryParse(value) ?? 0;
                            },
                            validator: (value) {
                              final cantidad = double.tryParse(value ?? '');
                              return cantidad == null || cantidad <= 0
                                  ? 'Debe ingresar una cantidad valida'
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

                        var shouldClose = false;
                        try {
                          final rutOtp = provider.controlladorrut.text
                              .toUpperCase()
                              .replaceAll(RegExp(r'[^0-9K]'), '');
                          final rut = rutOtp.substring(0, rutOtp.length - 1);
                          final digito = rutOtp.substring(rutOtp.length - 1);
                          provider.controlladordigito.text = digito;

                          final existeTrabajador = await provider
                              .existeTrabajadorEnCartilla(
                                rut,
                                idcartilla.idAndroidCartilla!,
                              );
                          if (existeTrabajador) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Ya existe un trabajador con este RUT en esta cartilla.',
                                  ),
                                ),
                              );
                            }
                            return;
                          }

                          List<Trabajador>? trabajador = await provider
                              .gettrabajadorbyrut(rut);
                          if (trabajador != null) {
                            provider.controlladoridempresa.text =
                                trabajador[0].idempresa!;
                            provider.controlladorcodigotrabajador.text =
                                trabajador[0].idtrabxcontratista!;
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
                            rut: rut,
                            digito: digito,
                            idempresa: provider.controlladoridempresa.text,
                            IdTrabXContratista:
                                provider.controlladorcodigotrabajador.text,
                            swsincronizado: '0',
                          );

                          await provider.insertentry(entrega);

                          await TrabajadorxContratistaProvider()
                              .getcartillasdisponibles();
                          List<QrCartillaResponse> fechainiciocartilla =
                              await provider.getfechainiciobyidcartilla(
                                idcartilla.idAndroidCartilla!,
                              );
                          fechainiciocartilla.isEmpty
                              ? provider.updatehorainicio(
                                idcartilla.idAndroidCartilla!,
                              )
                              : null;

                          TrabajadorxContratistaProvider().speak(
                            'Entrega Registrada',
                          );
                          shouldClose = true;
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'No se pudo registrar el trabajador: $e',
                                ),
                              ),
                            );
                          }
                        } finally {
                          if (context.mounted) {
                            provider.isLoading = false;
                          }
                        }

                        if (shouldClose && context.mounted) {
                          Navigator.of(context).pop();
                        }
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
