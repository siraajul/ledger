import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/settings/settings_bloc.dart';
import '../bloc/settings/settings_event.dart';
import '../theme.dart';
import '../widgets/brutal_widgets.dart';
import 'onboarding_pages.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  String _currentName = '';
  bool _nameMissing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 1 && _currentName.trim().isEmpty) {
      setState(() => _nameMissing = true);
      return;
    }
    if (_currentPage == 3) {
      _completeOnboarding();
    } else {
      _goToPage(_currentPage + 1);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) _goToPage(_currentPage - 1);
  }

  void _goToPage(int page) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpToPage(page);
    } else {
      _controller.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: kEaseOut,
      );
    }
  }

  void _completeOnboarding() {
    context.read<SettingsBloc>().add(const OnboardingCompleted());
  }

  void _onBudgetChanged(double value) {
    context.read<SettingsBloc>().add(BudgetChanged(value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildWelcomePage(),
                  _buildNamePage(),
                  _buildBudgetPage(),
                  _buildDonePage(),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          if (_currentPage > 0)
            BrutalTap(
              onTap: _previousPage,
              label: 'Back',
              child: Container(
                padding: const EdgeInsets.all(11),
                decoration: const BoxDecoration(
                  color: kWhite,
                  border: Border.fromBorderSide(
                    BorderSide(color: kBlack, width: 2),
                  ),
                ),
                child: const Icon(Icons.arrow_back, size: 18),
              ),
            )
          else
            const SizedBox(width: 44),
          const Spacer(),
          ...List.generate(4, (index) {
            final isActive = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 32 : 12,
              height: 12,
              decoration: BoxDecoration(
                color: isActive ? kBlack : kWhite,
                border: Border.all(color: kBlack, width: 2),
              ),
            );
          }),
          const Spacer(),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildWelcomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 80),
          Container(
            width: 140,
            height: 140,
            decoration: const BoxDecoration(
              color: kYellow,
              border: Border.fromBorderSide(
                BorderSide(color: kBlack, width: 4),
              ),
              boxShadow: [BoxShadow(offset: Offset(6, 6), color: kBlack)],
            ),
            child: const Center(
              child: Text('💸', style: TextStyle(fontSize: 64)),
            ),
          ),
          const SizedBox(height: 48),
          const Text(
            'TRACK\nYOUR\nMONEY',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: kBlack,
              height: 1.0,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: kOrange,
              border: Border.fromBorderSide(
                BorderSide(color: kBlack, width: 2),
              ),
            ),
            child: const Text(
              'NO BS. JUST NUMBERS.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: kBlack,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildNamePage() {
    return NamePageContent(
      onNext: _nextPage,
      error: _nameMissing ? 'ENTER YOUR NAME TO CONTINUE' : null,
      onNameChanged: (name) {
        _currentName = name;
        if (_nameMissing && name.trim().isNotEmpty) {
          setState(() => _nameMissing = false);
        }
      },
    );
  }

  Widget _buildBudgetPage() {
    return BudgetPageContent(
      onNext: _nextPage,
      onBudgetChanged: _onBudgetChanged,
    );
  }

  Widget _buildDonePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 80),
          _SpringPopIn(
            child: Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: kGreen,
                border: Border.fromBorderSide(
                  BorderSide(color: kBlack, width: 4),
                ),
                boxShadow: [BoxShadow(offset: Offset(6, 6), color: kBlack)],
              ),
              child: const Center(
                child: Text(
                  '✓',
                  style: TextStyle(fontSize: 64, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
          const Text(
            "LET'S\nGO.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: kBlack,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Add your first expense\nwith the + button.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: kBlack, height: 1.4),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final isLastPage = _currentPage == 3;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: BrutalTap(
        onTap: _nextPage,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: const BoxDecoration(
            color: kYellow,
            border: Border.fromBorderSide(BorderSide(color: kBlack, width: 3)),
            boxShadow: [kShadow],
          ),
          child: Center(
            child: Text(
              isLastPage ? 'START' : 'CONTINUE',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: kBlack,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One-time celebration for the final onboarding page: a subtle spring
/// from 0.9 with a fade. Reduced motion shows it settled.
class _SpringPopIn extends StatefulWidget {
  final Widget child;
  const _SpringPopIn({required this.child});

  @override
  State<_SpringPopIn> createState() => _SpringPopInState();
}

class _SpringPopInState extends State<_SpringPopIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController.unbounded(
    vsync: this,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.animateWith(
        SpringSimulation(
          SpringDescription.withDurationAndBounce(
            duration: const Duration(milliseconds: 500),
            bounce: 0.2,
          ),
          0,
          1,
          0,
        ),
      );
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
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: _controller.value.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: 0.9 + 0.1 * _controller.value,
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
