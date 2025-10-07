import 'package:verfwork/providers/provider.dart';
import 'package:verfwork/response/ActividadesResponse.dart';
import 'package:verfwork/response/CartillaQrResponse.dart';
import 'package:verfwork/response/CuartelResponse.dart';
import 'package:verfwork/util/VerfrutApp.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddCartilla extends StatelessWidget {
  TrabajadorxContratistaProvider provider;
  AddCartilla({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: VerfrutApp.Verfrutapp(title: 'Agregar Cartilla'),
      body: Form(
        key: provider.formkeyaddcartilla,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: FutureBuilder(
                future: provider.getlabores(),
                builder: ((context, AsyncSnapshot<List<Actividade>> snapshot) {
                  if (snapshot.data == null || !snapshot.hasData) {
                    return const CupertinoActivityIndicator();
                  }
                  List<Actividade> lista = snapshot.data!;
                  return DropdownSearch<Actividade>(
                    items: (a, b) => lista,
                    compareFn: (i, s) => i?.idFamilia == s?.idFamilia,
                    selectedItem: Actividade(
                      idFamilia: provider.cartillasdisponibles[0].idFamilia,
                      noombreFamilia:
                          provider.cartillasdisponibles[0].nomFamilia,
                    ),
                    onChanged: (Actividade? value) async {
                      provider.IdActividad = value!.idFamilia!;
                    },
                    validator: (value) {
                      return (value == null)
                          ? 'Debe seleccionar una actividad'
                          : null;
                    },
                    popupProps: const PopupProps.modalBottomSheet(
                      title: Center(child: Text('Seleccione una actividad')),
                      showSearchBox: true,
                    ),
                    itemAsString:
                        (Actividade ac) =>
                            ac.idFamilia! + '-' + ac.noombreFamilia!,
                    decoratorProps: VerfrutApp.DecorationProps(
                      label: 'Actividad',
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownSearch<Actividade>(
                key: provider.formkeylabor,
                items: (a, b) => provider.listalaboreslocal ?? [],
                selectedItem: Actividade(
                  idActividad: provider.cartillasdisponibles[0].idActividad,
                  nombre: provider.cartillasdisponibles[0].nomActividad,
                ),
                onChanged: (Actividade? value) {},
                validator: (value) {
                  return (value == null) ? 'Debe seleccionar una labor' : null;
                },
                popupProps: const PopupProps.modalBottomSheet(
                  title: Center(child: Text('Seleccione una labor')),
                  showSearchBox: true,
                ),
                compareFn:
                    (item1, item2) => item1?.idActividad == item2?.idActividad,
                itemAsString:
                    (Actividade ac) => '${ac.idActividad!}-${ac.nombre!}',
                decoratorProps: VerfrutApp.DecorationProps(label: 'Labor'),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownSearch<Cuarteles>(
                items: (a, b) => provider.listazonas ?? [],
                compareFn:
                    (item1, item2) => item1?.idCuartel == item2?.idCuartel,
                selectedItem: Cuarteles(
                  idCuartel: provider.cartillasdisponibles[0].idZona,
                  nomCuartel: provider.cartillasdisponibles[0].nomZon,
                ),
                onChanged: (Cuarteles? value) {},
                validator: (value) {
                  return (value == null) ? 'Debe seleccionar una Zona' : null;
                },
                popupProps: const PopupProps.modalBottomSheet(
                  title: Center(child: Text('Seleccione una Zona')),
                  showSearchBox: true,
                ),
                itemAsString:
                    (Cuarteles ac) => ac.idCuartel! + '-' + ac.nomCuartel!,
                decoratorProps: VerfrutApp.DecorationProps(label: 'Zona'),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownSearch<Cuarteles>(
                items: (a, b) => provider.listacuartel ?? [],
                compareFn:
                    (item1, item2) => item1?.idCuartel == item2?.idCuartel,
                onChanged: (Cuarteles? value) {
                  provider.cuartelseleccionado = value!;
                },
                validator: (value) {
                  return (value == null) ? 'Debe seleccionar un cuartel' : null;
                },
                popupProps: const PopupProps.modalBottomSheet(
                  title: Center(child: Text('Seleccione un cuartel')),
                  showSearchBox: true,
                ),
                itemAsString:
                    (Cuarteles ac) => ac.idCuartel! + '-' + ac.nomCuartel!,
                decoratorProps: VerfrutApp.DecorationProps(label: 'Cuartel'),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(18)),
                  color: Color.fromRGBO(230, 236, 245, 1),
                ),
                child: ListTile(
                  title: const Text(
                    'Uno a Uno',
                    style: TextStyle(fontFamily: 'MontserratR', fontSize: 12),
                  ),
                  trailing: Checkbox(
                    fillColor: MaterialStateProperty.resolveWith((states) {
                      return Color.fromRGBO(37, 98, 173, 1);
                    }),
                    value: provider.swunoauno,
                    onChanged: (value) => {provider.swunoauno = value!},
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(36, 99, 174, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // <-- Radius
                    ),
                  ),
                  onPressed: () async {
                    if (!provider.isValidateFormcartilla()) return;

                    /*  Cartillaqr cartilla=new Cartillaqr(
                        idAndroidCartilla: json["IdAndroidCartilla"],
                        idEmpresa: json["IdEmpresa"],
                        idFamilia: json["IdFamilia"],
                        idActividad: json["IdActividad"],
                        idContratista: json["IdContratista"],
                        idZona: json["IdZona"],
                        idEspecie: json["IdEspecie"],
                        idVariedad: json["IdVariedad"],
                        idCuartel: json["IdCuartel"],
                        horainicio: json["HORAINICIO"],
                        horatermino: json["HORATERMINO"],
                        fechainicio: json["FECHAINICIO"],
                        fechatermino: json["FECHATERMINO"],
                        idusuario: json["IDUSUARIO"],
                        swUnoaUno: json["SwUnoaUno"],
                        swCartillaCierre: json["SwCartillaCierre"],
                        fechasys: json["FECHASYS"],
                        codEnv: json["COD_ENV"],
                        nomEspecie: json["NomEspecie"],
                        nomVariedad: json["NomVariedad"],
                        nomZon: json["NomZon"],
                        nomCuartel: json["NomCuartel"],
                        nomContratista: json["NomContratista"],
                        nomFamilia: json["NomFamilia"],
                        nomActividad: json["NomActividad"],
                        SwSincronizado: json["SwSincronizado"])
                      ) */
                  },
                  child: const Text(
                    'Agregar Cartilla',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'MontserratB',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
