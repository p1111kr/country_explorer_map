import 'package:flutter/foundation.dart';
import '../models/country.dart';
import '../services/api_exception.dart';
import '../services/country_api_service.dart';

enum LoadingState { idle, loading, success, error, empty }

class CountryProvider extends ChangeNotifier {
  final CountryApiService _apiService = CountryApiService();

  // Home screen state
  List<Country> _allCountries = [];
  LoadingState _homeState = LoadingState.idle;
  String? _homeError;
  bool _isRetryableHome = true;

  // Filter/sort state
  String _selectedRegion = 'All';
  String _sortBy = 'name'; // 'name' | 'population'

  // Search screen state
  List<Country> _searchResults = [];
  LoadingState _searchState = LoadingState.idle;
  String? _searchError;
  String _lastQuery = '';

  // Detail screen state
  Country? _selectedCountry;
  LoadingState _detailState = LoadingState.idle;
  String? _detailError;
  bool _isRetryableDetail = true;

  List<Country> get allCountries {
    var list = _selectedRegion == 'All'
        ? List<Country>.from(_allCountries)
        : _allCountries.where((c) => c.region == _selectedRegion).toList();

    if (_sortBy == 'population') {
      list.sort((a, b) => b.population.compareTo(a.population));
    } else {
      list.sort((a, b) => a.name.compareTo(b.name));
    }
    return list;
  }

  List<String> get regions {
    final Set<String> set = {'All'};
    for (final c in _allCountries) {
      if (c.region.isNotEmpty) set.add(c.region);
    }
    final sorted = set.toList()..sort();
    // Keep 'All' first
    sorted.remove('All');
    return ['All', ...sorted];
  }

  LoadingState get homeState => _homeState;
  String? get homeError => _homeError;
  bool get isRetryableHome => _isRetryableHome;

  List<Country> get searchResults => _searchResults;
  LoadingState get searchState => _searchState;
  String? get searchError => _searchError;
  String get lastQuery => _lastQuery;

  Country? get selectedCountry => _selectedCountry;
  LoadingState get detailState => _detailState;
  String? get detailError => _detailError;
  bool get isRetryableDetail => _isRetryableDetail;

  String get selectedRegion => _selectedRegion;
  String get sortBy => _sortBy;

  // Home actions

  Future<void> loadAllCountries() async {
    if (_homeState == LoadingState.loading) return;
    _homeState = LoadingState.loading;
    _homeError = null;
    notifyListeners();

    try {
      _allCountries = await _apiService.fetchAllCountries();
      _homeState =
          _allCountries.isEmpty ? LoadingState.empty : LoadingState.success;
    } on ApiException catch (e) {
      _homeState = LoadingState.error;
      _homeError = e.userFriendlyMessage;
      _isRetryableHome = e.isRetryable;
    } catch (e) {
      _homeState = LoadingState.error;
      _homeError = 'Something unexpected happened. Please try again.';
      _isRetryableHome = true;
    }

    notifyListeners();
  }

  void setRegionFilter(String region) {
    _selectedRegion = region;
    notifyListeners();
  }

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    notifyListeners();
  }

  //  Search actions
  Future<void> searchCountries(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _searchState = LoadingState.idle;
      _lastQuery = '';
      notifyListeners();
      return;
    }

    _lastQuery = query.trim();
    _searchState = LoadingState.loading;
    _searchError = null;
    notifyListeners();

    try {
      _searchResults = await _apiService.searchByName(query.trim());
      _searchState =
          _searchResults.isEmpty ? LoadingState.empty : LoadingState.success;
    } on ApiException catch (e) {
      _searchState = LoadingState.error;
      _searchError = e.userFriendlyMessage;
    } catch (e) {
      _searchState = LoadingState.error;
      _searchError = 'Something unexpected happened. Please try again.';
    }

    notifyListeners();
  }

  void clearSearch() {
    _searchResults = [];
    _searchState = LoadingState.idle;
    _searchError = null;
    _lastQuery = '';
    notifyListeners();
  }

  // Detail actions
  Future<void> loadCountryDetail(String alpha3Code) async {
    _selectedCountry = null;
    _detailState = LoadingState.loading;
    _detailError = null;
    notifyListeners();

    try {
      _selectedCountry = await _apiService.fetchByCode(alpha3Code);
      _detailState = LoadingState.success;
    } on ApiException catch (e) {
      _detailState = LoadingState.error;
      _detailError = e.userFriendlyMessage;
      _isRetryableDetail = e.isRetryable;
    } catch (e) {
      _detailState = LoadingState.error;
      _detailError = 'Something unexpected happened. Please try again.';
      _isRetryableDetail = true;
    }

    notifyListeners();
  }

  void setSelectedCountryFromCache(Country country) {
    _selectedCountry = country;
    _detailState = LoadingState.loading; // still fetch full details
    notifyListeners();
  }
}
