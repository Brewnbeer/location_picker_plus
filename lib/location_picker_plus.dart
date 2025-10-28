import 'location_picker_plus_platform_interface.dart';

// Export core models and services
export 'models/location_result.dart';
export 'models/country_model.dart';
export 'models/state_model.dart';
export 'models/city_model.dart';
export 'services/google_places_service.dart';
export 'services/location_service.dart';

// Export widgets
export 'widgets/custom_street_address_field.dart';
export 'widgets/address_text_field.dart';
export 'widgets/address_dropdown_fields.dart';

class LocationPicker {
  Future<String?> getPlatformVersion() {
    return LocationPickerPlatform.instance.getPlatformVersion();
  }
}
