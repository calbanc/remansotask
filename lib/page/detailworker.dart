import 'package:verfwork/providers/editworkerprovider.dart';
import 'package:verfwork/providers/provider.dart';
import 'package:verfwork/response/response.dart';
import 'package:verfwork/util/VerfrutApp.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailWorker extends StatelessWidget {
  ListadoEntregaResponse worker;
  DetailWorker({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => EditWorkerProvider()),
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
          autovalidateMode: AutovalidateMode.onUserInteraction,
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
  bool _validarut(String? rut) {
    if (rut == null) return false;
    dynamic regExp;
    provider.validarut
        ? regExp = RegExp(r'(^(\d{1,2}(?:[\.]?\d{3}){2}-[\dkK])$)')
        : regExp = RegExp(r'^\d+$');

    ;
    return regExp.hasMatch(rut);
  }

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.only(
            left: 26,
            right: 26,
            top: 13,
            bottom: 13,
          ),
          child: TextFormField(
            onChanged: (value) {
              provider.nombre = value;
            },
            initialValue: worker.nombre,
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
          child: TextFormField(
            onChanged: (value) => provider.rut = value,
            initialValue: worker.rut!,
            validator: (value) {
              return (value == null || value.isEmpty)
                  ? 'Debe ingresar un rut'
                  : _validarut(value)
                  ? null
                  : 'Debe ingresar un rut valido';
            },
            decoration: VerfrutApp.InputDecorationVerf(
              label: 'Rut Trabajador',
              prefixicon: Icons.fingerprint,
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
                String name = worker.nombre!;
                String rutt = worker.rut!;
                provider.nombre != null ? name = provider.nombre! : name;

                provider.rut != null ? rutt = provider.rut! : rutt;
                int respuesta = await provider.updateworkerentry(
                  rutt,
                  name,
                  worker.identrega!,
                );
                provider.isloading = false;

                if (respuesta > 0) {
                  TrabajadorxContratistaProvider().speak(
                    'Trabajador modificado correctamente',
                  );
                  TrabajadorxContratistaProvider().listadoentregas(
                    worker.idcartilla!,
                  );
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
