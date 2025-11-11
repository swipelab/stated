import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:stated/stated.dart';

/// WIP
abstract class Pane with Emitter {
  Pane();

  final Map<Object?, Widget> widgets = {};
  final Map<Object?, Element> elements = {};
  final Map<Object?, RenderBox> renderBoxes = {};

  // ready to manage children
  PaneElement? element;
  PaneRender? renderer;

  bool get needsCompositing => renderer?.needsCompositing ?? false;

  set size(Size value) => renderer!.size = value;

  Size get size => renderer!.size;

  BoxConstraints get constraints => renderer!.constraints;

  void markNeedsLayout() => renderer?.markNeedsLayout();

  void markNeedsPaint() => renderer?.markNeedsPaint();

  void attachPipeline(PipelineOwner owner) {
    for (final child in renderBoxes.values) {
      child.attach(owner);
    }
  }

  void detachPipeline() {
    for (final child in renderBoxes.values) {
      child.detach();
    }
  }

  void visitChildrenRender(RenderObjectVisitor visitor) =>
      renderBoxes.values.forEach(visitor);

  void setupParentData(covariant RenderObject child, covariant Object? slot);

  List<DiagnosticsNode> debugDescribeChildren() => const [];

  void debugFillProperties(DiagnosticPropertiesBuilder properties) {}

  void applyPaintTransform(covariant RenderObject child, Matrix4 transform) {}

  bool hitTestChildren(BoxHitTestResult result, Offset position) => false;

  bool hitTestSelf(Offset position) => false;

  /// [constraints] are available
  /// [size] must be set
  void performLayout();

  void paint(PaintingContext context, Offset offset);

  void insertRenderObjectChild(
      PaneElement paneElement, covariant RenderBox child, Object? slot) {
    setupParentData(child, slot);
    renderBoxes[slot] = child;
    renderer?.adoptChild(child);
  }

  void moveRenderObjectChild(PaneElement paneElement, RenderObject child,
      Object? oldSlot, Object? newSlot) {}

  void removeRenderObjectChild(
      PaneElement paneElement, RenderObject child, Object? slot) {
    renderBoxes.remove(slot);
    renderer?.dropChild(child);
  }

  void visitChildrenElement(ElementVisitor visitor) =>
      elements.values.forEach(visitor);

  Widget itemBuilder(BuildContext context, Object? slot);

  RenderBox? invokeLayoutUpsert(Object? slot) {
    if (element == null) return null;
    RenderBox? child = renderBoxes[slot];
    if (child != null) return child;
    renderer?.invokeLayoutCallback((constraints) {
      child = buildChild(slot);
    });
    return child;
  }

  void invokeLayoutRemove(Object? slot) {
    if (element == null) return;
    renderer?.invokeLayoutCallback((constraints) {
      removeSlotElement(slot);
    });
  }

  void removeSlotElement(Object? slot) {
    final element = this.element;
    if (element == null) return;
    elements.remove(slot)?.pipe(element.deactivateChild);
    widgets.remove(slot);
  }

  void mountElement(Element? parent, Object? newSlot, PaneElement element) {
    this.element = element;
  }

  void unmountElement() {
    for (final child in renderBoxes.values) {
      renderer?.dropChild(child);
    }
    renderBoxes.clear();
    elements.clear();
    widgets.clear();

    element = null;
  }

  RenderBox? buildChild(Object? slot) {
    final element = this.element;
    if (element == null) return null;

    element.owner!.buildScope(element, () {
      Widget newWidget;
      try {
        newWidget = itemBuilder(element, slot);
      } catch (e) {
        return;
      }

      final oldElement = elements[slot];
      final oldWidget = widgets[slot];
      if (oldElement == null) {
        final newElement = element.inflateWidget(newWidget, slot);
        elements[slot] = newElement;
        widgets[slot] = newWidget;
      } else if (oldWidget != null && Widget.canUpdate(oldWidget, newWidget)) {
        oldElement.update(newWidget);
        widgets[slot] = newWidget;
      } else {
        element.deactivateChild(oldElement);
        final newElement = element.inflateWidget(newWidget, slot);
        elements[slot] = newElement;
        widgets[slot] = newWidget;
      }
    });
    return elements[slot]?.renderObject as RenderBox?;
  }

