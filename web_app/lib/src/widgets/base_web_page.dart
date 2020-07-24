import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class BaseScrollController extends InheritedWidget {
  const BaseScrollController({
    Key key,
    @required this.controller,
    @required Widget child,
  })  : assert(controller != null),
        assert(child != null),
        super(key: key, child: child);

  final ScrollController controller;

  static BaseScrollController of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<BaseScrollController>();
  }

  @override
  bool updateShouldNotify(BaseScrollController old) =>
      controller != old.controller;
}

class BaseWebPage extends StatefulWidget {
  const BaseWebPage({
    Key key,
    @required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  _BaseWebPageState createState() => _BaseWebPageState();
}

class _BaseWebPageState extends State<BaseWebPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return BaseScrollController(
      controller: _scrollController,
      child: Scaffold(
        body: Listener(
          onPointerSignal: (event) async {
            if (event is PointerScrollEvent) {
              // scroll down on the screen: negative offset,
              // scroll up: positive offset,
              print('Delta: ${event.scrollDelta}');

              double offset = 0.0;

              if (event.scrollDelta.dx == 0.0) {
                // vertical
                offset = event.scrollDelta.dy;
              } else {
                print('horizontal');
              }
              // TODO(brenodt): Implement scrolling logic.
              await _scrollController.animateTo(
                offset,
                duration: Duration(microseconds: 10),
                curve: Curves.decelerate,
              );
            }
          },
          child: ScrollConfiguration(
            behavior: GlowlessBehavior(),
            child: _CustomScrollbar(
              isAlwaysShown: true,
              controller: _scrollController,
              child: SingleChildScrollView(
                key: _key,
                controller: _scrollController,
                physics: NeverScrollableScrollPhysics(),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GlowlessBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

// CUPERTINO SCROLLBAR MODIFIED
// *****************************************************************************
// TODO: continue working on modifying it.

class _CustomScrollbar extends StatefulWidget {
  const _CustomScrollbar({
    Key key,
    this.controller,
    this.isAlwaysShown = false,
    @required this.child,
  })  : assert(!isAlwaysShown || controller != null,
            'When isAlwaysShown is true, must pass a controller that is attached to a scroll view'),
        super(key: key);

  final Widget child;
  final ScrollController controller;
  final bool isAlwaysShown;

  @override
  _CustomScrollbarState createState() => _CustomScrollbarState();
}

class _CustomScrollbarState extends State<_CustomScrollbar>
    with TickerProviderStateMixin {
  static const double _kScrollbarMinLength = 36.0;
  static const double _kScrollbarMinOverscrollLength = 8.0;
  static const Duration _kScrollbarTimeToFade = Duration(milliseconds: 1200);
  static const Duration _kScrollbarFadeDuration = Duration(milliseconds: 250);
  static const Duration _kScrollbarResizeDuration = Duration(milliseconds: 100);

  static const Color _kScrollbarColor = Color(0x59000000);
  static const double _kScrollbarThickness = 8.0;
  static const double _kScrollbarThicknessDragging = 12.0;
  static const Radius _kScrollbarRadius = Radius.circular(4.0);
  static const Radius _kScrollbarRadiusDragging = Radius.circular(15.0);

  static const double _kScrollbarMainAxisMargin = 3.0;
  static const double _kScrollbarCrossAxisMargin = 3.0;

  final GlobalKey _customPaintKey = GlobalKey();
  final GlobalKey _gestureDetectorkey = GlobalKey();
  ScrollbarPainter _painter;

  AnimationController _fadeoutAnimationController;
  Animation<double> _fadeoutOpacityAnimation;
  AnimationController _thicknessAnimationController;
  Timer _fadeoutTimer;
  double _dragScrollbarPositionY;
  Drag _drag;

  double get _thickness {
    return _kScrollbarThickness +
        _thicknessAnimationController.value *
            (_kScrollbarThicknessDragging - _kScrollbarThickness);
  }

  Radius get _radius {
    return Radius.lerp(_kScrollbarRadius, _kScrollbarRadiusDragging,
        _thicknessAnimationController.value);
  }

  ScrollController _currentController;
  // ScrollController get _controller =>
  //     widget.controller ?? PrimaryScrollController.of(context);
  ScrollController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _fadeoutAnimationController = AnimationController(
      vsync: this,
      duration: _kScrollbarFadeDuration,
    );
    _fadeoutOpacityAnimation = CurvedAnimation(
      parent: _fadeoutAnimationController,
      curve: Curves.fastOutSlowIn,
    );
    _thicknessAnimationController = AnimationController(
      vsync: this,
      duration: _kScrollbarResizeDuration,
    );
    _thicknessAnimationController.addListener(() {
      _painter.updateThickness(_thickness, _radius);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_painter == null) {
      _painter = _buildCupertinoScrollbarPainter(context);
    } else {
      _painter
        ..textDirection = Directionality.of(context)
        ..color = CupertinoDynamicColor.resolve(_kScrollbarColor, context)
        ..padding = MediaQuery.of(context).padding;
    }
    _triggerScrollbar();
  }

  @override
  void didUpdateWidget(_CustomScrollbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAlwaysShown != oldWidget.isAlwaysShown) {
      if (widget.isAlwaysShown == true) {
        _triggerScrollbar();
        _fadeoutAnimationController.animateTo(1.0);
      } else {
        _fadeoutAnimationController.reverse();
      }
    }
  }

  ScrollbarPainter _buildCupertinoScrollbarPainter(BuildContext context) {
    return ScrollbarPainter(
      color: CupertinoDynamicColor.resolve(_kScrollbarColor, context),
      textDirection: Directionality.of(context),
      thickness: _thickness,
      fadeoutOpacityAnimation: _fadeoutOpacityAnimation,
      mainAxisMargin: _kScrollbarMainAxisMargin,
      crossAxisMargin: _kScrollbarCrossAxisMargin,
      radius: _radius,
      padding: MediaQuery.of(context).padding,
      minLength: _kScrollbarMinLength,
      minOverscrollLength: _kScrollbarMinOverscrollLength,
    );
  }

  // Wait one frame and cause an empty scroll event.  This allows the thumb to
  // show immediately when isAlwaysShown is true.  A scroll event is required in
  // order to paint the thumb.
  void _triggerScrollbar() {
    WidgetsBinding.instance.addPostFrameCallback((Duration duration) {
      if (widget.isAlwaysShown) {
        _fadeoutTimer?.cancel();
        widget.controller.position.didUpdateScrollPositionBy(0);
      }
    });
  }

  // Handle a gesture that drags the scrollbar by the given amount.
  void _dragScrollbar(double primaryDelta) {
    assert(_currentController != null);

    // Convert primaryDelta, the amount that the scrollbar moved since the last
    // time _dragScrollbar was called, into the coordinate space of the scroll
    // position, and create/update the drag event with that position.
    final double scrollOffsetLocal = _painter.getTrackToScroll(primaryDelta);
    final double scrollOffsetGlobal =
        scrollOffsetLocal + _currentController.position.pixels;

    if (_drag == null) {
      _drag = _currentController.position.drag(
        DragStartDetails(
          globalPosition: Offset(0.0, scrollOffsetGlobal),
        ),
        () {},
      );
    } else {
      _drag.update(DragUpdateDetails(
        globalPosition: Offset(0.0, scrollOffsetGlobal),
        delta: Offset(0.0, -scrollOffsetLocal),
        primaryDelta: -scrollOffsetLocal,
      ));
    }
  }

  void _startFadeoutTimer() {
    if (!widget.isAlwaysShown) {
      _fadeoutTimer?.cancel();
      _fadeoutTimer = Timer(_kScrollbarTimeToFade, () {
        _fadeoutAnimationController.reverse();
        _fadeoutTimer = null;
      });
    }
  }

  bool _checkVertical() {
    try {
      return _currentController.position.axis == Axis.vertical;
    } catch (_) {
      // Ignore the gesture if we cannot determine the direction.
      return false;
    }
  }

  double _pressStartY = 0.0;

  // Long press event callbacks handle the gesture where the user long presses
  // on the scrollbar thumb and then drags the scrollbar without releasing.
  void _handleLongPressStart(LongPressStartDetails details) {
    _currentController = _controller;
    if (!_checkVertical()) {
      return;
    }
    _pressStartY = details.localPosition.dy;
    _fadeoutTimer?.cancel();
    _fadeoutAnimationController.forward();
    _dragScrollbar(details.localPosition.dy);
    _dragScrollbarPositionY = details.localPosition.dy;
  }

  void _handleLongPress() {
    if (!_checkVertical()) {
      return;
    }
    _fadeoutTimer?.cancel();
    _thicknessAnimationController.forward().then<void>(
          (_) => HapticFeedback.mediumImpact(),
        );
  }

  void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (!_checkVertical()) {
      return;
    }
    _dragScrollbar(details.localPosition.dy - _dragScrollbarPositionY);
    _dragScrollbarPositionY = details.localPosition.dy;
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    if (!_checkVertical()) {
      return;
    }
    _handleDragScrollEnd(details.velocity.pixelsPerSecond.dy);
    if (details.velocity.pixelsPerSecond.dy.abs() < 10 &&
        (details.localPosition.dy - _pressStartY).abs() > 0) {
      HapticFeedback.mediumImpact();
    }
    _currentController = null;
  }

  void _handleDragScrollEnd(double trackVelocityY) {
    _startFadeoutTimer();
    _thicknessAnimationController.reverse();
    _dragScrollbarPositionY = null;
    final double scrollVelocityY = _painter.getTrackToScroll(trackVelocityY);
    _drag?.end(DragEndDetails(
      primaryVelocity: -scrollVelocityY,
      velocity: Velocity(
        pixelsPerSecond: Offset(
          0.0,
          -scrollVelocityY,
        ),
      ),
    ));
    _drag = null;
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    // Ensures that other scrollable elements won't trigger a notification.
    // Othewise it will respond to any scrolling action in the screen.
    if (notification.depth > 0) {
      return false;
    }

    final ScrollMetrics metrics = notification.metrics;
    if (metrics.maxScrollExtent <= metrics.minScrollExtent) {
      return false;
    }

    if (notification is ScrollUpdateNotification ||
        notification is OverscrollNotification) {
      // Any movements always makes the scrollbar start showing up.
      if (_fadeoutAnimationController.status != AnimationStatus.forward) {
        _fadeoutAnimationController.forward();
      }

      _fadeoutTimer?.cancel();
      _painter.update(notification.metrics, notification.metrics.axisDirection);
    } else if (notification is ScrollEndNotification) {
      // On iOS, the scrollbar can only go away once the user lifted the finger.
      if (_dragScrollbarPositionY == null) {
        _startFadeoutTimer();
      }
    }
    return false;
  }

  // Get the GestureRecognizerFactories used to detect gestures on the scrollbar
  // thumb.
  Map<Type, GestureRecognizerFactory> get _gestures {
    final Map<Type, GestureRecognizerFactory> gestures =
        <Type, GestureRecognizerFactory>{};

    gestures[_ThumbPressGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<_ThumbPressGestureRecognizer>(
      () => _ThumbPressGestureRecognizer(
        debugOwner: this,
        customPaintKey: _customPaintKey,
      ),
      (_ThumbPressGestureRecognizer instance) {
        instance
          ..onLongPressStart = _handleLongPressStart
          ..onLongPress = _handleLongPress
          ..onLongPressMoveUpdate = _handleLongPressMoveUpdate
          ..onLongPressEnd = _handleLongPressEnd;
      },
    );

    return gestures;
  }

  @override
  void dispose() {
    _fadeoutAnimationController.dispose();
    _thicknessAnimationController.dispose();
    _fadeoutTimer?.cancel();
    _painter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: RepaintBoundary(
        child: RawGestureDetector(
          key: _gestureDetectorkey,
          gestures: _gestures,
          child: CustomPaint(
            key: _customPaintKey,
            foregroundPainter: _painter,
            child: RepaintBoundary(child: widget.child),
          ),
        ),
      ),
    );
  }
}

// A longpress gesture detector that only responds to events on the scrollbar's
// thumb and ignores everything else.
class _ThumbPressGestureRecognizer extends LongPressGestureRecognizer {
  _ThumbPressGestureRecognizer({
    double postAcceptSlopTolerance,
    PointerDeviceKind kind,
    Object debugOwner,
    GlobalKey customPaintKey,
  })  : _customPaintKey = customPaintKey,
        super(
          postAcceptSlopTolerance: postAcceptSlopTolerance,
          kind: kind,
          debugOwner: debugOwner,
          duration: const Duration(milliseconds: 100),
        );

  final GlobalKey _customPaintKey;

  @override
  bool isPointerAllowed(PointerDownEvent event) {
    if (!_hitTestInteractive(_customPaintKey, event.position)) {
      return false;
    }
    return super.isPointerAllowed(event);
  }
}

// foregroundPainter also hit tests its children by default, but the
// scrollbar should only respond to a gesture directly on its thumb, so
// manually check for a hit on the thumb here.
bool _hitTestInteractive(GlobalKey customPaintKey, Offset offset) {
  if (customPaintKey.currentContext == null) {
    return false;
  }
  final CustomPaint customPaint =
      customPaintKey.currentContext.widget as CustomPaint;
  final ScrollbarPainter painter =
      customPaint.foregroundPainter as ScrollbarPainter;
  final RenderBox renderBox =
      customPaintKey.currentContext.findRenderObject() as RenderBox;
  final Offset localOffset = renderBox.globalToLocal(offset);
  return painter.hitTestInteractive(localOffset);
}
