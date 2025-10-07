import 'package:verfwork/providers/addtrabajadorcontratistaprovider.dart';
import 'package:verfwork/util/VerfrutApp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../providers/optionsProvider.dart';

class addworkerScreen extends StatelessWidget {
  optionsProvider provider;
  addworkerScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    bool _validarut(String? rut) {
      if (rut == null) return false;
      dynamic regExp = RegExp(r'(^(\d{1,2}(?:[\.]?\d{3}){2}-[\dkK])$)');
      return regExp.hasMatch(rut);
    }

    return Scaffold(
      appBar: VerfrutApp.Verfrutapp(title: 'Agregar Trabajador'),
      body: Form(
        key: provider.formaddkey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 37),
              child: TextFormField(
                controller: provider.nombrectrl,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                  labelText: 'Nombre Trabajador',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 37),
              child: TextFormField(
                controller: provider.rutctrl,
                validator: (value) {
                  return _validarut(value)
                      ? null
                      : 'Debe ingresar un rut valido';
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromRGBO(118, 118, 118, 1),
                    ),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  labelText: 'Rut/DNI Trabajador',
                ),
              ),
            ),

            const SizedBox(height: 20),
            DropdownMenu<String>(
              width: MediaQuery.of(context).size.width * 0.8,
              initialSelection:
                  provider.sexo = provider.list.first.substring(0, 1),
              onSelected: (String? value) {
                // This is called when the user selects an item.
                provider.sexo = value!.substring(0, 1);
              },
              dropdownMenuEntries:
                  provider.list.map<DropdownMenuEntry<String>>((String value) {
                    return DropdownMenuEntry<String>(
                      value: value,
                      label: value,
                    );
                  }).toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 37),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(36, 99, 174, 1),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 0.5),
                      borderRadius: BorderRadius.circular(12), // <-- Radius
                    ),
                  ),
                  onPressed:
                      provider.isloading
                          ? null
                          : () async {
                            FocusScope.of(context).unfocus();
                            if (!provider.isValidateForm()) return;
                            String rut = provider.rutctrl.text;
                            String nombre = provider.nombrectrl.text;
                            String sexo = provider.sexo;
                            provider.isloading = true;

                            http.Response respuesta = await provider
                                .savetrabxcontratista(rut, nombre, sexo);
                            if (respuesta.statusCode == 200) {
                              Fluttertoast.showToast(
                                msg: 'Trabajador agregado correctamente',
                              );
                              provider.isloading = false;
                              await provider.getworkersbycontratista();
                              provider.formaddkey.currentState!.reset();

                              Navigator.of(context).pop();
                            } else {
                              provider.isloading = false;
                            }
                          },
                  child:
                      provider.isloading
                          ? CupertinoActivityIndicator()
                          : Text(
                            'Aceptar',
                            style: TextStyle(
                              fontFamily: 'MontserratB',
                              color: Colors.white,
                              fontSize: 20,
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
