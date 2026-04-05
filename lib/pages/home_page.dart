import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../models/material_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  List<MaterialModel> _materials = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  bool _isLowStockFilterActive = false;  // 👈 TAMBAHKAN INI

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

  List<String> get _categories {
    Set<String> cats = {'Semua'};
    for (var m in _materials) {
      cats.add(m.category);
    }
    return cats.toList();
  }

  List<MaterialModel> get _filteredMaterials {
    var result = _materials;
    
    // Filter by low stock (aktif)
    if (_isLowStockFilterActive) {
      result = result.where((m) => m.stock < 10).toList();
    }
    
    // Filter by category
    if (_selectedCategory != 'Semua') {
      result = result.where((m) => m.category == _selectedCategory).toList();
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      result = result.where((m) {
        return m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            m.category.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    
    return result;
  }

  int get _totalMaterials => _materials.length;
  int get _lowStockCount => _materials.where((m) => m.stock < 10).length;
  int get _totalCategories => _materials.map((m) => m.category).toSet().length;

  // 👈 TAMBAHKAN FUNGSI INI
  void _applyLowStockFilter() {
    setState(() {
      if (_isLowStockFilterActive) {
        // Jika sudah aktif, reset semua filter
        _resetAllFilters();
      } else {
        // Aktifkan filter low stock, reset filter lainnya biar konsisten
        _isLowStockFilterActive = true;
        _selectedCategory = 'Semua';
        _searchQuery = '';
      }
    });
  }

  // 👈 TAMBAHKAN FUNGSI INI
  void _resetAllFilters() {
    _isLowStockFilterActive = false;
    _selectedCategory = 'Semua';
    _searchQuery = '';
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
                  _buildHeader(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildStatGrid(),
                  const SizedBox(height: AppSpacing.lg),
                  
                  // 👈 TAMBAHKAN INDIKATOR FILTER AKTIF
                  if (_isLowStockFilterActive || _selectedCategory != 'Semua' || _searchQuery.isNotEmpty)
                    _buildActiveFilterChip(),
                  
                  _buildSearchBar(),
                  const SizedBox(height: AppSpacing.md),
                  _buildCategoryFilter(),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '${_filteredMaterials.length} material ditemukan',
                    style: AppTextStyle.bodySmall.copyWith(color: AppColors.gray500),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _filteredMaterials.isEmpty
                      ? _buildEmptyState()
                      : Column(
                          children: _filteredMaterials.map((material) {
                            return _buildMaterialCard(material);
                          }).toList(),
                        ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
    );
  }

  // 👈 TAMBAHKAN WIDGET INI
  Widget _buildActiveFilterChip() {
    String filterText = '';
    if (_isLowStockFilterActive) filterText = 'Stok Rendah (<10)';
    else if (_selectedCategory != 'Semua') filterText = 'Kategori: $_selectedCategory';
    else if (_searchQuery.isNotEmpty) filterText = 'Pencarian: $_searchQuery';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: AppBorderRadius.md,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_alt, size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              filterText,
              style: AppTextStyle.bodySmall.copyWith(color: AppColors.primary),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: _resetAllFilters,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(100), // ✅ PAKAI INI
                ),
                child: const Icon(Icons.close, size: 12, color: Colors.white),
              ),
            ),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: AppBorderRadius.md,
            ),
            child: const Icon(Icons.admin_panel_settings, size: 32, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang Di,',
                  style: AppTextStyle.bodyMedium.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  'MaterialKu',
                  style: AppTextStyle.heading3.copyWith(color: Colors.white, fontSize: 20),
                ),
                Text(
                  'Kelola stok material bangunan dengan mudah',
                  style: AppTextStyle.caption.copyWith(color: Colors.white60),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.inventory_2_rounded,
            title: 'Total Material',
            value: '$_totalMaterials',
            color: AppColors.primary,
            onTap: _resetAllFilters, // 👈 TAMBAHKAN
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStatCard(
            icon: Icons.warning_amber_rounded,
            title: 'Stok Rendah',
            value: '$_lowStockCount',
            color: AppColors.warning,
            onTap: _applyLowStockFilter, // 👈 TAMBAHKAN - INI YANG PENTING!
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStatCard(
            icon: Icons.category_rounded,
            title: 'Kategori',
            value: '$_totalCategories',
            color: AppColors.secondary,
            onTap: _resetAllFilters, // 👈 TAMBAHKAN
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    VoidCallback? onTap, // 👈 TAMBAHKAN PARAMETER INI
  }) {
    return GestureDetector( // 👈 BUNGKUS DENGAN GESTUREDETECTOR
      onTap: onTap,
      child: Container(
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
              style: AppTextStyle.heading2.copyWith(fontSize: 18),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              title,
              style: AppTextStyle.bodySmall.copyWith(color: AppColors.gray500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: AppBorderRadius.md,
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            // Reset filter low stock kalo user ngetik manual
            if (_isLowStockFilterActive) {
              _isLowStockFilterActive = false;
            }
          });
        },
        decoration: InputDecoration(
          hintText: 'Cari material...',
          hintStyle: AppTextStyle.bodyMedium.copyWith(color: AppColors.gray400),
          prefixIcon: const Icon(Icons.search, color: AppColors.gray400),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.gray400),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(AppSpacing.md),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return FilterChip(
            label: Text(category),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedCategory = category;
                // Reset low stock filter kalo user milih kategori
                if (_isLowStockFilterActive) {
                  _isLowStockFilterActive = false;
                }
              });
            },
            backgroundColor: AppColors.gray100,
            selectedColor: AppColors.primary.withValues(alpha: 0.2),
            checkmarkColor: AppColors.primary,
            labelStyle: TextStyle(
              color: isSelected ? AppColors.primary : AppColors.gray600,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
            shape: StadiumBorder(
              side: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.inbox, size: 64, color: AppColors.gray300),
          const SizedBox(height: AppSpacing.md),
          Text(
            _searchQuery.isNotEmpty || _selectedCategory != 'Semua' || _isLowStockFilterActive
                ? 'Tidak ada material yang cocok'
                : 'Belum ada material',
            style: AppTextStyle.bodyMedium.copyWith(color: AppColors.gray400),
          ),
          if (_searchQuery.isNotEmpty || _selectedCategory != 'Semua' || _isLowStockFilterActive)
            TextButton(
              onPressed: _resetAllFilters, // 👈 PAKAI FUNGSI RESET
              child: const Text('Reset Filter'),
            ),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(MaterialModel material) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadius.md,
        boxShadow: AppShadow.sm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: AppBorderRadius.md,
              child: material.imageUrl != null && material.imageUrl!.isNotEmpty
                  ? Image.network(
                      material.imageUrl!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: AppBorderRadius.md,
                        ),
                        child: Icon(_getCategoryIcon(material.category), color: AppColors.primary),
                      ),
                    )
                  : Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: AppBorderRadius.md,
                      ),
                      child: Icon(_getCategoryIcon(material.category), color: AppColors.primary),
                    ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    material.name,
                    style: AppTextStyle.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius: AppBorderRadius.sm,
                        ),
                        child: Text(material.category, style: AppTextStyle.caption),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 12,
                        color: material.stock < 10 ? AppColors.danger : AppColors.gray500,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'Stok: ${material.stock}',
                        style: AppTextStyle.caption.copyWith(
                          color: material.stock < 10 ? AppColors.danger : AppColors.gray500,
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
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'bata': return Icons.cabin_rounded;
      case 'besi': return Icons.hardware_rounded;
      case 'cat': return Icons.format_paint_rounded;
      case 'kayu': return Icons.forest_rounded;
      case 'semen': return Icons.construction_rounded;
      default: return Icons.category_rounded;
    }
  }
}