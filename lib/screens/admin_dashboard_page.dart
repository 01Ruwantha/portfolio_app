import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';
import '../services/supabase_service.dart';
import '../models/project_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:typed_data';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!SupabaseService().isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 100),
            children: [
              const SizedBox(height: 140),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Digital Architect Control',
                        style: GoogleFonts.manrope(
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                          letterSpacing: -0.96,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Orchestrate your architectural vision and project data from a centralized interface.',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () async {
                          await SupabaseService().logout();
                          if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: Text(
                          'Logout',
                          style: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
                        ),
                      ),
                      const SizedBox(width: 24),
                      PrimaryButton(text: '+ Add New Project', onPressed: () => _showProjectDialog()),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 80),
              const DatabaseUsageCard(),
              Text(
                'Project Inventory',
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 32),
              FutureBuilder<List<ProjectModel>>(
                future: SupabaseService().fetchAllProjects(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                     return const Padding(
                       padding: EdgeInsets.symmetric(vertical: 40),
                       child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                     );
                  }
                  
                  final projects = snapshot.data ?? [];
                  if (projects.isEmpty) {
                    return _buildStaticInventory(); // fallback
                  }

                  return Column(
                    children: projects.map((p) => _buildInventoryItem(context, p)).toList(),
                  );
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
          const Positioned(
            top: 24,
            left: 0,
            right: 0,
            child: TopNavigation(),
          ),
        ],
      ),
    );
  }

  Future<void> _showProjectDialog({ProjectModel? project}) async {
    final titleController = TextEditingController(text: project?.title ?? '');
    final descriptionController = TextEditingController(text: project?.description ?? '');
    XFile? selectedCoverImage;
    List<XFile> selectedGalleryImages = [];
    bool isLoading = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.surfaceContainerHigh,
            title: Text(project == null ? 'Add Project' : 'Edit Project', style: GoogleFonts.manrope(color: AppColors.onSurface)),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: AppColors.onSurface),
                    decoration: const InputDecoration(labelText: 'Title', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    style: const TextStyle(color: AppColors.onSurface),
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Description', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          selectedCoverImage != null ? 'Cover: ${selectedCoverImage!.name}' : (project?.imageUrl != null ? 'Has existing cover' : 'No cover image'),
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.add_photo_alternate, size: 18),
                        label: const Text('Cover'),
                        onPressed: () async {
                          final picker = ImagePicker();
                          final image = await picker.pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            setDialogState(() => selectedCoverImage = image);
                          }
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          selectedGalleryImages.isNotEmpty 
                            ? '${selectedGalleryImages.length} gallery images selected' 
                            : (project != null && project.galleryUrls.isNotEmpty ? '${project.galleryUrls.length} existing gallery images' : 'No gallery images'),
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.collections, size: 18),
                        label: const Text('Gallery'),
                        onPressed: () async {
                          final picker = ImagePicker();
                          final images = await picker.pickMultiImage();
                          if (images.isNotEmpty) {
                            setDialogState(() => selectedGalleryImages = images);
                          }
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              if (!isLoading)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ElevatedButton(
                onPressed: isLoading ? null : () async {
                  setDialogState(() => isLoading = true);
                  
                  String? newImageUrl;
                  if (selectedCoverImage != null) {
                    final bytes = await selectedCoverImage!.readAsBytes();
                    final fileName = '${DateTime.now().millisecondsSinceEpoch}_cover_${selectedCoverImage!.name}';
                    newImageUrl = await SupabaseService().uploadImage(fileName, bytes);
                  }

                  List<String> newGalleryUrls = project?.galleryUrls ?? [];
                  if (selectedGalleryImages.isNotEmpty) {
                    List<String> uploadedUrls = [];
                    for (var image in selectedGalleryImages) {
                      final bytes = await image.readAsBytes();
                      final fileName = '${DateTime.now().millisecondsSinceEpoch}_gallery_${image.name}';
                      final url = await SupabaseService().uploadImage(fileName, bytes);
                      if (url != null) uploadedUrls.add(url);
                    }
                    newGalleryUrls = uploadedUrls;
                  }

                  try {
                    if (project == null) {
                      await SupabaseService().createProject(
                        titleController.text, 
                        descriptionController.text, 
                        imageUrl: newImageUrl,
                        galleryUrls: newGalleryUrls,
                      );
                    } else {
                      await SupabaseService().updateProject(
                        project.id, 
                        titleController.text, 
                        descriptionController.text, 
                        imageUrl: newImageUrl ?? project.imageUrl,
                        galleryUrls: newGalleryUrls,
                      );
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Project saved successfully!'), backgroundColor: Colors.green),
                      );
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to save project: $e'), backgroundColor: Colors.red),
                      );
                    }
                  } finally {
                    if (context.mounted) setDialogState(() => isLoading = false);
                  }
                  setState(() {}); // refresh the future builder
                },
                child: isLoading 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                    : const Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _deleteProject(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text('Delete Project', style: GoogleFonts.manrope(color: AppColors.onSurface)),
        content: Text('Are you sure you want to delete this project?', style: GoogleFonts.inter(color: AppColors.onSurface)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: const TextStyle(color: Colors.redAccent))),
        ],
      )
    );

    if (confirm == true) {
      await SupabaseService().deleteProject(id);
      setState(() {});
    }
  }

  Widget _buildStaticInventory() {
    return Column(
      children: [
        _buildInventoryItem(context, ProjectModel(id: '1', title: 'The Zenith Pavilion', description: 'Contemporary cultural hub featuring sustainable bamboo structures and passive cooling.', isHidden: false, avgRating: 0, totalRatings: 0)),
        _buildInventoryItem(context, ProjectModel(id: '2', title: 'Obsidian Retreat (Draft)', description: 'Private residential complex integrated into Icelandic volcanic topography.', isHidden: false, avgRating: 0, totalRatings: 0)),
        _buildInventoryItem(context, ProjectModel(id: '3', title: 'Metropolis Library', description: 'Brutalist redesign of a city landmark using smart-glass technology.', isHidden: false, avgRating: 0, totalRatings: 0)),
      ],
    );
  }

  Widget _buildInventoryItem(BuildContext context, ProjectModel project) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (project.imageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: project.imageUrl!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  width: 60,
                  height: 60,
                  color: AppColors.surfaceContainerHighest,
                  child: const Icon(Icons.broken_image, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 24),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  style: GoogleFonts.manrope(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  project.description,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () => _showProjectDialog(project: project),
                child: Text('Edit', style: GoogleFonts.inter(color: AppColors.primary)),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () => _deleteProject(project.id),
                child: Text('Delete', style: GoogleFonts.inter(color: Colors.redAccent)),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class DatabaseUsageCard extends StatelessWidget {
  const DatabaseUsageCard({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: Future.wait([
        SupabaseService().getDatabaseSize(),
        SupabaseService().getStorageUsage(),
      ]).then((values) => {
        'dbSize': values[0],
        'storageSize': values[1],
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
           return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
        }
        
        final dbSize = snapshot.data?['dbSize'] as int?;
        final storageSize = snapshot.data?['storageSize'] as int? ?? 0;

        // 500 MB limit for free tier
        const maxBytes = 500 * 1024 * 1024;
        
        // Database stats
        final usedDBMB = dbSize != null ? (dbSize / (1024 * 1024)).toStringAsFixed(2) : '---';
        final dbProgress = dbSize != null ? (dbSize / maxBytes).clamp(0.0, 1.0) : 0.0;

        // Storage stats
        final usedStorageMB = (storageSize / (1024 * 1024)).toStringAsFixed(2);
        final storageProgress = (storageSize / maxBytes).clamp(0.0, 1.0);

        return Container(
          margin: const EdgeInsets.only(bottom: 80),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outlineVariant.withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resource Utilization',
                      style: GoogleFonts.manrope(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Monitoring your database and storage against free tier limits.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(32),
                child: Row(
                  children: [
                    Expanded(child: _buildUsageItem('Database Size', usedDBMB, dbProgress, dbSize == null ? 'RPC function "get_db_size" missing' : null)),
                    const SizedBox(width: 48),
                    Expanded(child: _buildUsageItem('Storage Usage (Images)', usedStorageMB, storageProgress, null)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUsageItem(String title, String used, double progress, String? error) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface),
            ),
            if (error == null)
              Text(
                '$used MB / 500 MB',
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress > 0.9 ? Colors.redAccent : AppColors.primary,
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 8),
          Text(
            error,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.orangeAccent),
          ),
        ]
      ],
    );
  }
}
