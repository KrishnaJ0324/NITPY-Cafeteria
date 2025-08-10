import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:admin_mess_app/general_components/general_widgets.dart';
import 'package:admin_mess_app/general_components/palette.dart';
import 'package:admin_mess_app/general_components/variable_sizes.dart';

class StartUpScreen extends StatefulWidget {
  const StartUpScreen({super.key});

  @override
  State<StartUpScreen> createState() => _StartUpScreenState();
}

class _StartUpScreenState extends State<StartUpScreen> {
  bool isSignedIn = false;
  String userRole = '';

  Future<void> _checkIfSignedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isSignedIn = prefs.getBool('isSignedIn') ?? false;
    userRole = prefs.getString('userRole') ?? '';
  }

  @override
  void initState() {
    super.initState();
    _checkIfSignedIn();
  }

  void _navigateBasedOnRole() async {
    cafeWidth = MediaQuery.sizeOf(context).width;
    cafeHeight = MediaQuery.sizeOf(context).height;
    initVars();

    await _checkIfSignedIn(); // make sure prefs are loaded before navigating

    if (!isSignedIn) {
      Navigator.pushReplacementNamed(context, "/login");
    } else if (userRole == 'admin') {
      Navigator.pushReplacementNamed(context, "/adminHomePage");
    } else if (userRole == 'student') {
      Navigator.pushReplacementNamed(context, "/studentHomePage");
    } else {
      Navigator.pushReplacementNamed(context, "/login"); // fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/splash_screen/final_bg.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: tPaletteLight,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 80),
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Image.asset("assets/logo.png"),
                      ),
                      const Text(
                        "National Institute of Technology Puducherry",
                        style: TextStyle(
                          fontFamily: 'Roboto Serif',
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 280,
                    child: Image.asset("assets/app_logo.png"),
                  ),
                  generalOutlineButton(
                    () {
                      _navigateBasedOnRole(); // <- call navigation logic
                    },
                    tPaletteTomato,
                    paletteLight,
                    2,
                    20,
                    "Get Cooking",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
