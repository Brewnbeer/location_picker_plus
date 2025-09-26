import 'package:flutter/material.dart';

/// Enhanced theme system for location picker widgets
/// Provides comprehensive customization options for all UI elements
class EnhancedLocationTheme {
  // Input field styling
  final TextStyle? inputTextStyle;
  final TextStyle? inputHintStyle;
  final InputDecoration? inputDecoration;
  final EdgeInsetsGeometry? inputPadding;
  final BorderRadius? inputBorderRadius;
  final Border? inputBorder;
  final Border? inputFocusedBorder;
  final Border? inputErrorBorder;
  final Color? inputFillColor;
  final bool? inputFilled;
  final double? inputBorderWidth;
  final Color? inputBorderColor;
  final Color? inputFocusedBorderColor;
  final Color? inputErrorBorderColor;

  // Dropdown/Suggestions styling
  final Color? dropdownBackgroundColor;
  final Color? dropdownHoverColor;
  final Color? dropdownSelectedColor;
  final BorderRadius? dropdownBorderRadius;
  final double? dropdownElevation;
  final EdgeInsetsGeometry? dropdownPadding;
  final double? dropdownMaxHeight;
  final BoxShadow? dropdownShadow;
  final Border? dropdownBorder;

  // Text styling
  final TextStyle? primaryTextStyle;
  final TextStyle? secondaryTextStyle;
  final TextStyle? hintTextStyle;
  final TextStyle? errorTextStyle;
  final TextStyle? labelTextStyle;

  // Icon styling
  final Color? iconColor;
  final Color? primaryIconColor;
  final Color? secondaryIconColor;
  final double? iconSize;
  final double? smallIconSize;
  final double? largeIconSize;

  // Colors
  final Color? primaryColor;
  final Color? secondaryColor;
  final Color? backgroundColor;
  final Color? surfaceColor;
  final Color? errorColor;
  final Color? successColor;
  final Color? warningColor;
  final Color? dividerColor;

  // Spacing and sizing
  final EdgeInsetsGeometry? defaultPadding;
  final EdgeInsetsGeometry? compactPadding;
  final EdgeInsetsGeometry? expansivePadding;
  final double? defaultSpacing;
  final double? compactSpacing;
  final double? expansiveSpacing;
  final BorderRadius? defaultBorderRadius;
  final BorderRadius? compactBorderRadius;
  final BorderRadius? expansiveBorderRadius;

  // Animation
  final Duration? animationDuration;
  final Duration? fastAnimationDuration;
  final Duration? slowAnimationDuration;
  final Curve? animationCurve;
  final bool enableAnimations;

  // Interaction
  final Duration? debounceDelay;
  final Duration? fastDebounceDelay;
  final Duration? slowDebounceDelay;

  // Accessibility
  final double? minTouchTargetSize;
  final bool enableSemantics;

  const EnhancedLocationTheme({
    // Input styling
    this.inputTextStyle,
    this.inputHintStyle,
    this.inputDecoration,
    this.inputPadding,
    this.inputBorderRadius,
    this.inputBorder,
    this.inputFocusedBorder,
    this.inputErrorBorder,
    this.inputFillColor,
    this.inputFilled,
    this.inputBorderWidth,
    this.inputBorderColor,
    this.inputFocusedBorderColor,
    this.inputErrorBorderColor,

    // Dropdown styling
    this.dropdownBackgroundColor,
    this.dropdownHoverColor,
    this.dropdownSelectedColor,
    this.dropdownBorderRadius,
    this.dropdownElevation,
    this.dropdownPadding,
    this.dropdownMaxHeight,
    this.dropdownShadow,
    this.dropdownBorder,

    // Text styling
    this.primaryTextStyle,
    this.secondaryTextStyle,
    this.hintTextStyle,
    this.errorTextStyle,
    this.labelTextStyle,

    // Icon styling
    this.iconColor,
    this.primaryIconColor,
    this.secondaryIconColor,
    this.iconSize,
    this.smallIconSize,
    this.largeIconSize,

    // Colors
    this.primaryColor,
    this.secondaryColor,
    this.backgroundColor,
    this.surfaceColor,
    this.errorColor,
    this.successColor,
    this.warningColor,
    this.dividerColor,

    // Spacing
    this.defaultPadding,
    this.compactPadding,
    this.expansivePadding,
    this.defaultSpacing,
    this.compactSpacing,
    this.expansiveSpacing,
    this.defaultBorderRadius,
    this.compactBorderRadius,
    this.expansiveBorderRadius,

    // Animation
    this.animationDuration,
    this.fastAnimationDuration,
    this.slowAnimationDuration,
    this.animationCurve,
    this.enableAnimations = true,

    // Interaction
    this.debounceDelay,
    this.fastDebounceDelay,
    this.slowDebounceDelay,

    // Accessibility
    this.minTouchTargetSize,
    this.enableSemantics = true,
  });

