import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:flutter/material.dart';

class AppOtpCodeField extends StatefulWidget {
  const AppOtpCodeField({
    super.key,
    required this.responsive,
    required this.length,
    required this.onChanged,
  });

  final AppResponsive responsive;
  final int length;
  final ValueChanged<String> onChanged;

  @override
  State<AppOtpCodeField> createState() => _AppOtpCodeFieldState();
}

class _AppOtpCodeFieldState extends State<AppOtpCodeField> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _notifyChange() {
    widget.onChanged(_controllers.map((controller) => controller.text).join());
  }

  void _handleChanged(int index, String value) {
    final String digit = value.replaceAll(RegExp(r'\D'), '');
    if (digit.isEmpty) {
      _controllers[index].clear();
      _notifyChange();
      return;
    }

    _controllers[index].text = digit.substring(0, 1);
    _controllers[index].selection = TextSelection.collapsed(offset: _controllers[index].text.length);
    _notifyChange();

    if (index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else {
      _focusNodes[index].unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double boxWidth = widget.responsive.w(48);
    final double boxHeight = widget.responsive.h(56);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        return SizedBox(
          width: boxWidth,
          height: boxHeight,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: TextStyle(
              color: const Color(0xFF111111),
              fontSize: widget.responsive.text(20),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              height: 1.20,
              letterSpacing: -0.50,
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.responsive.radius(12)),
                borderSide: const BorderSide(width: 2, color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.responsive.radius(12)),
                borderSide: const BorderSide(width: 2, color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.responsive.radius(12)),
                borderSide: const BorderSide(width: 2, color: AppColors.primary),
              ),
            ),
            onChanged: (value) {
              _handleChanged(index, value);
            },
          ),
        );
      }),
    );
  }
}