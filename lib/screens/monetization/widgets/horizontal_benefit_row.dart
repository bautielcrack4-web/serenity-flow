import 'package:flutter/material.dart';
import 'package:serenity_flow/core/design_system.dart';

class HorizontalBenefitRow extends StatelessWidget {
  const HorizontalBenefitRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildItem(Icons.all_inclusive_rounded, "Unlimited\nRoutines"),
        _buildItem(Icons.edit_note_rounded, "Custom\nBuilder"),
        _buildItem(Icons.insights_rounded, "Smart\nProgress"),
      ],
    );
  }

  Widget _buildItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.turquoise.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.turquoise, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.dark,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
