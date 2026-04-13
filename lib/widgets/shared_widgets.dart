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
  final bool isSecondary;
  const PrimaryButton({super.key, required this.text, this.onPressed, this.isSecondary = false});

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isSecondary ? AppColors.secondaryContainer : AppColors.primary;
    final fgColor = widget.isSecondary ? AppColors.onSecondaryContainer : AppColors.onPrimary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()..scale(isHovered ? 1.04 : 1.0),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(100),
            boxShadow: isHovered
                ? [
                    BoxShadow(
                      color: bgColor.withOpacity(0.4),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    )
                  ]
                : [],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
          child: Text(
            widget.text,
            style: GoogleFonts.inter(
              color: fgColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
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
  final Color? color;

  const GlassmorphismContainer({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.padding = EdgeInsets.zero,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? AppColors.surfaceContainerLow.withOpacity(0.7),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: AppColors.outlineVariant.withOpacity(0.1),
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
  final String? index;
  final String? year;
  final String? category;

  const ProjectCard({
    super.key,
    required this.title,
    required this.description,
    required this.accentColor,
    required this.height,
    this.imageUrl,
    this.onTap,
    this.index,
    this.year,
    this.category,
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
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutQuart,
            height: widget.height,
            transform: Matrix4.translationValues(0, isHovered ? -12.0 : 0, 0),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(32),
              boxShadow: isHovered
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 64,
                        offset: const Offset(0, 32),
                      )
                    ]
                  : [],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                if (widget.imageUrl != null)
                  Positioned.fill(
                    child: AnimatedScale(
                      scale: isHovered ? 1.1 : 1.0,
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOutQuart,
                      child: CachedNetworkImage(
                        imageUrl: widget.imageUrl!,
                        fit: BoxFit.cover,
                        colorBlendMode: BlendMode.darken,
                        color: Colors.black.withOpacity(isHovered ? 0.4 : 0.6),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ),
                if (widget.index != null)
                  Positioned(
                    top: 32,
                    right: 32,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
                      ),
                      child: Text(
                        widget.index!,
                        style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          if (widget.category != null) ...[
                            Text(
                              widget.category!.toUpperCase(),
                              style: GoogleFonts.inter(
                                color: widget.accentColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(width: 4, height: 4, decoration: BoxDecoration(color: AppColors.outlineVariant.withOpacity(0.3), shape: BoxShape.circle)),
                            const SizedBox(width: 16),
                          ],
                          if (widget.year != null)
                            Text(
                              widget.year!,
                              style: GoogleFonts.inter(
                                color: AppColors.onSurfaceVariant.withOpacity(0.6),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                letterSpacing: 1.0,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        widget.title,
                        style: GoogleFonts.manrope(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurface,
                          letterSpacing: -0.72,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 20),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 400),
                        opacity: isHovered ? 1.0 : 0.0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          height: isHovered ? 100 : 0,
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: Text(
                              widget.description,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                color: AppColors.onSurfaceVariant.withOpacity(0.8),
                                height: 1.6,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      if (!isHovered)
                        Text(
                          widget.description,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            color: AppColors.onSurfaceVariant.withOpacity(0.6),
                            height: 1.6,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 32),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: isHovered ? 1.0 : 0.0,
                        child: Row(
                          children: [
                            Text(
                              'EXPLORE STRUCTURE',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0,
                                color: widget.accentColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.arrow_forward, color: widget.accentColor, size: 20),
                          ],
                        ),
                      ),
                    ],
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
