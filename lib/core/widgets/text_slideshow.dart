import 'dart:async';
import 'package:flutter/material.dart';


class TextSlideshow extends StatefulWidget {
  final List<String> texts;
  final List<Color> colors;

  const TextSlideshow({super.key, required this.texts, required this.colors});

  @override
  State<TextSlideshow> createState() => _TextSlideshowState();
}

class _TextSlideshowState extends State<TextSlideshow> {
  int _currentIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.texts.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0.0, 0.2), end: Offset.zero).animate(animation),
          child: child,
        ));
      },
      child: Text(
        widget.texts[_currentIndex],
        key: ValueKey<int>(_currentIndex),
        style: Theme.of(context).textTheme.displayLarge?.copyWith(
          fontSize: 28,
          color: widget.colors[_currentIndex % widget.colors.length],
          shadows: [
            Shadow(color: widget.colors[_currentIndex % widget.colors.length].withValues(alpha: 0.5), blurRadius: 20)
          ]
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
