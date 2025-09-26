import 'package:flutter/material.dart';
import 'package:location_picker_plus/widgets/enhanced_google_places_widget.dart';
import 'package:location_picker_plus/models/location_result.dart';

/// Comprehensive demo showcasing advanced customization options
/// Demonstrates multiple themes and styling possibilities
class AdvancedCustomizationDemo extends StatefulWidget {
  const AdvancedCustomizationDemo({super.key});

  @override
  State<AdvancedCustomizationDemo> createState() => _AdvancedCustomizationDemoState();
}

class _AdvancedCustomizationDemoState extends State<AdvancedCustomizationDemo> {
  int _currentThemeIndex = 0;
  LocationResult? _selectedLocation;

  final List<String> _themeNames = [
    'Material Design',
    'iOS Cupertino',
    'Minimal Flat',
    'Vibrant Colorful',
    'Glassmorphic',
    'Custom Corporate',
    'Dark Neon',
    'Elegant Classic',
  ];

  final List<Widget Function()> _themeBuilders = [];

  @override
  void initState() {
    super.initState();
    _themeBuilders.addAll([
      _buildMaterialTheme,
      _buildCupertinoTheme,
      _buildMinimalTheme,
      _buildVibrantTheme,
      _buildGlassmorphicTheme,
      _buildCorporateTheme,
      _buildDarkNeonTheme,
      _buildElegantTheme,
    ]);
  }

