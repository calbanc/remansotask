import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/provider.dart';
import '../response/response.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'configuracion.dart';
import 'maindashboard.dart';

class ListCartilla extends StatefulWidget {
  const ListCartilla({super.key});

  @override
  State<ListCartilla> createState() => _ListCartillaState();
}

final today = DateTime.now();
final date = DateFormat('yyyy-MM-dd 00:00:00.000').format(today);

class _ListCartillaState extends State<ListCartilla> {
  String fechainicio = date;
  @override
  void initState() {
    // TODO: implement initState
    fechainicio = date;
    print(fechainicio);
  }

  @override
  Widget build(BuildContext context) {
    final cartillaprovider = Provider.of<CartillasProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Cartillas Registradas',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () async {
            /*Navigator.pushReplacement(context,  MaterialPageRoute(
                builder: ((context) =>  Configuracion())));*/
          },
        ),

        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /*  EasyDateTimeLine(
              initialDate: DateTime.now(),
              locale: "es_Es",
              onDateChange: ((selectedDate) {

                setState(() {
                  fechainicio=selectedDate.toString();
                });

              }),
              headerProps: const EasyHeaderProps(
                monthPickerType: MonthPickerType.switcher,
                selectedDateFormat: SelectedDateFormat.fullDateDMY,

              ),
              ), */
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: FutureBuilder(
                  future: cartillaprovider.getcartillasbydate(fechainicio),
                  builder: (
                    context,
                    AsyncSnapshot<List<QrCartillaResponse>> snapshot,
                  ) {
                    if (!snapshot.hasData || snapshot.data == null) {
                      return Container();
                    } else {
                      List<QrCartillaResponse> listado = snapshot.data!;
                      return _Card(
                        lista: listado,
                        cartillaprovider: cartillaprovider,
                      );
                      //_Card(lista: listado,cartillaprovider:cartillaprovider);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatefulWidget {
  final List<QrCartillaResponse> lista;
  final CartillasProvider cartillaprovider;
  const _Card({required this.lista, required this.cartillaprovider});

  @override
  State<_Card> createState() => _CardState();
}

TextEditingController controlladorhorainicio = TextEditingController();
TextEditingController controlladorhoratermino = TextEditingController();
String? horatermino;
List<ListadoEntregaResponse> listados = [];

class _CardState extends State<_Card> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.25,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.lista.length,
            itemBuilder: ((context, index) {
              String idcartilla = widget.lista[index].idcartilla;
              String cuartel = widget.lista[index].cuartel;
              String fechainicio = DateFormat(
                'dd/MM/yyyy',
              ).format(DateTime.parse(widget.lista[index].fechainicio));

              horatermino = widget.lista[index].horatermino;

              return SizedBox(
                width: 240,
                //height: 120,
                child: GestureDetector(
                  onTap: () async {
                    List<ListadoEntregaResponse>? listado =
                        await TrabajadorxContratistaProvider().listadoentregas(
                          idcartilla,
                        );
                    setState(() {
                      listados = listado!;
                    });
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(8),
                        right: Radius.circular(8),
                      ),
                    ),
                    color: Colors.amber[100],
                    child: Column(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 10),
                            const Text(
                              'Id Cartilla:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Text(idcartilla),
                            const SizedBox(width: 8),
                            const Text(
                              'Cuartel',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Text(cuartel),
                          ],
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Fecha: '),
                            Text(fechainicio.toString()),
                          ],
                        ),
                        SizedBox(height: 10),

                        horatermino != null
                            ? Container(
                              width: MediaQuery.of(context).size.width * 0.8,

                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    widget.cartillaprovider.abrircartilla(
                                      idcartilla,
                                    );
                                    setState(() {
                                      horatermino = null;
                                    });
                                    showDialog(
                                      context: context,
                                      builder:
                                          (
                                            BuildContext context,
                                          ) => CupertinoAlertDialog(
                                            title: new Text(
                                              "Cartilla Actualizada",
                                            ),
                                            content: new Text(
                                              "Estimado usuario cartilla actualizada correctamente",
                                            ),
                                          ),
                                    );
                                  },
                                  child: const Text('ABRIR CARTILLA'),
                                ),
                              ),
                            )
                            : Container(),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        _listadotrabajadores(listado: listados),
      ],
    );
  }
}

class _listadotrabajadores extends StatelessWidget {
  final List<ListadoEntregaResponse> listado;
  _listadotrabajadores({super.key, required this.listado});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: listado.length,
      itemBuilder: ((context, index) {
        String nombre = listado[index].nombre!;
        return Text(nombre);
      }),
    );
  }
}
