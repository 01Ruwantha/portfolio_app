import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';
import '../services/supabase_service.dart';
import '../models/project_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';


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
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SELECTED WORKS',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3.0,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Featured\nStructures',
                    style: GoogleFonts.manrope(
                      fontSize: 64,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.28,
                      color: AppColors.onSurface,
                      height: 0.9,
                    ),
                  ),
                ],
              ),
              Container(
                width: 450,
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'A precision-oriented collection of architectural studies, focusing on the intersection of digital transparency and material permanence.',
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
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }
              final projects = snapshot.data ?? [];
              
              if (projects.isEmpty) {
                return _buildStaticGeometricGrid(context);
              }

              return Column(
                children: List.generate((projects.length / 2).ceil(), (index) {
                  final leftIndex = index * 2;
                  final rightIndex = leftIndex + 1;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 80),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ProjectCard(
                            title: projects[leftIndex].title,
                            description: projects[leftIndex].description,
                            imageUrl: projects[leftIndex].imageUrl,
                            accentColor: AppColors.primary,
                            height: 600,
                            index: '[ ${(leftIndex + 1).toString().padLeft(2, '0')} ]',
                            category: 'ARCHITECTURAL STUDY',
                            year: '2024',
                            onTap: () => Navigator.pushNamed(
                              context, 
                              '/project', 
                              arguments: projects[leftIndex]
                            ),
                          ),
                        ),
                        const SizedBox(width: 80),
                        Expanded(
                          child: rightIndex < projects.length
                              ? ProjectCard(
                                  title: projects[rightIndex].title,
                                  description: projects[rightIndex].description,
                                  imageUrl: projects[rightIndex].imageUrl,
                                  accentColor: const Color(0xFFCFDEF5),
                                  height: 600,
                                  index: '[ ${(rightIndex + 1).toString().padLeft(2, '0')} ]',
                                  category: 'DIGITAL FABRICATION',
                                  year: '2024',
                                  onTap: () => Navigator.pushNamed(
                                    context, 
                                    '/project', 
                                    arguments: projects[rightIndex]
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

  Widget _buildStaticGeometricGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ProjectCard(
                title: 'The Luminescent Monolith',
                description: 'A study in vertical ecosystems and glassmorphic transparency.',
                accentColor: AppColors.primary,
                height: 600,
                index: '[ 01 ]',
                category: 'RESIDENTIAL',
                year: '2024',
                onTap: () => Navigator.pushNamed(context, '/project'),
              ),
            ),
            const SizedBox(width: 80),
            Expanded(
              child: ProjectCard(
                title: 'Slate Pavilion',
                description: 'Brutalist minimalism combined with ambient light manipulation.',
                accentColor: const Color(0xFFCFDEF5),
                height: 600,
                index: '[ 02 ]',
                category: 'CULTURAL',
                year: '2023',
                onTap: () => Navigator.pushNamed(context, '/project'),
              ),
            ),
          ],
        ),
      ],
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 100),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow.withOpacity(0.3),
        border: Border(top: BorderSide(color: AppColors.outlineVariant.withOpacity(0.1))),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Let\'s build\nthe future\ntogether.',
                      style: GoogleFonts.manrope(
                        fontSize: 64,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                        height: 0.9,
                        letterSpacing: -1.28,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Row(
                      children: [
                        _SocialButton(
                          icon: FontAwesomeIcons.whatsapp, 
                          url: 'https://wa.me/94778042931', 
                          label: 'WhatsApp',
                        ),
                        const SizedBox(width: 24),
                        _SocialButton(
                          icon: FontAwesomeIcons.facebook, 
                          url: 'https://web.facebook.com/vipula.padmalal', 
                          label: 'Facebook',
                        ),
                        const SizedBox(width: 24),
                        _SocialButton(
                          icon: FontAwesomeIcons.envelope, 
                          url: 'mailto:contact@digitalarchitect.com', 
                          label: 'Email',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Expanded(flex: 1, child: SizedBox()),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INSIGHTS & UPDATES',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.0,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Subscribe to receive our latest architectural studies and digital design explorations.',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        color: AppColors.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'architect@studio.com',
                              style: GoogleFonts.inter(color: AppColors.outlineVariant, fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        PrimaryButton(
                          text: 'Join', 
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 120),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '© 2024 Digital Architect. Crafted for excellence.',
                style: GoogleFonts.inter(
                  color: AppColors.onSurfaceVariant.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
              Row(
                children: [
                  _FooterLink(text: 'Privacy Policy'),
                  const SizedBox(width: 32),
                  _FooterLink(
                    text: 'Technical Guide (PRD)', 
                    onTap: () => Navigator.pushNamed(context, '/prd'),
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

class _SocialButton extends StatefulWidget {
  final dynamic icon;
  final String url;
  final String label;

  const _SocialButton({required this.icon, required this.url, required this.label});


  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegionCursor(
      child: GestureDetector(
        onTap: () async {
          final uri = Uri.parse(widget.url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        child: MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isHovered ? AppColors.primary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isHovered ? AppColors.primary : AppColors.outlineVariant.withOpacity(0.2),
                  ),
                ),
                child: FaIcon(
                  widget.icon,
                  color: isHovered ? AppColors.onPrimary : AppColors.onSurface,
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isHovered ? 1.0 : 0.0,
                child: Text(
                  widget.label,
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const _FooterLink({required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegionCursor(
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          text,
          style: GoogleFonts.inter(
            color: AppColors.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

