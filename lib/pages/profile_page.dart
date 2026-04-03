import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(
                Icons.store,
                size: 50,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'MaterialKu',
              style: AppTextStyle.heading2,
              
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Aplikasi Manajemen Material Bangunan',
              style: AppTextStyle.bodyMedium.copyWith(
                color: AppColors.gray500,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: AppBorderRadius.md,
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Developer'),
                    subtitle: Text(
                      'Mahatir Ajalah',
                      style: AppTextStyle.bodySmall,
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.school),
                    title: const Text('Mata Kuliah'),
                    subtitle: const Text('Mobile Programming'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('Versi Aplikasi'),
                    subtitle: const Text('1.0.0'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}