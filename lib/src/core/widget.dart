import 'package:flutter/widgets.dart';

extension GlobalKeyExtension on GlobalKey {
  Offset? get position {
    final context = currentContext;
    if (context == null) return null;
    final box = context.findRenderObject() as RenderBox;
    final pos = box.localToGlobal(Offset.zero);
    return pos;
  }

  Size? get size {
    final context = currentContext;
    if (context == null) return null;
    final box = context.findRenderObject() as RenderBox;
    return box.size;
  }

  Rect? rect({Offset offset = Offset.zero}) {
    final context = currentContext;
    if (context == null) return null;
    final box = context.findRenderObject() as RenderBox;
    return box.localToGlobal(offset) & box.size;
  }
}

extension SliverExtension on Widget {
  Widget sliver({Key? key}) => SliverToBoxAdapter(key: key, child: this);
}
