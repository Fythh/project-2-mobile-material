import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../models/material_model.dart';

class MaterialDetailPage extends StatefulWidget {
  final MaterialModel material;
  final VoidCallback onMaterialUpdated;

  const MaterialDetailPage({
    super.key,
    required this.material,
    required this.onMaterialUpdated,
  });

  @override
  State<MaterialDetailPage> createState() => _MaterialDetailPageState();
}

class _MaterialDetailPageState extends State<MaterialDetailPage> {
  late MaterialModel _material;
  final ApiService _apiService = ApiService();
  bool _isEditing = false;
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _descriptionController;
  late TextEditingController _ratingController;

  final List<String> _categoryOptions = [
    'Bata', 'Besi', 'Cat', 'Kayu', 'Semen', 'Lainnya'
  ];

  @override
  void initState() {
    super.initState();
    _material = widget.material;
    _initControllers();
  }

  void _initControllers() {
    _nameController = TextEditingController(text: _material.name);
    _categoryController = TextEditingController(text: _material.category);
    _priceController = TextEditingController(text: _material.price.toString());
    _stockController = TextEditingController(text: _material.stock.toString());
    _descriptionController = TextEditingController(text: _material.description);
    _ratingController = TextEditingController(
      text: _material.rating?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  Future<void> _updateMaterial() async {
    setState(() => _isLoading = true);

    final updatedMaterial = MaterialModel(
      id: _material.id,
      name: _nameController.text.trim(),
      category: _categoryController.text.trim(),
      price: int.parse(_priceController.text.trim()),
      stock: int.parse(_stockController.text.trim()),
      description: _descriptionController.text.trim(),
      rating: _ratingController.text.trim().isEmpty
          ? null
          : double.parse(_ratingController.text.trim()),
      imageUrl: _material.imageUrl,
    );

    try {
      await _apiService.updateMaterial(_material.id!, updatedMaterial);
      setState(() {
        _material = updatedMaterial;
        _isEditing = false;
        _isLoading = false;
      });
      widget.onMaterialUpdated();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Material berhasil diupdate'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal update: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lg),
        title: const Text('Hapus Material'),
        content: Text('Apakah Anda yakin ingin menghapus "${_material.name}"?'),
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
      setState(() => _isLoading = true);
      try {
        await _apiService.deleteMaterial(_material.id!, imageUrl: _material.imageUrl);
        widget.onMaterialUpdated();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Material berhasil dihapus'),
              backgroundColor: AppColors.success,
            ),
          );
        }
        Navigator.pop(context);
      } catch (e) {
        setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Material' : 'Detail Material'),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.check, color: Colors.white),
              onPressed: _isLoading ? null : _updateMaterial,
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _initControllers();
                });
              },
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: _confirmDelete,
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: _isEditing ? _buildEditForm() : _buildDetailView(),
            ),
    );
  }

  // ============ VIEW MODE (DENGAN GAMBAR) ============
  Widget _buildDetailView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // GAMBAR
        Center(
          child: ClipRRect(
            borderRadius: AppBorderRadius.lg,
            child: _material.imageUrl != null && _material.imageUrl!.isNotEmpty
                ? Image.network(
                    _material.imageUrl!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: AppBorderRadius.lg,
                      ),
                      child: Icon(
                        _getCategoryIcon(_material.category),
                        size: 80,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: AppBorderRadius.lg,
                      boxShadow: AppShadow.md,
                    ),
                    child: Icon(
                      _getCategoryIcon(_material.category),
                      size: 80,
                      color: AppColors.primary,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Nama & Rating
        Row(
          children: [
            Expanded(
              child: Text(
                _material.name,
                style: AppTextStyle.heading2,
              ),
            ),
            if ((_material.rating ?? 0) > 0)
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
                      _material.rating!.toStringAsFixed(1),
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
          value: _material.category,
          color: AppColors.secondary,
        ),
        const SizedBox(height: AppSpacing.md),

        // Info Card: Harga
        _buildInfoCard(
          icon: Icons.money_rounded,
          label: 'Harga',
          value: 'Rp ${_formatNumber(_material.price)}',
          color: AppColors.success,
        ),
        const SizedBox(height: AppSpacing.md),

        // Info Card: Stok
        _buildInfoCard(
          icon: Icons.inventory_2_rounded,
          label: 'Stok',
          value: '${_material.stock}',
          color: _material.stock < 10 ? AppColors.danger : AppColors.primary,
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
                _material.description.isEmpty
                    ? 'Tidak ada deskripsi'
                    : _material.description,
                style: AppTextStyle.bodyMedium.copyWith(
                  color: AppColors.gray600,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============ EDIT MODE ============
  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nama Material',
            prefixIcon: Icon(Icons.label),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        DropdownButtonFormField<String>(
          value: _categoryController.text,
          decoration: const InputDecoration(
            labelText: 'Kategori',
            prefixIcon: Icon(Icons.category),
            border: OutlineInputBorder(),
          ),
          items: _categoryOptions.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _categoryController.text = value!;
            });
          },
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  prefixIcon: Icon(Icons.money),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'Stok',
                  prefixIcon: Icon(Icons.inventory),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _ratingController,
          decoration: const InputDecoration(
            labelText: 'Rating (1-5)',
            prefixIcon: Icon(Icons.star),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Deskripsi',
            prefixIcon: Icon(Icons.description),
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
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

  // ============ HELPERS ============
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
}