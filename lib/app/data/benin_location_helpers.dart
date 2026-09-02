import 'benin_locations_data.dart';

// Méthodes complémentaires au fichier benin_locations_data.dart
// (GPS, liste des communes, tri)
class BeninLocationHelpers {
  // ── GPS coords des principales communes ──────────────────────────────────
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
    'Savè': (lat: 8.0339, lng: 2.4872),
    'Nikki': (lat: 9.9380, lng: 3.2106),
    'Comè': (lat: 6.3980, lng: 1.8812),
    'Grand-Popo': (lat: 6.2807, lng: 1.8250),
    'Tchaourou': (lat: 8.8833, lng: 2.6000),
    'Malanville': (lat: 11.8700, lng: 3.3900),
    'Sèmè-Kpodji': (lat: 6.3741, lng: 2.5710),
    'Allada': (lat: 6.6594, lng: 2.1554),
    'Bassila': (lat: 9.0057, lng: 1.6677),
    'Dassa-Zoumé': (lat: 7.7500, lng: 2.1833),
    'Savalou': (lat: 7.9167, lng: 1.9667),
    'Glazoué': (lat: 7.9833, lng: 2.2333),
    'Bembèrèkè': (lat: 10.2333, lng: 2.6667),
    'Banikoara': (lat: 11.3000, lng: 2.4333),
    'Gogounou': (lat: 10.8333, lng: 2.9000),
    'Kétou': (lat: 7.3601, lng: 2.5999),
    'Pobè': (lat: 6.9792, lng: 2.6556),
    'Tanguiéta': (lat: 10.6233, lng: 1.2700),
    'Kpomassè': (lat: 6.5833, lng: 2.0167),
    'Toffo': (lat: 6.8500, lng: 2.0833),
    'Dogbo': (lat: 6.7833, lng: 1.7833),
    'Aplahoué': (lat: 6.9333, lng: 1.7000),
    'So-Ava': (lat: 6.4833, lng: 2.4667),
    'Adjarra': (lat: 6.5500, lng: 2.6833),
    'Adjohoun': (lat: 6.6833, lng: 2.5500),
    'Akpro-Missérété': (lat: 6.5833, lng: 2.6000),
    'Avrankou': (lat: 6.5500, lng: 2.6500),
    'Péhunco': (lat: 10.2500, lng: 1.5833),
    'Kouandé': (lat: 10.3333, lng: 1.6833),
    "N'Dali": (lat: 9.8333, lng: 2.7167),
    'Pèrèrè': (lat: 10.1333, lng: 3.1667),
    'Sinendé': (lat: 10.0167, lng: 2.3667),
    'Kalalé': (lat: 10.5833, lng: 3.3833),
  };

  static ({double lat, double lng})? getCityCoords(String city) =>
      citiesWithCoords[city];

  // ── Liste triée de toutes les communes du Bénin ───────────────────────────
  static List<String> get cities {
    final list = _allCommunes.where(BeninLocations.hasArrondissements).toList()
      ..sort();
    return list.isEmpty ? (List.from(_allCommunes)..sort()) : list;
  }

  static List<String> orderedCities(List<String> priorityCities) {
    final all = cities;
    final priority =
        priorityCities.where(BeninLocations.hasArrondissements).toList();
    final rest = all.where((c) => !priority.contains(c)).toList();
    return [...priority, ...rest];
  }

  static bool communeExists(String commune) =>
      BeninLocations.hasArrondissements(commune);

  static Map<String, List<String>> get citiesWithArrondissements =>
      Map.fromEntries(cities.map(
          (c) => MapEntry(c, BeninLocations.getArrondissements(c))));

  static List<String> getArrondissements(String? commune) =>
      BeninLocations.getArrondissements(commune);

  static List<String> getQuartiers(String? commune, String? arrondissement) =>
      BeninLocations.getQuartiers(commune, arrondissement);

  // 77 communes officielles du Bénin
  static const List<String> _allCommunes = [
    'Abomey', 'Abomey-Calavi', 'Adja-Ouèrè', 'Adjarra', 'Adjohoun',
    'Agbangnizoun', 'Aguégués', 'Akpro-Missérété', 'Allada', 'Aplahoué',
    'Athiémé', 'Avrankou', 'Banikoara', 'Bantè', 'Bassila',
    'Bembèrèkè', 'Bohicon', 'Bonou', 'Bopa', 'Boukoumbé',
    'Cobly', 'Comè', 'Copargo', 'Cotonou', 'Covè',
    'Dangbo', 'Dassa-Zoumé', 'Djidja', 'Djakotomey', 'Djougou',
    'Dogbo', 'Glazoué', 'Gogounou', 'Grand-Popo', 'Houéyogbé',
    'Ifangni', 'Kalalé', 'Kandi', 'Karimama', 'Kérou',
    'Kétou', 'Klouékanmè', 'Kouandé', 'Kpomassè', 'Lalo',
    'Lokossa', 'Malanville', 'Matéri', "N'Dali", 'Natitingou',
    'Nikki', 'Ouaké', 'Ouèssè', 'Ouinhi', 'Ouidah',
    'Parakou', 'Péhunco', 'Pèrèrè', 'Pobè', 'Porto-Novo',
    'Sakété', 'Savalou', 'Savè', 'Ségbana', 'Sèmè-Kpodji',
    'Sinendé', 'So-Ava', 'Tanguiéta', 'Tchaourou', 'Toffo',
    'Tori-Bossito', 'Toukountouna', 'Toviklin', 'Za-Kpota', 'Zagnanado',
    'Zè', 'Zogbodomè',
  ];
}
