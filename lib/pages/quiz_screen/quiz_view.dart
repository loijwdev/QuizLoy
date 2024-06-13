library quick_quiz_view;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// A customizable and easy-to-use Flutter package for displaying quizzes with multiple-choice questions.
///
/// The `QuickQuizViewz` package is designed to simplify the implementation of quiz screens in Flutter
/// applications. It provides a simple widget for users to select options, navigate between questions,
/// and submit their answers.
///
/// ## Usage
///
/// ```dart
/// QuickQuizViewz(
///   title: 'What is the capital of Japan?',
///   option1: 'Tokyo',
///   option2: 'Beijing',
///   option3: 'Seoul',
///   option4: 'Bangkok',
///   onOptionSelected: (value) {
///     // Handle the selected option
///   },
///   onNextPressed: () {
///     // Handle the "Next" button pressed
///   },
///   onPreviousPressed: () {
///     // Handle the "Previous" button pressed
///   },
/// );
/// ```
///
/// ## Features
///
/// - Supports a customizable title and four multiple-choice options.
/// - Automatically manages the state of selected options.
/// - Provides callbacks for handling user interactions such as selecting options and navigating between questions.
/// - Styled with a light amber background for a pleasant user experience.
///
/// ## Example
///
/// ```dart
/// final quizWidget = QuickQuizViewz(
///   title: 'Example Quiz',
///   option1: 'Option A',
///   option2: 'Option B',
///   option3: 'Option C',
///   option4: 'Option D',
///   onOptionSelected: (value) {
///     print('Selected option: $value');
///   },
///   onNextPressed: () {
///     print('Next button pressed');
///   },
///   onPreviousPressed: () {
///     print('Previous button pressed');
///   },
/// );
/// ```
///

class QuickQuizViewz extends StatefulWidget {
  const QuickQuizViewz({
    super.key,
    required this.onOptionSelected,
    required this.onNextPressed,
    required this.onPreviousPressed,
    required this.title,
    required this.option1,
    required this.option2,
    required this.option3,
    required this.option4,
  });

  final Function(int) onOptionSelected;
  final VoidCallback onNextPressed;
  final VoidCallback? onPreviousPressed;

  final String title;

  final String option1;
  final String option2;
  final String option3;
  final String option4;

  @override
  State<QuickQuizViewz> createState() => _QuickQuizViewzState();
}

class _QuickQuizViewzState extends State<QuickQuizViewz> {
  int? selectedOption;

  @override
  void didUpdateWidget(covariant QuickQuizViewz oldWidget) {
    super.didUpdateWidget(oldWidget);
    selectedOption = 0;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Stack(children: [
        // SvgPicture.asset(
        //   "assets/logo/bg.svg",
        //   fit: BoxFit.fitWidth,
        //   width: double.infinity,
        // ),
        Container(
          height: 3 / 4 * height,
          // color: const Color.fromARGB(255, 101, 180, 245),
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                // style: Theme.of(context).textTheme.headlineMedium,
                // textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color.fromARGB(255, 41, 127, 194),
                    fontWeight: FontWeight.bold,
                    fontSize: 35),
              ),
              const SizedBox(height: 50),
              Container(
                margin: EdgeInsets.only(top: 18),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  color: Colors.grey[200]!,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                child: RadioListTile(
                  title: Text(widget.option1),
                  value: 1,
                  groupValue: selectedOption,
                  activeColor: Colors.black,
                  onChanged: (value) {
                    setState(() {
                      selectedOption = value;
                      widget.onOptionSelected(value!);
                    });
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 18),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  color: Colors.grey[200]!,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                child: RadioListTile(
                  title: Text(widget.option2),
                  value: 2,
                  groupValue: selectedOption,
                  activeColor: Colors.black,
                  onChanged: (value) {
                    setState(() {
                      selectedOption = value;
                      widget.onOptionSelected(value!);
                    });
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 18),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  color: Colors.grey[200]!,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                child: RadioListTile(
                  title: Text(widget.option3),
                  value: 3,
                  groupValue: selectedOption,
                  activeColor: Colors.black,
                  onChanged: (value) {
                    setState(() {
                      selectedOption = value;
                      widget.onOptionSelected(value!);
                    });
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 18),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  color: Colors.grey[200]!,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                child: RadioListTile(
                  title: Text(widget.option4),
                  value: 4,
                  groupValue: selectedOption,
                  activeColor: Colors.black,
                  onChanged: (value) {
                    setState(() {
                      selectedOption = value;
                      widget.onOptionSelected(value!);
                    });
                  },
                ),
              ),

              // Row(
              //   children: [
              //     TextButton(
              //       onPressed: widget.onPreviousPressed,
              //       child: const Text('Previous'),
              //     ),
              //     const Spacer(),
              //     TextButton(
              //       onPressed: widget.onNextPressed,
              //       child: const Text('Next'),
              //     )
              //   ],
              // )
            ],
          ),
        ),
      ]),
    );
  }
}
