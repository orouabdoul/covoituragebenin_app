import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:flutter/material.dart';

class AppField extends StatefulWidget {
  const AppField({
    super.key,
    required this.responsive,
    required this.label,
    this.child,
    this.controller,
    this.focusNode,
    this.hintText,
    this.keyboardType,
    this.textStyle,
    this.hintStyle,
    this.readOnly = false,
    this.obscureText = false,
    this.maxLines = 1,
    this.onTap,
    this.helperText,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.padding,
    this.labelStyle,
    this.helperStyle,
  });

  final AppResponsive responsive;
  final String label;
  final Widget? child;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final TextInputType? keyboardType;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final bool readOnly;
  final bool obscureText;
  final int? maxLines;
  final VoidCallback? onTap;
  final String? helperText;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final TextStyle? labelStyle;
  final TextStyle? helperStyle;

  @override
  State<AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<AppField> {
  FocusNode? _internalNode;
  FocusNode get _node =>
      widget.focusNode ?? (_internalNode ??= FocusNode());

  @override
  void dispose() {
    _internalNode?.dispose();
    super.dispose();
  }

  void _handleContainerTap() {
    if (widget.child == null && !widget.readOnly) {
      _node.requestFocus();
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;
    final double radius = widget.borderRadius ?? r.radius(16);
    final Color bg = widget.backgroundColor ?? AppColors.surface;
    final Color bc = widget.borderColor ?? AppColors.border;

    final bool hasCustomChild = widget.child != null;

    final Widget resolvedChild = hasCustomChild
        ? widget.child!
        : TextField(
            focusNode: _node,
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            style: widget.textStyle,
            readOnly: widget.readOnly,
            obscureText: widget.obscureText,
            maxLines: widget.maxLines,
            onTap: widget.onTap,
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              filled: false,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: widget.hintText,
              hintStyle: widget.hintStyle,
            ),
          );

    // Custom child → SizedBox.expand so columns/rows can control their own
    // alignment. Default TextField → Align centerLeft for vertical centering
    // within the minHeight constraint.
    final Widget containerChild = hasCustomChild
        ? SizedBox(width: double.infinity, child: resolvedChild)
        : Align(alignment: Alignment.centerLeft, child: resolvedChild);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: widget.labelStyle),
        SizedBox(height: r.h(8)),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _handleContainerTap,
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: r.h(52)),
            padding: widget.padding ?? EdgeInsets.all(r.w(16)),
            decoration: ShapeDecoration(
              color: bg,
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 2, color: bc),
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
            child: containerChild,
          ),
        ),
        if (widget.helperText != null) ...[
          SizedBox(height: r.h(8)),
          Text(widget.helperText!, style: widget.helperStyle),
        ],
      ],
    );
  }
}
