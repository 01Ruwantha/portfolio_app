import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';
import '../models/project_model.dart';

class ProjectDetailsPage extends StatelessWidget {
  const ProjectDetailsPage({super.key});

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
              Text(
                displayTitle,
                style: GoogleFonts.manrope(
                  fontSize: 64,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                  letterSpacing: -1.28,
                ),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayDescription,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            color: AppColors.onSurfaceVariant,
                            height: 1.6,
                          ),
                        ),
                        if (project == null) ...[
                          const SizedBox(height: 24),
                          Text(
                            'Our architectural approach prioritized the reduction of carbon footprint without sacrificing visual impact. The internal structure leverages a modular steel framework, allowing for flexible workspace configurations that adapt to the evolving needs of its inhabitants. Every angle was calculated to maximize natural light penetration, reducing the need for artificial illumination by 40% throughout the year.',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              color: AppColors.onSurfaceVariant,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 80),
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Specifications',
                            style: GoogleFonts.manrope(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildSpecItem('Location', 'Neo-Tokyo, JP'),
                          _buildSpecItem('Total Area', '12,500 m²'),
                          _buildSpecItem('Floors', '64 Above, 4 Below'),
                          _buildSpecItem('Sustainability', 'LEED Platinum'),
                        ],
                      ),
                    ),
                  )
                ],
              ),
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
              _buildComment('The way the light interacts with the glass at sunset is unparalleled. This is a masterclass in modern material science applied to traditional form.'),
              _buildComment("Stunning execution. I'm particularly impressed by the structural integration of the solar panels within the facade design."),
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

  Widget _buildSpecItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.outlineVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              color: AppColors.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComment(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 16,
          color: AppColors.onSurfaceVariant,
          height: 1.5,
        ),
      ),
    );
  }
}
