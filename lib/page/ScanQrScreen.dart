import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:verfwork/util/VerfrutApp.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final MobileScannerController controller = MobileScannerController(
    facing: CameraFacing.back,
    detectionSpeed: DetectionSpeed.noDuplicates,
    detectionTimeoutMs: 1000, // evita lecturas duplicadas muy rápidas
  );

  bool hasPopped = false;
  bool isRestarting = false;

  @override
  void dispose() {
    controller.dispose(); // 🔑 libera la cámara al salir
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture result) async {
    if (hasPopped) return;
    hasPopped = true;

    final String resp = result.barcodes.first.rawValue ?? '';

    // Detenemos la cámara antes de cerrar pantalla
    await controller.stop();

    if (!mounted) return;
    Navigator.of(context).pop(resp);
  }

  Future<void> _restartCamera() async {
    if (isRestarting) return;
    isRestarting = true;

    try {
      await controller.stop();
      await controller.start();
    } catch (e) {
      debugPrint("Error reiniciando cámara: $e");
    } finally {
      isRestarting = false;
    }
  }

  @override
  Widget build(BuildContext contexto) {
    return Scaffold(
      appBar: VerfrutApp.Verfrutapp(title: 'Scan Qr'),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: MediaQuery.sizeOf(contexto).width,
              height: MediaQuery.sizeOf(contexto).height * 0.6,
              child: MobileScanner(
                controller: controller,
                onDetect: _onDetect,
                errorBuilder: (context, error) {
                  // Mostrar un mensaje y reiniciar la cámara
                  _restartCamera();

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.warning, color: Colors.red, size: 48),
                        const SizedBox(height: 10),
                        Text(
                          "Problema con la cámara.\nReintentando...",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              controller.toggleTorch();
            },
            icon: const Icon(Icons.flashlight_on_sharp),
          ),
        ],
      ),
    );
  }
}
