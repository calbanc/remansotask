import 'package:verfwork/page/dashboard_min.dart';
import 'package:verfwork/providers/provider.dart';
import 'package:verfwork/response/CartillaQrResponse.dart';
import 'package:verfwork/response/detalleCartilla.dart';
import 'package:verfwork/response/qrcartilla_response.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'page.dart';

class MainDashboard extends StatelessWidget {
  MainDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => new TrabajadorxContratistaProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => new Connectivity_provider(),
        ),
      ],
      child: DashboardMain(),
    );
  }
}