  /// Default Material Design theme
  static EnhancedLocationTheme material([BuildContext? context]) {
    final theme = context != null ? Theme.of(context) : ThemeData();

    return EnhancedLocationTheme(
      // Input styling
      inputTextStyle: theme.textTheme.bodyLarge,
      inputHintStyle: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
      inputPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      inputBorderRadius: BorderRadius.circular(4),
      inputBorderWidth: 1,
      inputBorderColor: Colors.grey[400],
      inputFocusedBorderColor: theme.primaryColor,
      inputErrorBorderColor: theme.colorScheme.error,
      inputFillColor: theme.cardColor,
      inputFilled: false,

      // Dropdown styling
      dropdownBackgroundColor: theme.cardColor,
      dropdownHoverColor: theme.primaryColor.withValues(alpha: 0.08),
      dropdownSelectedColor: theme.primaryColor.withValues(alpha: 0.12),
      dropdownBorderRadius: BorderRadius.circular(4),
      dropdownElevation: 8,
      dropdownPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      dropdownMaxHeight: 300,

      // Text styling
      primaryTextStyle: theme.textTheme.bodyLarge,
      secondaryTextStyle: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
      hintTextStyle: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
      errorTextStyle: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
      labelTextStyle: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),

      // Icon styling
      iconColor: Colors.grey[600],
      primaryIconColor: theme.primaryColor,
      iconSize: 20,
      smallIconSize: 16,
      largeIconSize: 24,

      // Colors
      primaryColor: theme.primaryColor,
      secondaryColor: theme.colorScheme.secondary,
      backgroundColor: theme.scaffoldBackgroundColor,
      surfaceColor: theme.cardColor,
      errorColor: theme.colorScheme.error,
      dividerColor: Colors.grey[300],

      // Spacing
      defaultPadding: const EdgeInsets.all(16),
      compactPadding: const EdgeInsets.all(8),
      expansivePadding: const EdgeInsets.all(24),
      defaultSpacing: 16,
      compactSpacing: 8,
      expansiveSpacing: 24,
      defaultBorderRadius: BorderRadius.circular(4),

      // Animation
      animationDuration: const Duration(milliseconds: 200),
      fastAnimationDuration: const Duration(milliseconds: 100),
      slowAnimationDuration: const Duration(milliseconds: 300),
      animationCurve: Curves.easeInOut,

      // Interaction
      debounceDelay: const Duration(milliseconds: 300),
      fastDebounceDelay: const Duration(milliseconds: 150),
      slowDebounceDelay: const Duration(milliseconds: 500),
    );
  }

  /// iOS-style Cupertino theme
  static EnhancedLocationTheme cupertino([BuildContext? context]) {
    return EnhancedLocationTheme(
      // Input styling
      inputTextStyle: const TextStyle(fontSize: 17),
      inputHintStyle: TextStyle(fontSize: 17, color: Colors.grey[600]),
      inputPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      inputBorderRadius: BorderRadius.circular(10),
      inputBorderWidth: 1,
      inputBorderColor: Colors.grey[300],
      inputFocusedBorderColor: Colors.blue,
      inputErrorBorderColor: Colors.red,
      inputFillColor: Colors.grey[50],
      inputFilled: true,

      // Dropdown styling
      dropdownBackgroundColor: Colors.white,
      dropdownHoverColor: Colors.grey[100],
      dropdownSelectedColor: Colors.blue.withValues(alpha: 0.1),
      dropdownBorderRadius: BorderRadius.circular(10),
      dropdownElevation: 4,
      dropdownPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      dropdownMaxHeight: 300,

      // Text styling
      primaryTextStyle: const TextStyle(fontSize: 17, color: Colors.black87),
      secondaryTextStyle: TextStyle(fontSize: 15, color: Colors.grey[600]),
      hintTextStyle: TextStyle(fontSize: 17, color: Colors.grey[600]),
      errorTextStyle: const TextStyle(fontSize: 13, color: Colors.red),
      labelTextStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),

      // Icon styling
      iconColor: Colors.grey[600],
      primaryIconColor: Colors.blue,
      iconSize: 20,
      smallIconSize: 16,
      largeIconSize: 24,

      // Colors
      primaryColor: Colors.blue,
      backgroundColor: Colors.grey[50],
      surfaceColor: Colors.white,
      errorColor: Colors.red,
      dividerColor: Colors.grey[200],

      // Spacing
      defaultPadding: const EdgeInsets.all(16),
      compactPadding: const EdgeInsets.all(8),
      expansivePadding: const EdgeInsets.all(20),
      defaultSpacing: 16,
      compactSpacing: 8,
      expansiveSpacing: 20,
      defaultBorderRadius: BorderRadius.circular(10),

      // Animation
      animationDuration: const Duration(milliseconds: 250),
      animationCurve: Curves.easeInOut,

      // Interaction
      debounceDelay: const Duration(milliseconds: 300),
    );
  }

  /// Minimal flat design theme
  static EnhancedLocationTheme minimal([BuildContext? context]) {
    return EnhancedLocationTheme(
      // Input styling
      inputTextStyle: const TextStyle(fontSize: 16, color: Colors.black87),
      inputHintStyle: TextStyle(fontSize: 16, color: Colors.grey[500]),
      inputPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      inputBorderRadius: BorderRadius.circular(0),
      inputBorderWidth: 0,
      inputFillColor: Colors.transparent,
      inputFilled: false,

      // Dropdown styling
      dropdownBackgroundColor: Colors.white,
      dropdownHoverColor: Colors.grey[100],
      dropdownSelectedColor: Colors.grey[200],
      dropdownBorderRadius: BorderRadius.circular(0),
      dropdownElevation: 1,
      dropdownPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      dropdownMaxHeight: 250,

      // Text styling
      primaryTextStyle: const TextStyle(fontSize: 16, color: Colors.black87),
      secondaryTextStyle: TextStyle(fontSize: 14, color: Colors.grey[600]),
      hintTextStyle: TextStyle(fontSize: 16, color: Colors.grey[500]),
      errorTextStyle: const TextStyle(fontSize: 12, color: Colors.red),
      labelTextStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),

      // Icon styling
      iconColor: Colors.grey[600],
      primaryIconColor: Colors.black87,
      iconSize: 18,
      smallIconSize: 14,
      largeIconSize: 22,

      // Colors
      primaryColor: Colors.black87,
      backgroundColor: Colors.white,
      surfaceColor: Colors.white,
      errorColor: Colors.red,
      dividerColor: Colors.grey[300],

      // Spacing
      defaultPadding: const EdgeInsets.all(12),
      compactPadding: const EdgeInsets.all(6),
      expansivePadding: const EdgeInsets.all(18),
      defaultSpacing: 12,
      compactSpacing: 6,
      expansiveSpacing: 18,
      defaultBorderRadius: BorderRadius.circular(0),

      // Animation
      animationDuration: const Duration(milliseconds: 150),
      animationCurve: Curves.easeOut,
      enableAnimations: false,

      // Interaction
      debounceDelay: const Duration(milliseconds: 200),
    );
  }

  /// Vibrant colorful theme
  static EnhancedLocationTheme vibrant([BuildContext? context]) {
    return EnhancedLocationTheme(
      // Input styling
      inputTextStyle: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
      inputHintStyle: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.7)),
      inputPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      inputBorderRadius: BorderRadius.circular(25),
      inputBorderWidth: 2,
      inputBorderColor: Colors.transparent,
      inputFocusedBorderColor: Colors.white,
      inputErrorBorderColor: Colors.orange,
      inputFillColor: Colors.deepPurple.withValues(alpha: 0.8),
      inputFilled: true,

      // Dropdown styling
      dropdownBackgroundColor: Colors.deepPurple[700],
      dropdownHoverColor: Colors.deepPurple[600],
      dropdownSelectedColor: Colors.deepPurple[500],
      dropdownBorderRadius: BorderRadius.circular(15),
      dropdownElevation: 12,
      dropdownPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      dropdownMaxHeight: 320,

      // Text styling
      primaryTextStyle: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
      secondaryTextStyle: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8)),
      hintTextStyle: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.7)),
      errorTextStyle: const TextStyle(fontSize: 12, color: Colors.orange),
      labelTextStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),

      // Icon styling
      iconColor: Colors.white.withValues(alpha: 0.8),
      primaryIconColor: Colors.white,
      iconSize: 22,
      smallIconSize: 18,
      largeIconSize: 26,

      // Colors
      primaryColor: Colors.deepPurple,
      secondaryColor: Colors.pink,
      backgroundColor: LinearGradient(
        colors: [Colors.deepPurple, Colors.pink],
      ) as Color,
      surfaceColor: Colors.deepPurple[700],
      errorColor: Colors.orange,
      successColor: Colors.green,
      dividerColor: Colors.white.withValues(alpha: 0.2),

      // Spacing
      defaultPadding: const EdgeInsets.all(20),
      compactPadding: const EdgeInsets.all(12),
      expansivePadding: const EdgeInsets.all(28),
      defaultSpacing: 20,
      compactSpacing: 12,
      expansiveSpacing: 28,
      defaultBorderRadius: BorderRadius.circular(25),

      // Animation
      animationDuration: const Duration(milliseconds: 300),
      fastAnimationDuration: const Duration(milliseconds: 150),
      slowAnimationDuration: const Duration(milliseconds: 450),
      animationCurve: Curves.elasticOut,

      // Interaction
      debounceDelay: const Duration(milliseconds: 250),
    );
  }

  /// Glass morphism theme
  static EnhancedLocationTheme glassmorphic([BuildContext? context]) {
    return EnhancedLocationTheme(
      // Input styling
      inputTextStyle: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w400),
      inputHintStyle: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.6)),
      inputPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      inputBorderRadius: BorderRadius.circular(20),
      inputBorderWidth: 1,
      inputBorderColor: Colors.white.withValues(alpha: 0.2),
      inputFocusedBorderColor: Colors.white.withValues(alpha: 0.4),
      inputErrorBorderColor: Colors.red.withValues(alpha: 0.6),
      inputFillColor: Colors.white.withValues(alpha: 0.1),
      inputFilled: true,

      // Dropdown styling
      dropdownBackgroundColor: Colors.white.withValues(alpha: 0.15),
      dropdownHoverColor: Colors.white.withValues(alpha: 0.1),
      dropdownSelectedColor: Colors.white.withValues(alpha: 0.2),
      dropdownBorderRadius: BorderRadius.circular(15),
      dropdownElevation: 0,
      dropdownPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      dropdownMaxHeight: 300,

      // Text styling
      primaryTextStyle: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w400),
      secondaryTextStyle: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7)),
      hintTextStyle: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.6)),
      errorTextStyle: TextStyle(fontSize: 12, color: Colors.red.withValues(alpha: 0.8)),
      labelTextStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),

      // Icon styling
      iconColor: Colors.white.withValues(alpha: 0.7),
      primaryIconColor: Colors.white,
      iconSize: 20,
      smallIconSize: 16,
      largeIconSize: 24,

      // Colors
      primaryColor: Colors.white,
      backgroundColor: Colors.transparent,
      surfaceColor: Colors.white.withValues(alpha: 0.1),
      errorColor: Colors.red.withValues(alpha: 0.8),
      dividerColor: Colors.white.withValues(alpha: 0.1),

      // Spacing
      defaultPadding: const EdgeInsets.all(20),
      compactPadding: const EdgeInsets.all(12),
      expansivePadding: const EdgeInsets.all(28),
      defaultSpacing: 20,
      compactSpacing: 12,
      expansiveSpacing: 28,
      defaultBorderRadius: BorderRadius.circular(20),

      // Animation
      animationDuration: const Duration(milliseconds: 250),
      animationCurve: Curves.easeInOutCubic,

      // Interaction
      debounceDelay: const Duration(milliseconds: 300),
    );
  }

  /// Create a copy with overrides
  EnhancedLocationTheme copyWith({
    TextStyle? inputTextStyle,
    TextStyle? inputHintStyle,
    InputDecoration? inputDecoration,
    EdgeInsetsGeometry? inputPadding,
    BorderRadius? inputBorderRadius,
    Color? primaryColor,
    Color? backgroundColor,
    Duration? animationDuration,
    // ... add all other parameters
  }) {
    return EnhancedLocationTheme(
      inputTextStyle: inputTextStyle ?? this.inputTextStyle,
      inputHintStyle: inputHintStyle ?? this.inputHintStyle,
      inputDecoration: inputDecoration ?? this.inputDecoration,
      inputPadding: inputPadding ?? this.inputPadding,
      inputBorderRadius: inputBorderRadius ?? this.inputBorderRadius,
      primaryColor: primaryColor ?? this.primaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      animationDuration: animationDuration ?? this.animationDuration,
      // ... copy all other parameters
    );
  }
}