  void forgetChildElement(Element child) {
    elements.removeWhere((_, value) => value == child);
  }
}

class PaneView extends StatelessWidget {
  const PaneView({
    required this.controller,
    required this.scrollController,
    this.scrollPhysics,
    super.key,
  });

  final Pane controller;
  final ScrollController scrollController;
  final ScrollPhysics? scrollPhysics;

  Widget buildViewport(BuildContext context, ViewportOffset offset) {
    return PaneViewport(controller: controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scrollable(
      controller: scrollController,
      physics: scrollPhysics,
      viewportBuilder: buildViewport,
    );
  }
}

class PaneViewport extends RenderObjectWidget {
  const PaneViewport({
    required this.controller,
    super.key,
  });

  final Pane controller;

  @override
  RenderObjectElement createElement() {
    return PaneElement(this, controller);
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return PaneRender(controller: controller);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant PaneRender renderObject) {
    renderObject.controller = controller;
  }
}

class PaneElement extends RenderObjectElement {
  PaneElement(super.widget, this.controller);

  final Pane controller;

  @override
  void insertRenderObjectChild(
      covariant RenderBox child, covariant Object? slot) {
    controller.insertRenderObjectChild(this, child, slot);
  }

  @override
  void moveRenderObjectChild(covariant RenderObject child,
      covariant Object? oldSlot, covariant Object? newSlot) {
    controller.moveRenderObjectChild(this, child, oldSlot, newSlot);
  }

  @override
  void removeRenderObjectChild(
      covariant RenderObject child, covariant Object? slot) {
    controller.removeRenderObjectChild(this, child, slot);
  }

  @override
  void visitChildren(ElementVisitor visitor) =>
      controller.visitChildrenElement(visitor);

  @override
  void deactivateChild(Element child) => super.deactivateChild(child);

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    controller.mountElement(parent, newSlot, this);
  }

  @override
  void unmount() {
    controller.unmountElement();
    super.unmount();
  }

  @override
  void update(covariant RenderObjectWidget newWidget) {
    super.update(newWidget);
    renderObject.markNeedsLayout();
  }

  @override
  void forgetChild(Element child) {
    controller.forgetChildElement(child);
    super.forgetChild(child);
  }

  @override
  Element inflateWidget(Widget newWidget, Object? newSlot) =>
      super.inflateWidget(newWidget, newSlot);

  @override
  PaneRender get renderObject => super.renderObject as PaneRender;

  @override
  PaneViewport get widget => super.widget as PaneViewport;
}

class PaneRender extends RenderBox {
  PaneRender({
    required this.controller,
  });

  Pane controller;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    controller.attachPipeline(owner);
    controller.renderer = this;
  }

  @override
  void detach() {
    super.detach();
    controller.detachPipeline();
    controller.renderer = null;
  }

  @override
  set size(Size value) => super.size = value;

  @override
  void adoptChild(RenderObject child) => super.adoptChild(child);

  @override
  void dropChild(RenderObject child) => super.dropChild(child);

  @override
  void setupParentData(covariant RenderObject child) {
    //no-op
  }

  @override
  void performLayout() => controller.performLayout();

  @override
  void paint(PaintingContext context, Offset offset) =>
      controller.paint(context, offset);

  @override
  bool hitTestSelf(Offset position) => controller.hitTestSelf(position);

  @override
  void invokeLayoutCallback<T extends Constraints>(
          LayoutCallback<T> callback) =>
      super.invokeLayoutCallback(callback);

  @override
  bool hitTestChildren(
    BoxHitTestResult result, {
    required Offset position,
  }) =>
      controller.hitTestChildren(result, position);

  @override
  void visitChildren(RenderObjectVisitor visitor) =>
      controller.visitChildrenRender(visitor);

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    assert(child.parent == this);
    controller.applyPaintTransform(child, transform);
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() =>
      controller.debugDescribeChildren();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    controller.debugFillProperties(properties);
  }
}
