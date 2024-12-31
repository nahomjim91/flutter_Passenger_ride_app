import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateOfBirthField extends StatefulWidget {
  final TextEditingController dobController;
  final String? Function(String?) validator;

  const DateOfBirthField({
    required this.dobController,
    required this.validator,
    Key? key,
  }) : super(key: key);

  @override
  _DateOfBirthFieldState createState() => _DateOfBirthFieldState();
}

class _DateOfBirthFieldState extends State<DateOfBirthField> {
  void _selectDate() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        widget.dobController.text = DateFormat('MM/dd/yyyy').format(selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.dobController,
      readOnly: true,
      onTap: _selectDate,
      decoration: InputDecoration(
        labelText: "Date of Birth",
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today),
        hintText: "MM/DD/YYYY",
        helperText: "Tap the calendar icon to select your date of birth.",
      ),
      validator: widget.validator,
    );
  }
}
