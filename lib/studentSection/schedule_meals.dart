import 'package:flutter/material.dart';
import 'package:admin_mess_app/general_components/palette.dart';
import 'package:admin_mess_app/general_components/variable_sizes.dart';

class ScheduleMeals extends StatefulWidget {
  const ScheduleMeals({super.key});

  @override
  State<ScheduleMeals> createState() => _ScheduleMealsState();
}

class _ScheduleMealsState extends State<ScheduleMeals> {
  DateTime currentDate = DateTime.now();
  DateTime selectedDate = DateTime.now();
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController =
        PageController(initialPage: getMonthPageIndex(currentDate));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int getMonthPageIndex(DateTime date) {
    return date.year * 12 + date.month - 1;
  }

  DateTime getDateFromPageIndex(int index) {
    int year = index ~/ 12;
    int month = index % 12 + 1;
    return DateTime(year, month);
  }

  void _onPageChanged(int page) {
    setState(() {
      currentDate = getDateFromPageIndex(page);
    });
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  int calculateNumberOfRows(DateTime date) {
    DateTime firstDayOfMonth = DateTime(date.year, date.month, 1);
    DateTime lastDayOfMonth = DateTime(date.year, date.month + 1, 0);
    int totalDays = lastDayOfMonth.day;
    int startingWeekday = firstDayOfMonth.weekday % 7;
    int numDaysGridSlots = totalDays + startingWeekday;
    int numRows = (numDaysGridSlots / 7).ceil() + 1;
    return numRows;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cafeWidth * .8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: paletteLight,
      ),
      child: Padding(
        padding: EdgeInsets.all(8.0 * screenFactor),
      // <- Added scroll view here
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${getMonthName(currentDate.month)} ${currentDate.year}',
                style: TextStyle(
                  fontFamily: "Zilla Slab HighBold",
                  fontSize: 28 * screenFactor,
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 320 * screenFactor, // fixed height to prevent overflow
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, pageIndex) {
                    DateTime displayDate = getDateFromPageIndex(pageIndex);
                    return buildMonthCalendar(displayDate);
                  },
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget buildMonthCalendar(DateTime date) {
    DateTime firstDayOfMonth = DateTime(date.year, date.month, 1);
    DateTime lastDayOfMonth = DateTime(date.year, date.month + 1, 0);
    int totalDays = lastDayOfMonth.day;
    int startingWeekday = firstDayOfMonth.weekday % 7;

    List<Widget> dayWidgets = [];

    for (int i = 0; i < 7; i++) {
      dayWidgets.add(Center(
        child: Text(
          getWeekdayName(i),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ));
    }

    for (int i = 0; i < startingWeekday; i++) {
      dayWidgets.add(Container());
    }

    for (int day = 1; day <= totalDays; day++) {
      DateTime currentDay = DateTime(date.year, date.month, day);
      bool isToday = isSameDay(currentDay, DateTime.now());
      bool isSelected = isSameDay(currentDay, selectedDate);

      dayWidgets.add(GestureDetector(
        onTap: () => _onDateSelected(currentDay),
        child: Container(
          margin: EdgeInsets.all(4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.blueAccent
                : isToday
                    ? Colors.lightBlue
                    : Colors.white,
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.black54,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Text(
            '$day',
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
        ),
      ));
    }

    return GridView.count(
      crossAxisCount: 7,
      childAspectRatio: 1.2,
      padding: EdgeInsets.zero,
      children: dayWidgets,
    );
  }

  String getWeekdayName(int index) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[index];
  }

  String getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
