import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:japanese_learning_app/core/models/exercise.dart';

class MultipleChoiceExercise extends StatefulWidget {
  final Exercise exercise;
  final VoidCallback onCorrect;
  final VoidCallback onIncorrect;

  const MultipleChoiceExercise({
    super.key,
    required this.exercise,
    required this.onCorrect,
    required this.onIncorrect,
  });

  @override
  State<MultipleChoiceExercise> createState() => _MultipleChoiceExerciseState();
}

class _MultipleChoiceExerciseState extends State<MultipleChoiceExercise> {
  String? selectedOption;
  bool isChecked = false;
  late List<String> options;

  @override
  void initState() {
    super.initState();
    // Parsear string a map si el usuario lo guardó como JSON String en Firestore
    if (widget.exercise.options != null && widget.exercise.options!.isNotEmpty) {
      options = List<String>.from(widget.exercise.options!);
      options.shuffle();
    } else {
      final answerStr = widget.exercise.correctAnswer.toString();
      options = [answerStr, 'Dummy 1', 'Dummy 2', 'Dummy 3'];
      options.shuffle();
    }
  }

  void _checkAnswer() {
    if (selectedOption == null) return;
    setState(() {
      isChecked = true;
    });
    
    final correct = widget.exercise.correctAnswer is Map 
        ? widget.exercise.correctAnswer['correct'] 
        : widget.exercise.correctAnswer.toString();

    if (selectedOption == correct) {
      Future.delayed(const Duration(seconds: 1), widget.onCorrect);
    } else {
      Future.delayed(const Duration(seconds: 1), widget.onIncorrect);
    }
  }

  @override
  Widget build(BuildContext context) {
    final correct = widget.exercise.correctAnswer is Map 
        ? widget.exercise.correctAnswer['correct'] 
        : widget.exercise.correctAnswer.toString();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '¿Cuál es la lectura correcta?',
          style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Text(
          widget.exercise.question, 
          style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        ...options.map((option) {
          bool isCorrectOption = option == correct;
          Color buttonColor = Colors.white;
          Color textColor = Colors.black87;

          if (isChecked) {
            if (isCorrectOption) {
              buttonColor = const Color(0xFF58CC02);
              textColor = Colors.white;
            } else if (option == selectedOption) {
              buttonColor = Colors.red;
              textColor = Colors.white;
            }
          } else if (option == selectedOption) {
            buttonColor = Colors.blue.shade50;
            textColor = Colors.blue.shade700;
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              transform: Matrix4.identity()..scale(option == selectedOption ? 1.05 : 1.0),
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: textColor,
                  elevation: option == selectedOption && !isChecked ? 0 : 2,
                  side: BorderSide(
                    color: isChecked && isCorrectOption 
                        ? Colors.green.shade700 
                        : (option == selectedOption && !isChecked ? Colors.blue.shade300 : Colors.grey.shade300),
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: isChecked ? null : () {
                  setState(() {
                    selectedOption = option;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(option, style: const TextStyle(fontSize: 20)),
                    if (isChecked && option == selectedOption) ...[
                      const SizedBox(width: 8),
                      Icon(isCorrectOption ? Icons.check_circle : Icons.cancel, size: 24),
                    ] else if (isChecked && isCorrectOption) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.check_circle_outline, size: 24),
                    ]
                  ],
                ),
              ),
            ),
          );
        }),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isChecked || selectedOption == null ? null : _checkAnswer,
            child: const Text('COMPROBAR'),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
