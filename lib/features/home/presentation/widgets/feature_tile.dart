import 'package:flutter/material.dart';

class FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle; // Optional subtitle
  final VoidCallback onTap;
  final Color? iconColor; // Optional specific color

  const FeatureTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle = '', // Default to empty
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2.0,
      // Use InkWell for ripple effect on tap
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0), // Match Card's default shape
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: 40.0,
                color: iconColor ?? colorScheme.primary, // Use primary color or provided one
              ),
              const SizedBox(height: 12.0),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 4.0),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}