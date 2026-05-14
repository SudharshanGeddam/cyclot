// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:cyclot_v1/core/helpers/validation_helpers.dart';

void main() {
  group('ValidationHelpers', () {
    group('validateEmail', () {
      test('returns error when email is empty', () {
        expect(ValidationHelpers.validateEmail(''), isNotNull);
        expect(
          ValidationHelpers.validateEmail(''),
          equals('Email is required'),
        );
      });

      test('returns error when email is null', () {
        expect(ValidationHelpers.validateEmail(null), isNotNull);
      });

      test('returns error for invalid email format', () {
        final invalidEmails = [
          'notanemail',
          'missing@domain',
          '@nodomain.com',
          'spaces in@email.com',
          'double@@domain.com',
        ];

        for (final email in invalidEmails) {
          expect(
            ValidationHelpers.validateEmail(email),
            isNotNull,
            reason: '$email should be invalid',
          );
        }
      });

      test('accepts valid email formats', () {
        final validEmails = [
          'user@example.com',
          'john.doe@company.co.uk',
          'test123@domain-name.org',
          'a@b.co',
        ];

        for (final email in validEmails) {
          expect(
            ValidationHelpers.validateEmail(email),
            isNull,
            reason: '$email should be valid',
          );
        }
      });
    });

    group('validatePassword', () {
      test('returns error when password is empty', () {
        expect(ValidationHelpers.validatePassword(''), isNotNull);
        expect(
          ValidationHelpers.validatePassword(''),
          equals('Password is required'),
        );
      });

      test('returns error when password is null', () {
        expect(ValidationHelpers.validatePassword(null), isNotNull);
      });

      test('returns error when password is less than 6 characters', () {
        expect(ValidationHelpers.validatePassword('12345'), isNotNull);
        expect(
          ValidationHelpers.validatePassword('short'),
          contains('at least 6 characters'),
        );
      });

      test('accepts valid passwords', () {
        expect(ValidationHelpers.validatePassword('123456'), isNull);
        expect(ValidationHelpers.validatePassword('mypassword'), isNull);
        expect(ValidationHelpers.validatePassword('P@ssw0rd!'), isNull);
      });
    });

    group('validateName', () {
      test('returns error when name is empty', () {
        expect(ValidationHelpers.validateName(''), isNotNull);
      });

      test('returns error when name is null', () {
        expect(ValidationHelpers.validateName(null), isNotNull);
      });

      test('returns error when name is less than 2 characters', () {
        expect(ValidationHelpers.validateName('a'), isNotNull);
      });

      test('returns error when name exceeds 100 characters', () {
        final longName = 'a' * 101;
        expect(ValidationHelpers.validateName(longName), isNotNull);
      });

      test('accepts valid names', () {
        expect(ValidationHelpers.validateName('John'), isNull);
        expect(ValidationHelpers.validateName('Maria Garcia'), isNull);
        expect(ValidationHelpers.validateName('Dr. Smith-Jones'), isNull);
      });
    });

    group('validatePasswordConfirm', () {
      test('returns error when confirm password is empty', () {
        expect(
          ValidationHelpers.validatePasswordConfirm('password123', ''),
          isNotNull,
        );
      });

      test('returns error when confirm password is null', () {
        expect(
          ValidationHelpers.validatePasswordConfirm('password123', null),
          isNotNull,
        );
      });

      test('returns error when passwords do not match', () {
        expect(
          ValidationHelpers.validatePasswordConfirm('password123', 'different'),
          isNotNull,
        );
      });

      test('accepts matching passwords', () {
        expect(
          ValidationHelpers.validatePasswordConfirm(
            'password123',
            'password123',
          ),
          isNull,
        );
      });
    });

    group('isValidEmail', () {
      test('returns true for valid emails', () {
        expect(ValidationHelpers.isValidEmail('test@example.com'), isTrue);
      });

      test('returns false for invalid emails', () {
        expect(ValidationHelpers.isValidEmail('notanemail'), isFalse);
      });
    });

    group('isValidPassword', () {
      test('returns true for valid passwords', () {
        expect(ValidationHelpers.isValidPassword('password123'), isTrue);
      });

      test('returns false for invalid passwords', () {
        expect(ValidationHelpers.isValidPassword('short'), isFalse);
      });
    });

    group('isValidLoginForm', () {
      test('returns true when both email and password are valid', () {
        expect(
          ValidationHelpers.isValidLoginForm('user@example.com', 'password123'),
          isTrue,
        );
      });

      test('returns false when email is invalid', () {
        expect(
          ValidationHelpers.isValidLoginForm('notanemail', 'password123'),
          isFalse,
        );
      });

      test('returns false when password is invalid', () {
        expect(
          ValidationHelpers.isValidLoginForm('user@example.com', 'short'),
          isFalse,
        );
      });
    });

    group('isValidRegisterForm', () {
      test('returns true when all fields are valid', () {
        expect(
          ValidationHelpers.isValidRegisterForm(
            'user@example.com',
            'password123',
            'John Doe',
            'password123',
          ),
          isTrue,
        );
      });

      test('returns false when email is invalid', () {
        expect(
          ValidationHelpers.isValidRegisterForm(
            'notanemail',
            'password123',
            'John Doe',
            'password123',
          ),
          isFalse,
        );
      });

      test('returns false when password is invalid', () {
        expect(
          ValidationHelpers.isValidRegisterForm(
            'user@example.com',
            'short',
            'John Doe',
            'short',
          ),
          isFalse,
        );
      });

      test('returns false when name is invalid', () {
        expect(
          ValidationHelpers.isValidRegisterForm(
            'user@example.com',
            'password123',
            'J',
            'password123',
          ),
          isFalse,
        );
      });

      test('returns false when passwords do not match', () {
        expect(
          ValidationHelpers.isValidRegisterForm(
            'user@example.com',
            'password123',
            'John Doe',
            'different',
          ),
          isFalse,
        );
      });
    });
  });
}
