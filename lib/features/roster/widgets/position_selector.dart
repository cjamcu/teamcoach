import 'package:flutter/material.dart';
import 'package:teamcoach/core/constants/app_constants.dart';
import 'package:teamcoach/core/theme/app_theme.dart';

class PositionSelector extends StatelessWidget {
  final List<String> selectedPositions;
  final ValueChanged<List<String>> onChanged;

  const PositionSelector({
    super.key,
    required this.selectedPositions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Posiciones',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${selectedPositions.length}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: AppConstants.positions.map((position) {
            final isSelected = selectedPositions.contains(position);
            final color = AppTheme.positionColors[position] ?? theme.colorScheme.primary;
            
            return InkWell(
              onTap: () {
                final newPositions = List<String>.from(selectedPositions);
                
                if (isSelected) {
                  newPositions.remove(position);
                } else {
                  newPositions.add(position);
                }
                
                onChanged(newPositions);
              },
              borderRadius: BorderRadius.circular(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      final newPositions = List<String>.from(selectedPositions);
                      
                      if (value == true && !isSelected) {
                        newPositions.add(position);
                      } else if (value == false && isSelected) {
                        newPositions.remove(position);
                      }
                      
                      onChanged(newPositions);
                    },
                    activeColor: color,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        position,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isSelected ? color : theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        AppConstants.positionNames[position] ?? '',
                        style: TextStyle(
                          fontSize: 9,
                          color: isSelected 
                              ? color.withOpacity(0.8)
                              : theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
} 