import 'package:flutter_test/flutter_test.dart';
import 'package:strengthlabs/l10n/app_localizations_en.dart';
import 'package:strengthlabs/shared/utils/validators.dart';

void main() {
  final v = FormValidators(AppLocalizationsEn());

  group('FormValidators.email', () {
    test('returns error when null', () {
      expect(v.email(null), 'Email is required');
    });

    test('returns error when empty or whitespace', () {
      expect(v.email(''), 'Email is required');
      expect(v.email('   '), 'Email is required');
    });

    test('returns error when malformed', () {
      expect(v.email('not-an-email'), 'Enter a valid email');
      expect(v.email('foo@'), 'Enter a valid email');
      expect(v.email('foo@bar'), 'Enter a valid email');
      expect(v.email('@bar.com'), 'Enter a valid email');
    });

    test('accepts valid email', () {
      expect(v.email('user@example.com'), null);
      expect(v.email('first.last+tag@sub.domain.org'), null);
    });

    test('trims whitespace before validating', () {
      expect(v.email('  user@example.com  '), null);
    });
  });

  group('FormValidators.password', () {
    test('returns error when null or empty', () {
      expect(v.password(null), 'Password is required');
      expect(v.password(''), 'Password is required');
    });

    test('returns error when shorter than 6 chars', () {
      expect(v.password('12345'), 'At least 6 characters required');
    });

    test('accepts 6 chars or more', () {
      expect(v.password('123456'), null);
      expect(v.password('ALongerPassword123'), null);
    });
  });

  group('FormValidators.confirmPassword', () {
    test('returns error when null or empty', () {
      expect(v.confirmPassword(null, 'pass'), 'Please confirm your password');
      expect(v.confirmPassword('', 'pass'), 'Please confirm your password');
    });

    test('returns error when different from original', () {
      expect(
        v.confirmPassword('different', 'original'),
        'Passwords do not match',
      );
    });

    test('returns null when matching', () {
      expect(v.confirmPassword('same', 'same'), null);
    });
  });

  group('FormValidators.required', () {
    test('returns error with field when null or empty', () {
      expect(v.required(null, 'Name'), 'Name is required');
      expect(v.required('', 'Name'), 'Name is required');
      expect(v.required('   ', 'Name'), 'Name is required');
    });

    test('returns null when value present', () {
      expect(v.required('John', 'Name'), null);
    });
  });

  group('FormValidators.positiveNumber', () {
    test('returns null for empty (optional field)', () {
      expect(v.positiveNumber(null, 'weight'), null);
      expect(v.positiveNumber('', 'weight'), null);
    });

    test('returns error for non-numeric', () {
      expect(v.positiveNumber('abc', 'weight'), 'Enter a valid weight');
    });

    test('returns error for zero or negative', () {
      expect(v.positiveNumber('0', 'weight'), 'Enter a valid weight');
      expect(v.positiveNumber('-5', 'weight'), 'Enter a valid weight');
    });

    test('accepts positive integers and decimals', () {
      expect(v.positiveNumber('5', 'weight'), null);
      expect(v.positiveNumber('80.5', 'weight'), null);
    });
  });
}
