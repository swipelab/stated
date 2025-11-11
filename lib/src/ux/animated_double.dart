import 'package:flutter/widgets.dart';

class AnimatedDouble extends StatefulWidget {
  const AnimatedDouble({
    super.key,
    required this.builder,
    required this.start,
    required this.end,
    this.curve = Curves.linear,
    this.duration = const Duration(milliseconds: 200),
    this.child,
  });

  final ValueWidgetBuilder<double> builder;
  final Widget? child;
  final double start;
  final double end;
  final Duration duration;
  final Curve curve;

  @override
  State<AnimatedDouble> createState() => _AnimatedDoubleState();
}

class _AnimatedDoubleState extends State<AnimatedDouble>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController.unbounded(
        vsync: this, value: widget.start, duration: widget.duration);
    if (widget.end != widget.start) {
      controller.animateTo(widget.end);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AnimatedDouble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.end != oldWidget.end) {
      controller.animateTo(widget.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: widget.builder,
      child: widget.child,
    );
  }
}
