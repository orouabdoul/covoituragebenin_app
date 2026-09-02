import sys

file = r'c:/Users/HP_PC/StudioProjects/covoiturage_benin_app/lib/app/data/benin_locations_data.dart'
with open(file, 'r', encoding='utf-8') as f:
    content = f.read()

old = """  static List<String> getQuartiers(String? commune, String? arrondissement) {
    if (commune == null || arrondissement == null) return [];
    return _communeHierarchy[commune]?[arrondissement] ?? [];
  }
}"""

new = """  static List<String> getQuartiers(String? commune, String? arrondissement) {
    if (commune == null || arrondissement == null) return [];
    return _communeHierarchy[commune]?[arrondissement] ?? [];
  }

  static const Map<String, ({double lat, double lng})> citiesWithCoords = {
    'Cotonou': (lat: 6.3676, lng: 2.4199),
    'Porto-Novo': (lat: 6.4969, lng: 2.6289),
    'Abomey-Calavi': (lat: 6.4481, lng: 2.3559),
    'Parakou': (lat: 9.3399, lng: 2.6275),
    'Bohicon': (lat: 7.1782, lng: 2.0679),
    'Abomey': (lat: 7.1826, lng: 1.9826),
    'Natitingou': (lat: 10.3033, lng: 1.3804),
    'Lokossa': (lat: 6.6353, lng: 1.7182),
    'Ouidah': (lat: 6.3588, lng: 2.0864),
    'Kandi': (lat: 11.1327, lng: 2.9400),
    'Djougou': (lat: 9.7087, lng: 1.6659),
    'Grand-Popo': (lat: 6.2807, lng: 1.8250),
    'Tchaourou': (lat: 8.8833, lng: 2.6000),
    'Malanville': (lat: 11.8700, lng: 3.3900),
    'Allada': (lat: 6.6594, lng: 2.1554),
    'Bassila': (lat: 9.0057, lng: 1.6677),
    'Savalou': (lat: 7.9167, lng: 1.9667),
    'Banikoara': (lat: 11.3000, lng: 2.4333),
    'Gogounou': (lat: 10.8333, lng: 2.9000),
    'So-Ava': (lat: 6.4833, lng: 2.4667),
    'Adjarra': (lat: 6.5500, lng: 2.6833),
    'Adjohoun': (lat: 6.6833, lng: 2.5500),
    'Avrankou': (lat: 6.5500, lng: 2.6500),
    'Dogbo': (lat: 6.7833, lng: 1.7833),
    'Toffo': (lat: 6.8500, lng: 2.0833),
  };

  static ({double lat, double lng})? getCityCoords(String city) =>
      citiesWithCoords[city];

  static List<String> get cities {
    final list = _communeHierarchy.keys.toList()..sort();
    return list;
  }

  static List<String> orderedCities(List<String> priorityCities) {
    final all = cities;
    final priority =
        priorityCities.where((c) => _communeHierarchy.containsKey(c)).toList();
    final rest = all.where((c) => !priority.contains(c)).toList();
    return [...priority, ...rest];
  }

  static List<String> getDistricts(String? commune) {
    if (commune == null) return [];
    final arrs = _communeHierarchy[commune];
    if (arrs == null) return [];
    return arrs.values.expand((q) => q).toList()..sort();
  }

  static List<String> neighborhoods(String commune) => getDistricts(commune);
}"""

if old in content:
    new_content = content.replace(old, new, 1)
    with open(file, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print('SUCCESS: utility methods added')
    print(f'New line count: {new_content.count(chr(10))}')
else:
    print('ERROR: pattern not found')
    # Show last 300 chars to debug
    print('Last 300 chars:')
    print(repr(content[-300:]))
