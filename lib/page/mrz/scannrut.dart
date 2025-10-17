import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../util/VerfrutApp.dart';
import 'chile_mrz_parser.dart';

class scannrut extends StatefulWidget {
  const scannrut({super.key});

  @override
  State<scannrut> createState() => _scannrutState();
}

class _scannrutState extends State<scannrut> {
  @override
  Widget build(BuildContext context) {
    final _picker = ImagePicker();
    final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    String? _rawOcr;
    ChileIdMrz? _parsed;
    String? _error;
    File? _image;

    Future<void> _scanFromCamera() async {
      setState(() {
        _error = null;
        _parsed = null;
        _rawOcr = null;
        _image = null;
      });

      final shot = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 95,
      );
      if (shot == null) return;

      final file = File(shot.path);
      setState(() {
        _image = file;
      });

      try {
        final input = InputImage.fromFilePath(file.path);
        final result = await _recognizer.processImage(input);
        final text = result.text;
        setState(() {
          _rawOcr = text;
        });

        final parsed = ChileMrzParser.parseFromOcr(text);
        if (parsed == null) {
          setState(() {
            _error = 'No pude encontrar un bloque MRZ válido.';
          });
        } else {
          setState(() {
            _parsed = parsed;
          });
        }
      } catch (e) {
        setState(() {
          _error = 'Error de OCR: $e';
        });
      }
    }
    @override
    void dispose() {
      _recognizer.close();
      super.dispose();
    }

    return Scaffold(
      appBar: VerfrutApp.Verfrutapp(title: 'Rut Chile'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            ElevatedButton.icon(
              onPressed: _scanFromCamera,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Escanear reverso'),
            ),
            const SizedBox(height: 16),
            if (_image != null) Image.file(_image!),
            if (_parsed != null) ...[
              const SizedBox(height: 16),
              Text(_parsed.toString(), style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),

            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            if (_rawOcr != null && _parsed == null) ...[
              const SizedBox(height: 16),
              const Text('Texto OCR (depuración):'),
              Text(_rawOcr!, style: const TextStyle(fontFamily: 'monospace')),
            ],
          ],
        ),
      ),
    );
  }
}
