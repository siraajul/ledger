import 'package:flutter/material.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF58CC02).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '🎉',
                  style: TextStyle(fontSize: 56),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            "You're all set!",
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Here's how it works:",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),
          _buildTip(
            icon: Icons.add_circle_outline,
            title: 'Tap + to add expenses',
            subtitle: 'Quick and easy entry',
          ),
          const SizedBox(height: 16),
          _buildTip(
            icon: Icons.bar_chart_outlined,
            title: 'Check Stats tab',
            subtitle: 'See where your money goes',
          ),
          const SizedBox(height: 16),
          _buildTip(
            icon: Icons.calendar_today_outlined,
            title: 'Filter by time',
            subtitle: 'Today, week, month, or all',
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }

  Widget _buildTip({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: const Color(0xFF58CC02)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
