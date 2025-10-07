import 'dart:ui';

import 'package:verfwork/page/addtrabajador.dart';
import 'package:verfwork/page/detailworker.dart';
import 'package:verfwork/page/options_screen.dart';
import 'package:verfwork/page/page.dart';
import 'package:verfwork/providers/provider.dart';
import 'package:verfwork/response/CartillaQrResponse.dart';
import 'package:verfwork/response/response.dart';
import 'package:verfwork/util/VerfrutApp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../response/ActividadesResponse.dart';
import '../response/CuartelResponse.dart';

class DashboardMain extends StatelessWidget {
  const DashboardMain({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TrabajadorxContratistaProvider>(context);

    alertdialog(
      BuildContext context,
      TrabajadorxContratistaProvider trabajadorcontratisprovider,
      Cartillaqr qr,
    ) async {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return VerfrutApp.DialogalertEnvase(
            mensajecontent:
                'Elige el tipo y cantidad que mayor se adapte a tus necesidades',
            action: Form(
              key: trabajadorcontratisprovider.formalert,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  DropdownMenu(
                    width: 250,
                    label: const Text(
                      'Tipo de Envase',
                      style: TextStyle(fontFamily: 'MonserratR', fontSize: 15),
                    ),
                    hintText: 'Seleccione un envase',
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'MonserratR',
                    ),
                    onSelected: (value) {
                      trabajadorcontratisprovider.cod_env = value.toString();
                    },
                    inputDecorationTheme: const InputDecorationTheme(
                      filled: true,
                      fillColor: Color.fromRGBO(230, 236, 245, 1),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(18)),
                        borderSide: BorderSide(
                          color: Color.fromRGBO(230, 236, 245, 1),
                          width: 0,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(18)),
                        borderSide: BorderSide(
                          color: Color.fromRGBO(230, 236, 245, 1),
                          width: 1,
                        ),
                      ),
                    ),
                    dropdownMenuEntries:
                        trabajadorcontratisprovider.listaenvase!
                            .map(
                              (e) => DropdownMenuEntry(
                                value: e.codEnv,
                                label: e.nomEnv!,
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    controller: trabajadorcontratisprovider.maxenvController,
                    style: const TextStyle(fontFamily: 'MontserratR'),
                    validator: (value) {
                      return (value == null ||
                              value.isEmpty ||
                              value.length > 50)
                          ? 'Debe ingresar una cantidad validad'
                          : null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                      labelText: 'Cantidad Maxima de Entregas',
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(59, 131, 216, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // <-- Radius
                        ),
                      ),
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        if (!trabajadorcontratisprovider
                            .isValidateFormalert()) {
                          return;
                        }

                        qr.codEnv = trabajadorcontratisprovider.cod_env;
                        qr.maxEnv =
                            trabajadorcontratisprovider.maxenvController.text;

                        await trabajadorcontratisprovider.insertarqr(qr);
                        provider.speak('Cartilla registrada correctamente');

                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Confirmar',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'MontserratR',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: VerfrutApp.Verfrutapp(
        title: 'FrutApp Job',
        action: IconButton(
          onPressed: () async {
            Future.microtask(
              () => {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => optionsScreen(),
                    transitionDuration: const Duration(seconds: 1),
                  ),
                ),
              },
            );
          },
          icon: const Icon(Icons.menu, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(59, 131, 216, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // <-- Radius
                      ),
                    ),
                    onPressed: () async {
                      bool conected = await Connectivity_provider().isOnlineNet();
        
                      if (!conected) {
                        provider.speak('Sin conexion no puede sincronizar');
                        return;
                      }
        
                      provider.isLoading = true;
                      provider.speak('Sincronizacion en curso');
                      try {
                        await sincronizaciontrabajadores(provider, context);
                      } catch (e) {
                        provider.isLoading = false;
                        showDialog(
                          context: context,
                          builder: (context) {
                            return VerfrutApp.Dialogalert(
                              icono: Icons.cancel,
                              mensajecontent: 'error sincronizando datos $e',
                            );
                          },
                        );
                      }
        
                      provider.isLoading = false;
                      provider.speak('Sincronizacion finalizada');
                    },
                    child:
                        provider.isLoading
                            ? const CupertinoActivityIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'Sincronizar Datos',
                              style: TextStyle(
                                fontFamily: 'MontserratB',
                                color: Colors.white,
                                //fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Cuarteles',
                  style: TextStyle(fontFamily: 'MontserratR', fontSize: 20),
                ),
              ),
              _cartillasCuarteles(provider: provider),
        
              Container(
                child: Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 30,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Cartilla',
                          style: TextStyle(
                            fontFamily: 'MontserratR',
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: CheckboxListTile(
                        title: Text(
                          'Registro Uno a Uno',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'MontserratR',
                          ),
                        ),
                        value: provider.swunoauno,
                        onChanged: (bool? value) {
                          provider.swunoauno = value!;
                        },
                      ),
                    ),
                  ],
                ),
              ),
        
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(36, 99, 174, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // <-- Radius
                      ),
                    ),
                    onPressed: () async {
                      String str = await VerfrutApp().scanqr(context);
                      var entries = str
                          .substring(1, str.length - 1)
                          .split(RegExp(r',\s?'))
                          .map((e) => e.split(RegExp(r':\s?')))
                          .map((e) => MapEntry(e.first, e.last));
                      var result = Map.fromEntries(entries);
                      Cartillaqr qr = Cartillaqr.fromMap(result);
        
                      final datefechainicio = DateFormat(
                        'dd/MM/yy',
                      ).parse(qr.fechainicio!);
                      final now = DateFormat('dd/MM/yy').format(DateTime.now());
                      final fechainicio = DateFormat(
                        'dd/MM/yy',
                      ).format(datefechainicio);
        
                      if (now.compareTo(fechainicio) == 0) {
                        List<Cartillaqr> respuesta = await provider.consultaqr(
                          qr,
                        );
                        if (respuesta.length > 0) {
                          provider.speak('Cartilla ya registrada');
                          showDialog(
                            context: context,
                            builder: (context) {
                              return VerfrutApp.Dialogalert(
                                icono: Icons.cancel,
                                mensajecontent: 'Cartilla ya registrada',
                              );
                            },
                          );
                        } else {
                          if (qr.idFamilia == '105') {

                            alertdialog(context, provider, qr);
                          } else {
                            int respuesta = await provider.insertarqr(qr);
                            provider.speak('Cartilla registrada correctamente');
                          }
                        }
                      } else {
                        provider.speak('Fecha de termino concluida');
                        showDialog(
                          context: context,
                          builder: (context) {
                            return VerfrutApp.Dialogalert(
                              icono: Icons.cancel,
                              mensajecontent: 'Fecha de termino concluida',
                            );
                          },
                        );
                      }
                    },
                    child: const Text(
                      'Agregar Cartilla',
                      style: TextStyle(
                        fontFamily: 'MontserratB',
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // <-- Radius
                      ),
                    ),
                    onPressed: () async {
                      if (provider.cartillaseleccionada!.idAndroidCartilla ==
                          '') {
                        provider.speak('Debe seleccionar cartilla');
                        showDialog(
                          context: context,
                          builder: (context) {
                            return VerfrutApp.Dialogalert(
                              icono: Icons.cancel,
                              mensajecontent: 'Debe seleccionar cartilla',
                            );
                          },
                        );
                      }
        
                      String barcodeScanRes = await VerfrutApp().scanqr(context);
                      if (barcodeScanRes != "-1") {
                        String idcartilla =
                            provider.cartillaseleccionada!.idAndroidCartilla!;
                        List<Trabajador>? lista = await provider
                            .gettrabajadorbyqr(barcodeScanRes, idcartilla);
        
                        lista!.isEmpty
                            ? Future.microtask(
                              () => {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (_, __, ___) => AddTrabajador(
                                          qr: barcodeScanRes,
                                          idcartilla:
                                              provider.cartillaseleccionada!,
                                        ),
                                    transitionDuration: const Duration(
                                      seconds: 1,
                                    ),
                                  ),
                                ),
                              },
                            )
                            : insertarentrega(
                              provider,
                              barcodeScanRes,
                              lista!,
                              context,
                            );
                      }
                    },
                    child: const Text(
                      'Escanear Codigo QR',
                      style: TextStyle(
                        fontFamily: 'MontserratB',
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'Trabajadores: ${provider.listaentregas.length}  ',
                      style: TextStyle(fontFamily: 'MontserratR', fontSize: 12),
                    ),
        
                    Row(
                      children: [
                        SvgPicture.asset('assets/bins.svg'),
                        SizedBox(width: 5),
                        Text(
                          'Envase: ${provider.contador}',
                          style: TextStyle(
                            fontFamily: 'MontserratR',
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
        
                    Text(
                      'Entregas: ${provider.totalcantidadentregas.toString()}  ',
                      style: TextStyle(fontFamily: 'MontserratR', fontSize: 12),
                    ),
                  ],
                ),
              ),
              provider.listaentregas.isNotEmpty
                  ? SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: _listadoentregas(provider: provider),
                  )
                  : Container(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(child: _bottombar(provider: provider)),
    );
  }
}

