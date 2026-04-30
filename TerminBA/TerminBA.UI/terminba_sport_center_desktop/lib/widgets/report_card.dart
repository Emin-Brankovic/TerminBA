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
    this.padding = const EdgeInsets.all(12),
    this.iconColor,
    this.iconSize = 40,
    this.iconBackgroundColor,
    this.iconContainerSize = 28,
    this.iconToTitleSpacing = 12,
    this.titleToValueSpacing = 8,
    this.titleStyle = const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
    this.valueStyle = const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
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
  final TextStyle titleStyle;
  final TextStyle valueStyle;

  @override
  Widget build(BuildContext context) {
    final iconWidget = iconBackgroundColor == null
        ? Icon(
            iconData,
            color: iconColor ?? Colors.greenAccent.shade700,
            size: iconSize,
          )
        : Container(
            width: iconContainerSize,
            height: iconContainerSize,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconData,
              color: iconColor ?? Colors.white,
              size: iconSize,
            ),
          );

    return SizedBox(
      width: width,
      child: Card(
        elevation: 0,
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(
            color: borderColor ?? Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              iconWidget,
              SizedBox(height: iconToTitleSpacing),
              Text(
                title,
                style: titleStyle,
              ),
              SizedBox(height: titleToValueSpacing),
              Text(
                value,
                style: valueStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}