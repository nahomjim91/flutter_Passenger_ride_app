// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:ride_app/home_screen.dart';
// import 'package:ride_app/passenger.dart';
// import 'dart:convert';

// import 'package:ride_app/signup_screen.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   TextEditingController emailController = TextEditingController();
//   TextEditingController passwordController = TextEditingController();
//   final formKey = GlobalKey<FormState>();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Form(
//           key: formKey,
//           autovalidateMode: AutovalidateMode.always,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text("Login"),
//               TextFormField(
//                 controller: emailController,
//                 decoration: const InputDecoration(
//                   labelText: "Email",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {},
//               ),
//               const SizedBox(height: 20),
//               TextFormField(
//                 controller: passwordController,
//                 decoration: const InputDecoration(
//                   labelText: "Password",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {},
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () async {
//                   if (formKey.currentState!.validate()) {
//                     //   var response = await http.post(
//                     //     Uri.parse("http://localhost:8000/api/login"),
//                     //     headers: {
//                     //       'Content-Type': 'application/json',
//                     //     },
//                     //     body: jsonEncode({
//                     //       "email": emailController.text,
//                     //       "password": passwordController.text,
//                     //     }),
//                     //   );
//                     //   if (response.statusCode == 200) {
//                     //     final responseData = jsonDecode(response.body);
//                     //     print(responseData['token']);
//                     //     ScaffoldMessenger.of(context).showSnackBar(
//                     //       SnackBar(
//                     //           content: Text(
//                     //               'Login successful! Welcome ${responseData['user']['name']}')),
//                     //     );

//                     //     Navigator.pushReplacement(
//                     //       context,
//                     //       MaterialPageRoute(
//                     //         builder: (context) => const Home(),
//                     //       ),
//                     //     );
//                     //     // Save user data if needed, e.g., token or ID
//                     //   } else {
//                     //     ScaffoldMessenger.of(context).showSnackBar(
//                     //       SnackBar(content: Text('Invalid email or password')),
//                     //     );
//                     //   }

//                      await FirebaseAuth.instance.signInWithEmailAndPassword(
//                       email: emailController.text,
//                       password: passwordController.text,
//                      );

//                     Passenger passenger = Passenger(
//                       id: '1',
//                       phone_number: '0912345678',
//                       first_name: 'John',
//                       last_name: 'Doe',
//                       profile_photo: null,
//                       created_at: '2021-10-10',
//                       email: 'john@example.com',
//                       gender: 'Male',
//                     );
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                           content: Text(
//                               'Login successful! Welcome ${passenger.first_name}')),
//                     );

//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => Home(passenger: passenger),
//                       ),
//                     );
//                   }
//                 },
//                 child: const Text("Login"),
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text("Already have an account?"),
//                   TextButton(
//                     child: const Text("Sign Up"),
//                     onPressed: () {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const SignupPage(),
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
