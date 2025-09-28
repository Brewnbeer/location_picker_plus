import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'location_picker_plus_method_channel.dart';

abstract class LocationPickerPlatform extends PlatformInterface {
  /// Constructs a LocationPickerPlatform.
  LocationPickerPlatform() : super(token: _token);

  static final Object _token = Object();

  static LocationPickerPlatform _instance = MethodChannelLocationPicker();

  /// The default instance of [LocationPickerPlatform] to use.
  ///
  /// Defaults to [MethodChannelLocationPicker].
  static LocationPickerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [LocationPickerPlatform] when
  /// they register themselves.
  static set instance(LocationPickerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
