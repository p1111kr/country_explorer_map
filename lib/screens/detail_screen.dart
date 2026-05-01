import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/country.dart';
import '../providers/country_provider.dart';

class DetailScreen extends StatefulWidget {
  final String alpha3Code;

  const DetailScreen({super.key, required this.alpha3Code});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CountryProvider>().loadCountryDetail(widget.alpha3Code);
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      body: Consumer<CountryProvider>(
        builder: (_, provider, __) {
          if (provider.detailState == LoadingState.success &&
              provider.selectedCountry != null) {
            if (!_animController.isCompleted) _animController.forward();
          }
          return Stack(
            children: [
              _buildContent(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(CountryProvider provider) {
    switch (provider.detailState) {
      case LoadingState.loading:
      case LoadingState.idle:
        return SafeArea(
          child: Column(
            children: [
              _buildBackButton(),
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF4FC3F7)),
                ),
              ),
            ],
          ),
        );
      case LoadingState.error:
        return SafeArea(
          child: Column(
            children: [
              _buildBackButton(),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('😕', style: TextStyle(fontSize: 52)),
                        const SizedBox(height: 16),
                        Text(
                          provider.detailError != null
                              ? '${provider.detailError}'
                              : '',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                              color: Colors.white70, fontSize: 15),
                        ),
                        if (provider.isRetryableDetail) ...[
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () =>
                                provider.loadCountryDetail(widget.alpha3Code),
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Try Again'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4FC3F7),
                              foregroundColor: const Color(0xFF0A0F1E),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case LoadingState.success:
      case LoadingState.empty:
        final country = provider.selectedCountry;
        if (country == null) return const SizedBox.shrink();
        return _buildDetail(country);
    }
  }

  Widget _buildDetail(Country country) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(country),
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: _buildInfoSection(country),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(Country country) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: const Color(0xFF0A0F1E),
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: const Icon(Icons.arrow_back_rounded,
              color: Colors.white, size: 20),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(64, 0, 16, 16),
        title: Text(
          country.name,
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Flag image
            if (country.flagUrl.isNotEmpty)
              Image.network(
                country.flagUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF1A2340),
                  child: const Center(
                    child: Text('🏳', style: TextStyle(fontSize: 64)),
                  ),
                ),
              )
            else
              Container(
                color: const Color(0xFF1A2340),
                child: Center(
                  child: Text(
                    country.flagEmoji.isNotEmpty ? country.flagEmoji : '🏳',
                    style: const TextStyle(fontSize: 72),
                  ),
                ),
              ),
            // Gradient over flag
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF0A0F1E).withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(Country country) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Big flag emoji and  region badge
          Row(
            children: [
              Text(
                country.flagEmoji.isNotEmpty ? country.flagEmoji : '🏳',
                style: const TextStyle(fontSize: 44),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _regionBadge(country.region),
                  if (country.subregion != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      country.subregion!,
                      style:
                          GoogleFonts.lato(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              _quickStat('👥', 'Population', country.formattedPopulation),
              const SizedBox(width: 12),
              _quickStat('📐', 'Area', country.formattedArea),
            ],
          ),
          const SizedBox(height: 12),

          // Detail cards
          _detailCard('🏙️ Capital', country.capital ?? 'N/A'),
          const SizedBox(height: 10),
          _detailCard('💱 Currencies', country.currencyDisplay),
          const SizedBox(height: 10),
          _detailCard('🗣️ Languages', country.languageDisplay),
          const SizedBox(height: 10),
          _detailCard('🕐 Timezones', country.timezones.join(', ')),
          const SizedBox(height: 10),
          _detailCard('🔤 ISO Code', country.alpha3Code),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: const Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _regionBadge(String region) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF4FC3F7).withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF4FC3F7).withOpacity(0.4)),
      ),
      child: Text(
        region,
        style: GoogleFonts.lato(
          color: const Color(0xFF4FC3F7),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _quickStat(String emoji, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.lato(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailCard(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.lato(
              color: const Color(0xFF4FC3F7),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.lato(
              color: Colors.white,
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
