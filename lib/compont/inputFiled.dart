import 'package:flutter/material.dart';
import 'package:ride_app/validator.dart';

Widget CustomInputFiled(
  TextEditingController controller,
  String labelText,
  ValueNotifier<bool> obscureTextNotifier,
  IconData icon,
  String validatorType, {
  TextEditingController? password,
  bool enabled = true,
}) {
  final validator = Validator().whichValidator(validatorType);

  return ValueListenableBuilder<bool>(
    valueListenable: obscureTextNotifier,
    builder: (context, obscureText, child) {
      return TextFormField(
        controller: controller,
        obscureText: obscureText,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon),
          suffixIcon:
              validatorType == 'password' || validatorType == 'passwordConfirm'
                  ? IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        obscureTextNotifier.value = !obscureText;
                      },
                    )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF0C3B2E).withOpacity(0.3)),
          ),
        ),
        // ignore: unnecessary_null_comparison
        validator: validator != null
            ? validatorType == "passwordConfirm"
                ? (value) => validator(value, password)
                : (value) => validator(value)
            : null,
      );
    },
  );
}
