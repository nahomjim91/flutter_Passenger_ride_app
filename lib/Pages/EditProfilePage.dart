import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ride_app/Auth/api_service.dart';
import 'package:ride_app/Auth/profileAuthHandler.dart';
import 'package:ride_app/Pages/profilePage.dart';
import 'package:ride_app/Pages/restPassword.dart';
import 'package:ride_app/compont/inputFiled.dart';
import 'package:ride_app/passenger.dart';

// ignore: must_be_immutable
class EditProfilePage extends StatefulWidget {
  // Function(Passenger passenger) setPassenger;
  EditProfilePage({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late Passenger passenger;
  final _formKey = GlobalKey<FormState>();
  bool obscurePassword = true;
  final _firstNamecontroller = TextEditingController();
  final _lastNamecontroller = TextEditingController();
  final _emailcontroller = TextEditingController();
  final _passwordcontroller = TextEditingController();
  final _phonecontroller = TextEditingController();
  final _obscureTextNotifier = ValueNotifier<bool>(true);
  bool isLoading = false;
  String? signInMethod = ProfileAuthHandler().getSignInMethod();

  @override
  void initState() {
    super.initState();
    passenger = context.read<PassengerProvider>().passenger!;

    _firstNamecontroller.text = passenger.first_name;
    _lastNamecontroller.text = passenger.last_name;
    _emailcontroller.text = passenger.email;
    _phonecontroller.text = passenger.phone_number;
  }

  @override
  void dispose() {
    _obscureTextNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                ProfilePic(
                  isShowPhotoUpload: true,
                  resized: true,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Divider(),
                      const SizedBox(height: 20),
                      // First Name & Last Name
                      Row(
                        children: [
                          Expanded(
                            child: CustomInputFiled(
                                _firstNamecontroller,
                                'First Name',
                                ValueNotifier(false),
                                Icons.person_outline,
                                'name'),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomInputFiled(
                                _lastNamecontroller,
                                'Last Name',
                                ValueNotifier(false),
                                Icons.person_outline,
                                'name'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Email
                      CustomInputFiled(
                          enabled: false,
                          _emailcontroller,
                          'Email',
                          ValueNotifier(false),
                          Icons.email,
                          'email'),
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
                      // Password
                      if (signInMethod == 'email')
                        CustomInputFiled(_passwordcontroller, 'Password',
                            ValueNotifier(true), Icons.lock, 'password'),
                      const SizedBox(height: 8),
                      // Forgot Password
                      if (signInMethod == 'email')
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // Navigate to forgot password page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RestPassword(
                                    emailController: _emailcontroller,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'Rest Password?',
                              style: TextStyle(
                                color: Color(0xFF0C3B2E),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 120,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color!
                                    .withOpacity(0.08),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 48),
                                shape: const StadiumBorder(),
                              ),
                              child: const Text("Cancel"),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          SizedBox(
                            width: 160,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 48),
                                shape: const StadiumBorder(),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  try {
                                    final updatedPassenger = Passenger(
                                      id: passenger.id,
                                      first_name: _firstNamecontroller.text,
                                      last_name: _lastNamecontroller.text,
                                      email: _emailcontroller.text,
                                      phone_number: _phonecontroller.text,
                                      profile_photo: passenger.profile_photo,
                                      created_at: passenger.created_at,
                                      payment_method: passenger.payment_method,
                                    );

                                    final profileAuthHandler =
                                        ProfileAuthHandler();
                                    bool isUpdated =
                                        await profileAuthHandler.updateProfile(
                                      updatedPassenger,
                                      _passwordcontroller.text.isEmpty
                                          ? null
                                          : _passwordcontroller.text,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Profile updated successfully')),
                                    );
                                    if (isUpdated) {
                                      ApiService().updatePassenger(
                                        updatedPassenger,
                                      );
                                      context
                                          .read<PassengerProvider>()
                                          .updatePassenger(updatedPassenger);
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  } finally {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                }
                              },
                              child: isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text("Save Update"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
