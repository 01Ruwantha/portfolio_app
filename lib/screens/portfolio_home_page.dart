import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';
import '../services/supabase_service.dart';
import '../models/project_model.dart';

class PortfolioHomePage extends StatelessWidget {
  const PortfolioHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final hPadding = screenWidth > 900 ? 100.0 : 40.0;

    return Scaffold(
      body: Stack(
        children: [
          ListView(
            children: [
              const SizedBox(height: 140),
              HeroSection(padding: hPadding),
              const SizedBox(height: 120),
              ProjectsSection(padding: hPadding),
              const SizedBox(height: 120),
              FooterSection(padding: hPadding),
              const SizedBox(height: 60),
            ],
          ),
          const Positioned(top: 24, left: 0, right: 0, child: TopNavigation()),
        ],
      ),
    );
  }
}

class HeroSection extends StatelessWidget {
  final double padding;
  const HeroSection({super.key, required this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Redefining THE\nGeometry OF\nDigital Spaces.',
                  style: GoogleFonts.manrope(
                    fontSize: 100,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                    letterSpacing: -2.0,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: 600,
                  child: Text(
                    'We synthesize structural precision with luminous aesthetics to create environments that breathe. Every pixel is an intentional choice in our architectural journey.',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      color: AppColors.onSurfaceVariant.withOpacity(0.8),
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 64),
                PrimaryButton(
                  text: 'View Works',
                  onPressed: () {
                    // Smooth scroll logic could go here
                  },
                ),
              ],
            ),
          ),
          const Expanded(flex: 3, child: SizedBox()),
        ],
      ),
    );
  }
}

class ProjectsSection extends StatelessWidget {
  final double padding;
  const ProjectsSection({super.key, required this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent, // Background handled by parent or decoration
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured\nStructures',
                style: GoogleFonts.manrope(
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.12,
                  color: AppColors.onSurface,
                  height: 1.1,
                ),
              ),
              SizedBox(
                width: 400,
                child: Text(
                  'A curated selection of industrial, residential, and conceptual digital architectures—each a study in material transparency.',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    color: AppColors.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 120),
          FutureBuilder<List<ProjectModel>>(
            future: SupabaseService().fetchVisibleProjects(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              final projects = snapshot.data ?? [];
              if (projects.isEmpty) {
                return _buildAsymmetricGrid(context);
              }

              return Column(
                children: List.generate((projects.length / 2).ceil(), (index) {
                  final leftIndex = index * 2;
                  final rightIndex = leftIndex + 1;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 120),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: index.isEven ? 0 : 100,
                            ),
                            child: ProjectCard(
                              title: projects[leftIndex].title,
                              description: projects[leftIndex].description,
                              imageUrl: projects[leftIndex].imageUrl,
                              accentColor: AppColors.primary,
                              height: 600,
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/project',
                                arguments: projects[leftIndex],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 80),
                        Expanded(
                          flex: 5,
                          child: rightIndex < projects.length
                              ? Padding(
                                  padding: EdgeInsets.only(
                                    top: index.isEven ? 100 : 0,
                                  ),
                                  child: ProjectCard(
                                    title: projects[rightIndex].title,
                                    description:
                                        projects[rightIndex].description,
                                    imageUrl: projects[rightIndex].imageUrl,
                                    accentColor: const Color(0xFFCFDEF5),
                                    height: 600,
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      '/project',
                                      arguments: projects[rightIndex],
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                        ),
                      ],
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAsymmetricGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: ProjectCard(
                title: 'The Luminescent Monolith',
                description:
                    'A vertical ecosystem utilizing glassmorphic aesthetics and renewable energy integration for urban high-density living.',
                accentColor: AppColors.primary,
                height: 620,
                onTap: () => Navigator.pushNamed(context, '/project'),
              ),
            ),
            const SizedBox(width: 80),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.only(top: 100.0),
                child: ProjectCard(
                  title: 'Slate Pavilion',
                  description:
                      'A residential study in brutalist minimalism, balancing raw concrete textures with warm ambient luminescence.',
                  accentColor: const Color(0xFFCFDEF5),
                  height: 540,
                  onTap: () => Navigator.pushNamed(context, '/project'),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 120),
        Center(
          child: SizedBox(
            width: 1000,
            child: ProjectCard(
              title: 'Lume Museum',
              description:
                  'An experimental public space designed to reactive the senses through rhythmic shadow play and interactive surfaces.',
              accentColor: const Color(0xFF89A5FF),
              height: 480,
              onTap: () => Navigator.pushNamed(context, '/project'),
            ),
          ),
        ),
      ],
    );
  }
}

class FooterSection extends StatelessWidget {
  final double padding;
  const FooterSection({super.key, required this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Build the future with us.',
            style: GoogleFonts.manrope(
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
              letterSpacing: -0.96,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Stay updated with our latest design explorations and architectural insights\nsent directly to your inbox.',
            style: GoogleFonts.inter(
              fontSize: 18,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 320,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: AppColors.outlineVariant.withOpacity(0.3),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                alignment: Alignment.centerLeft,
                child: Text(
                  'Email Address',
                  style: GoogleFonts.inter(
                    color: AppColors.outlineVariant,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const PrimaryButton(text: 'Join Waitlist'),
            ],
          ),
          const SizedBox(height: 100),
          Divider(color: AppColors.outlineVariant.withOpacity(0.15)),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '© 2024 Digital Architect. All rights reserved.',
                style: GoogleFonts.inter(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
              Row(
                children: [
                  MouseRegionCursor(
                    child: Text(
                      'Privacy Policy',
                      style: GoogleFonts.inter(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                  MouseRegionCursor(
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/prd'),
                      child: Text(
                        'Technical Guide (PRD)',
                        style: GoogleFonts.inter(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
