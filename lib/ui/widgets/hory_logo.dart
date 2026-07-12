import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Logo textuel HORY.NEX (dessiné en code, aucune image externe requise).
/// Un vrai logo image peut être placé dans assets/images/logo.png.
class HoryLogo extends StatelessWidget {
  final double size;
  final bool showTagline;
  const HoryLogo({super.key, this.size = 88, this.showTagline = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.bleuFonce, AppColors.bleuFonceClair],
            ),
            borderRadius: BorderRadius.circular(size * 0.28),
            boxShadow: [
              BoxShadow(
                color: AppColors.bleuFonce.withOpacity(.35),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'H',
              style: TextStyle(
                fontSize: size * 0.5,
                fontWeight: FontWeight.w900,
                color: AppColors.blanc,
              ),
            ),
          ),
        ),
        SizedBox(height: size * 0.18),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: size * 0.30,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
            children: const [
              TextSpan(text: 'HORY', style: TextStyle(color: AppColors.bleuFonce)),
              TextSpan(text: '.NEX', style: TextStyle(color: AppColors.vert)),
            ],
          ),
        ),
        if (showTagline) ...[
          SizedBox(height: size * 0.06),
          Text(
            'Gestion PREPAC · Haïti',
            style: TextStyle(
              fontSize: size * 0.13,
              color: AppColors.grisMoyen,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
