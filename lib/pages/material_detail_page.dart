import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/material_model.dart';

class MaterialDetailPage extends StatelessWidget {
  final MaterialModel material;

  const MaterialDetailPage({
    super.key,
    required this.material,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Material'),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Tombol Edit
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              // TODO: Buka bottom sheet edit
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur edit akan segera hadir'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          // Tombol Hapus
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              // TODO: Konfirmasi hapus
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur hapus akan segera hadir'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Placeholder (nanti buat gambar)
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: AppBorderRadius.lg,
                  boxShadow: AppShadow.md,
                ),
                child: Icon(
                  _getCategoryIcon(material.category),
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Nama & Rating
            Row(
              children: [
                Expanded(
                  child: Text(
                    material.name,
                    style: AppTextStyle.heading2,
                  ),
                ),
                if ((material.rating ?? 0) > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: AppBorderRadius.sm,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          material.rating!.toStringAsFixed(1),
                          style: AppTextStyle.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Info Card: Kategori
            _buildInfoCard(
              icon: Icons.category_rounded,
              label: 'Kategori',
              value: material.category,
              color: AppColors.secondary,
            ),
            const SizedBox(height: AppSpacing.md),

            // Info Card: Harga
            _buildInfoCard(
              icon: Icons.money_rounded,
              label: 'Harga',
              value: 'Rp ${_formatNumber(material.price)} / ${_getUnit(material.category)}',
              color: AppColors.success,
            ),
            const SizedBox(height: AppSpacing.md),

            // Info Card: Stok
            _buildInfoCard(
              icon: Icons.inventory_2_rounded,
              label: 'Stok',
              value: '${_formatNumber(material.stock)} ${_getUnit(material.category)}',
              color: material.stock < 10 ? AppColors.danger : AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.md),

            // Deskripsi
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: AppBorderRadius.md,
                border: Border.all(color: AppColors.gray200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.description, size: 20, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Deskripsi',
                        style: AppTextStyle.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    material.description.isEmpty
                        ? 'Tidak ada deskripsi'
                        : material.description,
                    style: AppTextStyle.bodyMedium.copyWith(
                      color: AppColors.gray600,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadius.md,
        border: Border.all(color: AppColors.gray200),
        boxShadow: AppShadow.sm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: AppBorderRadius.md,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyle.caption.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
                Text(
                  value,
                  style: AppTextStyle.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Functions (copy dari home_page.dart)
  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'bata':
        return Icons.cabin_rounded;
      case 'besi':
        return Icons.hardware_rounded;
      case 'cat':
        return Icons.format_paint_rounded;
      case 'kayu':
        return Icons.forest_rounded;
      case 'semen':
        return Icons.construction_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  String _getUnit(String category) {
    switch (category.toLowerCase()) {
      case 'bata':
        return 'pcs';
      case 'besi':
        return 'btg';
      case 'cat':
        return 'kg';
      case 'kayu':
        return 'lbr';
      case 'semen':
        return 'sak';
      default:
        return 'unit';
    }
  }
}