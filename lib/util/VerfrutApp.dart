import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:verfwork/page/ScanQrScreen.dart';

class VerfrutApp {
  Future<String> scanqr(BuildContext context) async {
    String resultado = "";

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true, // esto lo presenta como modal
        builder: (context) => ScanQrScreen(),
      ),
    );

    if (result != null) {
      resultado = result;
    }

    return resultado;
  }

  static AppBar Verfrutapp({required String title, IconButton? action}) {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(36, 99, 175, 1),
              Color.fromRGBO(11, 52, 86, 1),
            ],
          ),
        ),
      ),
      actions: [action != null ? action : Container()],
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontFamily: 'MontserratR',
        ),
      ),
    );
  }

  static DropDownDecoratorProps DecorationProps({required String label}) {
    return DropDownDecoratorProps(
      baseStyle: const TextStyle(fontFamily: 'MontserratR', fontSize: 12),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color.fromRGBO(230, 236, 245, 1),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          borderSide: BorderSide(
            color: Color.fromRGBO(230, 236, 245, 1),
            width: 0,
          ),
        ),
        labelStyle: const TextStyle(fontFamily: 'MontserratR', fontSize: 12),
        labelText: label,
      ),
    );
  }

  static InputDecoration InputDecorationVerf({
    required String label,
    IconData? prefixicon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: const Color.fromRGBO(230, 236, 245, 1),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        borderSide: BorderSide(
          color: Color.fromRGBO(230, 236, 245, 1),
          width: 0,
        ),
      ),
      labelStyle: const TextStyle(fontFamily: 'MontserratR', fontSize: 12),
      labelText: label,
      prefixIcon: Icon(prefixicon, color: Color.fromRGBO(36, 99, 174, 1)),
    );
  }

  static AlertDialog Dialogalert({
    required IconData icono,
    required String mensajecontent,
  }) {
    return AlertDialog(
      //  title: Text( title! ,style: TextStyle(fontFamily: 'MontserratR'),) ,
      content: SizedBox(
        height: 160,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icono, size: 60, color: Colors.blue),
            Text(mensajecontent!, style: TextStyle(fontFamily: 'MontserratR')),
          ],
        ),
      ),
    );
  }

  static AlertDialog DialogalertIso({
    required String mensajecontent,
    required Widget action,
  }) {
    return AlertDialog(
      //  title: Text( title! ,style: TextStyle(fontFamily: 'MontserratR'),) ,
      content: SizedBox(
        height: 180,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/isologo.svg'),
            SizedBox(height: 10),
            Text(mensajecontent!, style: TextStyle(fontFamily: 'MontserratR')),
            SizedBox(height: 10),
            action,
          ],
        ),
      ),
    );
  }

  static AlertDialog DialogalertEnvase({
    required String mensajecontent,
    required Widget action,
  }) {
    return AlertDialog(
      backgroundColor: Colors.white,

      //  title: Text( title! ,style: TextStyle(fontFamily: 'MontserratR'),) ,
      content: SizedBox(
        height: 380,
        width: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/envase.png', width: 150, height: 100),
            const SizedBox(height: 10),
            Text(
              mensajecontent!,
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'MontserratR'),
            ),
            const SizedBox(height: 10),
            Padding(padding: const EdgeInsets.all(8.0), child: action),
          ],
        ),
      ),
    );
  }

  static AlertDialog DialogalertActions({
    required IconData icono,
    required String mensajecontent,
    TextFormField? cantidad,
    required List<Widget> options,
  }) {
    return AlertDialog(
      actions: options,
      //  title: Text( title! ,style: TextStyle(fontFamily: 'MontserratR'),) ,
      content: SizedBox(
        height: 160,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icono, size: 60, color: Colors.blue),
            Text(
              mensajecontent!,
              style: TextStyle(fontFamily: 'MontserratR', fontSize: 15),
            ),
            cantidad != null
                ? Padding(padding: const EdgeInsets.all(8.0), child: cantidad)
                : Container(),
          ],
        ),
      ),
    );
  }
}
