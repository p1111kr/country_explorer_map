class Country {
  final String name;
  final String flagEmoji;
  final String flagUrl;
  final String region;
  final String? subregion;
  final String? capital;
  final int population;
  final Map<String, String> currencies;
  final Map<String, String> languages;
  final double? area;
  final List<String> timezones;
  final String alpha3Code;

  const Country({
    required this.name,
    required this.flagEmoji,
    required this.flagUrl,
    required this.region,
    this.subregion,
    this.capital,
    required this.population,
    required this.currencies,
    required this.languages,
    this.area,
    required this.timezones,
    required this.alpha3Code,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    // Parse name
    final nameObj = json['name'] as Map<String, dynamic>? ?? {};
    final commonName = nameObj['common'] as String? ?? 'Unknown';

    // Parse flag emoji and URL
    final flagsObj = json['flags'] as Map<String, dynamic>? ?? {};
    final flagEmoji = (json['flag'] as String?) ?? '';
    final flagUrl =
        (flagsObj['png'] as String?) ?? (flagsObj['svg'] as String?) ?? '';

    // Parse capital
    final capitalList = json['capital'] as List<dynamic>?;
    final capital = (capitalList != null && capitalList.isNotEmpty)
        ? capitalList.first as String
        : null;

    // Parse currencies
    final currenciesRaw = json['currencies'] as Map<String, dynamic>? ?? {};
    final currencies = <String, String>{};
    currenciesRaw.forEach((code, value) {
      final currencyMap = value as Map<String, dynamic>? ?? {};
      final currencyName = currencyMap['name'] as String? ?? code;
      currencies[code] = currencyName;
    });

    // Parse languages
    final languagesRaw = json['languages'] as Map<String, dynamic>? ?? {};
    final languages = <String, String>{};
    languagesRaw.forEach((code, name) {
      languages[code] = name as String;
    });

    // Parse timezones
    final timezonesList = json['timezones'] as List<dynamic>? ?? [];
    final timezones = timezonesList.map((e) => e as String).toList();

    // Parse area
    final areaRaw = json['area'];
    double? area;
    if (areaRaw is num) {
      area = areaRaw.toDouble();
    }

    return Country(
      name: commonName,
      flagEmoji: flagEmoji,
      flagUrl: flagUrl,
      region: (json['region'] as String?) ?? 'Unknown',
      subregion: json['subregion'] as String?,
      capital: capital,
      population: (json['population'] as int?) ?? 0,
      currencies: currencies,
      languages: languages,
      area: area,
      timezones: timezones,
      alpha3Code: (json['cca3'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': {'common': name},
      'flag': flagEmoji,
      'flags': {'png': flagUrl},
      'region': region,
      'subregion': subregion,
      'capital': capital != null ? [capital] : [],
      'population': population,
      'currencies': currencies.map((k, v) => MapEntry(k, {'name': v})),
      'languages': languages,
      'area': area,
      'timezones': timezones,
      'cca3': alpha3Code,
    };
  }

  Country copyWith({
    String? name,
    String? flagEmoji,
    String? flagUrl,
    String? region,
    String? subregion,
    String? capital,
    int? population,
    Map<String, String>? currencies,
    Map<String, String>? languages,
    double? area,
    List<String>? timezones,
    String? alpha3Code,
  }) {
    return Country(
      name: name ?? this.name,
      flagEmoji: flagEmoji ?? this.flagEmoji,
      flagUrl: flagUrl ?? this.flagUrl,
      region: region ?? this.region,
      subregion: subregion ?? this.subregion,
      capital: capital ?? this.capital,
      population: population ?? this.population,
      currencies: currencies ?? this.currencies,
      languages: languages ?? this.languages,
      area: area ?? this.area,
      timezones: timezones ?? this.timezones,
      alpha3Code: alpha3Code ?? this.alpha3Code,
    );
  }

  String get formattedPopulation {
    if (population >= 1000000000) {
      return '${(population / 1000000000).toStringAsFixed(1)}B';
    } else if (population >= 1000000) {
      return '${(population / 1000000).toStringAsFixed(1)}M';
    } else if (population >= 1000) {
      return '${(population / 1000).toStringAsFixed(1)}K';
    }
    return population.toString();
  }

  String get formattedArea {
    if (area == null) return 'N/A';
    final km = area!;
    if (km >= 1000000) {
      return '${(km / 1000000).toStringAsFixed(2)}M km²';
    } else if (km >= 1000) {
      return '${(km / 1000).toStringAsFixed(1)}K km²';
    }
    return '${km.toStringAsFixed(0)} km²';
  }

  String get currencyDisplay {
    if (currencies.isEmpty) return 'N/A';
    return currencies.entries.map((e) => '${e.value} (${e.key})').join(', ');
  }

  String get languageDisplay {
    if (languages.isEmpty) return 'N/A';
    return languages.values.join(', ');
  }
}
