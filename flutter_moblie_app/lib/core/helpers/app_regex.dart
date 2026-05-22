class AppRegex {
  static bool isEmailValid(String email) {
    return RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
        .hasMatch(email);
  }

  static bool isPasswordValid(String password) {
    return RegExp(
            r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$")
        .hasMatch(password);
  }

  static bool isPhoneNumberValid(String phoneNumber) {
    // Extract only digits
    final digits = phoneNumber.trim().replaceAll(RegExp(r'[^\d]'), '');

    // Accept 10-12 digit numbers (all valid Egyptian phone formats)
    // - 10 digits: base Egyptian number (1001234567)
    // - 11 digits: Egyptian with leading 0 (01001234567)
    // - 12 digits: International format (201001234567)
    if (digits.length < 10 || digits.length > 12) {
      return false;
    }

    // Must start with 0, 1, or 2 (Egyptian prefix patterns)
    if (digits.startsWith('0') ||
        digits.startsWith('1') ||
        digits.startsWith('2')) {
      return true;
    }

    return false;
  }

  static bool hasLowerCase(String password) {
    return RegExp(r'^(?=.*[a-z])').hasMatch(password);
  }

  static bool hasUpperCase(String password) {
    return RegExp(r'^(?=.*[A-Z])').hasMatch(password);
  }

  static bool hasNumber(String password) {
    return RegExp(r'^(?=.*?[0-9])').hasMatch(password);
  }

  static bool hasSpecialCharacter(String password) {
    return RegExp(r'^(?=.*?[#?!@$%^&*-])').hasMatch(password);
  }

  static bool hasMinLength(String password) {
    return RegExp(r'^(?=.{8,})').hasMatch(password);
  }

  static bool isArabicName(String name) {
    return RegExp(r'^[\u0621-\u064A\s]+$').hasMatch(name);
  }
}
