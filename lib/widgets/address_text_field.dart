import 'package:flutter/material.dart';

/// A reusable text field widget for address components.
/// Can be used individually for street, city, state, country, or postal code.
class AddressTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final ValueChanged<String>? onErrorCleared;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? maxLength;

  const AddressTextField({
    super.key,
    this.controller,
    this.initialValue,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.onChanged,
    this.errorText,
    this.onErrorCleared,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          enabled: enabled,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          onChanged: (value) {
            if (errorText != null) {
              onErrorCleared?.call(value);
            }
            onChanged?.call(value);
          },
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: enabled
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  )
                : null,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : Colors.grey.shade300,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: errorText != null
                    ? Colors.red
                    : Theme.of(context).primaryColor,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    errorText!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Convenience widget for Street Address field
class StreetAddressField extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final ValueChanged<String>? onErrorCleared;

  const StreetAddressField({
    super.key,
    this.controller,
    this.initialValue,
    this.enabled = true,
    this.onChanged,
    this.errorText,
    this.onErrorCleared,
  });

  @override
  Widget build(BuildContext context) {
    return AddressTextField(
      controller: controller,
      initialValue: initialValue,
      label: 'Street Address',
      hint: 'Enter street address',
      prefixIcon: Icons.location_on,
      enabled: enabled,
      onChanged: onChanged,
      errorText: errorText,
      onErrorCleared: onErrorCleared,
      maxLines: 2,
    );
  }
}

/// Convenience widget for City field
class CityField extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final ValueChanged<String>? onErrorCleared;

  const CityField({
    super.key,
    this.controller,
    this.initialValue,
    this.enabled = true,
    this.onChanged,
    this.errorText,
    this.onErrorCleared,
  });

  @override
  Widget build(BuildContext context) {
    return AddressTextField(
      controller: controller,
      initialValue: initialValue,
      label: 'City',
      hint: 'Enter city',
      prefixIcon: Icons.location_city,
      enabled: enabled,
      onChanged: onChanged,
      errorText: errorText,
      onErrorCleared: onErrorCleared,
    );
  }
}

/// Convenience widget for State field
class StateField extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final ValueChanged<String>? onErrorCleared;

  const StateField({
    super.key,
    this.controller,
    this.initialValue,
    this.enabled = true,
    this.onChanged,
    this.errorText,
    this.onErrorCleared,
  });

  @override
  Widget build(BuildContext context) {
    return AddressTextField(
      controller: controller,
      initialValue: initialValue,
      label: 'State',
      hint: 'Enter state',
      prefixIcon: Icons.map,
      enabled: enabled,
      onChanged: onChanged,
      errorText: errorText,
      onErrorCleared: onErrorCleared,
    );
  }
}

/// Convenience widget for Country field
class CountryField extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final ValueChanged<String>? onErrorCleared;

  const CountryField({
    super.key,
    this.controller,
    this.initialValue,
    this.enabled = true,
    this.onChanged,
    this.errorText,
    this.onErrorCleared,
  });

  @override
  Widget build(BuildContext context) {
    return AddressTextField(
      controller: controller,
      initialValue: initialValue,
      label: 'Country',
      hint: 'Enter country',
      prefixIcon: Icons.public,
      enabled: enabled,
      onChanged: onChanged,
      errorText: errorText,
      onErrorCleared: onErrorCleared,
    );
  }
}

/// Convenience widget for Postal Code field
class PostalCodeField extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final ValueChanged<String>? onErrorCleared;

  const PostalCodeField({
    super.key,
    this.controller,
    this.initialValue,
    this.enabled = true,
    this.onChanged,
    this.errorText,
    this.onErrorCleared,
  });

  @override
  Widget build(BuildContext context) {
    return AddressTextField(
      controller: controller,
      initialValue: initialValue,
      label: 'Postal Code',
      hint: 'Enter postal code',
      prefixIcon: Icons.markunread_mailbox,
      enabled: enabled,
      onChanged: onChanged,
      errorText: errorText,
      onErrorCleared: onErrorCleared,
      keyboardType: TextInputType.number,
      maxLength: 10,
    );
  }
}
