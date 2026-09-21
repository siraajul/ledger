import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Animated number that counts up/down
class AnimatedCounter extends StatelessWidget {
  final double value;
  final TextStyle? style;
  final String prefix;
  final String suffix;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, val, child) {
        return Text(
          '$prefix${val.toStringAsFixed(2)}$suffix',
          style: style,
        );
      },
    );
  }
}

// Staggered list animation wrapper
class StaggeredAnimation extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;

  const StaggeredAnimation({
    super.key,
    required this.index,
    required this.child,
    this.delay = const Duration(milliseconds: 60),
    this.duration = const Duration(milliseconds: 400),
    this.offset = const Offset(0, 0.3),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration + (delay * index),
      curve: Curves.easeOutCubic,
      builder: (context, val, child) {
        return Opacity(
          opacity: val,
          child: Transform.translate(
            offset: Offset(
              offset.dx * (1 - val) * 100,
              offset.dy * (1 - val) * 100,
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// Animated bar that grows from left
class AnimatedBar extends StatefulWidget {
  final double ratio;
  final Color color;
  final Duration duration;
  final double height;

  const AnimatedBar({
    super.key,
    required this.ratio,
    required this.color,
    this.duration = const Duration(milliseconds: 800),
    this.height = 12,
  });

  @override
  State<AnimatedBar> createState() => _AnimatedBarState();
}

class _AnimatedBarState extends State<AnimatedBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(begin: 0, end: widget.ratio).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ratio != widget.ratio) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.ratio,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: widget.height,
              width: constraints.maxWidth,
              decoration: const BoxDecoration(
                border: Border.fromBorderSide(BorderSide(color: Color(0xFF1A1A1A), width: 2)),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: widget.height,
                  width: constraints.maxWidth * _animation.value,
                  color: widget.color,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Slide-to-dismiss background
class SlideToDeleteBackground extends StatelessWidget {
  const SlideToDeleteBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      color: const Color(0xFFFF6B9D),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete, color: Colors.white, size: 28),
          SizedBox(height: 4),
          Text(
            'DELETE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// Dismissible wrapper with physics
class SwipeToDelete extends StatelessWidget {
  final Widget child;
  final VoidCallback onDismissed;
  final String confirmMessage;

  /// Extra async gate (e.g. a PIN prompt) run after the confirm dialog.
  /// Returning false cancels the swipe and leaves the row in place.
  final Future<bool> Function()? beforeDismiss;

  const SwipeToDelete({
    super.key,
    required this.child,
    required this.onDismissed,
    this.confirmMessage = 'DELETE?',
    this.beforeDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: key ?? UniqueKey(),
      direction: DismissDirection.endToStart,
      background: const SlideToDeleteBackground(),
      confirmDismiss: (direction) async {
        HapticFeedback.heavyImpact();
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              side: BorderSide(color: Color(0xFF1A1A1A), width: 3),
            ),
            title: Text(
              confirmMessage,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'DELETE',
                  style: TextStyle(color: Color(0xFFFF6B9D)),
                ),
              ),
            ],
          ),
        );
        if (confirmed != true) return false;
        return await beforeDismiss?.call() ?? true;
      },
      onDismissed: (direction) {
        HapticFeedback.heavyImpact();
        onDismissed();
      },
      child: child,
    );
  }
}

// Pulse animation for attention
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const PulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 1.05).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: widget.child,
    );
  }
}

// Shake animation for errors
class ShakeAnimation extends StatefulWidget {
  final Widget child;
  final ShakeController? controller;

  const ShakeAnimation({
    super.key,
    required this.child,
    this.controller,
  });

  @override
  State<ShakeAnimation> createState() => _ShakeAnimationState();
}

class _ShakeAnimationState extends State<ShakeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: _ShakeCurve()),
    );
    widget.controller?._attach(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            (1 - _animation.value) * 10 *
                ((_animation.value * 4).floor().isEven ? 1 : -1),
            0,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class ShakeController {
  AnimationController? _controller;

  void _attach(AnimationController controller) {
    _controller = controller;
  }

  void shake() {
    if (_controller != null) {
      _controller!
        ..reset()
        ..forward();
    }
  }
}

class _ShakeCurve extends Curve {
  @override
  double transformInternal(double t) {
    if (t < 0.1) return t * 10;
    if (t < 0.3) return 1 - (t - 0.1) * 10;
    if (t < 0.5) return (t - 0.3) * 5;
    if (t < 0.7) return 1 - (t - 0.5) * 5;
    if (t < 0.85) return (t - 0.7) * (1 / 0.15);
    return 1 - (t - 0.85) * (1 / 0.15);
  }
}

// Slide page transition
class SlidePageTransition extends PageRouteBuilder {
  final Widget page;

  SlidePageTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        );
}

// Scale page transition (for dialogs)
class ScalePageTransition extends PageRouteBuilder {
  final Widget page;

  ScalePageTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ScaleTransition(
              scale: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

// Fade + slide up transition
class FadeSlideTransition extends PageRouteBuilder {
  final Widget page;

  FadeSlideTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final fadeTween = Tween<double>(begin: 0, end: 1);
            final slideTween = Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            );

            return FadeTransition(
              opacity: animation.drive(fadeTween),
              child: SlideTransition(
                position: animation.drive(slideTween),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        );
}
