import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/country.dart';
import '../providers/country_provider.dart';
import 'detail_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CountryProvider>().loadAllCountries();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0A0F1E).withOpacity(0.5),
                    const Color(0xFF0A0F1E).withOpacity(0.9),
                    const Color(0xFF0A0F1E),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  _buildFilterBar(context),
                  Expanded(child: _buildBody(context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🌍 World Explorer',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Consumer<CountryProvider>(
                  builder: (_, provider, __) {
                    final count = provider.allCountries.length;
                    return Text(
                      provider.homeState == LoadingState.success
                          ? '$count countries to discover'
                          : 'Fetching countries…',
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        color: Colors.white54,
                        letterSpacing: 0.3,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          _buildSearchButton(context),
        ],
      ),
    );
  }

  Widget _buildSearchButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SearchScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24),
        ),
        child: const Icon(Icons.search_rounded, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return Consumer<CountryProvider>(
      builder: (_, provider, __) {
        if (provider.homeState != LoadingState.success)
          return const SizedBox.shrink();
        return Column(
          children: [
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: provider.regions.length,
                itemBuilder: (ctx, i) {
                  final region = provider.regions[i];
                  final selected = provider.selectedRegion == region;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => provider.setRegionFilter(region),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF4FC3F7)
                              : Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF4FC3F7)
                                : Colors.white24,
                          ),
                        ),
                        child: Text(
                          region,
                          style: GoogleFonts.lato(
                            fontSize: 13,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w400,
                            color: selected
                                ? const Color(0xFF0A0F1E)
                                : Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Sort row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Sort: ',
                      style: GoogleFonts.lato(
                          color: Colors.white38, fontSize: 12)),
                  _sortChip(provider, 'Name', 'name'),
                  const SizedBox(width: 8),
                  _sortChip(provider, 'Population', 'population'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _sortChip(CountryProvider provider, String label, String value) {
    final selected = provider.sortBy == value;
    return GestureDetector(
      onTap: () => provider.setSortBy(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF4FC3F7).withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? const Color(0xFF4FC3F7) : Colors.white24,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 12,
            color: selected ? const Color(0xFF4FC3F7) : Colors.white54,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Consumer<CountryProvider>(
      builder: (_, provider, __) {
        switch (provider.homeState) {
          case LoadingState.loading:
          case LoadingState.idle:
            return _buildLoadingGrid();
          case LoadingState.error:
            return _buildError(
              provider.homeError ?? 'Something went wrong',
              provider.isRetryableHome,
              () => provider.loadAllCountries(),
            );
          case LoadingState.empty:
            return _buildEmpty('No countries found.');
          case LoadingState.success:
            return _buildGrid(provider.allCountries);
        }
      },
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: 12,
      itemBuilder: (ctx, i) => Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF4FC3F7),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(List<Country> countries) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.45,
      ),
      itemCount: countries.length,
      itemBuilder: (ctx, i) => _CountryCard(
        country: countries[i],
        onTap: () => _openDetail(context, countries[i]),
      ),
    );
  }

  void _openDetail(BuildContext context, Country country) {
    context.read<CountryProvider>().setSelectedCountryFromCache(country);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(alpha3Code: country.alpha3Code),
      ),
    );
  }

  Widget _buildError(String message, bool retryable, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('😕', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(color: Colors.white70, fontSize: 15),
            ),
            if (retryable) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
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
    );
  }

  Widget _buildEmpty(String message) {
    return Center(
      child: Text(
        message,
        style: GoogleFonts.lato(color: Colors.white54, fontSize: 16),
      ),
    );
  }
}

class _CountryCard extends StatefulWidget {
  const _CountryCard({required this.country, required this.onTap});

  final Country country;
  final VoidCallback onTap;

  @override
  State<_CountryCard> createState() => _CountryCardState();
}

class _CountryCardState extends State<_CountryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );

    _scale = _scaleController;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.reverse(),
      onTapUp: (_) {
        _scaleController.forward();
        widget.onTap();
      },
      onTapCancel: () => _scaleController.forward(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Flag image background
                if (widget.country.flagUrl.isNotEmpty)
                  Positioned(
                    right: -10,
                    top: -10,
                    child: Opacity(
                      opacity: 0.12,
                      child: Image.network(
                        widget.country.flagUrl,
                        width: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Flag emoji
                      Text(
                        widget.country.flagEmoji.isNotEmpty
                            ? widget.country.flagEmoji
                            : '🏳',
                        style: const TextStyle(fontSize: 28),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.country.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _pill(widget.country.region,
                                  const Color(0xFF4FC3F7)),
                              const SizedBox(width: 4),
                              Text(
                                widget.country.formattedPopulation,
                                style: GoogleFonts.lato(
                                  fontSize: 11,
                                  color: Colors.white38,
                                ),
                              ),
                            ],
                          ),
                        ],
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

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: GoogleFonts.lato(
            fontSize: 10, color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
