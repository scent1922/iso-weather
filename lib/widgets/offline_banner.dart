import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OfflineBanner extends StatelessWidget {
  final DateTime? lastUpdate;

  const OfflineBanner({super.key, this.lastUpdate});

  @override
  Widget build(BuildContext context) {
    final timeStr = lastUpdate != null
        ? DateFormat('HH:mm').format(lastUpdate!)
        : '--:--';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Offline Mode ($timeStr)',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
