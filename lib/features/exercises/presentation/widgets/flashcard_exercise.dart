import 'package:flutter/material.dart';
import 'package:japanese_learning_app/core/models/exercise.dart';
import 'dart:math';

class FlashcardExercise extends StatefulWidget {
  final Exercise exercise;
  final VoidCallback onKnewIt;
  final VoidCallback onDidNotKnowIt;

  const FlashcardExercise({
    super.key,
    required this.exercise,
    required this.onKnewIt,
    required this.onDidNotKnowIt,
  });

  @override
  State<FlashcardExercise> createState() => _FlashcardExerciseState();
}

class _FlashcardExerciseState extends State<FlashcardExercise> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isFlipped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (isFlipped) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      isFlipped = !isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    final answer = widget.exercise.correctAnswer.toString();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Toca la tarjeta para voltearla',
          style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 48),
        GestureDetector(
          onTap: _flipCard,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final angle = _animation.value * pi;
              final isFront = angle < pi / 2;
              
              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),
                alignment: Alignment.center,
                child: Container(
                  width: double.infinity,
                  height: 350,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 8))],
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Transform(
                    transform: Matrix4.identity()..rotateY(isFront ? 0 : pi),
                    alignment: Alignment.center,
                    child: Text(
                      isFront ? widget.exercise.question : answer,
                      style: TextStyle(
                        fontSize: isFront ? 100 : 50,
                        fontWeight: FontWeight.bold,
                        color: isFront ? Colors.black87 : const Color(0xFF58CC02),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const Spacer(),
        if (isFlipped)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  onPressed: widget.onDidNotKnowIt,
                  child: const Text('NO LA SABÍA'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF58CC02), foregroundColor: Colors.white),
                  onPressed: widget.onKnewIt,
                  child: const Text('SÍ LA SABÍA'),
                ),
              ),
            ],
          )
        else
          const SizedBox(height: 52), // Space placeholder to avoid UI jump
        const SizedBox(height: 24),
      ],
    );
  }
}
