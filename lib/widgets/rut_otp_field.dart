import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RutOtpField extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?) validator;
  final TextStyle? style;
  final String labelText;
  final bool validarRutChile;

  const RutOtpField({
    super.key,
    required this.validarRutChile,
    required this.controller,
    required this.validator,
    required this.labelText,
    this.style,
  });

  @override
  State<RutOtpField> createState() => _RutOtpFieldState();
}

class _RutOtpFieldState extends State<RutOtpField> {
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
  void didUpdateWidget(covariant RutOtpField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.validarRutChile != widget.validarRutChile &&
        _dvController.text.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fieldKey.currentState?.validate();
      });
    }
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
              style:
                  widget.style?.copyWith(fontSize: 12) ??
                  const TextStyle(fontSize: 12),
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
                      child: Text(
                        '-',
                        textAlign: TextAlign.center,
                        style:
                            widget.style?.copyWith(fontSize: 18) ??
                            const TextStyle(fontSize: 18),
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
        style: widget.style?.copyWith(fontSize: 16),
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

    String dv = '';
    String body = raw;
    final dashIndex = text.lastIndexOf('-');
    if (dashIndex != -1) {
      body = text.substring(0, dashIndex).replaceAll('.', '');
      final dashDv = text
          .substring(dashIndex + 1)
          .replaceAll(RegExp(r'[^0-9K]'), '');
      if (dashDv.isNotEmpty) dv = dashDv[0];
    } else if (raw.length > 1) {
      body = raw.substring(0, raw.length - 1);
      dv = raw.substring(raw.length - 1);
    }
    final digits = body.split('').take(8).toList();

    _syncingFromRutController = true;
    for (int i = 0; i < _digitControllers.length; i++) {
      _setText(_digitControllers[i], i < digits.length ? digits[i] : '');
    }
    _setText(_dvController, _dvRegExp.hasMatch(dv) ? dv : '');
    _syncingFromRutController = false;

    _fieldKey.currentState?.didChange(_rutValue);
    if (_dvController.text.isNotEmpty) _fieldKey.currentState?.validate();
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
    if (_dvController.text.isNotEmpty ||
        (_fieldKey.currentState?.hasError ?? false)) {
      _fieldKey.currentState?.validate();
    }
  }

  void _setText(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  bool get _isComplete {
    final body =
        _digitControllers
            .map(
              (controller) => controller.text.isEmpty ? '_' : controller.text,
            )
            .join();
    return RegExp(r'^\d{1,8}_*$').hasMatch(body) &&
        _dvController.text.isNotEmpty;
  }

  String get _rutValue {
    final rut = _digitControllers.map((controller) => controller.text).join();
    final dv = _dvController.text.toUpperCase();
    return dv.isEmpty ? rut : '$rut-$dv';
  }
}
