import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';
import '../services/supabase_service.dart';
import '../models/project_model.dart';
import '../models/comment_model.dart';

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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            bottom: -300,
            right: -200,
            child: Container(
              width: 800,
              height: 800,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.03),
              ),
            ),
          ),
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 100),
            children: [
              const SizedBox(height: 160),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Command Center',
                        style: GoogleFonts.manrope(
                          fontSize: 64,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurface,
                          letterSpacing: -1.28,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Orchestrate your architectural vision and dynamic project data.',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          color: AppColors.onSurfaceVariant.withOpacity(0.7),
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
                          'Logout Session',
                          style: GoogleFonts.inter(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
                      PrimaryButton(
                        text: '+ New Project', 
                        onPressed: () => _showProjectDialog(),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 80),
              const DatabaseUsageCard(),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Portfolio Inventory',
                    style: GoogleFonts.manrope(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                      letterSpacing: -0.64,
                    ),
                  ),
                  Text(
                    'Managed via Supabase Storage',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.outlineVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              FutureBuilder<List<ProjectModel>>(
                future: SupabaseService().fetchAllProjects(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                     return const Padding(
                       padding: EdgeInsets.symmetric(vertical: 80),
                       child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                     );
                  }
                  
                  final projects = snapshot.data ?? [];
                  if (projects.isEmpty) {
                    return _buildStaticInventory();
                  }

                  return Column(
                    children: projects.map((p) => _buildInventoryItem(context, p)).toList(),
                  );
                },
              ),
              const SizedBox(height: 120),
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

  Future<void> _showCommentsDialog(ProjectModel project) async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surfaceContainerHigh,
              title: Text('Comments: ${project.title}', style: GoogleFonts.manrope(color: AppColors.onSurface)),
              content: SizedBox(
                width: 600,
                height: 400,
                child: FutureBuilder<List<CommentModel>>(
                  future: SupabaseService().fetchComments(project.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final comments = snapshot.data ?? [];
                    if (comments.isEmpty) {
                      return Center(child: Text('No comments found.', style: GoogleFonts.inter(color: AppColors.onSurfaceVariant)));
                    }
                    return ListView.separated(
                      itemCount: comments.length,
                      separatorBuilder: (context, index) => Divider(color: AppColors.outlineVariant.withOpacity(0.1)),
                      itemBuilder: (context, index) {
                        final c = comments[index];
                        return ListTile(
                          title: Row(
                            children: [
                              Text(c.authorName, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                              const SizedBox(width: 8),
                              Row(
                                children: List.generate(5, (i) => Icon(
                                  i < c.rating ? Icons.star : Icons.star_border,
                                  size: 14,
                                  color: AppColors.primary,
                                )),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.content, style: GoogleFonts.inter(color: AppColors.onSurfaceVariant)),
                              const SizedBox(height: 4),
                              Text('${c.createdAt.day}/${c.createdAt.month}/${c.createdAt.year}', style: GoogleFonts.inter(fontSize: 10, color: AppColors.outlineVariant)),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: AppColors.surfaceContainerHigh,
                                  title: Text('Delete Comment', style: GoogleFonts.manrope(color: AppColors.onSurface)),
                                  content: Text('Are you sure you want to delete this comment?', style: GoogleFonts.inter(color: AppColors.onSurface)),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: const TextStyle(color: Colors.redAccent))),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await SupabaseService().deleteComment(c.id);
                                setDialogState(() {}); // Refresh the future builder in dialog
                                setState(() {}); // Refresh the dashboard (for rating updates)
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
              ],
            );
          }
        );
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
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              image: project.imageUrl != null 
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(project.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: project.imageUrl == null 
                ? const Icon(Icons.architecture, color: AppColors.outlineVariant) 
                : null,
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      project.title,
                      style: GoogleFonts.manrope(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    if (project.isHidden) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'DRAFT',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  project.description,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppColors.onSurfaceVariant.withOpacity(0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          Row(
            children: [
              IconButton(
                onPressed: () => _showCommentsDialog(project),
                icon: const Icon(Icons.chat_bubble_outline, color: AppColors.onSurfaceVariant),
                tooltip: 'Manage Comments',
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _showProjectDialog(project: project),
                icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                tooltip: 'Edit Project',
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _deleteProject(project.id),
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                tooltip: 'Delete Project',
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

        return GlassmorphismContainer(
          borderRadius: 32,
          padding: const EdgeInsets.all(48),
          color: AppColors.surfaceContainerHigh.withOpacity(0.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resource Infrastructure',
                        style: GoogleFonts.manrope(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurface,
                          letterSpacing: -0.64,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Monitoring database and storage utilization against high-performance limits.',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: AppColors.onSurfaceVariant.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bolt, color: AppColors.primary, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Tier: Free/Open',
                          style: GoogleFonts.inter(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 64),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildUsageItem('Database Cluster', usedDBMB, dbProgress, dbSize == null ? 'RPC logic pending' : null)),
                  const SizedBox(width: 80),
                  Expanded(child: _buildUsageItem('Cloud Storage', usedStorageMB, storageProgress, null)),
                ],
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
