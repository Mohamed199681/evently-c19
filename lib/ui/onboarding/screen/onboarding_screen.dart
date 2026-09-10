import 'package:flutter/material.dart';
import 'package:evently_c19/ui/onboarding/widgets/onboarding_page.dart';
import 'package:evently_c19/core/remote/local/prefs_manager.dart';
import 'package:evently_c19/core/resources/routes_manager.dart';
import 'package:evently_c19/core/resources/assets_manager.dart';
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
      "image": AssetsManager.beingCreative,
      "title": "Personalize Your Experience",
      "description": "Find events that match your interests",
    },
    {
      "image": AssetsManager.beingCreative,
      "title": "Find Events That Inspire You",
      "description": "Discover amazing events around you",
    },
    {
      "image": AssetsManager.beingCreative,
      "title": "Effortless Event Planning",
      "description": "Plan your events with ease",
    },
    {
      "image": AssetsManager.beingCreative,
      "title": "Connect with Friends & Share Moments",
      "description": "Share your experience with friends",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
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
                return OnboardingPage(
                  image: _pages[index]["image"]!,
                  title: _pages[index]["title"]!,
                  description: _pages[index]["description"]!,
                );
              },
            ),
          ),
          // Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
                  (index) => Container(
                margin: EdgeInsets.all(4),
                width: _currentPage == index ? 16 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? Colors.blue
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          // Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_currentPage < _pages.length - 1) {
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  }else {
         PrefsManager.setOnboardingShown();
          Navigator.pushReplacementNamed(
            context,
              RoutesManager.loginRouteName,
           );
               }
                },
                child: Text(
                  _currentPage < _pages.length - 1 ? "Next" : "Get Started",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}