class _bottombar extends StatelessWidget {
  const _bottombar({super.key, required this.provider});

  final TrabajadorxContratistaProvider provider;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(218, 37, 29, 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // <-- Radius
            ),
          ),
          onPressed: () async {
            showDialog(
              context: context,
              builder: (context) {
                return VerfrutApp.DialogalertActions(
                  icono: Icons.close,
                  options: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(59, 131, 216, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // <-- Radius
                        ),
                      ),
                      onPressed: () {
                        provider.updatehoratermino(
                          provider.cartillaseleccionada!.idAndroidCartilla!,
                        );
                        provider.speak('Cartilla cerrada correctamente');
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Cerrar',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'MontserratB',
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(218, 37, 29, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // <-- Radius
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'MontserratR',
                        ),
                      ),
                    ),
                  ],
                  mensajecontent: 'Desea cerrar la siguiente cartilla',
                );
              },
            );
          },
          child: const Text(
            'Cerrar Cartilla',
            style: TextStyle(
              fontFamily: 'MontserratB',
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _cartillasCuarteles extends StatelessWidget {
  const _cartillasCuarteles({super.key, required this.provider});

  final TrabajadorxContratistaProvider provider;

  @override
  Widget build(BuildContext context) {
    alertdialog(
      BuildContext context,
      TrabajadorxContratistaProvider trabajadorcontratisprovider,
      Cartillaqr qr,
    ) async {
      // trabajadorcontratisprovider.maxenvController.text=qr.maxEnv!.isEmpty ? '' : qr.maxEnv!;

      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return VerfrutApp.DialogalertEnvase(
            mensajecontent:
                'Elige el tipo y cantidad que mayor se adapte a tus necesidades',
            action: Form(
              key: trabajadorcontratisprovider.formalert,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  DropdownMenu(
                    width: 250,
                    label: const Text(
                      'Tipo de Envase',
                      style: TextStyle(fontFamily: 'MonserratR', fontSize: 15),
                    ),
                    hintText: 'Seleccione un envase',
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'MonserratR',
                    ),
                    onSelected: (value) {
                      trabajadorcontratisprovider.cod_env = value.toString();
                    },
                    inputDecorationTheme: const InputDecorationTheme(
                      filled: true,
                      fillColor: Color.fromRGBO(230, 236, 245, 1),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(18)),
                        borderSide: BorderSide(
                          color: Color.fromRGBO(230, 236, 245, 1),
                          width: 0,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(18)),
                        borderSide: BorderSide(
                          color: Color.fromRGBO(230, 236, 245, 1),
                          width: 1,
                        ),
                      ),
                    ),
                    dropdownMenuEntries:
                        trabajadorcontratisprovider.listaenvase!
                            .map(
                              (e) => DropdownMenuEntry(
                                value: e.codEnv,
                                label: e.nomEnv!,
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    controller: trabajadorcontratisprovider.maxenvController,
                    style: const TextStyle(fontFamily: 'MontserratR'),
                    validator: (value) {
                      return (value == null ||
                              value.isEmpty ||
                              value.length > 50)
                          ? 'Debe ingresar una cantidad validad'
                          : null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                      labelText: 'Cantidad Maxima de Entregas',
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(59, 131, 216, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // <-- Radius
                        ),
                      ),
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        if (!trabajadorcontratisprovider
                            .isValidateFormalert()) {
                          return;
                        }

                        qr.codEnv = trabajadorcontratisprovider.cod_env;
                        qr.maxEnv =
                            trabajadorcontratisprovider.maxenvController.text;

                        await trabajadorcontratisprovider.updateenvcartilla(qr);
                        trabajadorcontratisprovider.formalert.currentState!
                            .reset();

                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Confirmar',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'MontserratR',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.23,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        itemCount: provider.cartillasdisponibles.length + 1,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          if (index != provider.cartillasdisponibles.length) {
            String cuartel = provider.cartillasdisponibles[index].nomCuartel!;
            String variedad = provider.cartillasdisponibles[index].nomVariedad!;
            String labor = provider.cartillasdisponibles[index].nomActividad!;
            String contratista =
                provider.cartillasdisponibles[index].nomContratista!;
            provider.cartillaseleccionada ??
                (provider.cartillaseleccionada =
                    provider.cartillasdisponibles.first);
            String codenv =
                provider.cartillasdisponibles[index].codEnv != 'null'
                    ? provider.cartillasdisponibles[index].codEnv! +
                        ' ' +
                        provider.cartillasdisponibles[index].nomEnv!
                    : '';
            int cant_bins = provider.cartillasdisponibles[index].cantBins!;
            return GestureDetector(
              onTap: () async {
                provider.cartillaseleccionada =
                    provider.cartillasdisponibles[index];

                if ((provider.cartillaseleccionada!.codEnv!.isEmpty ||
                        provider.cartillaseleccionada!.codEnv == 'null') &&
                    provider.listaenvase.isNotEmpty) {
                  alertdialog(
                    context,
                    provider,
                    provider.cartillaseleccionada!,
                  );
                }
              },
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.18,
                width: 190,
                child: Card(
                  color:
                      provider.cartillaseleccionada!.idAndroidCartilla ==
                              provider
                                  .cartillasdisponibles[index]
                                  .idAndroidCartilla
                          ? Color.fromRGBO(36, 99, 174, 1)
                          : Colors.white,
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
                                  color: const Color.fromRGBO(
                                    210,
                                    172,
                                    130,
                                    0.5,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                height: 50,
                                width: 50,
                                child: Image.asset('assets/cuartel.png'),
                              ),
                            ),

                            provider.cartillasdisponibles[index].idFamilia ==
                                    '105'
                                ? IconButton(
                                  onPressed: () async {

                                    if ((provider
                                                .cartillaseleccionada!
                                                .codEnv!
                                                .isNotEmpty ||
                                            provider
                                                    .cartillaseleccionada!
                                                    .codEnv !=
                                                'null') &&
                                        provider.listaenvase.isNotEmpty) {
                                      alertdialog(
                                        context,
                                        provider,
                                        provider.cartillaseleccionada!,
                                      );
                                    }
                                  },
                                  icon: Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                    color:
                                        provider
                                                    .cartillaseleccionada!
                                                    .idAndroidCartilla ==
                                                provider
                                                    .cartillasdisponibles[index]
                                                    .idAndroidCartilla
                                            ? Colors.white
                                            : Colors.black,
                                  ),
                                )
                                : Container(),
                          ],
                        ),

                        Text(
                          cuartel,
                          style: TextStyle(
                            fontFamily: 'MontserratR',
                            fontSize: 14,
                            color:
                                provider
                                            .cartillaseleccionada!
                                            .idAndroidCartilla ==
                                        provider
                                            .cartillasdisponibles[index]
                                            .idAndroidCartilla
                                    ? Colors.white
                                    : null,
                          ),
                        ),
                        Text(
                          variedad,
                          style: TextStyle(
                            fontFamily: 'MontserratR',
                            fontSize: 10,
                            color:
                                provider
                                            .cartillaseleccionada!
                                            .idAndroidCartilla ==
                                        provider
                                            .cartillasdisponibles[index]
                                            .idAndroidCartilla
                                    ? Colors.red
                                    : Color.fromRGBO(36, 99, 174, 1),
                          ),
                        ),
                        Text(
                          labor,
                          style: TextStyle(
                            fontFamily: 'MontserratR',
                            fontSize: 10,
                            color:
                                provider
                                            .cartillaseleccionada!
                                            .idAndroidCartilla ==
                                        provider
                                            .cartillasdisponibles[index]
                                            .idAndroidCartilla
                                    ? Colors.white
                                    : null,
                          ),
                        ),
                        Text(
                          codenv,
                          style: TextStyle(
                            fontFamily: 'MontserratR',
                            fontSize: 10,
                            color:
                                provider
                                            .cartillaseleccionada!
                                            .idAndroidCartilla ==
                                        provider
                                            .cartillasdisponibles[index]
                                            .idAndroidCartilla
                                    ? Colors.white
                                    : null,
                          ),
                        ),
                        Text(
                          'Cantidad de bins: $cant_bins ',
                          style: TextStyle(
                            fontFamily: 'MontserratR',
                            fontSize: 10,
                            color:
                                provider
                                            .cartillaseleccionada!
                                            .idAndroidCartilla ==
                                        provider
                                            .cartillasdisponibles[index]
                                            .idAndroidCartilla
                                    ? Colors.white
                                    : Color.fromRGBO(36, 99, 174, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class _listadoentregas extends StatelessWidget {
  const _listadoentregas({super.key, required this.provider});

  final TrabajadorxContratistaProvider provider;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: provider.listaentregas.length,
      itemBuilder: (context, index) {
        String nombre = provider.listaentregas[index].nombre!;
        String entregas = provider.listaentregas[index].cantidad!.toString();
        String labor = provider.listaentregas[index].labor!;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                width: 0.5,
                color: Color.fromRGBO(195, 195, 195, 1),
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 70,
                  width: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Image.asset('assets/trabajador.png'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre,
                        style: const TextStyle(
                          fontFamily: 'MontserratR',
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Entregas: $entregas',
                        style: const TextStyle(
                          fontFamily: 'MontserratR',
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        labor,
                        style: const TextStyle(
                          fontFamily: 'MontserratR',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  child: const Icon(
                    Icons.more_vert,
                    color: Color.fromRGBO(36, 99, 174, 1),
                  ),
                  onSelected: (value) async {
                    if (value == "lessentry") {
                      provider.updateentrycant(provider.listaentregas[index]);

                      provider.listadoentregas(
                        provider.listaentregas[index].idcartilla!,
                      );
                      provider.speak('Entrega eliminada');
                      // add desired output
                    } else if (value == "edit") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => DetailWorker(
                                worker: provider.listaentregas[index],
                              ),
                        ),
                      );

                      // add desired output
                    } else if (value == "delete") {
                      provider.deleteentregas(provider.listaentregas[index]);

                      provider.listadoentregas(
                        provider.listaentregas[index].idcartilla!,
                      );
                      provider.speak('Trabajador eliminado');
                      // add desired output
                    }
                  },
                  itemBuilder:
                      (BuildContext context) => <PopupMenuEntry>[
                        const PopupMenuItem(
                          value: "lessentry",
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Icon(Icons.exposure_neg_1),
                              ),
                              Text(
                                'Eliminar entrega',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'MontserratR',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: "edit",
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Icon(Icons.change_circle),
                              ),
                              Text(
                                'Editar Trabajador',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'MontserratR',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: "delete",
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Icon(Icons.delete, color: Colors.red),
                              ),
                              Text(
                                'Eliminar trabajador',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'MontserratR',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

insertarentrega(
  TrabajadorxContratistaProvider provider,
  String barcodeScanRes,
  List<Trabajador> trabajador,
  BuildContext context,
) async {
  final date = DateFormat('dd/MM/yyyy').format(DateTime.now());
  final hora = DateTime.now();

  if (provider.swunoauno == true) {
    Entrega entrega = Entrega(
      idcartilla: provider.cartillaseleccionada!.idAndroidCartilla,
      qr: trabajador[0].qr,
      nombre: trabajador[0].nombre,
      digito: trabajador[0].digito,
      rut: trabajador[0].rut!,
      idempresa: trabajador[0].idempresa,
      IdTrabXContratista: trabajador[0].idtrabxcontratista,
      cantidad: 1,
      fecha: date,
      hora: hora.toString(),
      swsincronizado: '0',
    );

    List<Entrega>? listaentregado = await provider.entrega(entrega);
    if (provider.cartillaseleccionada!.idFamilia == '105' &&
        provider.cartillaseleccionada!.codEnv != 'null' && provider.cartillaseleccionada!.maxEnv!=null) {
      int contador = await TrabajadorxContratistaProvider().getcountentrybyid(
        provider.cartillaseleccionada!.idAndroidCartilla!,
      );

      Contador_bins contadorbins = Contador_bins(
        idAndroidCartilla: provider.cartillaseleccionada!.idAndroidCartilla!,
        cant: contador + 1,
      );
      if (int.parse(provider.cartillaseleccionada!.maxEnv!) >= contador + 1) {
        await TrabajadorxContratistaProvider().insertcontador(contadorbins);
        if (listaentregado == null) {
          provider.speak('Entrega ${entrega.cantidad} confirmada');
          final insert = await provider.insertentry(entrega);
          List<Cartillaqr>? fechainiciocartilla = await provider
              .getfechainiciobyidcartilla(
                provider.cartillaseleccionada!.idAndroidCartilla!,
              );
          fechainiciocartilla == null || fechainiciocartilla.length == 0
              ? null
              : provider.updatehorainicio(
                provider.cartillaseleccionada!.idAndroidCartilla!,
              );
        } else {
          DateTime horaentrega = DateTime.parse(listaentregado[0].hora!);
          Duration diff1 = hora.difference(horaentrega);
          if (diff1.inSeconds > 3) {
            Entrega nuevaentrega = Entrega(
              identrega: listaentregado[0].identrega,
              nombre: listaentregado[0].nombre,
              digito: listaentregado[0].digito,
              rut: listaentregado[0].rut!,
              idempresa: listaentregado[0].idempresa,
              IdTrabXContratista: listaentregado[0].IdTrabXContratista,
              idcartilla: listaentregado[0].idcartilla,
              qr: listaentregado[0].qr,
              cantidad: listaentregado[0].cantidad! + 1,
              fecha: date,
              hora: hora.toString(),
              swsincronizado: '0',
            );
            final update = await provider.updateentry(nuevaentrega);

            provider.speak('Entrega ${nuevaentrega.cantidad} confirmada');
            List<Cartillaqr>? fechainiciocartilla = await provider
                .getfechainiciobyidcartilla(
                  provider.cartillaseleccionada!.idAndroidCartilla!,
                );
            fechainiciocartilla == null || fechainiciocartilla.length == 0
                ? null
                : provider.updatehorainicio(
                  provider.cartillaseleccionada!.idAndroidCartilla!,
                );
          }
        }
      } else {
        provider.speak('Debe cerrar el envase antes');
      }
    } else {
      if (listaentregado == null) {
        provider.speak('Entrega ${entrega.cantidad} confirmada');
        final insert = await provider.insertentry(entrega);
        List<Cartillaqr>? fechainiciocartilla = await provider
            .getfechainiciobyidcartilla(
              provider.cartillaseleccionada!.idAndroidCartilla!,
            );
        fechainiciocartilla == null || fechainiciocartilla.length == 0
            ? null
            : provider.updatehorainicio(
              provider.cartillaseleccionada!.idAndroidCartilla!,
            );
      } else {
        DateTime horaentrega = DateTime.parse(listaentregado[0].hora!);
        Duration diff1 = hora.difference(horaentrega);
        if (diff1.inSeconds > 3) {
          Entrega nuevaentrega = Entrega(
            identrega: listaentregado[0].identrega,
            nombre: listaentregado[0].nombre,
            digito: listaentregado[0].digito,
            rut: listaentregado[0].rut!,
            idempresa: listaentregado[0].idempresa,
            IdTrabXContratista: listaentregado[0].IdTrabXContratista,
            idcartilla: listaentregado[0].idcartilla,
            qr: listaentregado[0].qr,
            cantidad: listaentregado[0].cantidad! + 1,
            fecha: date,
            hora: hora.toString(),
            swsincronizado: '0',
          );
          final update = await provider.updateentry(nuevaentrega);

          provider.speak('Entrega ${nuevaentrega.cantidad} confirmada');
          List<Cartillaqr>? fechainiciocartilla = await provider
              .getfechainiciobyidcartilla(
                provider.cartillaseleccionada!.idAndroidCartilla!,
              );
          fechainiciocartilla == null || fechainiciocartilla.length == 0
              ? null
              : provider.updatehorainicio(
                provider.cartillaseleccionada!.idAndroidCartilla!,
              );
        }
      }
    }
  } else {
    late String cantidad;
    showDialog(
      context: context,
      builder: (context) {
        return VerfrutApp.DialogalertActions(
          icono: Icons.add,
          mensajecontent: 'Ingresar numero de entregas',
          cantidad: TextFormField(
            onChanged: (value) => cantidad = value,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
              ),
              hintText: 'Ingrese cantidad',
              labelText: 'Cantidad de entregas',
            ),
          ),
          options: [
            ElevatedButton(
              onPressed: () async {
                FocusScope.of(context).unfocus();
                Entrega entrega = Entrega(
                  idcartilla: provider.cartillaseleccionada!.idAndroidCartilla,
                  qr: trabajador[0].qr,
                  nombre: trabajador[0].nombre,
                  digito: trabajador[0].digito,
                  rut: trabajador[0].rut!,
                  idempresa: trabajador[0].idempresa,
                  IdTrabXContratista: trabajador[0].idtrabxcontratista,
                  cantidad: int.parse(cantidad),
                  fecha: date,
                  hora: hora.toString(),
                  swsincronizado: '0',
                );
                if (provider.cartillaseleccionada!.idFamilia == '105' &&
                    provider.cartillaseleccionada!.codEnv != 'null') {
                  int contador = await TrabajadorxContratistaProvider()
                      .getcountentrybyid(
                        provider.cartillaseleccionada!.idAndroidCartilla!,
                      );

                  Contador_bins contadorbins = Contador_bins(
                    idAndroidCartilla:
                        provider.cartillaseleccionada!.idAndroidCartilla!,
                    cant: contador + entrega.cantidad!,
                  );
                  if (int.parse(provider.cartillaseleccionada!.maxEnv!) >=
                      contadorbins.cant!) {
                    await TrabajadorxContratistaProvider().insertcontador(
                      contadorbins,
                    );
                    List<Entrega>? listaentregado = await provider.entrega(
                      entrega,
                    );
                    if (listaentregado == null) {
                      provider.speak('Entrega ${entrega.cantidad} confirmada');
                      final insert = await provider.insertentry(entrega);
                      List<Cartillaqr>? fechainiciocartilla = await provider
                          .getfechainiciobyidcartilla(
                            provider.cartillaseleccionada!.idAndroidCartilla!,
                          );
                      fechainiciocartilla == null ||
                              fechainiciocartilla.length == 0
                          ? null
                          : provider.updatehorainicio(
                            provider.cartillaseleccionada!.idAndroidCartilla!,
                          );
                    } else {
                      DateTime horaentrega = DateTime.parse(
                        listaentregado[0].hora!,
                      );
                      Duration diff1 = hora.difference(horaentrega);
                      if (diff1.inSeconds > 3) {
                        Entrega nuevaentrega = Entrega(
                          identrega: listaentregado[0].identrega,
                          nombre: listaentregado[0].nombre,
                          digito: listaentregado[0].digito,
                          rut: listaentregado[0].rut!,
                          idempresa: listaentregado[0].idempresa,
                          IdTrabXContratista:
                              listaentregado[0].IdTrabXContratista,
                          idcartilla: listaentregado[0].idcartilla,
                          qr: listaentregado[0].qr,
                          cantidad:
                              listaentregado[0].cantidad! + int.parse(cantidad),
                          fecha: date,
                          hora: hora.toString(),
                          swsincronizado: '0',
                        );
                        final update = await provider.updateentry(nuevaentrega);

                        provider.speak(
                          'Entrega ${nuevaentrega.cantidad} confirmada',
                        );
                        List<Cartillaqr>? fechainiciocartilla = await provider
                            .getfechainiciobyidcartilla(
                              provider.cartillaseleccionada!.idAndroidCartilla!,
                            );
                        fechainiciocartilla == null ||
                                fechainiciocartilla.length == 0
                            ? null
                            : provider.updatehorainicio(
                              provider.cartillaseleccionada!.idAndroidCartilla!,
                            );
                      }
                    }
                    provider.listadoentregas(
                      provider.cartillaseleccionada!.idAndroidCartilla!,
                    );
                    Navigator.pop(context);
                  } else {
                    //cerrar el envase
                  }
                } else {
                  List<Entrega>? listaentregado = await provider.entrega(
                    entrega,
                  );
                  if (listaentregado == null) {
                    provider.speak('Entrega ${entrega.cantidad} confirmada');
                    final insert = await provider.insertentry(entrega);
                    List<Cartillaqr>? fechainiciocartilla = await provider
                        .getfechainiciobyidcartilla(
                          provider.cartillaseleccionada!.idAndroidCartilla!,
                        );
                    fechainiciocartilla == null ||
                            fechainiciocartilla.length == 0
                        ? null
                        : provider.updatehorainicio(
                          provider.cartillaseleccionada!.idAndroidCartilla!,
                        );
                  } else {
                    DateTime horaentrega = DateTime.parse(
                      listaentregado[0].hora!,
                    );
                    Duration diff1 = hora.difference(horaentrega);
                    if (diff1.inSeconds > 3) {
                      Entrega nuevaentrega = Entrega(
                        identrega: listaentregado[0].identrega,
                        nombre: listaentregado[0].nombre,
                        digito: listaentregado[0].digito,
                        rut: listaentregado[0].rut!,
                        idempresa: listaentregado[0].idempresa,
                        IdTrabXContratista:
                            listaentregado[0].IdTrabXContratista,
                        idcartilla: listaentregado[0].idcartilla,
                        qr: listaentregado[0].qr,
                        cantidad:
                            listaentregado[0].cantidad! + int.parse(cantidad),
                        fecha: date,
                        hora: hora.toString(),
                        swsincronizado: '0',
                      );
                      final update = await provider.updateentry(nuevaentrega);

                      provider.speak(
                        'Entrega ${nuevaentrega.cantidad} confirmada',
                      );
                      List<Cartillaqr>? fechainiciocartilla = await provider
                          .getfechainiciobyidcartilla(
                            provider.cartillaseleccionada!.idAndroidCartilla!,
                          );
                      fechainiciocartilla == null ||
                              fechainiciocartilla.length == 0
                          ? null
                          : provider.updatehorainicio(
                            provider.cartillaseleccionada!.idAndroidCartilla!,
                          );
                    }
                  }
                  provider.listadoentregas(
                    provider.cartillaseleccionada!.idAndroidCartilla!,
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(59, 131, 216, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // <-- Radius
                ),
              ),
              child: const Text(
                'Aceptar',
                style: TextStyle(
                  fontFamily: 'MontserratR',
                  color: Colors.white,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(218, 37, 29, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // <-- Radius
                ),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  fontFamily: 'MontserratR',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  provider.listadoentregas(provider.cartillaseleccionada!.idAndroidCartilla!);
}

Future<void> sincronizaciontrabajadores(
  TrabajadorxContratistaProvider provider,
  BuildContext context,
) async {
  List<Trabajador> respuesta = await provider.getlistado(
    provider.cartillasdisponibles[0].idAndroidCartilla!,
  );

  if (respuesta.isNotEmpty) {
    respuesta.forEach(
      (element) async => {
        await provider.insertatrabajadorescontratista(element),
      },
    );
  }

  http.Response response = await provider.getcuarteles(
    provider.cartillasdisponibles[0].idAndroidCartilla!,
  );
  if (response.statusCode == 200) {
    final cuartelresponse = CuartelResponse.fromJson(response.body);
    List<Cuarteles> listacuartels = cuartelresponse.cuartel;
    await provider.insertcuarteles(listacuartels);
  }

  List<Actividade> respuestaactividades = await provider.getmaestroactividades(
    provider.cartillasdisponibles[0].idEmpresa!,
  );
  await provider.insertmaestrolavores(respuestaactividades);

  List<Cartillaqr> respuestacartilla = await provider.getcartillastosync(false);

  for (Cartillaqr lista in respuestacartilla) {
    String mensaje = await provider.synccartillashoras(lista);
    if (mensaje == 'error') {
      showDialog(
        context: context,
        builder: (context) {
          return VerfrutApp.Dialogalert(
            icono: Icons.cancel,
            mensajecontent: 'Error sincronizando cartillas',
          );
        },
      );
    }
  }

  List<EntregaResponse> listaentregasnolocal = await provider.getentryforsync(
    false,
  );

  for (EntregaResponse lista in listaentregasnolocal) {
    String message = await provider.sync(lista);
    if (message == 'error') {
      showDialog(
        context: context,
        builder: (context) {
          return VerfrutApp.Dialogalert(
            icono: Icons.cancel,
            mensajecontent: 'Error sincronizando entregas',
          );
        },
      );
    }
  }
}
