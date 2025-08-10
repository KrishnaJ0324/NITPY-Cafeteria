import 'package:flutter/material.dart';
import 'package:admin_mess_app/general_components/palette.dart';
import 'package:admin_mess_app/general_components/variable_sizes.dart';

class REviewPage extends StatefulWidget {
  final String mealType;

  REviewPage({required this.mealType});

  @override
  _REviewPageState createState() => _REviewPageState();
}

class _REviewPageState extends State<REviewPage> {
  // Track selected options
  String _mealServiceRating = 'Good';
  String _foodQualityRating = 'Good';
  int _starRating = 0;

  // Controller for comments
  final TextEditingController _commentsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
            color: Colors.red[800],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Meal type title
              Text(
                widget.mealType,
                style: TextStyle(
                  fontFamily: 'ZillaSlab',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),

              // Meal Service Rating
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Meal Service",
                  style: TextStyle(
                    fontFamily: 'ZillaSlab',
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 10),
              RatingOptions(
                options: ['Poor', 'Good', 'Excellent'],
                selectedOption: _mealServiceRating,
                onSelected: (rating) {
                  setState(() {
                    _mealServiceRating = rating;
                  });
                },
              ),
              SizedBox(height: 20),

              // Food Quality Rating
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Food Quality",
                  style: TextStyle(
                    fontFamily: 'ZillaSlab',
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 10),
              RatingOptions(
                options: ['Poor', 'Good', 'Excellent'],
                selectedOption: _foodQualityRating,
                onSelected: (rating) {
                  setState(() {
                    _foodQualityRating = rating;
                  });
                },
              ),
              SizedBox(height: 20),

              // Comments text field
              TextField(
                controller: _commentsController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Type your comments',
                  hintStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Star rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _starRating ? Icons.star : Icons.star_border,
                      color: Colors.yellow,
                    ),
                    onPressed: () {
                      setState(() {
                        _starRating = index + 1;
                      });
                    },
                  );
                }),
              ),
              SizedBox(height: 20),

              // Submit button
              ElevatedButton(
                onPressed: () {
                  // Submit review logic can be added here
                  Navigator.pop(context); // Close the review page after submission
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: paletteGold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text(
                    "Submit",
                    style: TextStyle(
                      fontFamily: 'ZillaSlab',
                      fontSize: 18,
                      color: Colors.black,
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

class RatingOptions extends StatelessWidget {
  final List<String> options;
  final String selectedOption;
  final Function(String) onSelected;

  RatingOptions({
    required this.options,
    required this.selectedOption,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: options.map((option) {
        bool isSelected = option == selectedOption;
        return GestureDetector(
          onTap: () => onSelected(option),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.lime[700] : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              option,
              style: TextStyle(
                fontFamily: 'ZillaSlab',
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
