import 'package:flutter/material.dart';
import 'package:japanese_learning_app/core/models/exercise.dart';

class DrawingExercise extends StatefulWidget {
  final Exercise exercise;
  final void Function(bool) onEvaluated;

  const DrawingExercise({
    super.key,
    required this.exercise,
    required this.onEvaluated,
  });

  @override
  State<DrawingExercise> createState() => _DrawingExerciseState();
}

class _DrawingExerciseState extends State<DrawingExercise> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  bool _isEvaluating = false;

  void _startStroke(DragStartDetails details) {
    setState(() {
      _currentStroke = [details.localPosition];
      _strokes.add(_currentStroke);
    });
  }

  void _updateStroke(DragUpdateDetails details) {
    setState(() {
      _currentStroke.add(details.localPosition);
    });
  }

  void _endStroke(DragEndDetails details) {
    // El trazo actual ya está en _strokes, no necesitamos hacer nada más aquí.
  }

  void _clear() {
    setState(() {
      _strokes.clear();
      _currentStroke = [];
      _isEvaluating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isEvaluating ? '¿Se parece al carácter real?' : 'Dibuja el carácter',
          style: const TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        // Área del Canvas
        Container(
          width: 320,
          height: 320,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade300, width: 2),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
          ),
          child: Stack(
            children: [
              // Marca de agua (El carácter de fondo)
              Center(
                child: Text(
                  widget.exercise.question, 
                  style: TextStyle(
                    fontSize: 220,
                    fontWeight: FontWeight.w100,
                    color: _isEvaluating ? const Color(0xFF78C6A3).withOpacity(0.3) : Colors.grey.shade200,
                    height: 1.0,
                  ),
                ),
              ),
              // Superficie interactiva de dibujo
              IgnorePointer(
                ignoring: _isEvaluating,
                child: GestureDetector(
                  onPanStart: _startStroke,
                  onPanUpdate: _updateStroke,
                  onPanEnd: _endStroke,
                  child: CustomPaint(
                    painter: _DrawingPainter(strokes: _strokes),
                    size: Size.infinite,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Controles
        if (_isEvaluating)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  onPressed: () => widget.onEvaluated(false),
                  child: const Text('ME EQUIVOQUÉ'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF58CC02), foregroundColor: Colors.white),
                  onPressed: () => widget.onEvaluated(true),
                  child: const Text('LO TRACÉ BIEN'),
                ),
              ),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clear,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('BORRAR'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_strokes.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Dibuja algo antes de validar')),
                      );
                      return;
                    }
                    setState(() {
                      _isEvaluating = true;
                    });
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('VALIDAR'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF58CC02),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final List<List<Offset>> strokes;

  _DrawingPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      
      final path = Path();
      path.moveTo(stroke.first.dx, stroke.first.dy);
      
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) {
    return true; // Simplificado: repintar siempre que el estado cambie
  }
}
