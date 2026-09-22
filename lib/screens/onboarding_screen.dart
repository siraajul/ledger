import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/settings/settings_bloc.dart';
import '../bloc/settings/settings_event.dart';
import '../theme.dart';
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 1 && _currentName.trim().isEmpty) return;
    if (_currentPage == 3) {
      _completeOnboarding();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
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
            GestureDetector(
              onTap: _previousPage,
              child: Container(
                padding: const EdgeInsets.all(8),
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
            const SizedBox(width: 36),
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
          const SizedBox(width: 36),
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
              color: kPink,
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
      onNameChanged: (name) => _currentName = name,
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
          Container(
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
      child: GestureDetector(
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
