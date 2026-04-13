import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';

class PortfolioTechnicalGuidePage extends StatelessWidget {
  const PortfolioTechnicalGuidePage({super.key});

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
              Text(
                'Flutter & Supabase Portfolio Application Guide',
                style: GoogleFonts.manrope(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                  letterSpacing: -0.96,
                ),
              ),
              const SizedBox(height: 48),
              _buildSection(
                title: '1. SQL Schema (PostgreSQL)',
                content: '''-- Projects table
CREATE TABLE projects (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  image_url TEXT,
  is_hidden BOOLEAN DEFAULT FALSE,
  avg_rating DECIMAL DEFAULT 0,
  total_ratings INT DEFAULT 0
);

-- Ratings table
CREATE TABLE ratings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
  device_id TEXT NOT NULL,
  score INT CHECK (score >= 1 AND score <= 5),
  UNIQUE(project_id, device_id)
);''',
                isCode: true,
              ),
              const SizedBox(height: 32),
              _buildSection(
                title: '2. Supabase Configuration',
                content: '''1. Authentication: Go to Auth -> Users. Create an admin account (email/password).
2. Storage: Create a public bucket named project-images. Set RLS to allow public SELECT and authenticated INSERT/DELETE.
3. API Keys: Copy your SUPABASE_URL and SUPABASE_ANON_KEY.''',
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

  Widget _buildSection({required String title, required String content, bool isCode = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outlineVariant.withOpacity(0.15)),
          ),
          child: Text(
            content,
            style: isCode
                ? GoogleFonts.robotoMono(
                    fontSize: 14,
                    color: AppColors.primary,
                    height: 1.5,
                  )
                : GoogleFonts.inter(
                    fontSize: 16,
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
          ),
        ),
      ],
    );
  }
}
