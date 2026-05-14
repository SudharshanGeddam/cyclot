// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:cyclot_v1/core/helpers/validation_helpers.dart';

void main() {
  group('LoginScreen - Validation Logic Tests', () {
    /// Note: Full widget tests require Firebase initialization
    /// These tests verify the validation logic used by LoginScreen

    test('validates email field correctly', () {
      expect(ValidationHelpers.validateEmail(''), isNotNull);
      expect(ValidationHelpers.validateEmail('notanemail'), isNotNull);
      expect(ValidationHelpers.validateEmail('user@example.com'), isNull);
    });

    test('validates password field correctly', () {
      expect(ValidationHelpers.validatePassword(''), isNotNull);
      expect(ValidationHelpers.validatePassword('123'), isNotNull);
      expect(ValidationHelpers.validatePassword('password123'), isNull);
    });

    test('disables login button when form is invalid', () {
      const invalidEmail = 'notanemail';
      const validPassword = 'password123';

      final isFormValid = ValidationHelpers.isValidLoginForm(
        invalidEmail,
        validPassword,
      );
      expect(isFormValid, isFalse);
    });

    test('enables login button when form is valid', () {
      const validEmail = 'user@example.com';
      const validPassword = 'password123';

      final isFormValid = ValidationHelpers.isValidLoginForm(
        validEmail,
        validPassword,
      );
      expect(isFormValid, isTrue);
    });

    test('handles various invalid email formats', () {
      final invalidEmails = [
        '',
        'notanemail',
        'missing@domain',
        'spaces in@email.com',
      ];

      for (final email in invalidEmails) {
        expect(
          ValidationHelpers.validateEmail(email),
          isNotNull,
          reason: '$email should be invalid',
        );
      }
    });

    test('handles various valid email formats', () {
      final validEmails = [
        'user@example.com',
        'john.doe@company.co.uk',
        'test123@domain-name.org',
      ];

      for (final email in validEmails) {
        expect(
          ValidationHelpers.validateEmail(email),
          isNull,
          reason: '$email should be valid',
        );
      }
    });

    test('password must be at least 6 characters', () {
      expect(ValidationHelpers.validatePassword('12345'), isNotNull);
      expect(ValidationHelpers.validatePassword('123456'), isNull);
    });

    test('all login validation rules together', () {
      // Invalid: empty email
      expect(ValidationHelpers.isValidLoginForm('', 'password123'), isFalse);

      // Invalid: bad email
      expect(
        ValidationHelpers.isValidLoginForm('notanemail', 'password123'),
        isFalse,
      );

      // Invalid: short password
      expect(
        ValidationHelpers.isValidLoginForm('user@example.com', 'short'),
        isFalse,
      );

      // Valid: both correct
      expect(
        ValidationHelpers.isValidLoginForm('user@example.com', 'password123'),
        isTrue,
      );
    });
  });
}
