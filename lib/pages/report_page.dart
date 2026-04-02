import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../models/material_model.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final ApiService _apiService = ApiService();
  List<MaterialModel> _materials = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final materials = await _apiService.getMaterials();
      setState(() {
        _materials = materials;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  // ============ STATISTIK LANJUTAN ============
  
  int get _totalMaterials => _materials.length;
  
  int get _totalStockValue => _materials.fold(
        0,
        (sum, m) => sum + (m.price * m.stock),
      );
  
  int get _totalStockItems => _materials.fold(
        0,
        (sum, m) => sum + m.stock,
      );
  
  // Material dengan stok terbanyak
  MaterialModel? get _topStockMaterial {
    if (_materials.isEmpty) return null;
    return _materials.reduce((a, b) => a.stock > b.stock ? a : b);
  }
  
  // Material dengan nilai stok tertinggi
  MaterialModel? get _topValueMaterial {
    if (_materials.isEmpty) return null;
    return _materials.reduce((a, b) => 
      (a.price * a.stock) > (b.price * b.stock) ? a : b);
  }
  
  // Material dengan stok rendah (warning)
  List<MaterialModel> get _lowStockMaterials {
    return _materials.where((m) => m.stock < 10).toList();
  }
  
  // Kategori dengan jumlah material terbanyak
  MapEntry<String, int>? get _topCategory {
    if (_materials.isEmpty) return null;
    Map<String, int> categoryCount = {};
    for (var m in _materials) {
      categoryCount[m.category] = (categoryCount[m.category] ?? 0) + 1;
    }
    return categoryCount.entries.reduce((a, b) => a.value > b.value ? a : b);
  }
  
  // Total nilai stok per kategori
  Map<String, int> get _categoryStockValue {
    Map<String, int> result = {};
    for (var m in _materials) {
      result[m.category] = (result[m.category] ?? 0) + (m.price * m.stock);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(),
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Ringkasan Utama
                  _buildSummaryCards(),
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Material Terbaik & Terlaris
                  _buildTopMaterials(),
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Stok Menipis (Warning)
                  if (_lowStockMaterials.isNotEmpty)
                    _buildLowStockWarning(),
                  
                  // Statistik Kategori
                  const SizedBox(height: AppSpacing.xl),
                  _buildCategoryStats(),
                  
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppBorderRadius.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: AppBorderRadius.md,
                ),
                child: const Icon(
                  Icons.analytics,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Laporan Stok',
                      style: AppTextStyle.heading3.copyWith(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      'Ringkasan bisnis material bangunan',
                      style: AppTextStyle.caption.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.inventory_2_rounded,
                title: 'Total Material',
                value: '$_totalMaterials',
                subtitle: 'jenis material',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.money_rounded,
                title: 'Nilai Stok',
                value: 'Rp ${_formatNumber(_totalStockValue)}',
                subtitle: 'total keseluruhan',
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.inventory,
                title: 'Total Item',
                value: '${_formatNumber(_totalStockItems)}',
                subtitle: 'unit stok',
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.category_rounded,
                title: 'Kategori',
                value: '${_materials.map((m) => m.category).toSet().length}',
                subtitle: 'jenis kategori',
                color: AppColors.warning,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadius.md,
        boxShadow: AppShadow.sm,
        border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: AppBorderRadius.sm,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyle.heading2.copyWith(fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            title,
            style: AppTextStyle.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: AppTextStyle.caption.copyWith(
              color: AppColors.gray400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopMaterials() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🏆 Material Teratas',
          style: AppTextStyle.heading3,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildTopCard(
                title: 'Stok Terbanyak',
                material: _topStockMaterial,
                value: '${_topStockMaterial?.stock ?? 0} ${_getUnit(_topStockMaterial?.category ?? "")}',
                icon: Icons.inventory,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildTopCard(
                title: 'Nilai Tertinggi',
                material: _topValueMaterial,
                value: 'Rp ${_formatNumber((_topValueMaterial?.price ?? 0) * (_topValueMaterial?.stock ?? 0))}',
                icon: Icons.attach_money,
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildTopCard(
                title: 'Kategori Terbanyak',
                material: null,
                value: _topCategory?.key ?? '-',
                subtitle: '${_topCategory?.value ?? 0} material',
                icon: Icons.category,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildTopCard(
                title: 'Total Kategori',
                material: null,
                value: '${_materials.map((m) => m.category).toSet().length}',
                subtitle: 'jenis kategori',
                icon: Icons.grid_view,
                color: AppColors.warning,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopCard({
    required String title,
    required String value,
    MaterialModel? material,
    String? subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadius.md,
        boxShadow: AppShadow.sm,
        border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: AppBorderRadius.sm,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyle.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (material != null) ...[
            Text(
              material.name,
              style: AppTextStyle.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              material.category,
              style: AppTextStyle.caption.copyWith(
                color: AppColors.gray500,
              ),
            ),
          ],
          Text(
            value,
            style: AppTextStyle.heading2.copyWith(fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: AppTextStyle.caption.copyWith(
                color: AppColors.gray400,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLowStockWarning() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.danger.withValues(alpha: 0.05),
            borderRadius: AppBorderRadius.md,
            border: Border.all(color: AppColors.danger.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber, color: AppColors.danger),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '⚠️ Stok Menipis',
                    style: AppTextStyle.heading3.copyWith(
                      color: AppColors.danger,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '${_lowStockMaterials.length} material dengan stok di bawah 10 unit',
                style: AppTextStyle.bodySmall.copyWith(
                  color: AppColors.gray600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ..._lowStockMaterials.take(3).map((m) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 6, color: AppColors.danger),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '${m.name} - Sisa ${m.stock} ${_getUnit(m.category)}',
                        style: AppTextStyle.bodySmall,
                      ),
                    ),
                  ],
                ),
              )),
              if (_lowStockMaterials.length > 3)
                Text(
                  'dan ${_lowStockMaterials.length - 3} material lainnya',
                  style: AppTextStyle.caption.copyWith(
                    color: AppColors.gray400,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryStats() {
    final categoryValues = _categoryStockValue.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    if (categoryValues.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final maxValue = categoryValues.first.value;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📊 Nilai Stok per Kategori',
          style: AppTextStyle.heading3,
        ),
        const SizedBox(height: AppSpacing.md),
        ...categoryValues.map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getCategoryIcon(entry.key),
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        entry.key,
                        style: AppTextStyle.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Rp ${_formatNumber(entry.value)}',
                    style: AppTextStyle.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              LinearProgressIndicator(
                value: entry.value / maxValue,
                backgroundColor: AppColors.gray200,
                color: AppColors.primary,
                minHeight: 6,
                borderRadius: AppBorderRadius.sm,
              ),
            ],
          ),
        )),
      ],
    );
  }

  // HELPERS
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