import 'package:intl/intl.dart';

class Validator {
  Function whichValidator(String? value) {
    if (value == null) {
      return () {};
    } else if (value == 'email') {
      return emailVaidater;
    } else if (value == 'name') {
      return nameVaidater;
    } else if (value == 'password') {
      return passwordVaidater;
    } else if (value == 'passwordConfirm') {
      return passwordConfirmVaidater;
    } else if (value == 'dob') {
      return dobValidator;
    } else if (value == 'phone') {
      return phoneVaidater;
    }
    return () {};
  }

  String? nameVaidater(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    } else if (value.length < 3) {
      return 'Name must be at least 3 characters';
    } else if (value.length > 20) {
      return 'Name must be less than 20 characters';
    } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name must contain only letters and spaces';
    }
    return null;
  }

  String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    } else if (value.length < 10) {
      return 'Phone number must be at least 10 digits';
    } else if (value.length > 20) {
      return 'Phone number must be less than 20 digits';
    } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Phone number must contain only digits';
    }
    return null;
  }

  String? phoneVaidater(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    } else if (value.length < 10) {
      return 'Phone number must be at least 10 digits';
    } else if (value.length > 20) {
      return 'Phone number must be less than 20 digits';
    } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Phone number must contain only digits';
    }
    return null;
  }

  String? emailVaidater(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? passwordVaidater(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    } else if (value.length < 8) {
      return 'Password must be at least 8 characters';
    } else if (value.length > 20) {
      return 'Password must be less than 20 characters';
    }
    return null;
  }

  String? passwordConfirmVaidater(value, passwordValue) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    } else if (value.length < 8) {
      return 'Password must be at least 8 characters';
    } else if (value.length > 20) {
      return 'Password must be less than 20 characters';
    } else if (value != passwordValue.text) {
      print(
          'Please enter your password' + value + ' and ' + passwordValue.text);
      return 'Password does not match';
    }
    return null;
  }

  String? dobValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date of Birth is required';
    }

    try {
      final dob = DateFormat('MM/dd/yyyy').parseStrict(value);
      final today = DateTime.now();
      final age = today.year -
          dob.year -
          (today.month < dob.month ||
                  (today.month == dob.month && today.day < dob.day)
              ? 1
              : 0);

      if (age < 18) {
        return 'You must be at least 18 years old';
      }
    } catch (e) {
      return 'Enter a valid date in MM/DD/YYYY format';
    }

    return null; // Return null if validation passes
  }
}
