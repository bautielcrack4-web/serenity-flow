
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'dart:ui';

class SentimentReviewDialog extends StatefulWidget {
  const SentimentReviewDialog({super.key});

  @override
  State<SentimentReviewDialog> createState() => _SentimentReviewDialogState();
}

class _SentimentReviewDialogState extends State<SentimentReviewDialog> with SingleTickerProviderStateMixin {
  double _rating = 5.0; // Default sentiment
  late AnimationController _emojiController;

  @override
  void initState() {
    super.initState();
    _emojiController = AnimationController(
       vsync: this, 
       duration: const Duration(milliseconds: 300),
       lowerBound: 0.8,
       upperBound: 1.2,
    );
  }

  @override
  void dispose() {
    _emojiController.dispose();
    super.dispose();
  }

  String _getEmoji(double value) {
    if (value <= 2) return "🌧️"; // Stormy
    if (value <= 4) return "☁️"; // Cloudy
    if (value <= 6) return "⛅"; // Partly Sunny
    if (value <= 8) return "☀️"; // Sunny
    return "🤩"; // Starry/Ecstatic
  }

  String _getText(double value) {
    if (value <= 2) return "Not meant for me";
    if (value <= 4) return "It's okay";
    if (value <= 6) return "Good vibes";
    if (value <= 8) return "Feeling great!";
    return "Absolutely magical!";
  }

  Color _getColor(double value) {
    if (value <= 3) return AppColors.gray;
    if (value <= 6) return AppColors.turquoise;
    if (value <= 8) return AppColors.coral;
    return AppColors.gold;
  }

  void _updateRating(double value) {
    if ((value - _rating).abs() > 0.5) {
      HapticFeedback.selectionClick();
      _emojiController.forward().then((_) => _emojiController.reverse());
    }
    setState(() {
      _rating = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9), // Glass feel
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: AppShadows.elevated,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Text(
                  "How's the flow?",
                  style: AppTextStyles.headline.copyWith(color: AppColors.dark, fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Animated Main Emoji
                ScaleTransition(
                  scale: _emojiController,
                  child: Text(
                    _getEmoji(_rating),
                    style: const TextStyle(fontSize: 72),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Sentiment Text
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _getText(_rating),
                    key: ValueKey<int>(_rating.round()),
                    style: AppTextStyles.title.copyWith(
                      color: _getColor(_rating),
                      fontSize: 18,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),

                // Ultra Slider Custom Implementation
                SizedBox(
                  height: 60,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Track
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: LinearGradient(
                            colors: [
                              Colors.grey.shade300,
                              AppColors.turquoise.withOpacity(0.5),
                              AppColors.coral.withOpacity(0.5),
                              AppColors.gold.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                      // Slider
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 12,
                          activeTrackColor: Colors.transparent, // Handled by container
                          inactiveTrackColor: Colors.transparent,
                          thumbColor: Colors.white,
                          overlayColor: _getColor(_rating).withOpacity(0.1),
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 16, elevation: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 28),
                        ),
                        child: Slider(
                          value: _rating,
                          min: 1,
                          max: 10,
                          divisions: 9,
                          onChanged: _updateRating,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("1", style: AppTextStyles.caption),
                    Text("10", style: AppTextStyles.caption),
                  ],
                ),

                const SizedBox(height: 32),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      // Only return true (to prompt rate) if rating is >= 9
                      Navigator.pop(context, _rating >= 9);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    child: const Text(
                      "CONTINUE",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
