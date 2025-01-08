import 'package:flutter/material.dart';
import 'package:ride_app/compont/inputFiled.dart';
import 'package:ride_app/compont/firebaseUtillies.dart';
import 'package:ride_app/navigatorPage.dart';
import 'package:ride_app/passenger.dart';

class DataCustomize extends StatefulWidget {
  final Passenger passenger;

  const DataCustomize({Key? key, required this.passenger}) : super(key: key);

  @override
  State<DataCustomize> createState() => _DataCustomizeState();
}

class _DataCustomizeState extends State<DataCustomize> {
  final _formKey = GlobalKey<FormState>();
  final _firstNamecontroller = TextEditingController();
  final _lastNamecontroller = TextEditingController();
  final _phonecontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _firstNamecontroller.text =
        widget.passenger.first_name?.split(' ').first ?? 'Unknown';
    _lastNamecontroller.text =
        widget.passenger.first_name?.split(' ').skip(1).join(' ') ??
            'Unknown'; // Extract last name
    _phonecontroller.text = widget.passenger.phone_number;
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      // Update the Passenger object
      final updatedPassenger = widget.passenger.copyWith(
        first_name: _firstNamecontroller.text,
        last_name: _lastNamecontroller.text,
        phone_number: _phonecontroller.text,
      );
      // Save to Firestore
      await Firebaseutillies().savePassengerToFirestore(updatedPassenger);
      // Navigate to Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Home(passenger: updatedPassenger),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Your Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomInputFiled(_firstNamecontroller, 'First Name',
                        ValueNotifier(false), Icons.person_outline, 'name'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomInputFiled(_lastNamecontroller, 'Last Name',
                        ValueNotifier(false), Icons.person_outline, 'name'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Phone
              CustomInputFiled(
                _phonecontroller,
                'Phone',
                ValueNotifier(false),
                Icons.phone,
                'phone',
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