  void _onLocationSelected(LocationResult? result) {
    setState(() {
      _selectedLocation = result;
    });

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selected: ${result.address}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Material Design Theme Example
  Widget _buildMaterialTheme() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(20),
      child: EnhancedGooglePlacesWidget(
        apiKey: 'YOUR_GOOGLE_PLACES_API_KEY',
        hintText: 'Search places...',
        textStyle: const TextStyle(fontSize: 16),
        hintStyle: TextStyle(color: Colors.grey[600]),
        borderRadius: BorderRadius.circular(8),
        borderColor: Colors.grey[400],
        focusedBorderColor: Colors.blue,
        fillColor: Colors.white,
        filled: true,
        suggestionBackgroundColor: Colors.white,
        suggestionElevation: 4,
        suggestionBorderRadius: BorderRadius.circular(8),
        debounceDelay: const Duration(milliseconds: 300),
        showAnimations: true,
        animationDuration: const Duration(milliseconds: 200),
        onLocationSelected: _onLocationSelected,
      ),
    );
  }

  /// iOS Cupertino Theme Example
  Widget _buildCupertinoTheme() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: EnhancedGooglePlacesWidget(
        apiKey: 'YOUR_GOOGLE_PLACES_API_KEY',
        hintText: 'Search location',
        textStyle: const TextStyle(fontSize: 17, color: Colors.black87),
        hintStyle: TextStyle(fontSize: 17, color: Colors.grey[600]),
        borderRadius: BorderRadius.circular(12),
        borderColor: Colors.grey[300],
        focusedBorderColor: Colors.blue,
        fillColor: Colors.grey[50],
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        suggestionBackgroundColor: Colors.white,
        suggestionElevation: 2,
        suggestionBorderRadius: BorderRadius.circular(12),
        suggestionPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        locationIcon: const Icon(Icons.location_on, color: Colors.blue),
        onLocationSelected: _onLocationSelected,
      ),
    );
  }

  /// Minimal Flat Theme Example
  Widget _buildMinimalTheme() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey, width: 1)),
      ),
      padding: const EdgeInsets.all(20),
      child: EnhancedGooglePlacesWidget(
        apiKey: 'YOUR_GOOGLE_PLACES_API_KEY',
        hintText: 'Type to search',
        textStyle: const TextStyle(fontSize: 16, color: Colors.black87),
        hintStyle: TextStyle(fontSize: 16, color: Colors.grey[500]),
        borderRadius: BorderRadius.circular(0),
        border: const Border(bottom: BorderSide(color: Colors.grey)),
        focusedBorder: const Border(bottom: BorderSide(color: Colors.black, width: 2)),
        fillColor: Colors.transparent,
        filled: false,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        prefixIcon: null,
        suggestionBackgroundColor: Colors.white,
        suggestionElevation: 1,
        suggestionBorderRadius: BorderRadius.circular(0),
        suggestionPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
        locationIcon: const Icon(Icons.place, color: Colors.black54, size: 18),
        showAnimations: false,
        onLocationSelected: _onLocationSelected,
      ),
    );
  }

  /// Vibrant Colorful Theme Example
  Widget _buildVibrantTheme() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.deepPurple, Colors.pink],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(24),
      child: EnhancedGooglePlacesWidget(
        apiKey: 'YOUR_GOOGLE_PLACES_API_KEY',
        hintText: '✨ Find amazing places',
        textStyle: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
        hintStyle: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.7)),
        borderRadius: BorderRadius.circular(25),
        borderColor: Colors.transparent,
        focusedBorderColor: Colors.white,
        fillColor: Colors.white.withValues(alpha: 0.2),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.8)),
        clearIcon: IconButton(
          icon: Icon(Icons.clear, color: Colors.white.withValues(alpha: 0.8)),
          onPressed: () {},
        ),
        suggestionBackgroundColor: Colors.deepPurple[700],
        suggestionElevation: 12,
        suggestionBorderRadius: BorderRadius.circular(15),
        suggestionTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        suggestionSubtextStyle: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
        locationIcon: Icon(Icons.location_on, color: Colors.white.withValues(alpha: 0.8)),
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.elasticOut,
        onLocationSelected: _onLocationSelected,
      ),
    );
  }

  /// Glassmorphic Theme Example
  Widget _buildGlassmorphicTheme() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF667eea),
            Color(0xFF764ba2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        padding: const EdgeInsets.all(16),
        child: EnhancedGooglePlacesWidget(
          apiKey: 'YOUR_GOOGLE_PLACES_API_KEY',
          hintText: 'Search with glass effect',
          textStyle: const TextStyle(fontSize: 16, color: Colors.white),
          hintStyle: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.6)),
          borderRadius: BorderRadius.circular(12),
          borderColor: Colors.white.withValues(alpha: 0.3),
          focusedBorderColor: Colors.white.withValues(alpha: 0.5),
          fillColor: Colors.white.withValues(alpha: 0.1),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.7)),
          suggestionBackgroundColor: Colors.white.withValues(alpha: 0.15),
          suggestionElevation: 0,
          suggestionBorderRadius: BorderRadius.circular(12),
          suggestionTextStyle: const TextStyle(color: Colors.white),
          suggestionSubtextStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
          locationIcon: Icon(Icons.location_on, color: Colors.white.withValues(alpha: 0.7)),
          onLocationSelected: _onLocationSelected,
        ),
      ),
    );
  }

  /// Corporate Theme Example
  Widget _buildCorporateTheme() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1a237e),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Corporate Location Search',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          EnhancedGooglePlacesWidget(
            apiKey: 'YOUR_GOOGLE_PLACES_API_KEY',
            hintText: 'Enter business location',
            textStyle: const TextStyle(fontSize: 16, color: Colors.white),
            hintStyle: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.7)),
            borderRadius: BorderRadius.circular(4),
            borderColor: Colors.white.withValues(alpha: 0.3),
            focusedBorderColor: Colors.amber,
            fillColor: Colors.white.withValues(alpha: 0.1),
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            prefixIcon: Icon(Icons.business, color: Colors.white.withValues(alpha: 0.8)),
            suggestionBackgroundColor: const Color(0xFF1a237e),
            suggestionElevation: 8,
            suggestionBorderRadius: BorderRadius.circular(4),
            suggestionTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
            suggestionSubtextStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
            locationIcon: Icon(Icons.location_city, color: Colors.amber, size: 18),
            onLocationSelected: _onLocationSelected,
          ),
        ],
      ),
    );
  }

  /// Dark Neon Theme Example
  Widget _buildDarkNeonTheme() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0a0a0a),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyan.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(20),
      child: EnhancedGooglePlacesWidget(
        apiKey: 'YOUR_GOOGLE_PLACES_API_KEY',
        hintText: '> Search_location.exe',
        textStyle: const TextStyle(
          fontSize: 16,
          color: Colors.cyan,
          fontFamily: 'monospace',
        ),
        hintStyle: TextStyle(
          fontSize: 16,
          color: Colors.cyan.withValues(alpha: 0.6),
          fontFamily: 'monospace',
        ),
        borderRadius: BorderRadius.circular(8),
        borderColor: Colors.cyan.withValues(alpha: 0.5),
        focusedBorderColor: Colors.cyan,
        fillColor: const Color(0xFF111111),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        prefixIcon: Icon(Icons.terminal, color: Colors.cyan.withValues(alpha: 0.8)),
        suggestionBackgroundColor: const Color(0xFF111111),
        suggestionElevation: 8,
        suggestionBorderRadius: BorderRadius.circular(8),
        suggestionTextStyle: const TextStyle(
          color: Colors.cyan,
          fontFamily: 'monospace',
        ),
        suggestionSubtextStyle: TextStyle(
          color: Colors.cyan.withValues(alpha: 0.6),
          fontFamily: 'monospace',
          fontSize: 12,
        ),
        locationIcon: Icon(Icons.my_location, color: Colors.cyan, size: 16),
        customSuggestionBuilder: (prediction) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.cyan.withValues(alpha: 0.2)),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.keyboard_arrow_right, color: Colors.cyan, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prediction.mainText ?? prediction.description,
                        style: const TextStyle(
                          color: Colors.cyan,
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                      ),
                      if (prediction.secondaryText != null)
                        Text(
                          '// ${prediction.secondaryText}',
                          style: TextStyle(
                            color: Colors.cyan.withValues(alpha: 0.6),
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        onLocationSelected: _onLocationSelected,
      ),
    );
  }

  /// Elegant Classic Theme Example
  Widget _buildElegantTheme() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Elegant Search',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: Colors.grey[800],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find your perfect location with style',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 24),
          EnhancedGooglePlacesWidget(
            apiKey: 'YOUR_GOOGLE_PLACES_API_KEY',
            hintText: 'Where would you like to go?',
            textStyle: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
              fontWeight: FontWeight.w400,
            ),
            hintStyle: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
              fontWeight: FontWeight.w300,
            ),
            borderRadius: BorderRadius.circular(12),
            borderColor: Colors.grey[300],
            focusedBorderColor: Colors.indigo[300],
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 22),
            suggestionBackgroundColor: Colors.white,
            suggestionElevation: 6,
            suggestionBorderRadius: BorderRadius.circular(12),
            suggestionPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            suggestionTextStyle: TextStyle(
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
            suggestionSubtextStyle: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w300,
            ),
            locationIcon: Icon(Icons.location_on_outlined, color: Colors.indigo[300], size: 20),
            animationDuration: const Duration(milliseconds: 250),
            animationCurve: Curves.easeInOutCubic,
            onLocationSelected: _onLocationSelected,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Customization'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.palette),
            onSelected: (index) {
              setState(() {
                _currentThemeIndex = index;
                _selectedLocation = null;
              });
            },
            itemBuilder: (context) => List.generate(
              _themeNames.length,
              (index) => PopupMenuItem(
                value: index,
                child: Row(
                  children: [
                    if (index == _currentThemeIndex)
                      const Icon(Icons.check, size: 16),
                    if (index == _currentThemeIndex)
                      const SizedBox(width: 8),
                    Text(_themeNames[index]),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Theme showcase
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.style, color: Colors.indigo[600]),
                          const SizedBox(width: 8),
                          Text(
                            _themeNames[_currentThemeIndex],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _themeBuilders[_currentThemeIndex](),
                    ],
                  ),
                ),
              ),
            ),

            // Selected location display
            if (_selectedLocation != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  color: Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green[600]),
                            const SizedBox(width: 8),
                            const Text(
                              'Selected Location',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedLocation!.address,
                          style: const TextStyle(fontSize: 14),
                        ),
                        if (_selectedLocation!.latitude != 0.0 && _selectedLocation!.longitude != 0.0)
                          Text(
                            'Coordinates: ${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

            // Features list
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Customization Features',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _FeatureItem('🎨 Complete visual customization'),
                      const _FeatureItem('🌈 Multiple pre-built themes'),
                      const _FeatureItem('✨ Smooth animations & transitions'),
                      const _FeatureItem('🎯 Custom suggestion builders'),
                      const _FeatureItem('📱 Responsive design'),
                      const _FeatureItem('♿ Accessibility support'),
                      const _FeatureItem('⚡ Performance optimized'),
                      const _FeatureItem('🔧 Flexible configuration'),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String text;

  const _FeatureItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}