import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../app_theme.dart';

class ItalyMapWidget extends StatelessWidget {
  final double size;
  const ItalyMapWidget({super.key, this.size = 400});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/it.svg',
      width: size,
      colorFilter: const ColorFilter.mode(
        Color(0xFF2A2A2A),
        BlendMode.srcIn,
      ),
    );
  }
}
