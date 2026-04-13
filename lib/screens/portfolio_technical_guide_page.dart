import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';

class PortfolioTechnicalGuidePage extends StatelessWidget {
  const PortfolioTechnicalGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 160),
            children: [
              const SizedBox(height: 180),
              Text(
                'SYSTEM //\nTECHNICAL SPECIFICATION',
                style: GoogleFonts.manrope(
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                  letterSpacing: -1.12,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Architectural deployment guide for the Flutter & Supabase ecosystem.',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  color: AppColors.onSurfaceVariant.withOpacity(0.6),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 80),
              _buildSection(
                title: 'DATABASE SCHEMA .SQL',
                content: '''-- Structural definition for PostgreSQL engine
CREATE TABLE projects (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  image_url TEXT,
  is_hidden BOOLEAN DEFAULT FALSE,
  avg_rating DECIMAL DEFAULT 0,
  total_ratings INT DEFAULT 0,
  gallery_urls TEXT[] DEFAULT '{}'
);

-- Real-time discussion & engagement
CREATE TABLE comments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
  author_name TEXT NOT NULL,
  author_email TEXT NOT NULL,
  content TEXT NOT NULL,
  rating INT DEFAULT 5,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);''',
                isCode: true,
              ),
              const SizedBox(height: 48),
              _buildSection(
                title: 'INFRASTRUCTURE PROVISIONING',
                content: '''[AUTH] Go to Supabase Auth. Provision one admin identity for portfolio curation.
[STORAGE] Create 'project-images' bucket. Set RLS: SELECT=public, INSERT/DELETE=authenticated.
[ENVIRONMENT] Update .env or Dart Environment with SUPABASE_URL and SUPABASE_ANON_KEY.''',
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

  Widget _buildSection({required String title, required String content, bool isCode = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        GlassmorphismContainer(
          borderRadius: 24,
          padding: const EdgeInsets.all(40),
          color: AppColors.surfaceContainerLow.withOpacity(0.5),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              content,
              style: isCode
                  ? GoogleFonts.robotoMono(
                      fontSize: 14,
                      color: AppColors.primary.withOpacity(0.8),
                      height: 1.8,
                    )
                  : GoogleFonts.inter(
                      fontSize: 16,
                      color: AppColors.onSurfaceVariant,
                      height: 1.8,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
