import 'package:admin_mess_app/studentSection/previous_meal_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:admin_mess_app/general_components/general_widgets.dart';
import 'package:admin_mess_app/general_components/palette.dart';
import 'package:admin_mess_app/general_components/variable_sizes.dart';
import 'package:http/http.dart' as http;
import 'package:admin_mess_app/services/backend_service.dart';
import 'dart:convert';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:admin_mess_app/studentSection/schedule_meals.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  List<String> announcements = [];
  double currentPage = 0;
  final PageController _pageController = PageController(viewportFraction: 1);
  String mealItems = '';

  String? mealOfDay;
  bool ratedR = false;
  String dateR = '';
  String dayR = '';
  String mealR = '';
  int mealIdR = 0;
  double valueR = 0;

  bool displayMenu = false;
  final PageController _menuPageController =
      PageController(viewportFraction: 0.9);
  int currentMenu = 0;

  bool displaySchedule = false;

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isSignedIn', false);
    prefs.remove('userEmail');
  }

  @override
  void initState() {
    super.initState();
    fetchAnnouncements();
    fetchMeal();
    fetchLastRating();
    determineMealAndFetchRating();
    autoScroll();
  }

  void determineMealAndFetchRating() {
    DateTime now = DateTime.now();
    DateTime breakfastEnd = DateTime(now.year, now.month, now.day, 9, 30);
    DateTime lunchEnd = DateTime(now.year, now.month, now.day, 14, 30);
    DateTime snacksEnd = DateTime(now.year, now.month, now.day, 18, 30);
    DateTime dinnerEnd = DateTime(now.year, now.month, now.day, 21, 30);

    if (now.isBefore(breakfastEnd)) {
      mealOfDay = 'Breakfast';
    } else if (now.isBefore(lunchEnd)) {
      mealOfDay = 'Lunch';
    } else if (now.isBefore(snacksEnd)) {
      mealOfDay = 'Snacks';
    } else if (now.isBefore(dinnerEnd)) {
      mealOfDay = 'Dinner';
    } else {
      mealOfDay = 'Dinner';
    }
    fetchLastRating();
  }

  Future<void> fetchAnnouncements() async {
    try {
      final response = await BackendService().getAnnouncements();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          announcements = data.map((item) => item['announ'] as String).toList();
        });
      } else {
        print("Failed to load announcements. Status: \${response.statusCode}");
      }
    } catch (e) {
      print("Error: \$e");
    }
  }

