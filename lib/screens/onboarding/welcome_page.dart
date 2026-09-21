import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          // Playful illustration
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFF58CC02).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '💸',
                style: TextStyle(fontSize: 72),
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Track your\nspending.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Know where your money goes.\nNo spreadsheets needed.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              color: Colors.grey[500],
              height: 1.5,
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}
