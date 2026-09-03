import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class AvatarCircle extends StatelessWidget {
  final String avatarPath;
  final double radius;
  final VoidCallback? onTap;

  const AvatarCircle({
    super.key,
    required this.avatarPath,
    this.radius = 40,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius + 2,
        backgroundColor: AppColors.primaryGreen,
        child: CircleAvatar(
          radius: radius,
          backgroundColor: Colors.white,
          backgroundImage: avatarPath.startsWith('assets/')
              ? AssetImage(avatarPath) as ImageProvider
              : NetworkImage(avatarPath),
          errorBuilder: (_, __, ___) => Icon(
            Icons.person,
            size: radius,
            color: AppColors.primaryGreen,
          ),
        ),
      ),
    );
  }
}
