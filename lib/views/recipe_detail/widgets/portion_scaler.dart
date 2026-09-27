import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class PortionScaler extends StatelessWidget {
  final int servings;
  final ValueChanged<int> onServingsChanged;

  const PortionScaler({
    super.key,
    required this.servings,
    required this.onServingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.restaurant, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Portion Scaler',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.chipBackground,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                  icon: const Icon(Icons.remove_rounded, size: 18, color: AppColors.textPrimary),
                  onPressed: servings > 1 ? () => onServingsChanged(servings - 1) : null,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Text(
                    '$servings ${servings == 1 ? "Serve" : "Serves"}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                  icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.textPrimary),
                  onPressed: () => onServingsChanged(servings + 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
