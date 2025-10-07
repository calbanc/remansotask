import 'package:verfwork/page/addworkerscreen.dart';
import 'package:verfwork/util/VerfrutApp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../providers/optionsProvider.dart';
import '../response/TrabajadorxContratista.dart';

class workerScreen extends StatelessWidget {
  optionsProvider provider;
  workerScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: VerfrutApp.Verfrutapp(title: 'Mis Trabajadores'),
      body: Column(
        children: [
          SizedBox(height: 10),
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            child: TextFormField(
              controller: provider.filterctrl,
              onChanged: (value) async {
                provider.listatrabajadoresfilter =
                    provider.listatrabajadores
                        .where((element) => element.rut!.contains(value))
                        .toList();
              },
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  onPressed: () {
                    provider.filterctrl.text = '';
                    provider.listatrabajadoresfilter =
                        provider.listatrabajadores;
                  },
                  icon: Icon(Icons.cancel_outlined),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
                labelText: 'Buscar trabajador por Rut',
              ),
            ),
          ),
          SizedBox(height: 10),
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(59, 131, 216, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // <-- Radius
                ),
              ),
              onPressed: () {
                Future.microtask(
                  () => {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder:
                            (_, __, ___) => addworkerScreen(provider: provider),
                        transitionDuration: const Duration(seconds: 1),
                      ),
                    ),
                  },
                );
              },
              child: Text(
                'Agregar Trabajador',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'MontserratB',
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child:
                  provider.listatrabajadores.length < 1
                      ? Center(child: CupertinoActivityIndicator())
                      : _listadotrabajadores(
                        listado: provider.listatrabajadoresfilter,
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

class _listadotrabajadores extends StatelessWidget {
  List<Trabajadorxcontratista> listado;
  _listadotrabajadores({super.key, required this.listado});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: listado.length,
      itemBuilder: (context, index) {
        String nombre = listado[index].nombre!;
        String rut = listado[index].rut! + '-' + listado[index].digito!;
        String idtrabajador = listado[index].idTrabXContratista!;

        return Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: Container(child: Image.asset('assets/trabajador.png')),
                ),
                SizedBox(width: 10),
                Expanded(
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
                        'Rut: $rut',
                        style: const TextStyle(
                          fontFamily: 'MontserratR',
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Codigo: $idtrabajador ',
                        style: const TextStyle(
                          fontFamily: 'MontserratR',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                /*Container(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: PopupMenuButton(
                        child: const Icon(
                          Icons.more_vert,
                          color: Color.fromRGBO(36, 99, 174, 1),
                        ),
                        onSelected: (value) async {
                          if (value == "lessentry") {

                            // add desired output
                          } else if (value == "edit") {


                            // add desired output
                          } else if (value == "delete") {

                            // add desired output
                          }
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                          const PopupMenuItem(
                            value: "details",
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [

                                Text(
                                  'Ver detalle',
                                  style: TextStyle(
                                      fontSize: 12, fontFamily: 'MontserratR'),
                                ),
                                SizedBox(width: 10,),
                                Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                  child: Icon(Icons.file_open_outlined),
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: "edit",
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [

                                Text(
                                  'Modificar',
                                  style: TextStyle(
                                      fontSize: 12, fontFamily: 'MontserratR'),
                                ),
                                SizedBox(width: 10,),
                                Padding(
                                    padding: EdgeInsets.only(right: 8.0),
                                    child: Icon(Icons.edit)),

                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: "activate",
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [

                                Text(
                                  'Activar',
                                  style: TextStyle(
                                      fontSize: 12, fontFamily: 'MontserratR',color: Colors.green,fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 10,),
                                Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Icon(
                                      Icons.check_box_outlined,
                                      color: Colors.green,
                                    )),

                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),*/
              ],
            ),
          ),
        );
      },
    );
  }
}
