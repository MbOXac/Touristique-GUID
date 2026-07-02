import 'package:flutter/material.dart';
import '../models/circuit.dart';
import '../screens/circuit_detail_screen.dart';
import '../theme/app_theme.dart';

class CircuitMiniCard extends StatelessWidget {
  final Circuit circuit;
  final double width;

  const CircuitMiniCard({
    super.key,
    required this.circuit,
    this.width = 220,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final placeholderBg = isDark ? AppTheme.darkCard : Colors.grey.shade200;
    final placeholderIconColor =
        isDark ? Colors.grey.shade600 : Colors.grey.shade400;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CircuitDetailScreen(circuit: circuit),
          ),
        );
      },
      child: Container(
        width: width,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 70 : 30),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Image ───────────────────────────────────────
              Stack(
                children: [
                  SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: circuit.imageUrl.isNotEmpty
                        ? Image.network(
                            circuit.imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: placeholderBg,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: AppTheme.primaryOrange,
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: placeholderBg,
                              child: Icon(circuit.typeIcon,
                                  color: placeholderIconColor, size: 38),
                            ),
                          )
                        : Container(
                            color: placeholderBg,
                            child: Icon(circuit.typeIcon,
                                color: placeholderIconColor, size: 38),
                          ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: AppTheme.orangeGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        circuit.durationText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ─── Title + price ───────────────────────────────
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      circuit.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: theme.textTheme.titleLarge?.color,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(circuit.typeIcon,
                            size: 13, color: theme.textTheme.bodyMedium?.color),
                        const Spacer(),
                        Text(
                          circuit.formattedPrice,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryOrange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
