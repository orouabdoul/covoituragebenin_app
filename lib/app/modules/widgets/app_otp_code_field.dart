import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    _focusNodes = List.generate(widget.length, (index) {
      final node = FocusNode();

      // Sélectionne le contenu existant dès que le champ reçoit le focus —
      // que ce soit par tap ou par avance/recul programmatique.
      // Ainsi, taper un nouveau chiffre remplace l'ancien sans bloquer.
      node.addListener(() {
        if (node.hasFocus && _controllers[index].text.isNotEmpty) {
          _controllers[index].selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controllers[index].text.length,
          );
        }
      });

      // Backspace sur un champ DÉJÀ VIDE → recule au champ précédent.
      node.onKeyEvent = (_, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            _controllers[index].text.isEmpty &&
            index > 0) {
          _focusNodes[index - 1].requestFocus();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      };

      return node;
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _focusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _notifyChange() {
    widget.onChanged(
      _controllers.map((c) => c.text).join(),
    );
  }

  void _handleChanged(int index, String value) {
    _notifyChange();

    if (value.isNotEmpty && index < widget.length - 1) {
      // Chiffre saisi → avance au champ suivant.
      _focusNodes[index + 1].requestFocus();
    } else if (value.isNotEmpty) {
      // Dernier champ rempli → ferme le clavier.
      _focusNodes[index].unfocus();
    }
    // Champ vidé (valeur vide) → on ne recule PAS ici.
    // Le recul est géré par onKeyEvent uniquement quand le champ était déjà vide.
    // Cela permet d'effacer le chiffre courant et de rester sur place pour le ressaisir.
  }

  void _selectAll(int index) {
    if (_controllers[index].text.isNotEmpty) {
      _controllers[index].selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controllers[index].text.length,
      );
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
            textInputAction: index == widget.length - 1
                ? TextInputAction.done
                : TextInputAction.next,
            textAlign: TextAlign.center,
            maxLength: 1,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
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
                borderRadius:
                    BorderRadius.circular(widget.responsive.radius(12)),
                borderSide: const BorderSide(width: 2, color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(widget.responsive.radius(12)),
                borderSide: const BorderSide(width: 2, color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(widget.responsive.radius(12)),
                borderSide:
                    const BorderSide(width: 2, color: AppColors.primary),
              ),
            ),
            // Si l'utilisateur re-tape sur un champ déjà focusé, sélectionne tout.
            onTap: () => _selectAll(index),
            onChanged: (value) => _handleChanged(index, value),
          ),
        );
      }),
    );
  }
}
