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

  // Ambil daftar kategori unik
  List<String> get _categories {
    Set<String> cats = {'Semua'};
    for (var m in _materials) {
      cats.add(m.category);
    }
    return cats.toList();
  }

  // Filter material berdasarkan search dan kategori
  List<MaterialModel> get _filteredMaterials {
    var result = _materials;
    
    // Filter kategori
    if (_selectedCategory != 'Semua') {
      result = result.where((m) => m.category == _selectedCategory).toList();
    }
    
    // Filter search
    if (_searchQuery.isNotEmpty) {
      result = result.where((m) {
        return m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            m.category.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    
    return result;
  }

  // Statistik
  int get _totalMaterials => _materials.length;
  int get _lowStockCount => _materials.where((m) => m.stock < 10).length;
  int get _totalStockValue => _materials.fold(
        0,
        (sum, m) => sum + (m.price * m.stock),
      );
  int get _totalCategories => _materials.map((m) => m.category).toSet().length;

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
                  // Header Selamat Datang Admin
                  _buildHeader(),
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Stat Cards
                  _buildStatGrid(),
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Search Bar
                  _buildSearchBar(),
                  const SizedBox(height: AppSpacing.md),
                  
                  // Filter Kategori (Chips)
                  _buildCategoryFilter(),
                  const SizedBox(height: AppSpacing.md),
                  
                  // Result Count
                  Text(
                    '${_filteredMaterials.length} material ditemukan',
                    style: AppTextStyle.bodySmall.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  // List Material
                  _filteredMaterials.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filteredMaterials.length,
                          itemBuilder: (context, index) {
                            return _buildMaterialCard(_filteredMaterials[index]);
                          },
                        ),
                  
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
    );
  }

  // HEADER
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
            child: const Icon(
              Icons.admin_panel_settings,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang Di,',
                  style: AppTextStyle.bodyMedium.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Material Nyawit',
                  style: AppTextStyle.heading3.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'Kelola stok material bangunan dengan mudah',
                  style: AppTextStyle.caption.copyWith(
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // STAT GRID (4 card)
  Widget _buildStatGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          icon: Icons.inventory_2_rounded,
          title: 'Total Material',
          value: '$_totalMaterials',
          color: AppColors.primary,
        ),
        _buildStatCard(
          icon: Icons.warning_amber_rounded,
          title: 'Stok Rendah',
          value: '$_lowStockCount',
          color: AppColors.warning,
        ),
        _buildStatCard(
          icon: Icons.account_balance_wallet_rounded,
          title: 'Nilai Stok',
          value: 'Rp ${_formatNumber(_totalStockValue)}',
          color: AppColors.success,
        ),
        _buildStatCard(
          icon: Icons.category_rounded,
          title: 'Kategori',
          value: '$_totalCategories',
          color: AppColors.secondary,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
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
        mainAxisAlignment: MainAxisAlignment.center,
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
            style: AppTextStyle.bodySmall.copyWith(
              color: AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }

  // SEARCH BAR
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
          });
        },
        decoration: InputDecoration(
          hintText: 'Cari material...',
          hintStyle: AppTextStyle.bodyMedium.copyWith(
            color: AppColors.gray400,
          ),
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

  // FILTER KATEGORI (Chips)
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

  // EMPTY STATE
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.inbox,
            size: 64,
            color: AppColors.gray300,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _searchQuery.isNotEmpty || _selectedCategory != 'Semua'
                ? 'Tidak ada material yang cocok'
                : 'Belum ada material',
            style: AppTextStyle.bodyMedium.copyWith(
              color: AppColors.gray400,
            ),
          ),
          if (_searchQuery.isNotEmpty || _selectedCategory != 'Semua')
            TextButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedCategory = 'Semua';
                });
              },
              child: const Text('Reset Filter'),
            ),
        ],
      ),
    );
  }

  // CARD MATERIAL
  Widget _buildMaterialCard(MaterialModel material) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadius.md,
        boxShadow: AppShadow.sm,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppBorderRadius.md,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Icon & Stok Badge
              Stack(
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: AppBorderRadius.md,
                    ),
                    child: Icon(
                      _getCategoryIcon(material.category),
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                  if (material.stock < 10)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          '!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppSpacing.md),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.name,
                      style: AppTextStyle.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gray100,
                            borderRadius: AppBorderRadius.sm,
                          ),
                          child: Text(
                            material.category,
                            style: AppTextStyle.caption,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 12,
                          color: material.stock < 10
                              ? AppColors.danger
                              : AppColors.gray500,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'Stok: ${material.stock} ${_getUnit(material.category)}',
                          style: AppTextStyle.caption.copyWith(
                            color: material.stock < 10
                                ? AppColors.danger
                                : AppColors.gray500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Harga & Aksi
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rp ${_formatNumber(material.price)}',
                    style: AppTextStyle.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tombol Edit
                      InkWell(
                        onTap: () {
                          // TODO: Panggil edit bottom sheet
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fitur edit segera hadir'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: AppBorderRadius.sm,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 18,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Tombol Hapus
                      InkWell(
                        onTap: () {
                          _confirmDelete(material);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withValues(alpha: 0.1),
                            borderRadius: AppBorderRadius.sm,
                          ),
                          child: const Icon(
                            Icons.delete,
                            size: 18,
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // DELETE CONFIRMATION
  Future<void> _confirmDelete(MaterialModel material) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lg),
        title: const Text('Hapus Material'),
        content: Text('Yakin hapus "${material.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _apiService.deleteMaterial(material.id!);
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Material berhasil dihapus'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal hapus: $e'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    }
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