import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import 'home_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnboardingPage> _pages = [
    _OnboardingPage(
      title: 'MiniWeather',
      subtitle: '당신만의 작은 날씨 세계',
      icon: Icons.public,
      description: '세계 63개 도시의 아이소메트릭 미니어처 디오라마로\n날씨를 만나보세요.',
    ),
    _OnboardingPage(
      title: '도시 미니어처',
      icon: Icons.location_city,
      description: '계절, 시간, 날씨에 따라 변하는 아름다운 도시 풍경.\n2,520장의 이미지가 현재 날씨를 생생하게 표현합니다.',
    ),
    _OnboardingPage(
      title: '스마트 옷차림 추천',
      icon: Icons.checkroom,
      description: '오늘 하루 전체를 분석하여 나에게 맞는 옷차림을 추천합니다.\n개인 체감 유형에 따른 맞춤 추천도 가능해요.',
    ),
    _OnboardingPage(
      title: '상세 날씨 & 도시 검색',
      icon: Icons.search,
      description: '옆으로 스와이프하면 시간별·주간 날씨를 확인할 수 있어요.\n한글로 도시를 검색해보세요.',
    ),
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _skip() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _finish() {
    ref.read(settingsProvider.notifier).setOnboardingComplete(true);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF87CEEB), Color(0xFF5BA8CC)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Page content
              PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index], index);
                },
              ),

              // Skip button (pages 0-2)
              if (_currentPage < _pages.length - 1)
                Positioned(
                  top: 12,
                  right: 20,
                  child: TextButton(
                    onPressed: _skip,
                    child: Text(
                      '건너뛰기',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                ),

              // Bottom: dots + button
              Positioned(
                bottom: 48,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    _buildPageIndicator(),
                    const SizedBox(height: 32),
                    if (_currentPage == _pages.length - 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _finish,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF5BA8CC),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              '시작하기',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF5BA8CC),
                              ),
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
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page, int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 80, 32, 160),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with circular background
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 80,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 48),

          // Title
          Text(
            page.title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),

          // Subtitle (page 0 only)
          if (page.subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              page.subtitle!,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.85),
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 24),

          // Description
          Text(
            page.description,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.80),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

class _OnboardingPage {
  final String title;
  final String? subtitle;
  final IconData icon;
  final String description;

  const _OnboardingPage({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.description,
  });
}
