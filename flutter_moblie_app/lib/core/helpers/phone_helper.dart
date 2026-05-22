class PhoneHelper {
  /// Normalizes Egyptian phone numbers to the format 20XXXXXXXXXX (12 digits)
  /// This format is required by the backend API and OTP services (WhatsApp).
  ///
  /// Supports all Egyptian number formats:
  /// - 01001234567 (Egyptian format with leading 0, 11 digits total)
  /// - 1001234567 (Base Egyptian format, 10 digits)
  /// - 201001234567 (International format, 12 digits)
  /// - +201001234567 (International with +, 13 chars)
  /// - 00201001234567 (International with 00, 14 digits)
  ///
  /// Returns: 20XXXXXXXXXX (without + prefix)
  static String normalizeEgyptPhone(String input) {
    // Remove all non-digits first
    String digits = input.trim().replaceAll(RegExp(r'[^0-9]'), '');

    // Step 1: Remove known international prefixes to get base 10-digit number
    if (digits.startsWith('0020')) {
      digits = digits.substring(4);
    } else if (digits.startsWith('20') && digits.length == 12) {
      digits = digits.substring(2);
    } else if (digits.startsWith('0') && digits.length == 11) {
      digits = digits.substring(1);
    }

    // Step 2: Ensure we have exactly the last 10 digits (the core mobile number)
    if (digits.length > 10) {
      digits = digits.substring(digits.length - 10);
    } else if (digits.length < 10) {
      // Pad with zeros if too short, though this shouldn't happen with valid numbers
      digits = digits.padLeft(10, '0');
    }

    // Step 3: Add the '+20' prefix and return
    return '+20$digits';
  }
}
