import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'location_picker_plus_platform_interface.dart';

/// An implementation of [LocationPickerPlatform] that uses method channels.
class MethodChannelLocationPicker extends LocationPickerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('location_picker_plus');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