Future<void> fetchMeal() async {
  try {
    final response = await BackendService().getMeals();
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;

      // Determine current meal based on time
      DateTime now = DateTime.now();
      String currentMeal = "";

      if (now.hour < 9 || (now.hour == 9 && now.minute <= 30)) {
        currentMeal = "Breakfast";
      } else if (now.hour < 14 || (now.hour == 14 && now.minute <= 30)) {
        currentMeal = "Lunch";
      } else if (now.hour < 18 || (now.hour == 18 && now.minute <= 30)) {
        currentMeal = "Snacks";
      } else {
        currentMeal = "Dinner";
      }

      // Find the current meal in the response
      final current = data.firstWhere(
        (meal) => meal["name"].toString().toLowerCase() == currentMeal.toLowerCase(),
        orElse: () => null,
      );

      if (current != null) {
        setState(() {
          mealOfDay = current["name"];
          mealItems = current["items"].join(", ");
        });
      }
    } else {
      print("Failed to load meals");
    }
  } catch (e) {
    print("Error: $e");
  }
}


  Future<void> fetchLastRating() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    final response = await http.post(
      Uri.parse('http://192.168.245.119:5000/last_meal_rating/get_rating'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String?>{
        'email': prefs.getString("userEmail"),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["status"]) {
        setState(() {
          ratedR = true;
          mealIdR = data["mealId"];
          dateR = data["date"];
          dayR = data["day"];
          mealR = data["meal"];
        });
      } else {
        setState(() {
          ratedR = false;
        });
      }
    } else {
      print("Failed to fetch rating info: ${response.statusCode}");
    }
  } catch (e) {
    print("Error in fetchLastRating: $e");
  }
}

  Future<void> setLastRating() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.post(
        Uri.parse('http://192.168.245.119:5000/last_meal_rating/set_rating'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
          <String, dynamic>{
            'email': prefs.getString("userEmail"),
            'meal_id': mealIdR,
            'rating': valueR,
          },
        ),
      );
      if (response.statusCode == 200) {
        setState(() {
          ratedR = false;
        });
      } else {
        print("Failed to submit rating. Status: \${response.statusCode}");
      }
    } catch (e) {
      print("Error: \$e");
    }
  }

  void autoScroll() {
    Future.delayed(const Duration(seconds: 10), () {
      if (announcements.isNotEmpty) {
        int nextPage =
            (_pageController.page!.toInt() + 1) % announcements.length;
        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() {
          currentPage = nextPage.toDouble();
        });
        autoScroll();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: tPaletteLight,
            resizeToAvoidBottomInset: false,
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                setState(() {
                  displayMenu = !displayMenu;
                });
              },
              shape: const CircleBorder(
                side: BorderSide(
                  color: paletteDark,
                ),
              ),
              child: Image.asset(
                "assets/large_logo.png",
              ),
            ),
            appBar: AppBar(
              title: Text(
                "NITPY Cafeteria",
                style: TextStyle(
                  fontFamily: "Zilla Slab SemiBold",
                  fontSize: (28 * screenFactor),
                  color: paletteLight,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  color: paletteLight,
                  onPressed: () {
                    _logout();
                    Navigator.pushReplacementNamed(context, "/");
                  },
                ),
              ],
              backgroundColor: paletteDark,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: 20 * screenFactor, horizontal: 20 * screenFactor),
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: tPaletteLight,
                          border: Border.all(color: paletteDark),
                          borderRadius: BorderRadius.all(
                            Radius.circular(10 * screenFactor),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 8.0 * screenFactor),
                          child: Column(
                            children: [
                              Text(
                                "Announcements",
                                style: TextStyle(
                                  fontFamily: "Zilla Slab HighBold",
                                  fontSize: 30 * screenFactor,
                                ),
                              ),
                              SizedBox(
                                height: 100 * screenFactor,
                                width: double.infinity,
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: announcements.length,
                                  onPageChanged: (int page) {
                                    setState(() {
                                      currentPage = page.toDouble();
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 25.0 * screenFactor,
                                          vertical: 5.0 * screenFactor),
                                      child: SingleChildScrollView(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "➤ ",
                                              style: TextStyle(
                                                fontFamily: "Zilla Slab",
                                                fontSize: 16 * screenFactor,
                                                color: paletteDark,
                                              ),
                                            ),
                                            Flexible(
                                              child: Text(
                                                "${announcements[index]}",
                                                softWrap: true,
                                                style: TextStyle(
                                                  fontFamily: "Zilla Slab",
                                                  fontSize: 16 * screenFactor,
                                                  color: paletteDark,
                                                ),
                                                textAlign: TextAlign.justify,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              DotsIndicator(
                                dotsCount: announcements.isEmpty
                                    ? 1
                                    : announcements.length,
                                position: currentPage.toInt(),
                                decorator: DotsDecorator(
                                  color: paletteDark,
                                  activeColor: paletteRed,
                                  size: Size.square(6.0),
                                  activeSize: Size(16.0, 6.0),
                                  activeShape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10 * screenFactor,
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: tPaletteGold,
                          border: Border.all(color: paletteDark),
                          borderRadius: BorderRadius.all(
                            Radius.circular(10 * screenFactor),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 8.0 * screenFactor),
                          child: Column(
                            children: [
                              Text(
                                "$mealOfDay|Menu",
                                style: TextStyle(
                                  fontFamily: "Zilla Slab HighBold",
                                  fontSize: 22 * screenFactor,
                                ),
                              ),
                              SizedBox(
                                height: 120 * screenFactor,
                                width: double.infinity,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 25.0 * screenFactor,
                                      vertical: 5.0 * screenFactor),
                                  child: SingleChildScrollView(
                                    child: Text(
                                      mealItems,
                                      softWrap: true,
                                      style: TextStyle(
                                        fontFamily: "Zilla Slab",
                                        fontSize: 16 * screenFactor,
                                        color: paletteDark,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ratedR
                          ? Column(
                              children: [
                                SizedBox(
                                  height: 10 * screenFactor,
                                ),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: tPaletteTomato,
                                    border: Border.all(color: paletteDark),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10 * screenFactor),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8.0 * screenFactor),
                                    child: Column(
                                      children: [
                                        Text(
                                          "Rate|Your|Meal",
                                          style: TextStyle(
                                            fontFamily: "Zilla Slab HighBold",
                                            fontSize: 22 * screenFactor,
                                          ),
                                        ),
                                        SizedBox(
                                          width: double.infinity,
                                          child: Padding(
                                            padding: EdgeInsets.fromLTRB(
                                              25.0 * screenFactor,
                                              0,
                                              25.0 * screenFactor,
                                              5 * screenFactor,
                                            ),
                                            child: SingleChildScrollView(
                                              child: Column(
                                                children: [
                                                  Text(
                                                    "$dayR - $mealR",
                                                    softWrap: true,
                                                    style: TextStyle(
                                                      fontFamily: "Zilla Slab",
                                                      fontSize:
                                                          30 * screenFactor,
                                                      color: paletteDark,
                                                    ),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                  Text(
                                                    dateR,
                                                    softWrap: true,
                                                    style: TextStyle(
                                                      fontFamily: "Zilla Slab",
                                                      fontSize:
                                                          16 * screenFactor,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: paletteDark,
                                                    ),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                  SizedBox(
                                                    height: 2.5 * screenFactor,
                                                  ),
                                                  StarRating(
                                                    rating: valueR,
                                                    onRatingChanged: (rating) {
                                                      setState(() {
                                                        valueR = rating;
Future.microtask(() => setLastRating());

                                                      });
                                                    },
                                                    color: paletteGold,
                                                    size: 30,
                                                    spacing: 4.0,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                      SizedBox(
                        height: 10 * screenFactor,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          generalOutlineButton(
                            () {                                        Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PreviousMealsPage()), // Navigate to the new page
                    );},
                            tPaletteGreen,
                            paletteDark,
                            0,
                            16 * screenFactor,
                            "Previous Meals",
                          ),
                          generalOutlineButton(
                            () {
                              setState(() {
                                displaySchedule = !displaySchedule;
                              });
                            },
                            tPaletteGreen,
                            paletteDark,
                            0,
                            16 * screenFactor,
                            "Schedule Meals",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          displayMenu
              ? Scaffold(
                  backgroundColor: tPaletteDark,
                  resizeToAvoidBottomInset: false,
                  floatingActionButton: FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        displayMenu = !displayMenu;
                        currentMenu = 0;
                      });
                    },
                    shape: const CircleBorder(
                      side: BorderSide(
                        color: paletteDark,
                      ),
                    ),
                    child: Image.asset(
                      "assets/large_logo.png",
                    ),
                  ),
                  body: Center(
                    child: Container(
                      width: cafeWidth * .7,
                      height: cafeHeight * .75,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: paletteLight,
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            width: cafeWidth * .7,
                            height: cafeHeight * .7,
                            child: PageView.builder(
                              controller: _menuPageController,
                              itemCount: 7,
                              onPageChanged: (int page) {
                                setState(() {
                                  currentMenu = page;
                                });
                              },
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 25.0 * screenFactor,
                                      vertical: 5.0 * screenFactor),
                                  child: Image.asset(
                                    "assets/home_screen_student/menu${index + 1}.jpg",
                                  ),
                                );
                              },
                            ),
                          ),
                          DotsIndicator(
                            dotsCount: 7,
                            position: currentMenu,
                            decorator: DotsDecorator(
                              color: tPaletteDark,
                              activeColor: tPaletteRed,
                              size: Size.square(6.0),
                              activeSize: Size(16.0, 6.0),
                              activeShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox(
                  height: 0,
                  width: 0,
                ),
          displaySchedule
              ? Scaffold(
                  backgroundColor: tPaletteDark,
                  body: Stack(
                    children: [
                      // This GestureDetector captures taps outside ScheduleMeals
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            displaySchedule = false; // Close the schedule
                          });
                        },
                        child: Container(
                          color: Colors.transparent, // Transparent background
                        ),
                      ),
                      // Main content
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            // Prevent closing when tapping on ScheduleMeals
                          },
                          child: ScheduleMeals(),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(
                  height: 0,
                  width: 0,
                ),
        ],
      ),
    );
  }
}

class StarRating extends StatelessWidget {
  final int starCount;
  final double rating;
  final ValueChanged<double> onRatingChanged;
  final Color color;
  final double size;
  final double spacing;

  const StarRating({
    super.key,
    this.starCount = 5,
    this.rating = 0.0,
    required this.onRatingChanged,
    this.color = paletteGold,
    this.size = 40.0,
    this.spacing = 4.0,
  });

  Widget buildStar(BuildContext context, int index) {
    Icon icon;
    if (index >= rating) {
      icon = Icon(Icons.star_border, color: color, size: size);
    } else if (index > rating - 1 && index < rating) {
      icon = Icon(Icons.star_half, color: color, size: size);
    } else {
      icon = Icon(Icons.star, color: color, size: size);
    }
    return GestureDetector(
      onTap: () => onRatingChanged(index + 1.0),
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        starCount,
        (index) => Padding(
          padding: EdgeInsets.only(right: index < starCount - 1 ? spacing : 0),
          child: buildStar(context, index),
        ),
      ),
    );
  }
}





