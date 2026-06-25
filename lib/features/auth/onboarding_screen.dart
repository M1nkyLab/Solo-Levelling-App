import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';
import 'package:solo_levelling_app/features/quests/schedule_selection_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'THE SYSTEM HAS CHOSEN YOU',
      'description': "You have been granted access to the Hunter's Interface. Train daily. Rank up. Dominate.",
    },
    {
      'title': 'DAILY QUESTS',
      'description': "Complete your daily training protocols. Failure to do so will result in penalty.",
    },
    {
      'title': 'LEVEL UP',
      'description': "Gain experience, increase your stats, and challenge the portal trials to prove your worth.",
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      HapticFeedback.lightImpact();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ScheduleSelectionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // #000000 from design
      body: SafeArea(
        child: Column(
          children: [
            // Slide Indicator Row (Top)
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentPage == index ? 24 : 8,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? ShadowColors.amethyst : const Color(0xFF333333),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: _currentPage == index
                          ? [
                              BoxShadow(
                                color: ShadowColors.amethyst.withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: -2,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ),
            ),
            
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Hero Illustration
                        SizedBox(
                          height: 380,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Aura Glow
                              Container(
                                width: 300,
                                height: 300,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: ShadowColors.amethyst.withValues(alpha: 0.4), // #8A2BE266
                                  boxShadow: [
                                    BoxShadow(
                                      color: ShadowColors.amethyst.withValues(alpha: 0.4),
                                      blurRadius: 60,
                                    ),
                                  ],
                                ),
                              ),
                              // Character Placeholder
                              Container(
                                width: 200,
                                height: 260,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1A1A),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'ARISE',
                                  style: ShadowTextTheme.headline(
                                    32,
                                    color: ShadowColors.amethyst.withValues(alpha: 0.25), // #8A2BE240
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Content Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32.0),
                          child: Column(
                            children: [
                              Text(
                                page['title']!,
                                style: ShadowTextTheme.headline(22, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                page['description']!,
                                style: ShadowTextTheme.body(
                                  15, 
                                  color: const Color(0xFFA0A0A0),
                                  height: 1.6,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Pagination Dots & CTA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32.0),
              child: Column(
                children: [
                  // Pagination Dots (Bottom)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 4,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? ShadowColors.amethyst : const Color(0xFF333333),
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: _currentPage == index
                              ? [
                                  BoxShadow(
                                    color: ShadowColors.amethyst.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    spreadRadius: -2,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // CTA Button
                  GestureDetector(
                    onTap: _onNextPressed,
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: ShadowColors.amethyst, // #8A2BE2
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: ShadowColors.amethyst.withValues(alpha: 0.5),
                            blurRadius: 20,
                            spreadRadius: -5,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'BEGIN YOUR JOURNEY' : 'NEXT',
                        style: ShadowTextTheme.headline(
                          16, 
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
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

