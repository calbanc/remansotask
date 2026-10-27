import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart'
    as googlekit;
import 'package:image_picker/image_picker.dart';
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

    // Redirect to login if no cartillas available
    Future<String?> _showActionSheet(BuildContext context) async {
      return await showCupertinoModalPopup<String>(
        context: context,
        builder:
            (BuildContext context) => CupertinoActionSheet(
              title: const Text('Opciones'),
              actions: <CupertinoActionSheetAction>[
                CupertinoActionSheetAction(
                  onPressed: () async {
                    final String qr = await VerfrutApp().scanqr(context);
                    Navigator.pop(context, qr);

                    //Navigator.pop(context, 'camera'); // devuelve la opción
                  },
                  child: const Text(
                    'Scanear qr',
                    style: TextStyle(fontSize: 12, fontFamily: 'MontserratR'),
                  ),
                ),
                CupertinoActionSheetAction(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final XFile? file = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (file == null) return;
                    final scanner = googlekit.BarcodeScanner(
                      formats: [
                        googlekit.BarcodeFormat.qrCode,
                      ], // fuerza solo QR
                    );

                    final input = googlekit.InputImage.fromFilePath(file.path);
                    final barcodes = await scanner.processImage(input);

                    if (barcodes.isEmpty) {
                      Navigator.pop(context, '');
                      return;
                    }
                    final String? raw = barcodes.first.rawValue;
                    Navigator.pop(context, raw);
                  },
                  child: const Text(
                    'Seleccionar Qr',
                    style: TextStyle(fontSize: 12, fontFamily: 'MontserratR'),
                  ),
                ),
                CupertinoActionSheetAction(
                  isDestructiveAction: true,
                  onPressed: () {
                    Navigator.pop(
                      context,
                      'cancelar',
                    ); // puedes devolver null si prefieres
                  },
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'MontserratR',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
                        if (provider.isLoading) return;

                        bool conected =
                            await Connectivity_provider().isOnlineNet();

                        if (!conected) {
                          provider.speak('Sin conexion no puede sincronizar');
                          return;
                        }

                        if (!context.mounted) {
                          return;
                        }

                        provider.isLoading = true;
                        provider.startSyncProgress();
                        provider.speak('Sincronizacion en curso');

                        List<String> syncMessages = [];
                        Object? syncError;
                        bool syncDialogVisible = false;
                        try {
                          _showSyncProgressDialog(context, provider);
                          syncDialogVisible = true;
                          await Future<void>.delayed(
                            const Duration(milliseconds: 100),
                          );

                          syncMessages = await sincronizaciontrabajadores(
                            provider,
                          );
                          provider.updateSyncProgress(
                            1,
                            'Sincronizacion finalizada',
                          );
                          await Future.delayed(
                            const Duration(milliseconds: 300),
                          );
                        } catch (e) {
                          syncError = e;
                        } finally {
                          if (syncDialogVisible && context.mounted) {
                            Navigator.of(context, rootNavigator: true).pop();
                          }
                          provider.finishSyncProgress();
                          provider.isLoading = false;
                        }

                        if (!context.mounted) {
                          return;
                        }

                        if (syncError != null) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return VerfrutApp.Dialogalert(
                                icono: Icons.cancel,
                                mensajecontent:
                                    'error sincronizando datos $syncError',
                              );
                            },
                          );
                          return;
                        }

                        final selectedCartilla = provider.cartillaseleccionada;
                        final selectedCartillaId =
                            selectedCartilla?.idAndroidCartilla;
                        if (selectedCartillaId != null &&
                            selectedCartillaId.isNotEmpty) {
                          await provider.listadoentregas(selectedCartillaId);
                        }

                        if (!context.mounted) {
                          return;
                        }

                        if (syncMessages.isNotEmpty) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return VerfrutApp.Dialogalert(
                                icono: Icons.cancel,
                                mensajecontent: syncMessages.join('\n'),
                              );
                            },
                          );
                        }

                        Fluttertoast.showToast(
                          msg: 'Sincronizacion culminada',
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                        );
                        provider.speak('Sincronizacion culminada');
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

                //provider.cartillasdisponibles.isEmpty ? const _RedirectToLogin() :  _cartillasCuarteles(provider: provider),
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
                            provider.cambiartipolectura(
                              provider.cartillaseleccionada!,
                              value,
                            );
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
                        try {
                          String str = await _showActionSheet(context) ?? '';

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
                          final now = DateFormat(
                            'dd/MM/yy',
                          ).format(DateTime.now());
                          final fechainicio = DateFormat(
                            'dd/MM/yy',
                          ).format(datefechainicio);

                          if (now.compareTo(fechainicio) == 0) {
                            List<Cartillaqr> respuesta = await provider
                                .consultaqr(qr);
                            if (respuesta.length > 0) {
                              provider.speak('Cartilla ya registrada');

                              showDialog(
                                context: context,
                                builder: (context) {
                                  return VerfrutApp.DialogalertIso(
                                    mensajecontent:
                                        'Cartilla ya registrada,desea abrirla?',
                                    action: SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.5,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                              onPressed: () async {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text(
                                                'No',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Color.fromRGBO(
                                                  36,
                                                  99,
                                                  175,
                                                  1,
                                                ),
                                              ),
                                              onPressed: () async {
                                                await provider.abrircartilla(
                                                  qr.idAndroidCartilla!,
                                                );

                                                await provider
                                                    .getcartillasdisponibles();
                                                provider.cartillaseleccionada =
                                                    qr;
                                                Navigator.of(context).pop();
                                              },
                                              child: Text(
                                                'Si',
                                                style: TextStyle(
                                                  color: Colors.white,
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
                            } else {
                              int respuesta = await provider.insertarqr(qr);
                              provider.speak(
                                'Cartilla registrada correctamente',
                              );
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
                        } catch (e) {
                          showDialog(
                            context: context,
                            builder:
                                (BuildContext context) => CupertinoAlertDialog(
                                  title: Text("Qr Invalido"),
                                  content: Text(
                                    "Estimado usuario QR escaneado no es valido, fecha de termino ya concluida $e",
                                  ),
                                ),
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

                        String barcodeScanRes = await VerfrutApp().scanqr(
                          context,
                        );
                        if (barcodeScanRes != "-1" ||
                            barcodeScanRes.isNotEmpty) {
                          if (barcodeScanRes.length > 10) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return VerfrutApp.Dialogalert(
                                  icono: Icons.warning_amber_rounded,
                                  mensajecontent: 'Codigo QR no valido',
                                );
                              },
                            );
                            return;
                          }

                          String idcartilla =
                              provider.cartillaseleccionada!.idAndroidCartilla!;
                          List<Trabajador>? lista = await provider
                              .gettrabajadorbyqr(barcodeScanRes, idcartilla);

                          if (lista!. isEmpty) {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => AddTrabajador(
                                      qr: barcodeScanRes,
                                      idcartilla:
                                          provider.cartillaseleccionada!,
                                    ),
                              ),
                            );
                            await provider.listadoentregas(
                              provider.cartillaseleccionada!.idAndroidCartilla!,
                            );
                          } else {
                            insertarentrega(
                              provider,
                              barcodeScanRes,
                              lista!,
                              context,
                            );
                          }
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
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: TabBar(
                      onTap: (i) {
                        // si el tab 3 no está habilitado, no permitimos ir

                        if (provider.cartillaseleccionada!.codEnvContenedor ==
                            null) {
                          Fluttertoast.showToast(
                            msg: 'No se puede acceder a esta pestaña',
                          );
                          provider.setTabIndex(0);
                          return;
                        } else {
                          provider.setTabIndex(i);
                        }
                      },
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorColor: const Color.fromRGBO(36, 99, 174, 1),
                      indicatorWeight: 3,
                      labelColor: const Color.fromRGBO(36, 99, 174, 1),
                      unselectedLabelColor: Colors.black87,
                      dividerColor: Colors.transparent,
                      tabs: [
                        Tab(
                          child: Text(
                            'Trabajadores: ${provider.listaentregas.length}',
                            style: const TextStyle(
                              fontFamily: 'MontserratR',
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Tab(
                          child: Text(
                            'Entregas: ${provider.totalcantidadentregas.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontFamily: 'MontserratR',
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset('assets/bins.svg', height: 14),
                              const SizedBox(width: 5),
                              Text(
                                'Unid Cont: ${provider.contador}',
                                style: const TextStyle(
                                  fontFamily: 'MontserratR',
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
      ),
    );
  }
}

void _showSyncProgressDialog(
  BuildContext context,
  TrabajadorxContratistaProvider syncProvider,
) {
  showDialog(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    builder: (context) {
      return ChangeNotifierProvider.value(
        value: syncProvider,
        child: PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: Colors.white,
            content: Consumer<TrabajadorxContratistaProvider>(
              builder: (context, provider, child) {
                final progress = provider.syncProgress.clamp(0, 1).toDouble();

                return SizedBox(
                  width: 260,
                  height: 120,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Sincronizando datos',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'MontserratB',
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      LinearProgressIndicator(
                        minHeight: 8,
                        value: progress,
                        backgroundColor: const Color.fromRGBO(230, 236, 245, 1),
                        color: const Color.fromRGBO(36, 99, 174, 1),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        provider.syncProgressMessage,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'MontserratR',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
    },
  );
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
            bool result = await provider.dataavailabletosync();
            if (result) {
              showDialog(
                context: context,
                builder: (context) {
                  return VerfrutApp.Dialogalert(
                    icono: Icons.warning,
                    mensajecontent:
                        'Tiene datos por sincronizar, no puede cerrar cartilla',
                  );
                },
              );
              return;
            }
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
                      onPressed: () async {
                        try {
                          await provider.updatehoratermino(
                            provider.cartillaseleccionada!.idAndroidCartilla!,
                          );

                          List<Cartillaqr> respuestacartilla = await provider
                              .getcartillastosync(false);

                          for (Cartillaqr lista in respuestacartilla) {
                            String mensaje = await provider.synccartillashoras(
                              lista,
                            );
                            if (mensaje == 'error') {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return VerfrutApp.Dialogalert(
                                    icono: Icons.cancel,
                                    mensajecontent:
                                        'Error sincronizando cartillas',
                                  );
                                },
                              );
                            }
                          }

                          if (provider.cartillasdisponibles.isEmpty) {
                            Navigator.pushReplacementNamed(context, 'login');
                            return;
                          }

                          Navigator.pop(context);
                        } catch (e) {
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
          child:
              provider.tabIndex == 2
                  ? Text(
                    'Cerrar Unidad Contenedora',
                    style: TextStyle(
                      fontFamily: 'MontserratB',
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  )
                  : Text(
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
    if (provider.cartillasdisponibles.isEmpty) {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.23,
      );
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.23,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        itemCount: provider.cartillasdisponibles.length,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final cartilla = provider.cartillasdisponibles[index];
          final selectedCartilla =
              provider.cartillaseleccionada ??
              provider.cartillasdisponibles.first;
          final isSelected =
              selectedCartilla.idAndroidCartilla == cartilla.idAndroidCartilla;
          String cuartel = cartilla.nomCuartel!;
          String variedad = cartilla.nomVariedad!;
          String labor = cartilla.nomActividad!;
          String codenv =
              cartilla.codEnv != 'null'
                  ? cartilla.codEnv! + ' ' + cartilla.nomEnv!
                  : '';
          int cant_bins = cartilla.cantBins!;
          return GestureDetector(
            onTap: () async {
              provider.cartillaseleccionada = cartilla;
            },
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.18,
              width: 190,
              child: Card(
                color:
                    isSelected ? Color.fromRGBO(36, 99, 174, 1) : Colors.white,
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
                        cuartel,
                        style: TextStyle(
                          fontFamily: 'MontserratR',
                          fontSize: 14,
                          color: isSelected ? Colors.white : null,
                        ),
                      ),
                      Text(
                        variedad,
                        style: TextStyle(
                          fontFamily: 'MontserratR',
                          fontSize: 10,
                          color:
                              isSelected
                                  ? Colors.red
                                  : Color.fromRGBO(36, 99, 174, 1),
                        ),
                      ),
                      Text(
                        labor,
                        style: TextStyle(
                          fontFamily: 'MontserratR',
                          fontSize: 10,
                          color: isSelected ? Colors.white : null,
                        ),
                      ),
                      Text(
                        codenv,
                        style: TextStyle(
                          fontFamily: 'MontserratR',
                          fontSize: 10,
                          color: isSelected ? Colors.white : null,
                        ),
                      ),
                      Text(
                        'Cantidad de bins: $cant_bins ',
                        style: TextStyle(
                          fontFamily: 'MontserratR',
                          fontSize: 10,
                          color:
                              isSelected
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
        String rut = provider.listaentregas[index].rut!;
        String dv = provider.listaentregas[index].digito!;
        String qr = provider.listaentregas[index].qr!;
        final isSynced = provider.listaentregas[index].swsincronizado == '1';
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: isSynced ? 1.5 : 0.5,
                color:
                    isSynced
                        ? Colors.green
                        : const Color.fromRGBO(195, 195, 195, 1),
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  height: 70,
                  width: 70,
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: Image.asset('assets/trabajador.png'),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(
                        qr,
                        style: const TextStyle(
                          fontFamily: 'MontserratR',
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        nombre,
                        style: const TextStyle(
                          fontFamily: 'MontserratR',
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${rut}-${dv} ',
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
                      SizedBox(height: 4),
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
                      final k = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => DetailWorker(
                                worker: provider.listaentregas[index],
                              ),
                        ),
                      );
                      await provider.listadoentregas(
                        provider.listaentregas[index].idcartilla!,
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

    if (listaentregado == null) {
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

      String cantidadFormateada = entrega.cantidad!.toInt().toString();

      // Es un número entero

      provider.speak('Entrega ${cantidadFormateada} confirmada');
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

        String cantidadFormateada;
        if (nuevaentrega.cantidad! % 1 == 0) {
          // Es un número entero
          cantidadFormateada = nuevaentrega.cantidad!.toInt().toString();
        } else {
          // Tiene decimales
          cantidadFormateada = nuevaentrega.cantidad.toString();
        }
        provider.speak('Entrega ${cantidadFormateada} confirmada');
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
    late String cantidad;
    final _finalRegex = RegExp(r'^(?:\d+|\d+\.\d{2})$');
    final _typingRegex = RegExp(r'^\d+(\.\d{0,2})?$');

    showDialog(
      context: context,
      builder: (context) {
        return VerfrutApp.DialogalertActions(
          icono: Icons.add,
          mensajecontent: 'Ingresar numero de entregas',
          cantidad: TextFormField(
            onChanged: (value) => cantidad = value,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              TextInputFormatter.withFunction((oldValue, newValue) {
                final t = newValue.text;
                if (t.isEmpty || _typingRegex.hasMatch(t))
                  return newValue; // permite borrar/editar
                return oldValue; // bloquea cambios inválidos
              }),
            ],
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return 'Ingrese un valor';
              if (!_finalRegex.hasMatch(v))
                return 'Formato inválido. Use "1234" o "1234.56"';
              // (opcional) si debe ser > 0:
              final n = double.tryParse(v);
              if (n == null || n <= 0) return 'Debe ser mayor que 0';
              return null;
            },
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
                  cantidad: double.parse(cantidad),
                  fecha: date,
                  hora: hora.toString(),
                  swsincronizado: '0',
                );

                List<Entrega>? listaentregado = await provider.entrega(entrega);
                if (listaentregado == null) {
                  String cantidadFormateada;
                  if (entrega.cantidad! % 1 == 0) {
                    // Es un número entero
                    cantidadFormateada = entrega.cantidad!.toInt().toString();
                  } else {
                    // Tiene decimales
                    cantidadFormateada = entrega.cantidad.toString();
                  }
                  provider.speak('Entrega ${cantidadFormateada} confirmada');
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
                      IdTrabXContratista: listaentregado[0].IdTrabXContratista,
                      idcartilla: listaentregado[0].idcartilla,
                      qr: listaentregado[0].qr,
                      cantidad:
                          listaentregado[0].cantidad! + double.parse(cantidad),
                      fecha: date,
                      hora: hora.toString(),
                      swsincronizado: '0',
                    );

                    String cantidadFormateada;
                    if (nuevaentrega.cantidad! % 1 == 0) {
                      // Es un número entero
                      cantidadFormateada =
                          nuevaentrega.cantidad!.toInt().toString();
                    } else {
                      // Tiene decimales
                      cantidadFormateada = nuevaentrega.cantidad.toString();
                    }
                    final update = await provider.updateentry(nuevaentrega);

                    provider.speak('Entrega ${cantidadFormateada} confirmada');
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

Future<List<String>> sincronizaciontrabajadores(
  TrabajadorxContratistaProvider provider,
) async {
  final syncMessages = <String>[];

  void addSyncMessage(String message) {
    if (!syncMessages.contains(message)) {
      syncMessages.add(message);
    }
  }

  if (provider.cartillasdisponibles.isEmpty) {
    provider.updateSyncProgress(1, 'No hay cartillas para sincronizar');
    return syncMessages;
  }

  provider.updateSyncProgress(0.02, 'Consultando trabajadores');
  /*List<Trabajador> respuesta = await provider.getlistado(
    provider.cartillasdisponibles[0].idAndroidCartilla!,
  );*/

  provider.updateSyncProgress(0.06, 'Consultando cartillas');
  List<Cartillaqr> respuestacartilla = await provider.getcartillastosync(false);

  provider.updateSyncProgress(0.10, 'Consultando entregas');
  List<EntregaResponse> listaentregasnolocal = await provider.getentryforsync(
    false,
  );

  final total =
      //respuesta.length +
          respuestacartilla.length + listaentregasnolocal.length;

  if (total == 0) {
    provider.updateSyncProgress(1, 'No hay datos pendientes');
    return syncMessages;
  }

  var completed = 0;

  void updateProgress(String message) {
    provider.updateSyncProgress(0.10 + (completed / total) * 0.90, message);
  }

  void completeProgress(String message) {
    completed++;
    provider.updateSyncProgress(0.10 + (completed / total) * 0.90, message);
  }

/*  for (var i = 0; i < respuesta.length; i++) {
    updateProgress('Sincronizando trabajadores ${i + 1}/${respuesta.length}');
    await provider.insertatrabajadorescontratista(respuesta[i]);
    completeProgress('Trabajadores ${i + 1}/${respuesta.length}');
  }*/

  for (var i = 0; i < respuestacartilla.length; i++) {
    updateProgress(
      'Sincronizando cartillas ${i + 1}/${respuestacartilla.length}',
    );
    String mensaje = await provider.synccartillashoras(respuestacartilla[i]);
    if (mensaje == 'error') {
      addSyncMessage('Error sincronizando cartillas');
    }
    completeProgress('Cartillas ${i + 1}/${respuestacartilla.length}');
  }

  for (var i = 0; i < listaentregasnolocal.length; i++) {
    updateProgress(
      'Sincronizando entregas ${i + 1}/${listaentregasnolocal.length}',
    );
    String message = await provider.sync(listaentregasnolocal[i]);
    if (message == 'error') {
      addSyncMessage('Error sincronizando entregas');
    }
    if (message == 'aprobada') {
      addSyncMessage('Cartilla ya fue aprobada');
    }
    completeProgress('Entregas ${i + 1}/${listaentregasnolocal.length}');
  }

  return syncMessages;
}

class _RedirectToLogin extends StatelessWidget {
  const _RedirectToLogin({super.key});

  @override
  Widget build(BuildContext context) {
    // dispara navegación en el siguiente frame para no romper el build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Login()),
        (route) => false,
      );
    });
    // no pinta nada
    return const SizedBox.shrink();
  }
}
