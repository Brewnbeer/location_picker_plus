import 'package:flutter_test/flutter_test.dart';
import 'package:location_picker_plus/location_picker_plus.dart';
import 'package:location_picker_plus/location_picker_plus_platform_interface.dart';
import 'package:location_picker_plus/location_picker_plus_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockLocationPickerPlatform
    with MockPlatformInterfaceMixin
    implements LocationPickerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final LocationPickerPlatform initialPlatform = LocationPickerPlatform.instance;

  test('$MethodChannelLocationPicker is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelLocationPicker>());
  });

  test('getPlatformVersion', () async {
    LocationPicker locationPickerPlugin = LocationPicker();
    MockLocationPickerPlatform fakePlatform = MockLocationPickerPlatform();
    LocationPickerPlatform.instance = fakePlatform;

    expect(await locationPickerPlugin.getPlatformVersion(), '42');
  });
}
