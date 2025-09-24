import 'location_picker_plus_platform_interface.dart';

export 'models/city_model.dart';
export 'models/country_model.dart';
export 'models/state_model.dart';
export 'models/location_model.dart';
export 'services/location_service.dart';
export 'services/location_detector_service.dart';
export 'themes/location_picker_plus_theme.dart';
export 'widgets/autocomplete_dropdown.dart';
export 'widgets/location_picker_plus_widget.dart';
export 'widgets/location_detector_widget.dart';

class LocationPicker {
  Future<String?> getPlatformVersion() {
    return LocationPickerPlatform.instance.getPlatformVersion();
  }
}
