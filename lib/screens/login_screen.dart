import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../services/auth.dart';
import '../theme.dart';
import '../widgets/brutal_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _signIn() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await signInWithGoogle();
      // The auth gate in app.dart swaps this screen out on success.
    } on GoogleSignInException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.code == GoogleSignInExceptionCode.canceled
            ? null
            : 'Sign-in failed: ${e.code.name}';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Sign-in failed. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: const BoxDecoration(
                  color: kYellow,
                  border: Border.fromBorderSide(
                    BorderSide(color: kBlack, width: 3),
                  ),
                  boxShadow: [BoxShadow(offset: Offset(4, 4), color: kBlack)],
                ),
                child: const Text(
                  'LEDGER',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -2,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'SIGN IN TO CONTINUE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),
              if (_busy)
                const Center(child: CircularProgressIndicator(color: kBlack))
              else
                BrutalButton(
                  label: 'CONTINUE WITH GOOGLE',
                  color: kWhite,
                  icon: Icons.login_rounded,
                  onPressed: _signIn,
                ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: kPink,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
