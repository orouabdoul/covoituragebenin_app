#!/bin/bash
FILE="lib/app/modules/principal/driver/trajet/views/trajet_view.dart"
T7=$(printf '\t%.0s' {1..7})
T8=$(printf '\t%.0s' {1..8})
T9=$(printf '\t%.0s' {1..9})
T10=$(printf '\t%.0s' {1..10})
T11=$(printf '\t%.0s' {1..11})
T12=$(printf '\t%.0s' {1..12})

# Lines 251-271: replace SizedBox(6)+Opacity block with FittedBox fix
sed -i "251,271c\\
${T7}SizedBox(width: responsive.w(4)),\\
${T7}Opacity(\\
${T8}opacity: selected ? 0.75 : 1,\\
${T8}child: Container(\\
${T9}constraints: BoxConstraints(maxWidth: responsive.w(44)),\\
${T9}padding: EdgeInsets.symmetric(horizontal: responsive.w(5), vertical: responsive.h(2)),\\
${T9}decoration: ShapeDecoration(\\
${T10}shape: RoundedRectangleBorder(\\
${T11}side: const BorderSide(color: AppColors.border),\\
${T11}borderRadius: BorderRadius.circular(9999),\\
${T10}),\\
${T9}),\\
${T9}child: FittedBox(\\
${T10}fit: BoxFit.scaleDown,\\
${T10}child: Text(\\
${T11}summary.count,\\
${T11}maxLines: 1,\\
${T11}style: AppTextStyles.caption(responsive).copyWith(\\
${T12}color: chipTextColor,\\
${T12}fontSize: responsive.text(12),\\
${T12}fontWeight: FontWeight.w600,\\
${T11}),\\
${T10}),\\
${T9}),\\
${T8}),\\
${T7})," "$FILE"

echo "Done"
