import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:verfwork/providers/editworkerprovider.dart';
import 'package:verfwork/providers/provider.dart';
import 'package:verfwork/response/response.dart';
import 'package:verfwork/util/VerfrutApp.dart';
import 'package:verfwork/util/validar_rut.dart';
import 'package:verfwork/widgets/rut_otp_field.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class DetailWorker extends StatelessWidget {
  ListadoEntregaResponse worker;
  DetailWorker({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create:
              (context) => EditWorkerProvider()..cargardatosiniciales(worker),
        ),
      ],
      child: _detailworker(worker: worker),
    );
  }
}

class _detailworker extends StatelessWidget {
  ListadoEntregaResponse worker;
  _detailworker({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EditWorkerProvider>(context);

    return Scaffold(
      appBar: VerfrutApp.Verfrutapp(title: 'Detalle de trabajador'),
      body: SingleChildScrollView(
        child: Form(
          key: provider.formdetailkey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(
            children: [
              _datospersonales(provider: provider, worker: worker),
              Column(
                children: [
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      'Detalle',
                      style: TextStyle(
                        fontFamily: 'MontserratB',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(36, 99, 174, 1),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 26,
                      right: 26,
                      top: 13,
                      bottom: 13,
                    ),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(230, 236, 245, 1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: Icon(
                                    Icons.home_outlined,
                                    color: Color.fromRGBO(36, 99, 174, 1),
                                  ),
                                ),
                                Text(
                                  'Cuartel',
                                  style: TextStyle(fontFamily: 'MontserratR'),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Text(
                              worker.cuartel!,
                              style: TextStyle(fontFamily: 'MontserratR'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 26,
                      right: 26,
                      top: 8,
                      bottom: 13,
                    ),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(230, 236, 245, 1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: Image(
                                    color: Color.fromRGBO(36, 99, 174, 1),
                                    image: AssetImage('assets/labor.png'),
                                    width: 30,
                                  ),
                                ),
                                Text(
                                  'Labor',
                                  style: TextStyle(fontFamily: 'MontserratR'),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: Text(
                              worker.labor!,
                              style: TextStyle(fontFamily: 'MontserratR'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 26,
                      right: 26,
                      top: 8,
                      bottom: 13,
                    ),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(230, 236, 245, 1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: Image(
                                    color: Color.fromRGBO(36, 99, 174, 1),
                                    image: AssetImage('assets/boxex.png'),
                                    width: 30,
                                  ),
                                ),
                                Text(
                                  'Cantidad',
                                  style: TextStyle(fontFamily: 'MontserratR'),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: Text(
                              worker.cantidad.toString()!,
                              style: TextStyle(fontFamily: 'MontserratR'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _datospersonales extends StatelessWidget {
  const _datospersonales({
    super.key,
    required this.provider,
    required this.worker,
  });

  final EditWorkerProvider provider;
  final ListadoEntregaResponse worker;

  @override
  Widget build(BuildContext context) {
    final _picker = ImagePicker();
    return Column(
      children: [
        const SizedBox(height: 30),
        const Center(
          child: Text(
            'Datos Personales',
            style: TextStyle(
              fontFamily: 'MontserratB',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(36, 99, 174, 1),
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
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
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
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
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
          padding: const EdgeInsets.only(
            left: 26,
            right: 26,
            top: 13,
            bottom: 13,
          ),
          child: TextFormField(
            controller: provider.controllername,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
            validator: (value) {
              return (value == null || value.isEmpty || value.length > 50)
                  ? 'Debe ingresar un nombre valido'
                  : null;
            },

            decoration: VerfrutApp.InputDecorationVerf(
              label: 'Nombre Trabajador',
              prefixicon: Icons.account_circle_outlined,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 26,
            right: 26,
            top: 13,
            bottom: 13,
          ),
          child: RutOtpField(
            validarRutChile: provider.validarut,
            style: const TextStyle(fontFamily: 'MontserratR'),
            controller: provider.controllerrut,
            validator: (value) {
              return validarDocumento(
                value,
                validarRutChile: provider.validarut,
              );
            },
            labelText: 'Rut/DNI Trabajador',
          ),
        ),

        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 26,
              right: 26,
              top: 13,
              bottom: 13,
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(36, 99, 174, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // <-- Radius
                ),
              ),
              onPressed: () async {
                FocusScope.of(context).unfocus();
                if (!provider.isValidateForm()) return;

                provider.isloading = true;
                String name = provider.controllername.text;
                final documento = separarDocumento(provider.controllerrut.text);
                final rutt = documento.rut;
                final dv = documento.digito;
                int respuesta = await provider.updateworkerentry(
                  rutt,
                  name,
                  worker,
                  dv,
                );
                provider.isloading = false;

                if (respuesta > 0) {
                  if (!context.mounted) return;
                  TrabajadorxContratistaProvider().speak(
                    'Trabajador modificado correctamente',
                  );
                  TrabajadorxContratistaProvider().listadoentregas(
                    worker.idcartilla!,
                  );
                  Navigator.of(context).pop('actualiza');
                }
              },
              child:
                  provider.isloading
                      ? const CupertinoActivityIndicator(color: Colors.white)
                      : const Text(
                        'Actualizar',
                        style: TextStyle(
                          fontFamily: 'MontserratB',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),
        ),
      ],
    );
  }
}
