import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/country.dart';
import '../providers/country_provider.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      context.read<CountryProvider>().clearSearch();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<CountryProvider>().searchCountries(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                Expanded(child: _buildResults()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: TextField(
                controller: _controller,
                autofocus: true,
                onChanged: _onChanged,
                style: GoogleFonts.lato(color: Colors.white, fontSize: 16),
                cursorColor: const Color(0xFF4FC3F7),
                decoration: InputDecoration(
                  hintText: 'Search any country…',
                  hintStyle:
                      GoogleFonts.lato(color: Colors.white38, fontSize: 15),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: Colors.white38, size: 20),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _controller,
                    builder: (_, value, __) => value.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _controller.clear();
                              context.read<CountryProvider>().clearSearch();
                            },
                            child: const Icon(Icons.close_rounded,
                                color: Colors.white38, size: 18),
                          )
                        : const SizedBox.shrink(),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return Consumer<CountryProvider>(
      builder: (_, provider, __) {
        switch (provider.searchState) {
          case LoadingState.idle:
            return _buildIdle();
          case LoadingState.loading:
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4FC3F7)),
            );
          case LoadingState.error:
            return _buildError(provider.searchError ?? 'Something went wrong',
                () {
              provider.searchCountries(provider.lastQuery);
            });
          case LoadingState.empty:
            return _buildEmpty(provider.lastQuery);
          case LoadingState.success:
            return _buildList(provider.searchResults);
        }
      },
    );
  }

  Widget _buildIdle() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 54)),
          const SizedBox(height: 16),
          Text(
            'Type a country name to search',
            style: GoogleFonts.lato(color: Colors.white38, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(
            'e.g. "Germany", "Japan", "Brazil"',
            style: GoogleFonts.lato(color: Colors.white24, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(String query) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🗺️', style: TextStyle(fontSize: 54)),
          const SizedBox(height: 16),
          Text(
            'No results for "$query"',
            style:
                GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different spelling or name',
            style: GoogleFonts.lato(color: Colors.white38, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message, VoidCallback onRetry) {
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
        ),
      ),
    );
  }

  Widget _buildList(List<Country> countries) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: countries.length,
      itemBuilder: (ctx, i) {
        final country = countries[i];
        return GestureDetector(
          onTap: () {
            context
                .read<CountryProvider>()
                .setSelectedCountryFromCache(country);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailScreen(alpha3Code: country.alpha3Code),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.09),
                  Colors.white.withOpacity(0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                Text(
                  country.flagEmoji.isNotEmpty ? country.flagEmoji : '🏳',
                  style: const TextStyle(fontSize: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        country.name,
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${country.region}${country.capital != null ? ' · ${country.capital}' : ''}',
                        style: GoogleFonts.lato(
                            color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  country.formattedPopulation,
                  style: GoogleFonts.lato(
                    color: const Color(0xFF4FC3F7),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white24, size: 14),
              ],
            ),
          ),
        );
      },
    );
  }
}
