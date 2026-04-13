import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';
import '../models/project_model.dart';
import '../models/comment_model.dart';
import '../services/supabase_service.dart';

class ProjectDetailsPage extends StatefulWidget {
  const ProjectDetailsPage({super.key});

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  final SupabaseService _supabaseService = SupabaseService();
  List<CommentModel> _comments = [];
  bool _isLoading = true;
  int _selectedRating = 5;
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadComments();
    });
  }

  Future<void> _loadComments() async {
    final project = ModalRoute.of(context)?.settings.arguments as ProjectModel?;
    if (project != null) {
      try {
        final comments = await _supabaseService.fetchComments(project.id);
        if (mounted) {
          setState(() {
            _comments = comments;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitReview(String projectId) async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      await _supabaseService.addComment(
        projectId: projectId,
        rating: _selectedRating,
        content: _commentController.text.trim(),
        authorName: _nameController.text.trim(),
        authorEmail: _emailController.text.trim(),
      );
      _commentController.clear();
      _nameController.clear();
      _emailController.clear();
      _selectedRating = 5;
      await _loadComments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      await _supabaseService.deleteComment(commentId);
      await _loadComments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting comment: $e')),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    // Retrieve the passed ProjectModel
    final project = ModalRoute.of(context)?.settings.arguments as ProjectModel?;
    
    // Fallback values if navigated directly without an argument
    final String displayTitle = project?.title ?? 'The Luminescent Monolith';
    final String displayDescription = project?.description ?? 
        'This project redefines the intersection of brutalist geometry and digital transparency. Located in the heart of the metropolitan district, the Monolith serves as a beacon of sustainable innovation, utilizing a custom-engineered photoluminescent glass skin that harvests solar energy by day and emits a soft, ethereal glow by night.';

    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 100),
            children: [
              const SizedBox(height: 160),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      displayTitle,
                      style: GoogleFonts.manrope(
                        fontSize: 64,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                        letterSpacing: -1.28,
                      ),
                    ),
                  ),
                  if (project != null && project.totalRatings > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: AppColors.onPrimaryContainer, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '${project.avgRating.toStringAsFixed(1)} (${project.totalRatings} reviews)',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 48),
              Container(
                height: 500,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: project?.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: CachedNetworkImage(
                        imageUrl: project!.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: AppColors.surfaceContainerHigh),
                        errorWidget: (context, url, error) => const Icon(Icons.error_outline),
                      ),
                    )
                  : null,
              ),
              const SizedBox(height: 80),
              // Description Section (Full width now)
              Text(
                displayDescription,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  color: AppColors.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 80),
              const SizedBox(height: 100),
              if (project != null && project.galleryUrls.isNotEmpty) ...[
                Text(
                  'Project Gallery',
                  style: GoogleFonts.manrope(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 48),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: project.galleryUrls.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl: project.galleryUrls[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: AppColors.surfaceContainerHigh),
                        errorWidget: (context, url, error) => const Icon(Icons.error_outline),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 100),
              ],
              Divider(color: AppColors.outlineVariant.withOpacity(0.15)),
              const SizedBox(height: 100),
              Text(
                'Project Discussions',
                style: GoogleFonts.manrope(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 48),
              // Comments List (Moved up)
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_comments.isEmpty)
                Center(
                  child: Text(
                    'No reviews yet. Be the first to review!',
                    style: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _comments.length,
                  itemBuilder: (context, index) {
                    final comment = _comments[index];
                    return _buildComment(comment);
                  },
                ),
              const SizedBox(height: 80),
              // Add Review Section
              if (project != null) ...[
                Text(
                  'Your Details',
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        style: GoogleFonts.inter(color: AppColors.onSurface),
                        decoration: _inputDecoration('Your Name'),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: TextField(
                        controller: _emailController,
                        style: GoogleFonts.inter(color: AppColors.onSurface),
                        decoration: _inputDecoration('Email Address'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  'Post a Comment',
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _commentController,
                  maxLines: 4,
                  style: GoogleFonts.inter(color: AppColors.onSurface),
                  decoration: _inputDecoration('Share your thoughts about this project...'),
                ),
                const SizedBox(height: 64),
                Text(
                  'Rate this Project',
                  style: GoogleFonts.manrope(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Based on ${project.totalRatings} architect reviews',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () => setState(() => _selectedRating = index + 1),
                      icon: Icon(
                        index < _selectedRating ? Icons.star : Icons.star_border,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : () => _submitReview(project.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text('Submit Review', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
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


  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: AppColors.onSurfaceVariant.withOpacity(0.4)),
      filled: true,
      fillColor: AppColors.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.outlineVariant.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.outlineVariant.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1),
      ),
    );
  }

  Widget _buildComment(CommentModel comment) {
    // Generate avatar URL using Robohash (Cat set)
    final String avatarUrl = 'https://robohash.org/${comment.authorEmail}.png?set=set4';

    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow.withOpacity(0.5),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 56,
                  height: 56,
                  color: AppColors.surfaceContainerHigh,
                  child: CachedNetworkImage(
                    imageUrl: avatarUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    errorWidget: (context, url, error) => const Icon(Icons.person_outline),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.authorName,
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < comment.rating ? Icons.star : Icons.star_border,
                              color: AppColors.primary,
                              size: 14,
                            );
                          }),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${comment.createdAt.day}/${comment.createdAt.month}/${comment.createdAt.year}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.outlineVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_supabaseService.isAuthenticated) ...[
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  onPressed: () => _deleteComment(comment.id),
                  tooltip: 'Delete Review (Admin)',
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          Text(
            comment.content,
            style: GoogleFonts.inter(
              fontSize: 18,
              color: AppColors.onSurfaceVariant.withOpacity(0.8),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
