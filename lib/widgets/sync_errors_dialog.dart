import 'package:flutter/material.dart';

class SyncErrorsDialog extends StatelessWidget {
  const SyncErrorsDialog({super.key, required this.messages});

  final List<String> messages;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      scrollable: true,
      title: const Text(
        'Detalle de sincronización',
        style: TextStyle(fontFamily: 'MontserratB', fontSize: 16),
      ),
      content: SelectableText(
        messages.join('\n\n'),
        style: const TextStyle(fontFamily: 'MontserratR', fontSize: 12),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: const Color.fromRGBO(46, 125, 50, 1),
          ),
          child: const Text(
            'Aceptar',
            style: TextStyle(fontFamily: 'MontserratB'),
          ),
        ),
      ],
    );
  }
}
