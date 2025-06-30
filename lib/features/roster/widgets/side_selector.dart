import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SideSelector extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final List<SideOption> options;

  const SideSelector({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isSelected = value == option.value;
              final isFirst = index == 0;
              final isLast = index == options.length - 1;
              
              return Expanded(
                child: InkWell(
                  onTap: () => onChanged(option.value),
                  borderRadius: BorderRadius.horizontal(
                    left: isFirst ? const Radius.circular(8) : Radius.zero,
                    right: isLast ? const Radius.circular(8) : Radius.zero,
                  ),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.horizontal(
                        left: isFirst ? const Radius.circular(7) : Radius.zero,
                        right: isLast ? const Radius.circular(7) : Radius.zero,
                      ),
                      border: !isLast ? Border(
                        right: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.3),
                          width: 1,
                        ),
                      ) : null,
                    ),
                    child: Center(
                      child: Text(
                        option.label,
                        style: TextStyle(
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class SideOption {
  final String value;
  final String label;
  final IconData icon;

  const SideOption({
    required this.value,
    required this.label,
    required this.icon,
  });
}

// Opciones predefinidas
class SideOptions {
  static const List<SideOption> batting = [
    SideOption(value: 'right', label: 'Derecha', icon: Icons.arrow_forward),
    SideOption(value: 'left', label: 'Izquierda', icon: Icons.arrow_back),
    SideOption(value: 'switch', label: 'Ambas', icon: Icons.swap_horiz),
  ];
  
  static const List<SideOption> throwing = [
    SideOption(value: 'right', label: 'Derecha', icon: Icons.sports_baseball),
    SideOption(value: 'left', label: 'Izquierda', icon: Icons.sports_baseball),
  ];
} 