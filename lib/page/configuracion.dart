/*import 'package:contratistas/page/page.dart';
import 'package:contratistas/providers/provider.dart';
import 'package:contratistas/response/CartillaQrResponse.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../response/response.dart';


class Configuracion extends StatelessWidget {
  const Configuracion({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Configuracion',style: TextStyle(color: Colors.white),),
        centerTitle: true,
          leading:
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new),
            onPressed: ()async{
              List<Cartillaqr> lista=await TrabajadorxContratistaProvider().getcartillasdisponibles();

              List<Cartillaqr> seleccionado=await TrabajadorxContratistaProvider().getcartillabyid(lista[0].idAndroidCartilla!);
              Future.microtask(() => {
                Navigator.pushReplacement(context, PageRouteBuilder(
                    pageBuilder: ( _, __ , ___ ) => MainDashboard(),
                    transitionDuration:const Duration( seconds: 1)
                )
                )
              });

            },
          )
        ),




      body: _ListOptions(),


    );
  }
}


class _ListOptions extends StatelessWidget {
  const _ListOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
          padding: EdgeInsets.all(32),
           scrollDirection: Axis.vertical,
           children: [
              ListTile(
                title: Text('Cartillas',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold
                    ),),
                subtitle: Text('Ver todas las cartillas ingresadas',style: TextStyle(fontStyle: FontStyle.italic),),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: (){
                   Navigator.pushReplacement(context,  MaterialPageRoute(
                  builder: ((context) =>  _ListCartillas())));
                },
                
              ),
              ListTile(
                title: Text('Version de App',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold
                    ),),
                subtitle: Text('Ver codigos de app',style: TextStyle(fontStyle: FontStyle.italic),),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: ()async {
                   PackageInfo packageInfo = await PackageInfo.fromPlatform();
                    String version = packageInfo.version;
                    String code = packageInfo.buildNumber;

                  
                    showDialog(
                                   barrierDismissible: false,
                                   context: context, builder: ((context) {
                                 return AlertDialog(
                                  title: Text('Informacion de app'),
                                  content: Text(
                                    'Version de app: $version\nCodigo de app: $code'
                                  ),
                                 ); 
                               }));
                },
                
              ),
         *//*     ListTile(
                title: Text('Tiempo de Capturas',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold
                    ),),
                subtitle: Text('Configura el tiempo entre scan y scan',style: TextStyle(fontStyle: FontStyle.italic),),
                trailing: Icon(Icons.arrow_forward_ios),
              )*//*


           ],
         
      
    );
  }
}

class _ListCartillas extends StatelessWidget {
  const _ListCartillas({super.key});


  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (context)=>new CartillasProvider(),
      child: ListCartilla()
      );
    *//*  *//*
  }
} */

