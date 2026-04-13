import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';

class MouseRegionCursor extends StatelessWidget {
  final Widget child;
  const MouseRegionCursor({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: child,
    );
  }
}

class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  const PrimaryButton({super.key, required this.text, this.onPressed});

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(isHovered ? 1.02 : 1.0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryContainer],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(100),
          boxShadow: isHovered
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.6),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  )
                ]
              : [],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        child: Text(
          widget.text,
          style: GoogleFonts.inter(
            color: const Color(0xFF004A5D),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      ),
    );
  }
}

class GlassmorphismContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;

  const GlassmorphismContainer({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.surfaceBright.withOpacity(0.6),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: AppColors.outlineVariant.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class TopNavigation extends StatelessWidget {
  const TopNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassmorphismContainer(
        borderRadius: 40,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MouseRegionCursor(
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/'),
                child: Text(
                  'Digital Architect',
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                    letterSpacing: -0.36,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 60),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/'),
              child: Text(
                'Portfolio',
                style: GoogleFonts.inter(
                  color: AppColors.onSurface,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 24),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: Text(
                'Admin Login',
                style: GoogleFonts.inter(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectCard extends StatefulWidget {
  final String title;
  final String description;
  final Color accentColor;
  final double height;
  final String? imageUrl;
  final VoidCallback? onTap;

  const ProjectCard({
    super.key,
    required this.title,
    required this.description,
    required this.accentColor,
    required this.height,
    this.imageUrl,
    this.onTap,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegionCursor(
      child: GestureDetector(
        onTap: widget.onTap,
        child: MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            height: widget.height,
            transform: Matrix4.translationValues(0, isHovered ? -8.0 : 0, 0),
            decoration: BoxDecoration(
              color: isHovered ? AppColors.surfaceContainerHighest : AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(24),
              image: widget.imageUrl != null 
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(widget.imageUrl!),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(isHovered ? 0.6 : 0.75), 
                        BlendMode.darken,
                      ),
                    )
                  : null,
              boxShadow: isHovered
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 48,
                        offset: const Offset(0, 24),
                      )
                    ]
                  : [],
            ),
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: widget.accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Spacer(),
                Text(
                  widget.title,
                  style: GoogleFonts.manrope(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                    letterSpacing: -0.64,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.description,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
