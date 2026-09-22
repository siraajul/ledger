import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';
import 'brutal_widgets.dart';

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
    // Tabular digits so the width holds steady while it counts.
    final tabular = (style ?? const TextStyle()).copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : duration,
      curve: Curves.easeOutCubic,
      builder: (context, val, child) {
        return Text('$prefix${val.toStringAsFixed(2)}$suffix', style: tabular);
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
    if (MediaQuery.disableAnimationsOf(context)) return child;
    // Capped: rows built later by scrolling must not wait longer and longer.
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration + (delay * index.clamp(0, 4)),
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
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(
      begin: 0,
      end: widget.ratio,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ratio != widget.ratio) {
      _animation = Tween<double>(begin: _animation.value, end: widget.ratio)
          .animate(
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
                border: Border.fromBorderSide(
                  BorderSide(color: Color(0xFF1A1A1A), width: 2),
                ),
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
      color: kPink,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete, color: kBlack, size: 28),
          SizedBox(height: 4),
          Text(
            'DELETE',
            style: TextStyle(
              color: kBlack,
              fontSize: 12,
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
    this.confirmMessage = 'DELETE THIS EXPENSE?',
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
        final confirmed = await showBrutalConfirm(
          context,
          title: confirmMessage,
          confirmLabel: 'DELETE EXPENSE',
          color: kPink,
        );
        if (!confirmed) return false;
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

// Slide page transition
class SlidePageTransition extends PageRouteBuilder {
  final Widget page;

  SlidePageTransition({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          if (MediaQuery.disableAnimationsOf(context)) return child;
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
