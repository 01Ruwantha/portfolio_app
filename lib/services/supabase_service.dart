import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/project_model.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Singletons pattern
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  /// Auth: Login Admin
  Future<AuthResponse> loginAdmin(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Auth: Logout
  Future<void> logout() async {
    await _client.auth.signOut();
  }

  /// Check Authentication Status
  bool get isAuthenticated => _client.auth.currentSession != null;

  /// Fetch public projects
  Future<List<ProjectModel>> fetchVisibleProjects() async {
    final response = await _client
        .from('projects')
        .select()
        .eq('is_hidden', false)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((e) => ProjectModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetch all projects (For Admins)
  Future<List<ProjectModel>> fetchAllProjects() async {
    final response = await _client
        .from('projects')
        .select()
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((e) => ProjectModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  /// Add a new project
  Future<void> createProject(String title, String description, {String? imageUrl, List<String>? galleryUrls}) async {
    await _client.from('projects').insert({
      'title': title,
      'description': description,
      if (imageUrl != null) 'image_url': imageUrl,
      if (galleryUrls != null) 'gallery_urls': galleryUrls,
    });
  }

  /// Update an existing project
  Future<void> updateProject(String id, String title, String description, {String? imageUrl, List<String>? galleryUrls}) async {
    await _client.from('projects').update({
      'title': title,
      'description': description,
      if (imageUrl != null) 'image_url': imageUrl,
      if (galleryUrls != null) 'gallery_urls': galleryUrls,
    }).eq('id', id);
  }

  /// Delete a project
  Future<void> deleteProject(String id) async {
    await _client.from('projects').delete().eq('id', id);
  }

  /// Get Database Size in bytes. Returns null if RPC fails.
  Future<int?> getDatabaseSize() async {
    try {
      final response = await _client.rpc('get_db_size');
      if (response == null) return null;
      return (response as num).toInt();
    } catch (e) {
      print('Database Size Error: $e');
      return null;
    }
  }

  /// Get Storage Usage (total size of project_images bucket in bytes)
  Future<int> getStorageUsage() async {
    try {
      final List<FileObject> files = await _client.storage.from('project_images').list(path: 'public');
      int totalSize = 0;
      for (var file in files) {
        totalSize += file.metadata?['size'] as int? ?? 0;
      }
      return totalSize;
    } catch (e) {
      print('Storage Usage Error: $e');
      return 0;
    }
  }

  /// Upload an image to the 'project_images' bucket and return its public URL.
  Future<String?> uploadImage(String fileName, Uint8List fileBytes) async {
    try {
      final path = 'public/$fileName';
      final response = await _client.storage.from('project_images').uploadBinary(
        path,
        fileBytes,
        fileOptions: const FileOptions(upsert: true),
      );
      
      if (response.isEmpty) {
        print('Upload response was empty for $fileName');
        return null;
      }

      final publicUrl = _client.storage.from('project_images').getPublicUrl(path);
      print('Successfully uploaded $fileName. URL: $publicUrl');
      return publicUrl;
    } on StorageException catch (e) {
      print('Storage Error: ${e.message} (Code: ${e.statusCode})');
      return null;
    } catch (e) {
      print('Unexpected Upload error: $e');
      return null;
    }
  }
}
