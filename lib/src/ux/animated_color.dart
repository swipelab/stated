import 'package:flutter/widgets.dart';

class AnimatedColor extends StatefulWidget {
  const AnimatedColor({
    required this.color,
    required this.builder,
    this.child,
    this.curve = Curves.linear,
    this.duration = const Duration(milliseconds: 200),
    super.key,
  });

  final Curve curve;
  final Duration duration;
  final Color? color;
  final ValueWidgetBuilder<Color?> builder;
  final Widget? child;

  @override
  State<AnimatedColor> createState() => _AnimatedColorState();
}

class _AnimatedColorState extends State<AnimatedColor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(duration: widget.duration, vsync: this);
    _colorAnimation =
        ColorTween(begin: widget.color, end: widget.color).animate(
      CurvedAnimation(parent: _animationController, curve: widget.curve),
    );
  }

  @override
  void didUpdateWidget(AnimatedColor oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.color != widget.color) {
      _colorAnimation =
          ColorTween(begin: oldWidget.color, end: widget.color).animate(
        CurvedAnimation(parent: _animationController, curve: widget.curve),
      );
      _animationController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) =>
          widget.builder(context, _colorAnimation.value, child),
    );
  }
}
