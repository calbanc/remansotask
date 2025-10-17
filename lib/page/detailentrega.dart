import 'package:verfwork/page/maindashboard.dart';
import 'package:verfwork/providers/provider.dart';
import 'package:verfwork/response/CartillaQrResponse.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../response/response.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DetailEntrega extends StatelessWidget {
  final ListadoEntregaResponse lista;
  const DetailEntrega({super.key, required this.lista});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TrabajadorxContratistaProvider(),
      child: _detailentrega(listado: lista),
    );
  }
}

class _detailentrega extends StatefulWidget {
  final ListadoEntregaResponse listado;
  const _detailentrega({super.key, required this.listado});

  @override
  State<_detailentrega> createState() => _detailentregaState();
}

class _detailentregaState extends State<_detailentrega> {
  String identrega = '';
  String ruttrabajador = '';
  String nombre = '';
  String digito = '';
  String qr = '';
  double cantidad = 0;
  String idcartilla = '';
  TextEditingController controlladoridentrega = TextEditingController();
  TextEditingController controlladorcartilla = TextEditingController();
  TextEditingController controlladornombre = TextEditingController();
  TextEditingController controlladorcantidad = TextEditingController();
  TextEditingController controlladorlabor = TextEditingController();
  TextEditingController controlladorqr = TextEditingController();
  TextEditingController controlladorrut = TextEditingController();
  TextEditingController controlladordigito = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controlladoridentrega.text = widget.listado.identrega.toString();
    controlladorqr.text = widget.listado.qr.toString();
    controlladorcartilla.text = widget.listado.idcartilla.toString();
    controlladorrut.text = widget.listado.rut.toString();
    controlladordigito.text = widget.listado.digito.toString();
    controlladornombre.text = widget.listado.nombre.toString();
    controlladorlabor.text = widget.listado.labor.toString();
    controlladorcantidad.text = widget.listado.cantidad.toString();
  }

  @override
  Widget build(BuildContext context) {
    final trabajadorcontratisprovider =
        Provider.of<TrabajadorxContratistaProvider>(context);

    identrega = widget.listado.identrega.toString();
    qr = widget.listado.qr.toString();
    ruttrabajador = widget.listado.rut.toString();
    cantidad = double.parse(widget.listado.cantidad.toString());
    nombre = widget.listado.nombre.toString();
    digito = widget.listado.digito!;
    idcartilla = widget.listado.idcartilla.toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalle Entrega',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () async {

                await trabajadorcontratisprovider.getcartillasdisponibles();

            List<Cartillaqr> seleccionado = await trabajadorcontratisprovider
                .getcartillabyid(widget.listado.idcartilla!);
            Future.microtask(
              () => {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => MainDashboard(),
                    transitionDuration: const Duration(seconds: 1),
                  ),
                ),
              },
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: trabajadorcontratisprovider.formkey2,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  //initialValue: widget.listado.identrega.toString(),
                  controller: controlladoridentrega,
                  enabled: false,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(255, 239, 239, 240),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    ),
                    labelText: "Id de Entrega",
                    labelStyle: TextStyle(
                      color: Color.fromARGB(255, 16, 84, 163),
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: 'ComicNeue',
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: controlladorqr,
                  //initialValue: widget.listado.qr,
                  enabled: false,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(255, 239, 239, 240),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    ),
                    labelText: "Qr",
                    labelStyle: TextStyle(
                      color: Color.fromARGB(255, 16, 84, 163),
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: 'ComicNeue',
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FocusScope(
                  child: Focus(
                    onFocusChange: (focus) async {
                      if (focus == false) {
                        //consultamos el trabajador en la base de datos
                        List<Trabajador>? listatra =
                            await trabajadorcontratisprovider
                                .gettrabajadorbyrut(ruttrabajador);
                        if (listatra!.length > 0) {
                          setState(() {
                            controlladornombre.text = listatra[0].nombre!;
                            controlladordigito.text = listatra[0].digito!;
                          });
                        }
                      }
                    },
                    child: TextFormField(
                      //  initialValue: widget.listado.rut,
                      controller: controlladorrut,
                      onChanged: (String value) {
                        setState(() {
                          //controlladorrut.text=value;
                          controlladorrut.text = value;
                        });
                      },
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color.fromARGB(255, 239, 239, 240),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                        ),
                        labelText: "Rut Trabajador",
                        labelStyle: TextStyle(
                          color: Color.fromARGB(255, 16, 84, 163),
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: 'ComicNeue',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  //initialValue: widget.listado.digito,
                  controller: controlladordigito,
                  onChanged: (String value) {
                    setState(() {
                      controlladordigito.text = value;
                    });
                  },
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(255, 239, 239, 240),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    ),
                    labelText: "Digito",
                    labelStyle: TextStyle(
                      color: Color.fromARGB(255, 16, 84, 163),
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: 'ComicNeue',
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  //initialValue: widget.listado.nombre,
                  onChanged: (value) {
                    setState(() {
                      controlladornombre.text = value;
                    });
                  },
                  controller: controlladornombre,
                  enabled: true,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(255, 239, 239, 240),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    ),
                    labelText: "Trabajador",
                    labelStyle: TextStyle(
                      color: Color.fromARGB(255, 16, 84, 163),
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: 'ComicNeue',
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  // initialValue: widget.listado.idcartilla,
                  controller: controlladorcartilla,
                  enabled: false,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(255, 239, 239, 240),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    ),
                    labelText: "Id de Cartilla",
                    labelStyle: TextStyle(
                      color: Color.fromARGB(255, 16, 84, 163),
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: 'ComicNeue',
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  //initialValue: widget.listado.labor,
                  controller: controlladorlabor,
                  enabled: false,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(255, 239, 239, 240),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    ),
                    labelText: "Labor",
                    labelStyle: TextStyle(
                      color: Color.fromARGB(255, 16, 84, 163),
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: 'ComicNeue',
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: controlladorcantidad,
                  //initialValue: widget.listado.cantidad.toString(),
                  enabled: true,
                  keyboardType: TextInputType.numberWithOptions(
                    signed: false,
                    decimal: true,
                  ),
                  onChanged: (value) {
                    setState(() {
                      controlladorcantidad.text = value;
                    });
                    //controlladorcantidad.text=value;
                  },
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(255, 239, 239, 240),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    ),
                    labelText: "Entregas",
                    labelStyle: TextStyle(
                      color: Color.fromARGB(255, 16, 84, 163),
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: 'ComicNeue',
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 20, height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[800],
                      ),
                      onPressed: () async {
                        final fecha = DateFormat(
                          'dd/MM/yyyy',
                        ).format(DateTime.now());
                        final hora = DateTime.now();

                        Entrega nuevaentrega = Entrega(
                          identrega: int.parse(controlladoridentrega.text),
                          idcartilla: controlladorcartilla.text,
                          nombre: controlladornombre.text,
                          digito: controlladordigito.text,

                          rut: controlladorrut.text,
                          qr: controlladorqr.text,
                          cantidad: double.parse(controlladorcantidad.text),
                          fecha: fecha,
                          hora: hora.toString(),
                          swsincronizado: '0',
                        );

                        final update = await trabajadorcontratisprovider
                            .updateentry(nuevaentrega);
                        if (controlladorrut.text != widget.listado.rut ||
                            controlladordigito.text != widget.listado.digito ||
                            controlladornombre.text != widget.listado.nombre) {
                          final update2 = await trabajadorcontratisprovider
                              .updatetrabajador(nuevaentrega);
                        }

                        Fluttertoast.showToast(
                          msg: "Actualizado correctamente",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.grey[300],
                          timeInSecForIosWeb: 1,
                          textColor: Colors.black,
                          fontSize: 16.0,
                        );


                            await trabajadorcontratisprovider
                                .getcartillasdisponibles();

                        List<Cartillaqr> seleccionado =
                            await trabajadorcontratisprovider.getcartillabyid(
                              widget.listado.idcartilla!,
                            );
                        Future.microtask(
                          () => {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) => MainDashboard(),
                                transitionDuration: const Duration(seconds: 1),
                              ),
                            ),
                          },
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sync_rounded, color: Colors.white),
                          SizedBox(width: 8, height: 8),
                          Text(
                            'Actualizar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8, width: 8),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 60,

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[900],
                      ),

                      onPressed: () async {
                        cantidad = 0;
                        final hora = DateTime.now();
                        final date = DateFormat(
                          'dd/MM/yyyy',
                        ).format(DateTime.now());
                        Entrega nuevaentrega = Entrega(
                          identrega: widget.listado.identrega,
                          nombre: widget.listado.nombre!,
                          rut: widget.listado.rut!,
                          digito: widget.listado.digito,

                          idcartilla: widget.listado.idcartilla,
                          qr: widget.listado.qr,
                          cantidad: cantidad,
                          fecha: date,
                          hora: hora.toString(),
                          swsincronizado: '0',
                        );
                        final update = await trabajadorcontratisprovider
                            .updateentry(nuevaentrega);
                        Fluttertoast.showToast(
                          msg: "Entregas eliminadas",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.grey[300],
                          timeInSecForIosWeb: 1,
                          textColor: Colors.black,
                          fontSize: 16.0,
                        );

                            await trabajadorcontratisprovider
                                .getcartillasdisponibles();

                        List<Cartillaqr> seleccionado =
                            await trabajadorcontratisprovider.getcartillabyid(
                              widget.listado.idcartilla!,
                            );
                        Future.microtask(
                          () => {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) => MainDashboard(),
                                transitionDuration: const Duration(seconds: 1),
                              ),
                            ),
                          },
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_delete, color: Colors.white),
                          SizedBox(width: 8, height: 8),
                          Text(
                            'Eliminar',
                            style: TextStyle(color: Colors.white),
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
