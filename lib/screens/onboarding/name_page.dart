import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/settings/settings_bloc.dart';
import '../../bloc/settings/settings_event.dart';

class NamePage extends StatefulWidget {
  const NamePage({super.key});

  @override
  State<NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasStartedTyping = false;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _controller.addListener(() {
      setState(() {
        _hasStartedTyping = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(flex: 2),
            Text(
              "What's your\nname?",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1A2E),
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "We'll personalize your experience.",
              style: TextStyle(
                fontSize: 17,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
              decoration: InputDecoration(
                hintText: 'Your name',
                hintStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[200],
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFF58CC02),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onChanged: (value) {
                context.read<SettingsBloc>().add(UserNameChanged(value));
              },
            ),
            if (_hasStartedTyping) ...[
              const SizedBox(height: 12),
              Text(
                _getGreeting(),
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF58CC02),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final name = _controller.text.trim();
    if (name.length < 2) return '';
    
    final greetings = [
      "Nice to meet you, $name!",
      "Hey $name, let's do this!",
      "$name it is!",
    ];
    
    return greetings[name.hashCode.abs() % greetings.length];
  }
}
