
import 'location_picker_platform_interface.dart';

export 'models/country_model.dart';
export 'models/state_model.dart';
export 'models/city_model.dart';
export 'widgets/location_picker_widget.dart';
export 'widgets/autocomplete_dropdown.dart';
export 'themes/location_picker_theme.dart';
export 'services/location_service.dart';

class LocationPicker {
  Future<String?> getPlatformVersion() {
    return LocationPickerPlatform.instance.getPlatformVersion();
  }
}
