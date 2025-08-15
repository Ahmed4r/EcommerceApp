import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  static const String routeName = '/onboarding';
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _current = 0;
  SharedPreferences? pref;
  bool seen = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    pref = await SharedPreferences.getInstance();
    seen = pref?.getBool('onboarding_seen') ?? false;
  }

  final List<_OnboardPage> _pages = [
    _OnboardPage(
      title: 'Welcome',
      subtitle: 'Discover products you love.',
      // replace with your asset or network image
      image: Icons.shopping_bag_outlined,
    ),
    _OnboardPage(
      title: 'Fast Delivery',
      subtitle: 'Get your order delivered quickly.',
      image: Icons.local_shipping_outlined,
    ),
    _OnboardPage(
      title: 'Secure Payments',
      subtitle: 'Pay safely with multiple options.',
      image: Icons.lock_outline,
    ),
  ];

  void _goNext() async {
    if (_current < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setBool('onboarding_seen', true);
    }
  }

  void _skip() {
    _controller.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _finishOnboarding() {
    pref?.setBool('onboarding_seen', true);
    Navigator.of(context).pop();
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_pages.length, (i) {
        final bool active = i == _current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? Colors.amber : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _skip,
                child: const Text('Skip'),
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(
                    AppColors.secondary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _current = index),
                itemBuilder: (context, index) {
                  final p = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(p.image, size: 140, color: AppColors.secondary),
                        const SizedBox(height: 32),
                        Text(
                          p.title,
                          style: GoogleFonts.cairo(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          p.subtitle,
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            color: AppColors.secondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildIndicator(),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        _current == _pages.length - 1
                            ? AppColors.secondary
                            : Colors.grey,
                      ),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                    ),
                    onPressed: _goNext,
                    child: Text(
                      _current == _pages.length - 1 ? 'Get Started' : 'Next',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage {
  final String title;
  final String subtitle;
  final IconData image;
  const _OnboardPage({
    required this.title,
    required this.subtitle,
    required this.image,
  });
}
