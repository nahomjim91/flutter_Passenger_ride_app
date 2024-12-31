// import 'package:flutter/material.dart';
// import 'package:ride_app/DateOfBirth_field.dart';
// import 'package:ride_app/home_screen.dart';
// import 'package:ride_app/login_page.dart';
// import 'package:ride_app/passenger.dart';
// import 'package:ride_app/validator.dart';

// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class SignupPage extends StatefulWidget {
//   const SignupPage({super.key});

//   @override
//   State<SignupPage> createState() => _SignupPageState();
// }

// class _SignupPageState extends State<SignupPage> {
//   TextEditingController emailController = TextEditingController();
//   TextEditingController passwordController = TextEditingController();
//   TextEditingController passwordConfirmController = TextEditingController();
//   TextEditingController nameController = TextEditingController();
//   TextEditingController phoneController = TextEditingController();
//   TextEditingController dobController = TextEditingController();
//   List<String> genderOptions = ['Male', 'Female', 'Other'];
//   String _selectedGender = 'Male';
//   int _radioGroupValue_Gender = 0;

//   final formKey = GlobalKey<FormState>();
//   @override
//   Widget build(BuildContext context) {
//     Validator validator = Validator();
//     return Scaffold(
//       body: Center(
//         child: Form(
//           key: formKey,
//           autovalidateMode: AutovalidateMode.always,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text("Sign Up"),
//               TextFormField(
//                 controller: nameController,
//                 decoration: const InputDecoration(
//                   labelText: "Name",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) => validator.nameVaidater(value),
//               ),
//               const SizedBox(height: 20),
//               TextFormField(
//                 controller: phoneController,
//                 decoration: const InputDecoration(
//                   labelText: "Phone",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: validator.phoneVaidater,
//               ),
//               const SizedBox(height: 20),
//               TextFormField(
//                 controller: emailController,
//                 decoration: const InputDecoration(
//                   labelText: "Email",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: validator.emailVaidater,
//               ),
//               const SizedBox(height: 20),
//               DateOfBirthField(
//                 dobController: dobController,
//                 validator: validator.dobValidator,
//               ),
//               const SizedBox(height: 20),
//               TextFormField(
//                 controller: passwordController,
//                 decoration: const InputDecoration(
//                   labelText: "Password",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: validator.passwordVaidater,
//               ),
//               const SizedBox(height: 20),
//               TextFormField(
//                 controller: passwordConfirmController,
//                 decoration: const InputDecoration(
//                   labelText: "Confirm Password",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) => validator.passwordConfirmVaidater(
//                     value, passwordController),
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 children: [
//                   Radio(
//                       value: 0,
//                       groupValue: _radioGroupValue_Gender,
//                       onChanged: (value) => setState(() {
//                             _radioGroupValue_Gender = value!;
//                             _selectedGender = genderOptions[0];
//                           })),
//                   Text("Male"),
//                   Radio(
//                       value: 1,
//                       groupValue: _radioGroupValue_Gender,
//                       onChanged: (value) => setState(() {
//                             _radioGroupValue_Gender = value!;
//                             _selectedGender = genderOptions[1];
//                           })),
//                   Text("Female"),
//                 ],
//               ),
//               const Divider(
//                 height: 5,
//               ),
//               ElevatedButton(
//                 onPressed: () async {
//                   if (formKey.currentState!.validate()) {
//                     // final url = Uri.parse("http://127.0.0.1:8000/api/register");

//                     // final response = await http.post(
//                     //   url,
//                     //   headers: {"Content-Type": "application/json"},
//                     //   body: jsonEncode({
//                     //     "first_name": nameController.text,
//                     //     "last_name": nameController.text,
//                     //     "email": emailController.text,
//                     //     "phone": phoneController.text,
//                     //     "password": passwordController.text,
//                     //     "gender": _selectedGender.toLowerCase(),
//                     //   }),
//                     // );
//                     // print(jsonEncode({
//                     //   "first_name": nameController.text,
//                     //   "last_name": nameController.text,
//                     //   "email": emailController.text,
//                     //   "phone": phoneController.text,
//                     //   "password": passwordController.text,
//                     //   "gender": _selectedGender,
//                     // }));

//                     // if (response.statusCode == 201) {
//                     Passenger passenger = Passenger(
//                         id: '1',
//                         phone_number: phoneController.text,
//                         first_name: nameController.text,
//                         last_name: nameController.text,
//                         profile_photo: null,
//                         created_at: '2021-10-10',
//                         email: emailController.text,
//                         gender: _selectedGender);

//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                           content: Text('User registered successfully!')),
//                     );
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) =>  Home(passenger :passenger),
//                       ),
//                     );
//                     // } else {
//                     //   ScaffoldMessenger.of(context).showSnackBar(
//                     //     const SnackBar(content: Text('Registration failed!')),
//                     //   );
//                     // }
//                   }
//                 },
//                 child: const Text("Sign Up"),
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text("Already have an account?"),
//                   TextButton(
//                     child: const Text("Login"),
//                     onPressed: () {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const LoginPage(),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
