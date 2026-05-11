import 'package:strengthlabs/l10n/app_localizations.dart';

class FormValidators {
  const FormValidators(this._l10n);
  final AppLocalizations _l10n;

  static final _emailRe = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  String? email(String? value) {
    if (value == null || value.trim().isEmpty) return _l10n.validatorEmailRequired;
    if (!_emailRe.hasMatch(value.trim())) return _l10n.validatorEmailInvalid;
    return null;
  }

  String? password(String? value) {
    if (value == null || value.isEmpty) return _l10n.validatorPasswordRequired;
    if (value.length < 6) return _l10n.validatorPasswordTooShort;
    return null;
  }

  String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return _l10n.validatorConfirmRequired;
    if (value != original) return _l10n.validatorConfirmMismatch;
    return null;
  }

  String? required(String? value, String field) {
    if (value == null || value.trim().isEmpty) return _l10n.validatorFieldRequired(field);
    return null;
  }

  String? positiveNumber(String? value, String field) {
    if (value == null || value.trim().isEmpty) return null;
    final n = double.tryParse(value);
    if (n == null || n <= 0) return _l10n.validatorFieldInvalid(field);
    return null;
  }
}
