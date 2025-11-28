import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../Utils/color.dart';


class TermsAndConditionsScreen extends StatefulWidget {
  final String lastUpdated;
  final String version;
  final List<Map<String, String>> sections;

  const TermsAndConditionsScreen({
    super.key,
    required this.lastUpdated,
    required this.version,
    required this.sections,
  });

  @override
  State<TermsAndConditionsScreen> createState() => _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> with TickerProviderStateMixin {
  late AnimationController _appBarController;
  late Animation<double> _appBarFadeAnimation;
  late Animation<Offset> _appBarSlideAnimation;
  late List<AnimationController> _cardControllers;
  late List<Animation<double>> _cardFadeAnimations;
  late List<Animation<Offset>> _cardSlideAnimations;
  final List<bool> _expandedSections = [];

  @override
  void initState() {
    super.initState();
    _expandedSections.addAll(List.generate(widget.sections.length, (_) => false));

    // AppBar animation setup
    _appBarController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _appBarFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _appBarController, curve: Curves.easeInOut),
    );
    _appBarSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _appBarController, curve: Curves.easeInOut),
    );

    // Card animations setup
    _cardControllers = List.generate(
      widget.sections.length,
          (_) => AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      ),
    );
    _cardFadeAnimations = _cardControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeIn),
      );
    }).toList();
    _cardSlideAnimations = _cardControllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    // Start animations
    _appBarController.forward();
    for (var i = 0; i < _cardControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) _cardControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    _appBarController.dispose();
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.navyBlue,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.h),
        child: FadeTransition(
          opacity: _appBarFadeAnimation,
          child: SlideTransition(
            position: _appBarSlideAnimation,
            child: AppBar(
              backgroundColor: AppColors.navyBlue,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text('Terms & Conditions')


            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: widget.sections.asMap().entries.map((entry) {
            final index = entry.key;
            final section = entry.value;
            return FadeTransition(
              opacity: _cardFadeAnimations[index],
              child: SlideTransition(
                position: _cardSlideAnimations[index],
                child: Card(
                  elevation: 2,
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      section['title'] ?? 'Section ${index + 1}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    initiallyExpanded: _expandedSections[index],
                    backgroundColor: Colors.white,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _expandedSections[index] = expanded;
                      });
                    },
                    children: [
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            section['content'] ?? '',
                            textAlign: TextAlign.justify,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}