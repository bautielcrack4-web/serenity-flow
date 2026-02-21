import 'package:flutter/material.dart';
import 'package:serenity_flow/core/design_system.dart';
import 'package:url_launcher/url_launcher.dart';

class ExpandableLegalSection extends StatefulWidget {
  final VoidCallback onRestore;
  
  const ExpandableLegalSection({super.key, required this.onRestore});

  @override
  State<ExpandableLegalSection> createState() => _ExpandableLegalSectionState();
}

class _ExpandableLegalSectionState extends State<ExpandableLegalSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: widget.onRestore,
                  child: Text(
                    "Restore Purchases",
                    style: TextStyle(
                      color: AppColors.dark.withValues(alpha: 0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text("•", style: TextStyle(color: AppColors.dark.withValues(alpha: 0.3))),
                ),
                Text(
                  _isExpanded ? "Hide Terms" : "Terms & Privacy",
                  style: TextStyle(
                    color: AppColors.dark.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded,
                  size: 16,
                  color: AppColors.dark.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
        
        AnimatedCrossFade(
          firstChild: const SizedBox(height: 0),
          secondChild: _buildFullLegalText(),
          crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }

  Widget _buildFullLegalText() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        children: [
          Text(
            "A purchase will be applied to your iTunes account on confirmation. Subscriptions will automatically renew unless canceled within 24-hours before the end of the current period. You can cancel anytime with your iTunes account settings. Any unused portion of a free trial will be forfeited if you purchase a subscription.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: AppColors.dark.withValues(alpha: 0.4), height: 1.4),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLink("Privacy Policy", "https://sites.google.com/view/yunaapp/privacy-policy"),
              Text(" • ", style: TextStyle(color: AppColors.dark.withValues(alpha: 0.3))),
              _buildLink("Terms of Use (EULA)", "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLink(String text, String url) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) await launchUrl(uri);
      },
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.dark.withValues(alpha: 0.5),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
