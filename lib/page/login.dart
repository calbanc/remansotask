import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart' as googlekit;
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:verfwork/page/maindashboard.dart';
import 'package:verfwork/page/page.dart';
import 'package:verfwork/providers/connectivity_provider.dart';
import 'package:verfwork/providers/trabajadorxcontratistaprovider.dart';
import 'package:verfwork/response/CartillaQrResponse.dart';
import 'package:verfwork/util/VerfrutApp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => new TrabajadorxContratistaProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => new Connectivity_provider(),
        ),
      ],
      child: _Login(),
    );
  }
}

class _Login extends StatelessWidget {
  _Login({super.key});

  final picker = new ImagePicker();
  final MobileScannerController _controller = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
  );

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
                    formats: [googlekit.BarcodeFormat.qrCode], // fuerza solo QR
                  );

                  final input = googlekit.InputImage.fromFilePath(file.path);
                  final barcodes = await scanner.processImage(input);

                  if(barcodes.isEmpty){
                    Navigator.pop(context,'');
                    return ;
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

  @override
  Widget build(BuildContext context) {
    final trabajadorcontratisprovider =
        Provider.of<TrabajadorxContratistaProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder(
              future: trabajadorcontratisprovider.redirect(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.data == null) {
                  return Container();
                } else {
                  String data = snapshot.data!;
                  if (data == 'Si') {
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
                  return Container();
                }
              },
            ),
            Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.85,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromRGBO(36, 99, 175, 1),
                        Color.fromRGBO(11, 52, 86, 1),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.25,
                  left: MediaQuery.of(context).size.width * 0.15,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 400,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 20,
                          right: 20,
                          left: 20,
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Toca aqui para iniciar',
                              style: TextStyle(
                                fontFamily: 'MontserratR',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                try {
                                  String str =
                                      await _showActionSheet(context) ?? '';

                                  if(str==''){

                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return VerfrutApp.Dialogalert(
                                          icono: Icons.cancel,
                                          mensajecontent:
                                          'Error en qr ',
                                        );
                                      },
                                    );
                                    return;
                                  }
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
                                    List<Cartillaqr> respuesta =
                                        await trabajadorcontratisprovider
                                            .consultaqr(qr);
                                    if (respuesta.isNotEmpty) {
                                      trabajadorcontratisprovider.speak(
                                        'Cartilla ya registrada',
                                      );
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return VerfrutApp.Dialogalert(
                                            icono: Icons.cancel,
                                            mensajecontent:
                                                'Cartilla ya registrada',
                                          );
                                        },
                                      );
                                    } else {
                                      bool conectado =
                                          await Connectivity_provider()
                                              .isOnlineNet();
                                      await insertaqr(
                                        trabajadorcontratisprovider,
                                        qr,
                                      );
                                      Future.microtask(
                                        () => {
                                          Navigator.pushReplacement(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder:
                                                  (_, __, ___) =>
                                                      MainDashboard(),
                                              transitionDuration:
                                                  const Duration(seconds: 3),
                                            ),
                                          ),
                                        },
                                      );


                                    }
                                  } else {
                                    trabajadorcontratisprovider.speak(
                                      'Fecha de termino concluida',
                                    );
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return VerfrutApp.Dialogalert(
                                          icono: Icons.cancel,
                                          mensajecontent:
                                              'Fecha de termino concluida',
                                        );
                                      },
                                    );
                                  }
                                } catch (e) {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (
                                          BuildContext context,
                                        ) => CupertinoAlertDialog(
                                          title: Text("Qr Invalido"),
                                          content: Text(
                                            "Estimado usuario QR escaneado no es valido, fecha de termino ya concluida $e",
                                          ),
                                        ),
                                  );
                                }
                              },
                              child: Image(
                                image: const AssetImage('assets/qrlogin.png'),
                                width: MediaQuery.of(context).size.width * 0.7,
                              ),
                            ),
                            const SizedBox(height: 5),
                            SvgPicture.asset('assets/verfrut.svg'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<int> insertaqr(
    TrabajadorxContratistaProvider trabajadorcontratisprovider,
    Cartillaqr qr,
  ) async {
    trabajadorcontratisprovider.speak('Bienvenido');
    return await trabajadorcontratisprovider.insertarqr(qr);
  }

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
                              label: "${e.codEnv}  ${e.nomEnv!}",
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  controller: trabajadorcontratisprovider.maxenvController,
                  style: const TextStyle(fontFamily: 'MontserratR'),
                  validator: (value) {
                    return (value == null || value.isEmpty || value.length > 50)
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
                      if (!trabajadorcontratisprovider.isValidateFormalert()) {
                        return;
                      }

                      qr.codEnv = trabajadorcontratisprovider.cod_env;
                      qr.maxEnv =
                          trabajadorcontratisprovider.maxenvController.text;

                      await trabajadorcontratisprovider.insertarqr(qr);
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
}
