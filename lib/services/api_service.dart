import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/material_model.dart';

class ApiService {
  final SupabaseClient supabase = Supabase.instance.client;
  final String tableName = 'materials'; // Nama tabel yang akan dibuat

  // CREATE
  Future<MaterialModel> createMaterial(MaterialModel material) async {
    final response = await supabase
        .from(tableName)
        .insert(material.toJson())
        .select()
        .single();
    
    return MaterialModel.fromJson(response);
  }

  // READ (GET ALL)
  Future<List<MaterialModel>> getMaterials() async {
    final response = await supabase
        .from(tableName)
        .select()
        .order('id', ascending: false);
    
    return (response as List)
        .map((json) => MaterialModel.fromJson(json))
        .toList();
  }

  // UPDATE
  Future<MaterialModel> updateMaterial(int id, MaterialModel material) async {
    final response = await supabase
        .from(tableName)
        .update(material.toJson())
        .eq('id', id)
        .select()
        .single();
    
    return MaterialModel.fromJson(response);
  }

  // DELETE
  Future<void> deleteMaterial(int id) async {
    await supabase
        .from(tableName)
        .delete()
        .eq('id', id);
  }
}