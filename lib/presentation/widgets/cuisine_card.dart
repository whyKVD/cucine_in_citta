import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/cuisine.dart';
import '../app_theme.dart';

class CuisineCard extends StatelessWidget {
  final Cuisine cuisine;

  const CuisineCard({super.key, required this.cuisine});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: cuisine.imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: _resolveUrl(cuisine.imageUrl),
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const _PlaceholderBox(),
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.restaurant, color: AppColors.textSecondary, size: 32),
                  )
                : const Icon(Icons.restaurant, color: AppColors.textSecondary, size: 32),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              cuisine.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _resolveUrl(String original) {
    if (original.isEmpty) return '';
    if (kIsWeb) {
      return 'https://images.weserv.nl/?url=${Uri.encodeComponent(original)}&w=120';
    }
    return original;
  }
}

class _PlaceholderBox extends StatelessWidget {
  const _PlaceholderBox();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
