import 'package:flutter/material.dart';

class AmenityIconMapper {
  AmenityIconMapper._();

  static const _map = <String, IconData>{
    'parking':      Icons.local_parking,
    'restaurant':   Icons.restaurant,
    'locker room':  Icons.lock_outline,
    'caffe':        Icons.local_cafe,
    'sauna':        Icons.hot_tub,
    'shower':       Icons.shower,
    'cafeteria':    Icons.local_dining,
    'wifi':         Icons.wifi,
    'first aid':    Icons.medical_services,
  };

  static IconData getIcon(String? amenityName) {
    if (amenityName == null || amenityName.isEmpty) {
      return Icons.check_circle_outline;
    }
    final key = amenityName.toLowerCase().trim();
    return _map[key] ?? Icons.check_circle_outline;
  }
}