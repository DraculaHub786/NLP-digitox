import 'package:flutter/material.dart';

@immutable
class DeviceInfoModel {
  final String manufacturer;
  final String model;
  final String androidVersion;
  final int sdkVersion;
  final String digitoxVersion;

  const DeviceInfoModel({
    required this.manufacturer,
    required this.model,
    required this.androidVersion,
    required this.sdkVersion,
    required this.digitoxVersion,
  });

  factory DeviceInfoModel.fromMap(Map<String, dynamic> map) {
    return DeviceInfoModel(
      manufacturer: map['manufacturer'] ?? '',
      model: map['model'] ?? '',
      androidVersion: map['androidVersion'] ?? '',
      sdkVersion: map['sdkVersion'] ?? 24,
      digitoxVersion: map['digitoxVersion'] ?? '',
    );
  }
}
