import 'package:flutter/material.dart';

class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    required this.title,
    required this.value,
    required this.iconData,
    this.width,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.all(16),
    this.iconColor,
    this.iconSize = 20,
    this.iconBackgroundColor,
    this.iconContainerSize = 36,
    this.iconToTitleSpacing = 10,
    this.titleToValueSpacing = 8,
    this.titleStyle,
    this.valueStyle,
  });

  final String title;
  final String value;
  final IconData iconData;
  final double? width;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? iconColor;
  final double iconSize;
  final Color? iconBackgroundColor;
  final double iconContainerSize;
  final double iconToTitleSpacing;
  final double titleToValueSpacing;
  final TextStyle? titleStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    const defaultTitleStyle = TextStyle(
      fontSize: 13.2,
      fontWeight: FontWeight.w700,
      color: Color(0xFF64748B),
      letterSpacing: 0.6,
    );

    const defaultValueStyle = TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w800,
      color: Color(0xFF0F172A),
      letterSpacing: -0.5,
    );

    final effectiveTitleStyle = titleStyle ?? defaultTitleStyle;
    final effectiveValueStyle = valueStyle ?? defaultValueStyle;

    final iconWidget = Container(
      width: iconContainerSize,
      height: iconContainerSize,
      decoration: BoxDecoration(
        color: iconBackgroundColor ?? const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          iconData,
          color: iconColor ?? const Color(0xFF059669),
          size: iconSize,
        ),
      ),
    );

    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor ?? const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: effectiveTitleStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                iconWidget,
              ],
            ),
            SizedBox(height: titleToValueSpacing),
            Text(
              value,
              style: effectiveValueStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}