import 'package:flutter/material.dart';

class LocationPickerTheme {
  final InputDecoration? inputDecoration;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? itemTextStyle;
  final Color? dropdownBackgroundColor;
  final Color? itemHighlightColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final BoxShadow? shadow;
  final double? elevation;
  final Color? iconColor;
  final double? iconSize;
  final double? maxHeight;
  final bool showSearchBox;
  final InputDecoration? searchBoxDecoration;
  final String? searchHint;
  final Duration? animationDuration;
  final bool showFlags;
  final bool showPhoneCodes;

  const LocationPickerTheme({
    this.inputDecoration,
    this.labelStyle,
    this.hintStyle,
    this.itemTextStyle,
    this.dropdownBackgroundColor,
    this.itemHighlightColor,
    this.padding,
    this.margin,
    this.borderRadius,
    this.shadow,
    this.elevation,
    this.iconColor,
    this.iconSize,
    this.maxHeight,
    this.showSearchBox = true,
    this.searchBoxDecoration,
    this.searchHint,
    this.animationDuration,
    this.showFlags = true,
    this.showPhoneCodes = false,
  });

  LocationPickerTheme copyWith({
    InputDecoration? inputDecoration,
    TextStyle? labelStyle,
    TextStyle? hintStyle,
    TextStyle? itemTextStyle,
    Color? dropdownBackgroundColor,
    Color? itemHighlightColor,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    BoxShadow? shadow,
    double? elevation,
    Color? iconColor,
    double? iconSize,
    double? maxHeight,
    bool? showSearchBox,
    InputDecoration? searchBoxDecoration,
    String? searchHint,
    Duration? animationDuration,
    bool? showFlags,
    bool? showPhoneCodes,
  }) {
    return LocationPickerTheme(
      inputDecoration: inputDecoration ?? this.inputDecoration,
      labelStyle: labelStyle ?? this.labelStyle,
      hintStyle: hintStyle ?? this.hintStyle,
      itemTextStyle: itemTextStyle ?? this.itemTextStyle,
      dropdownBackgroundColor: dropdownBackgroundColor ?? this.dropdownBackgroundColor,
      itemHighlightColor: itemHighlightColor ?? this.itemHighlightColor,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      borderRadius: borderRadius ?? this.borderRadius,
      shadow: shadow ?? this.shadow,
      elevation: elevation ?? this.elevation,
      iconColor: iconColor ?? this.iconColor,
      iconSize: iconSize ?? this.iconSize,
      maxHeight: maxHeight ?? this.maxHeight,
      showSearchBox: showSearchBox ?? this.showSearchBox,
      searchBoxDecoration: searchBoxDecoration ?? this.searchBoxDecoration,
      searchHint: searchHint ?? this.searchHint,
      animationDuration: animationDuration ?? this.animationDuration,
      showFlags: showFlags ?? this.showFlags,
      showPhoneCodes: showPhoneCodes ?? this.showPhoneCodes,
    );
  }

  static LocationPickerTheme defaultTheme() {
    return const LocationPickerTheme(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: EdgeInsets.symmetric(vertical: 4),
      borderRadius: BorderRadius.all(Radius.circular(8)),
      maxHeight: 200,
      showSearchBox: true,
      searchHint: 'Search...',
      animationDuration: Duration(milliseconds: 200),
      showFlags: true,
      showPhoneCodes: false,
    );
  }

  static LocationPickerTheme materialTheme() {
    return LocationPickerTheme(
      inputDecoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(vertical: 4),
      borderRadius: BorderRadius.circular(4),
      elevation: 2,
      maxHeight: 250,
      showSearchBox: true,
      searchBoxDecoration: const InputDecoration(
        hintText: 'Search...',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      animationDuration: const Duration(milliseconds: 150),
    );
  }

  static LocationPickerTheme cupertinoTheme() {
    return LocationPickerTheme(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      borderRadius: BorderRadius.circular(10),
      dropdownBackgroundColor: Colors.white,
      elevation: 4,
      maxHeight: 200,
      showSearchBox: true,
      searchHint: 'Search...',
      animationDuration: const Duration(milliseconds: 250),
    );
  }
}

class LocationPickerStyle {
  static BoxDecoration getContainerDecoration(LocationPickerTheme theme, BuildContext context) {
    return BoxDecoration(
      color: theme.dropdownBackgroundColor ?? Theme.of(context).cardColor,
      borderRadius: theme.borderRadius ?? BorderRadius.circular(8),
      boxShadow: theme.shadow != null
        ? [theme.shadow!]
        : theme.elevation != null
          ? [BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: theme.elevation!,
              offset: Offset(0, theme.elevation! / 2),
            )]
          : null,
    );
  }

  static InputDecoration getInputDecoration(LocationPickerTheme theme, String hint) {
    return theme.inputDecoration ??
        InputDecoration(
          hintText: hint,
          hintStyle: theme.hintStyle,
          border: const OutlineInputBorder(),
          contentPadding: theme.padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        );
  }

  static TextStyle getItemTextStyle(LocationPickerTheme theme, BuildContext context) {
    return theme.itemTextStyle ?? Theme.of(context).textTheme.bodyMedium!;
  }

  static TextStyle getLabelStyle(LocationPickerTheme theme, BuildContext context) {
    return theme.labelStyle ?? Theme.of(context).textTheme.labelMedium!;
  }
}