import 'package:flutter/material.dart';
import 'package:admin_mess_app/general_components/palette.dart';
import 'package:admin_mess_app/general_components/variable_sizes.dart';
import 'package:admin_mess_app/services/backend_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class AnnouncementPage extends StatelessWidget {
  final TextEditingController announcementController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
              title: Text(
                "NITPY Cafeteria",
                style: TextStyle(
                  fontFamily: "ZillaSlabSemiBold",
                  fontSize: (28 * screenFactor),
                  color: paletteLight,
                ),
              ),
              centerTitle: true,
              // actions: [
              //   IconButton(
              //     icon: const Icon(Icons.logout),
              //     color: paletteLight,
              //     onPressed: () {
              //     //  _logout();
              //       Navigator.pushReplacementNamed(context, "/");
              //     },
              //   ),
              // ],
              backgroundColor: paletteDark,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
            ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/image.png'), // Add your background image here
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Announcement box
                Container(
                  width: 300,
                  height: 200,
                  decoration: BoxDecoration(
                    color: paletteRed,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: announcementController,
                      decoration: InputDecoration(
                        hintText: 'Type announcement...',
                        border: InputBorder.none,
                      ),
                      maxLines: 5,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Post button
                ElevatedButton(
 onPressed: () async {
  final announcement = announcementController.text;
  if (announcement.isNotEmpty) {
    try {
      final response = await http.post(
        Uri.parse("http://192.168.245.119:5000/announcements"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': announcement}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Announcement Posted: $announcement')),
        );
        announcementController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post announcement')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please type an announcement')),
    );
  }
},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[600], // Button color based on your screenshot
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'POST',
                    style: TextStyle(
                      fontFamily: "ZillaSlab",
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
