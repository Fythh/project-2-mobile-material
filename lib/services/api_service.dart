import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/material_model.dart';
import 'dart:io';

class ApiService {
  final SupabaseClient supabase = Supabase.instance.client;
  final String tableName = 'materials';
  final String storageBucket = 'material-images';

  // ============ UPLOAD GAMBAR ============
Future<String?> uploadImage(File imageFile, String fileName) async {
  try {
    print('=== UPLOAD START ===');
    print('Bucket: $storageBucket');
    print('File name: $fileName');
    
    await supabase.storage
        .from(storageBucket)
        .upload(fileName, imageFile, fileOptions: const FileOptions(cacheControl: '3600'));

    final publicUrl = supabase.storage.from(storageBucket).getPublicUrl(fileName);
    print('Public URL: $publicUrl');
    print('=== UPLOAD SUCCESS ===');
    
    return publicUrl;
  } catch (e) {
    print('=== UPLOAD ERROR ===');
    print('Error: $e');
    return null;
  }
}

  // ============ HAPUS GAMBAR ============
  Future<void> deleteImage(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) return;
    
    try {
      final fileName = imageUrl.split('/').last;
      await supabase.storage.from(storageBucket).remove([fileName]);
    } catch (e) {
      print('Error delete image: $e');
    }
  }

  // ============ CREATE ============
  Future<MaterialModel> createMaterial(MaterialModel material, {File? imageFile}) async {
    String? imageUrl;
    
    if (imageFile != null) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      imageUrl = await uploadImage(imageFile, fileName);
    }
    
    final materialWithImage = MaterialModel(
      id: material.id,
      name: material.name,
      category: material.category,
      price: material.price,
      stock: material.stock,
      description: material.description,
      rating: material.rating,
      imageUrl: imageUrl,
    );
    
    final response = await supabase
        .from(tableName)
        .insert(materialWithImage.toJson())
        .select()
        .single();
    
    return MaterialModel.fromJson(response);
  }

  // ============ READ ============
  Future<List<MaterialModel>> getMaterials() async {
    final response = await supabase
        .from(tableName)
        .select('*')
        .order('id', ascending: false);
    
    return (response as List)
        .map((json) => MaterialModel.fromJson(json))
        .toList();
  }

  // ============ UPDATE ============
  Future<MaterialModel> updateMaterial(int id, MaterialModel material, {File? imageFile}) async {
  String? imageUrl = material.imageUrl;
  
  if (imageFile != null) {
    if (material.imageUrl != null && material.imageUrl!.isNotEmpty) {
      await deleteImage(material.imageUrl);
    }
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
    imageUrl = await uploadImage(imageFile, fileName);
  }
  
  final updatedMaterial = MaterialModel(
    id: material.id,
    name: material.name,
    category: material.category,
    price: material.price,
    stock: material.stock,
    description: material.description,
    rating: material.rating,
    imageUrl: imageUrl,
  );
  
  final response = await supabase
      .from(tableName)
      .update(updatedMaterial.toJson())
      .eq('id', id)
      .select()
      .single();
  
  return MaterialModel.fromJson(response);
}

  // ============ DELETE ============
  Future<void> deleteMaterial(int id, {String? imageUrl}) async {
    await deleteImage(imageUrl);
    await supabase
        .from(tableName)
        .delete()
        .eq('id', id);
  }
}