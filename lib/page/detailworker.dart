import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:verfwork/providers/editworkerprovider.dart';
import 'package:verfwork/providers/provider.dart';
import 'package:verfwork/response/response.dart';
import 'package:verfwork/util/VerfrutApp.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class DetailWorker extends StatelessWidget {
  ListadoEntregaResponse worker;
  DetailWorker({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create:
              (context) => EditWorkerProvider()..cargardatosiniciales(worker),
        ),
      ],
      child: _detailworker(worker: worker),
    );
  }
}

class _detailworker extends StatelessWidget {
  ListadoEntregaResponse worker;
  _detailworker({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EditWorkerProvider>(context);

    return Scaffold(
      appBar: VerfrutApp.Verfrutapp(title: 'Detalle de trabajador'),
      body: SingleChildScrollView(
        child: Form(
          key: provider.formdetailkey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              _datospersonales(provider: provider, worker: worker),
              Column(
                children: [
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      'Detalle',
                      style: TextStyle(
                        fontFamily: 'MontserratB',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(36, 99, 174, 1),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 26,
                      right: 26,
                      top: 13,
                      bottom: 13,
                    ),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(230, 236, 245, 1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: Icon(
                                    Icons.home_outlined,
                                    color: Color.fromRGBO(36, 99, 174, 1),
                                  ),
                                ),
                                Text(
                                  'Cuartel',
                                  style: TextStyle(fontFamily: 'MontserratR'),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Text(
                              worker.cuartel!,
                              style: TextStyle(fontFamily: 'MontserratR'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 26,
                      right: 26,
                      top: 8,
                      bottom: 13,
                    ),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(230, 236, 245, 1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: Image(
                                    color: Color.fromRGBO(36, 99, 174, 1),
                                    image: AssetImage('assets/labor.png'),
                                    width: 30,
                                  ),
                                ),
                                Text(
                                  'Labor',
                                  style: TextStyle(fontFamily: 'MontserratR'),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: Text(
                              worker.labor!,
                              style: TextStyle(fontFamily: 'MontserratR'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 26,
                      right: 26,
                      top: 8,
                      bottom: 13,
                    ),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(230, 236, 245, 1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: Image(
                                    color: Color.fromRGBO(36, 99, 174, 1),
                                    image: AssetImage('assets/boxex.png'),
                                    width: 30,
                                  ),
                                ),
                                Text(
                                  'Cantidad',
                                  style: TextStyle(fontFamily: 'MontserratR'),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: Text(
                              worker.cantidad.toString()!,
                              style: TextStyle(fontFamily: 'MontserratR'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _datospersonales extends StatelessWidget {
  const _datospersonales({
    super.key,
    required this.provider,
    required this.worker,
  });

  final EditWorkerProvider provider;
  final ListadoEntregaResponse worker;
  bool _validarut(String? input) {
    if (input == null) return false;

    final raw = input.toUpperCase().replaceAll(RegExp(r'[^0-9K]'), '');
    if (raw.length != 9) return false;

    final body = raw.substring(0, 8);
    final dv = raw.substring(8);

    if (!RegExp(r'^\d{8}$').hasMatch(body)) return false;
    if (!RegExp(r'^[0-9K]$').hasMatch(dv)) return false;

    if (!provider.validarut) return true;

    int sum = 0;
    int factor = 2;
    for (int i = body.length - 1; i >= 0; i--) {
      sum += int.parse(body[i]) * factor;
      factor = (factor == 7) ? 2 : factor + 1;
    }
    final mod = 11 - (sum % 11);
    final expectedDv = switch (mod) {
      11 => '0',
      10 => 'K',
      _ => mod.toString(),
    };

    return dv == expectedDv;
  }

  @override
  Widget build(BuildContext context) {
    final _picker = ImagePicker();
    return Column(
      children: [
        const SizedBox(height: 30),
        const Center(
          child: Text(
            'Datos Personales',
            style: TextStyle(
              fontFamily: 'MontserratB',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(36, 99, 174, 1),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListTile(
            title: const Text(
              'Validar Rut Chile',
              style: TextStyle(fontFamily: 'MontserratR', fontSize: 12),
            ),
            contentPadding: EdgeInsets.all(8),
            trailing: CupertinoSwitch(
              value: provider.validarut,
              onChanged: (bool value) {
                provider.validarut = value;
              },
            ),
          ),
        ),

        if (provider.validarut && provider.path == '')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
            child: GestureDetector(
              onTap: () async {
                final image = await _picker.pickImage(
                  source: ImageSource.camera,
                );
                if (image != null) {
                  provider.path = image.path;
                  await provider.procesardatos(image.path);
                }
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 16,
                  ),
                  child: Center(
                    child: Text(
                      'Toca aqui para tomar foto al reverso del Documento de Identidad ',
                    ),
                  ),
                ),
              ),
            ),
          ),
        provider.path == ''
            ? Container()
            : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
              child: GestureDetector(
                onTap: () async {
                  final image = await _picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (image != null) {
                    provider.path = image.path;
                    await provider.procesardatos(image.path);
                  }
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Image.file(File(provider.path)),
                ),
              ),
            ),
        Padding(
          padding: const EdgeInsets.only(
            left: 26,
            right: 26,
            top: 13,
            bottom: 13,
          ),
          child: TextFormField(
            controller: provider.controllername,
            inputFormatters: [
              LengthLimitingTextInputFormatter(50),
            ],
            validator: (value) {
              return (value == null || value.isEmpty || value.length > 50)
                  ? 'Debe ingresar un nombre valido'
                  : null;
            },

            decoration: VerfrutApp.InputDecorationVerf(
              label: 'Nombre Trabajador',
              prefixicon: Icons.account_circle_outlined,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 26,
            right: 26,
            top: 13,
            bottom: 13,
          ),
          child: _RutOtpField(
            controller: provider.controllerrut,
            validator: (value) {
              return (value == null || value.isEmpty)
                  ? 'Debe ingresar un rut'
                  : _validarut(value)
                  ? null
                  : 'Debe ingresar un rut valido';
            },
            labelText: 'Rut/DNI Trabajador',
          ),
        ),

        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 26,
              right: 26,
              top: 13,
              bottom: 13,
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(36, 99, 174, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // <-- Radius
                ),
              ),
              onPressed: () async {
                FocusScope.of(context).unfocus();
                if (!provider.isValidateForm()) return;

                provider.isloading = true;
                String name = provider.controllername.text;
                final rutOtp = provider.controllerrut.text
                    .toUpperCase()
                    .replaceAll(RegExp(r'[^0-9K]'), '');
                String rutt = rutOtp.substring(0, 8);
                String dv = rutOtp.substring(8);
                //provider.nombre != null ? name = provider.nombre! : name;
                provider.rut != null ? rutt = provider.rut! : rutt;
                int respuesta = await provider.updateworkerentry(
                  rutt,
                  name,
                  worker,
                  dv,
                );
                provider.isloading = false;

                if (respuesta > 0) {
                  if (!context.mounted) return;
                  TrabajadorxContratistaProvider().speak(
                    'Trabajador modificado correctamente',
                  );
                  TrabajadorxContratistaProvider().listadoentregas(
                    worker.idcartilla!,
                  );
                  Navigator.of(context).pop('actualiza');
                }
              },
              child:
                  provider.isloading
                      ? const CupertinoActivityIndicator(color: Colors.white)
                      : const Text(
                        'Actualizar',
                        style: TextStyle(
                          fontFamily: 'MontserratB',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RutOtpField extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?) validator;
  final String labelText;

  const _RutOtpField({
    required this.controller,
    required this.validator,
    required this.labelText,
  });

  @override
  State<_RutOtpField> createState() => _RutOtpFieldState();
}

class _RutOtpFieldState extends State<_RutOtpField> {
  static final RegExp _digitRegExp = RegExp(r'^\d$');
  static final RegExp _dvRegExp = RegExp(r'^[0-9K]$');

  final GlobalKey<FormFieldState<String>> _fieldKey =
      GlobalKey<FormFieldState<String>>();
  final List<TextEditingController> _digitControllers = List.generate(
    8,
    (_) => TextEditingController(),
  );
  final TextEditingController _dvController = TextEditingController();
  final List<FocusNode> _focusNodes = List.generate(9, (_) => FocusNode());

  bool _updatingRutController = false;
  bool _syncingFromRutController = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleRutControllerChanged);
    _syncFromRutController();
  }

  @override
  void didUpdateWidget(covariant _RutOtpField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleRutControllerChanged);
      widget.controller.addListener(_handleRutControllerChanged);
      _syncFromRutController();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleRutControllerChanged);
    for (final controller in _digitControllers) {
      controller.dispose();
    }
    _dvController.dispose();
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      key: _fieldKey,
      initialValue: _rutValue,
      validator: (value) {
        if (!_isComplete) return 'Debe completar todos los campos del rut';
        return widget.validator(value);
      },
      builder: (field) {
        final borderColor = field.hasError ? Colors.red : Colors.grey;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.labelText,
              style: const TextStyle(fontFamily: 'MontserratR', fontSize: 12),
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                const gap = 3.0;
                const dashWidth = 10.0;
                final boxWidth =
                    ((constraints.maxWidth - dashWidth - (gap * 9)) / 9).clamp(
                      20.0,
                      42.0,
                    );

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < _digitControllers.length; i++) ...[
                      _buildOtpBox(
                        controller: _digitControllers[i],
                        focusNode: _focusNodes[i],
                        width: boxWidth,
                        borderColor: borderColor,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(1),
                        ],
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        onChanged:
                            (value) =>
                                _handleDigitChanged(i, value, field.didChange),
                      ),
                      const SizedBox(width: gap),
                    ],
                    SizedBox(
                      width: dashWidth,
                      child: const Text(
                        '-',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: gap),
                    _buildOtpBox(
                      controller: _dvController,
                      focusNode: _focusNodes.last,
                      width: boxWidth,
                      borderColor: borderColor,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9kK]')),
                        LengthLimitingTextInputFormatter(1),
                      ],
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      onChanged:
                          (value) => _handleDvChanged(value, field.didChange),
                    ),
                  ],
                );
              },
            ),
            if (field.hasError) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  field.errorText!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildOtpBox({
    required TextEditingController controller,
    required FocusNode focusNode,
    required double width,
    required Color borderColor,
    required List<TextInputFormatter> inputFormatters,
    required TextInputType keyboardType,
    required TextInputAction textInputAction,
    required ValueChanged<String> onChanged,
  }) {
    return SizedBox(
      width: width,
      height: 52,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        style: const TextStyle(fontFamily: 'MontserratR', fontSize: 16),
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          counterText: '',
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: Color.fromRGBO(36, 99, 174, 1)),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: BorderSide(color: borderColor),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }

  void _handleRutControllerChanged() {
    if (_updatingRutController) return;
    _syncFromRutController();
  }

  void _handleDigitChanged(
    int index,
    String value,
    ValueChanged<String?> didChange,
  ) {
    if (_syncingFromRutController) return;

    final digit = value.isEmpty ? '' : value[value.length - 1];
    if (digit.isNotEmpty && !_digitRegExp.hasMatch(digit)) {
      _setText(_digitControllers[index], '');
      return;
    }

    if (_digitControllers[index].text != digit) {
      _setText(_digitControllers[index], digit);
    }

    _writeRutController(didChange);
    if (digit.isNotEmpty && index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (digit.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _handleDvChanged(String value, ValueChanged<String?> didChange) {
    if (_syncingFromRutController) return;

    final dv = value.isEmpty ? '' : value[value.length - 1].toUpperCase();
    if (dv.isNotEmpty && !_dvRegExp.hasMatch(dv)) {
      _setText(_dvController, '');
      return;
    }

    if (_dvController.text != dv) {
      _setText(_dvController, dv);
    }

    _writeRutController(didChange);
    if (dv.isEmpty) {
      _focusNodes[_focusNodes.length - 2].requestFocus();
    }
  }

  void _syncFromRutController() {
    final text = widget.controller.text.toUpperCase().trim();
    final raw = text.replaceAll(RegExp(r'[^0-9K]'), '');
    final digits =
        RegExp(
          r'\d',
        ).allMatches(raw).map((match) => match.group(0)!).take(8).toList();

    String dv = '';
    final dashIndex = text.lastIndexOf('-');
    if (dashIndex != -1) {
      final dashDv = text
          .substring(dashIndex + 1)
          .replaceAll(RegExp(r'[^0-9K]'), '');
      if (dashDv.isNotEmpty) dv = dashDv[0];
    } else if (raw.length > 8) {
      dv = raw[8];
    }

    _syncingFromRutController = true;
    for (int i = 0; i < _digitControllers.length; i++) {
      _setText(_digitControllers[i], i < digits.length ? digits[i] : '');
    }
    _setText(_dvController, _dvRegExp.hasMatch(dv) ? dv : '');
    _syncingFromRutController = false;

    _fieldKey.currentState?.didChange(_rutValue);
  }

  void _writeRutController(ValueChanged<String?> didChange) {
    final value = _rutValue;

    _updatingRutController = true;
    if (widget.controller.text != value) {
      widget.controller.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }
    _updatingRutController = false;

    didChange(value);
  }

  void _setText(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  bool get _isComplete {
    return _digitControllers.every(
          (controller) => controller.text.isNotEmpty,
        ) &&
        _dvController.text.isNotEmpty;
  }

  String get _rutValue {
    final rut = _digitControllers.map((controller) => controller.text).join();
    final dv = _dvController.text.toUpperCase();
    return dv.isEmpty ? rut : '$rut-$dv';
  }
}
