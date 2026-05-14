/// Validation helpers for user input
class ValidationHelpers {
  /// Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  /// Validate name
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (value.length > 100) {
      return 'Name must be less than 100 characters';
    }

    return null;
  }

  /// Validate password confirmation
  static String? validatePasswordConfirm(String? password, String? confirm) {
    if (confirm == null || confirm.isEmpty) {
      return 'Confirm password is required';
    }

    if (password != confirm) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Check if email format is valid (without error message)
  static bool isValidEmail(String email) {
    return validateEmail(email) == null;
  }

  /// Check if password is valid (without error message)
  static bool isValidPassword(String password) {
    return validatePassword(password) == null;
  }

  /// Check if all login fields are valid
  static bool isValidLoginForm(String email, String password) {
    return isValidEmail(email) && isValidPassword(password);
  }

  /// Check if all registration fields are valid
  static bool isValidRegisterForm(
    String email,
    String password,
    String name,
    String confirmPassword,
  ) {
    return isValidEmail(email) &&
        isValidPassword(password) &&
        validateName(name) == null &&
        validatePasswordConfirm(password, confirmPassword) == null;
  }
}
