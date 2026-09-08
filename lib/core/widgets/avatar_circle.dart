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
    final bool isAsset = avatarPath.startsWith('assets/');

    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius + 2,
        backgroundColor: AppColors.primary,
        child: CircleAvatar(
          radius: radius,
          backgroundColor: Colors.white,
          child: ClipOval(
            child: isAsset
                ? Image.asset(
                    avatarPath,
                    width: radius * 2,
                    height: radius * 2,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.person,
                      size: radius,
                      color: AppColors.primary,
                    ),
                  )
                : Image.network(
                    avatarPath,
                    width: radius * 2,
                    height: radius * 2,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.person,
                      size: radius,
                      color: AppColors.primary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
