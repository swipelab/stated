import 'package:flutter/widgets.dart';

class Measured extends StatefulWidget {
  const Measured({
    required this.child,
    this.onSize,
    super.key,
  });

  final Widget child;
  final VoidCallback? onSize;

  @override
  State<Measured> createState() => _MeasuredState();
}

class _MeasuredState extends State<Measured> {
  @override
  void initState() {
    super.initState();
    report();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: handleSizeChanged,
      child: SizeChangedLayoutNotifier(
        child: widget.child,
      ),
    );
  }

  void report() {
    widget.onSize?.call();
  }

  bool handleSizeChanged(SizeChangedLayoutNotification notification) {
    report();
    return false;
  }
}
