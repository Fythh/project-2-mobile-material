import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../models/material_model.dart';
import 'material_detail_page.dart';

class MaterialListPage extends StatefulWidget {
  const MaterialListPage({super.key});

  @override
  State<MaterialListPage> createState() => _MaterialListPageState();
}

class _MaterialListPageState extends State<MaterialListPage> {
  final ApiService _apiService = ApiService();
  List<MaterialModel> _materials = [];
  bool _isLoading = true;
  String _searchQuery = '';

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

  List<MaterialModel> get _filteredMaterials {
    if (_searchQuery.isEmpty) return _materials;
    return _materials.where((m) {
      return m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.category.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _showAddBottomSheet() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => MaterialFormBottomSheet(
        onSave: (material, imageFile) async {
          try {
            await _apiService.createMaterial(material, imageFile: imageFile);
            await _loadData();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Material berhasil ditambahkan'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gagal menambah: $e'),
                  backgroundColor: AppColors.danger,
                ),
              );
            }
          }
        },
      ),
    );
    
    if (result == true && mounted) {
      await _loadData();
    }
  }

  Future<void> _showEditBottomSheet(MaterialModel material) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => MaterialFormBottomSheet(
        material: material,
        isEdit: true,
        onSave: (updatedMaterial, imageFile) async {
          try {
            await _apiService.updateMaterial(material.id!, updatedMaterial, imageFile: imageFile);
            await _loadData();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Material berhasil diupdate'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gagal mengupdate: $e'),
                  backgroundColor: AppColors.danger,
                ),
              );
            }
          }
        },
      ),
    );
    
    if (result == true && mounted) {
      await _loadData();
    }
  }

  Future<void> _confirmDelete(MaterialModel material) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lg),
        title: const Text('Hapus Material'),
        content: Text('Apakah Anda yakin ingin menghapus "${material.name}"?'),
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
        await _apiService.deleteMaterial(material.id!, imageUrl: material.imageUrl);
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
              content: Text('Gagal menghapus: $e'),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Container(
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
                  hintStyle: AppTextStyle.bodyMedium.copyWith(color: AppColors.gray400),
                  prefixIcon: const Icon(Icons.search, color: AppColors.gray400),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredMaterials.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox, size: 64, color: AppColors.gray300),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              _searchQuery.isEmpty ? 'Belum ada material' : 'Tidak ada material yang cocok',
                              style: AppTextStyle.bodyMedium.copyWith(color: AppColors.gray400),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          itemCount: _filteredMaterials.length,
                          itemBuilder: (context, index) {
                            final material = _filteredMaterials[index];
                            return _buildMaterialCard(material);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBottomSheet,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: AppBorderRadius.md,
        child: InkWell(
          borderRadius: AppBorderRadius.md,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MaterialDetailPage(
                  material: material,
                  onMaterialUpdated: _loadData,
                ),
              ),
            );
          },
          onLongPress: () => _showEditBottomSheet(material),
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
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: AppBorderRadius.md,
                              ),
                              child: Icon(
                                _getCategoryIcon(material.category),
                                color: AppColors.primary,
                                size: 28,
                              ),
                            );
                          },
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: AppBorderRadius.md,
                          ),
                          child: Icon(
                            _getCategoryIcon(material.category),
                            color: AppColors.primary,
                            size: 28,
                          ),
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
                Text(
                  'Rp ${_formatNumber(material.price)}',
                  style: AppTextStyle.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(Icons.chevron_right, size: 20, color: AppColors.gray400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
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

// ============ BOTTOM SHEET FORM (CREATE & EDIT) ============
class MaterialFormBottomSheet extends StatefulWidget {
  final MaterialModel? material;
  final bool isEdit;
  final Function(MaterialModel, File?) onSave;

  const MaterialFormBottomSheet({
    super.key,
    this.material,
    this.isEdit = false,
    required this.onSave,
  });

  @override
  State<MaterialFormBottomSheet> createState() => _MaterialFormBottomSheetState();
}

class _MaterialFormBottomSheetState extends State<MaterialFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _descriptionController;
  late TextEditingController _ratingController;
  File? _selectedImage;
  bool _isLoading = false;

  final List<String> _categoryOptions = [
    'Bata', 'Besi', 'Cat', 'Kayu', 'Semen', 'Lainnya'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.material?.name ?? '');
    _categoryController = TextEditingController(text: widget.material?.category ?? 'Bata');
    _priceController = TextEditingController(
      text: widget.material?.price.toString() ?? '',
    );
    _stockController = TextEditingController(
      text: widget.material?.stock.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.material?.description ?? '',
    );
    _ratingController = TextEditingController(
      text: widget.material?.rating?.toString() ?? '',
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final material = MaterialModel(
      id: widget.material?.id,
      name: _nameController.text.trim(),
      category: _categoryController.text.trim(),
      price: int.parse(_priceController.text.trim()),
      stock: int.parse(_stockController.text.trim()),
      description: _descriptionController.text.trim(),
      rating: _ratingController.text.trim().isEmpty
          ? null
          : double.parse(_ratingController.text.trim()),
      imageUrl: widget.material?.imageUrl,
    );

    final imageToSend = (!widget.isEdit && _selectedImage != null) ? _selectedImage : null;
    await widget.onSave(material, imageToSend);
    
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: AppBorderRadius.sm,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              widget.isEdit ? '✏️ Edit Material' : '➕ Tambah Material',
              style: AppTextStyle.heading3,
            ),
            const SizedBox(height: AppSpacing.lg),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  if (!widget.isEdit) ...[
                    InkWell(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius: AppBorderRadius.md,
                          border: Border.all(color: AppColors.gray300),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _selectedImage != null ? Icons.check_circle : Icons.add_photo_alternate,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                _selectedImage != null
                                    ? 'Gambar dipilih: ${_selectedImage!.path.split('/').last}'
                                    : 'Pilih gambar dari galeri (opsional)',
                                style: AppTextStyle.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Material',
                      prefixIcon: Icon(Icons.label),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama material wajib diisi';
                      }
                      return null;
                    },
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Kategori wajib dipilih';
                      }
                      return null;
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
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Harga wajib diisi';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Harga harus angka';
                            }
                            return null;
                          },
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
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Stok wajib diisi';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Stok harus angka';
                            }
                            return null;
                          },
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
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        final rating = double.tryParse(value);
                        if (rating == null || rating < 0 || rating > 5) {
                          return 'Rating harus antara 0-5';
                        }
                      }
                      return null;
                    },
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
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppBorderRadius.md,
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              widget.isEdit ? 'Update' : 'Simpan',
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}