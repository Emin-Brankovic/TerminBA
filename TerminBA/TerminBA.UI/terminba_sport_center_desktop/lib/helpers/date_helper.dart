import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateHelper {
  // Auto-detects device locale
  static String toLocalDate(DateTime date, BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMMd(locale).format(date);
  }

  // With time
  static String toLocalDateTime(DateTime date, BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMMd(locale).add_Hm().format(date);
    // → 17. apr 2026. 12:00
  }

  // Without context — use explicit locale
  static String toLocalDateStatic(DateTime date, {String locale = 'bs'}) {
    return DateFormat.yMd(locale).format(date);
  }
}