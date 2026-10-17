import 'package:flutter/material.dart';
import '../theme/schoolride_theme.dart';

class FeaturePage extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<FeatureItem> items;

  const FeaturePage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [SchoolRideColors.navy, SchoolRideColors.blue],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 27,
                    backgroundColor: Colors.white.withValues(alpha: .16),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            ...items.map(
              (e) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: e.color.withValues(alpha: .12),
                    child: Icon(e.icon, color: e.color),
                  ),
                  title: Text(
                    e.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: e.detail.isEmpty ? null : Text(e.detail),
                  trailing: e.trailing ?? const Icon(Icons.chevron_right),
                  onTap: e.onTap,
                ),
              ),
            ),
          ],
        ),
      );
}

class FeatureItem {
  final String title;
  final String detail;
  final IconData icon;
  final Color color;
  final Widget? trailing;
  final VoidCallback? onTap;

  const FeatureItem(
    this.title,
    this.detail,
    this.icon,
    this.color, {
    this.trailing,
    this.onTap,
  });
}
