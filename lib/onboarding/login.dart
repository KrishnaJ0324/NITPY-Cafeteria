import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Local Imports
import 'package:admin_mess_app/general_components/palette.dart';
import 'package:admin_mess_app/general_components/variable_sizes.dart';
import 'package:admin_mess_app/onboarding/shared_component.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String? emailError;
  String? passwordError;

  RegExp emailExp = RegExp(r"^[\w\.-]+@[\w\.-]+\.\w+$");



Future<void> login() async {
  // Clear previous errors before trying again
  setState(() {
    emailError = null;
    passwordError = null;
  });

  try {
    final response = await http.post(
      Uri.parse('http://192.168.245.119:5000/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': emailController.text,
        'password': passwordController.text,
      }),
    ).timeout(const Duration(seconds: 10)); // Added a 10-second timeout

    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (!mounted) return;

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final role = data["role"];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isSignedIn', true);
      await prefs.setString('userEmail', emailController.text);
      await prefs.setString('userRole', role);

      // Navigate based on role
      if (role == "student") {
        Navigator.pushReplacementNamed(context, "/studentHomePage");
      } else if (role == "admin") {
        Navigator.pushReplacementNamed(context, "/adminHomePage");
      } else {
        setState(() {
          emailError = "Unknown user role from server.";
        });
      }
    } else {
      // Handle non-200 responses (like 401, 404)
      setState(() {
        emailError = 'Login failed. Status: ${response.statusCode}';
        passwordError = 'Incorrect email or password.';
      });
    }
  } catch (e) {
    print('AN ERROR OCCURRED: $e'); // This will print the detailed error in your console
    if (!mounted) return;
    setState(() {
      // Display the actual error in the UI to make it visible
      emailError = e.toString();
      passwordError = null;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/final_bg.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: tPaletteLight,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            "Login",
            style: TextStyle(
              fontFamily: "Zilla Slab SemiBold",
              fontSize: (30 * screenFactor),
              color: paletteLight,
            ),
          ),
          centerTitle: true,
          backgroundColor: paletteDark,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(
              vertical: 8.0 * screenFactor, horizontal: 30 * screenFactor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30 * screenFactor),
              buildInputField(
                emailController,
                paletteTomato,
                paletteDark,
                16,
                "E-Mail",
                emailError,
                false,
              ),
              buildInputField(
                passwordController,
                paletteTomato,
                paletteDark,
                16,
                "Password",
                passwordError,
                true,
              ),
              SizedBox(height: 30 * screenFactor),
              ElevatedButton(
                onPressed: () async {
                  if (emailExp.hasMatch(emailController.text) &&
                      passwordController.text.isNotEmpty) {
                    await login();
                  } else {
                    setState(() {
                      emailExp.hasMatch(emailController.text)
                          ? emailError = null
                          : emailError = "Invalid E-mail";
                      passwordController.text.isNotEmpty
                          ? passwordError = null
                          : passwordError = "Password cannot be empty";
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0 * screenFactor),
                    side: const BorderSide(color: Colors.black),
                  ),
                  backgroundColor: tPaletteTomato,
                  shadowColor: Colors.transparent,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 5, vertical: 10.0 * screenFactor),
                  child: Text(
                    "Login",
                    style: TextStyle(
                      fontFamily: "Zilla Slab",
                      fontWeight: FontWeight.w100,
                      fontSize: 18 * screenFactor,
                      letterSpacing: 2 * screenFactor,
                      color: paletteLight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
