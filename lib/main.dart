import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:device_preview/presets.dart';
import 'app.dart';

void main() {
  // DevicePreview manages its own binding in debug mode
  if (kDebugMode) {
    DevicePreview.enable();
    DevicePreview.maybeController?.applyPreset(DevicePresets.pixel9);
  }

  runApp(const AutoCareApp());
}
