class BeninLocations {
  static const Map<String, List<String>> citiesWithDistricts = {
    // Littoral
    'Cotonou': [
      'Akpakpa', 'Agla', 'Avotrou', 'Cadjèhoun', 'Dantokpa', 'Fidjrossè',
      'Gbèdjromèdo', 'Guinkomey', 'Haie-Vive', 'Houéyiho', 'Jéricho', 'Ladji',
      'Mènontin', 'Misséssin', 'Saint-Michel', 'Sainte-Rita', 'Sikècodji',
      'Tokpa', 'Vedoko', 'Vodjè', 'Xwlacodji', 'Zongo',
    ],
    // Ouémé
    'Porto-Novo': [
      'Avannou', 'Centre-ville', 'Djassin', 'Gbékon-Houèto', 'Houinmè',
      'Hounkpamè', 'Lèkè', 'Louho', 'Ouando', 'Saint-Jean', 'Toffa', 'Tokpota',
    ],
    'Sèmè-Kpodji': ['Agblangandan', 'Ahozon', 'Djrègbé', 'Sèmè-Plage', 'Tohouè'],
    'Adjarra': ['Adjarra Centre', 'Avagbodji', 'Hèvè'],
    'Adjohoun': ['Adjohoun Centre', 'Akpadanou', 'Gangban', 'Kodé'],
    'Aguégués': ['Avagbodji', 'Iko', 'Zoungamè'],
    'Akpro-Missérété': ['Akpro Centre', 'Missérété', 'Vakon'],
    'Avrankou': ['Avrankou Centre', 'Adjovimè', 'Éwè'],
    'Bonou': ['Bonou Centre', 'Damè', 'Tobré'],
    'Dangbo': ['Dangbo Centre', 'Gbèko', 'Godohoun'],
    // Atlantique
    'Abomey-Calavi': [
      'Akassato', 'Centre', 'Godomey', 'Hêvié', 'Kpanroun', 'Ouèdo', 'Togba', 'Zinvié',
    ],
    'Allada': ['Allada Centre', 'Attogon', 'Hinvi', 'Lissèzoun', 'Sékou', 'Togoudo'],
    'Kpomassè': ['Kpomassè Centre', 'Aganmassè', 'Tévèdji'],
    'Ouidah': ['Avlékété', 'Centre', 'Djègbadji', 'Houakpè-Daho', 'Pahou', 'Savi'],
    'So-Ava': ['Ahomadégbé', 'Ganvié', 'So-Ava Centre', 'Vêki'],
    'Toffo': ['Agonlin-Houégbo', 'Dam', 'Dogbo-Tota', 'Toffo Centre'],
    'Tori-Bossito': ['Adingnigon', 'Dékanmè', 'Tori-Bossito Centre', 'Tori-Cada'],
    'Zè': ['Dodji-Bata', 'Sèdjè-Dénou', 'Tangbo', 'Tokpa-Domè', 'Zè Centre'],
    // Borgou
    'Parakou': [
      'Banikanni', 'Centre-ville', 'Gah', 'Guèmè', 'Kpébié',
      'Madina', 'Sèkèrè', 'Tourou', 'Zongo',
    ],
    'Bembèrèkè': ['Béroubouay', 'Bembèrèkè Centre', 'Gamia', 'Goumori'],
    'Kalalé': ['Bori', 'Dérassi', 'Kalalé Centre', 'Péonga'],
    "N'Dali": ["Gbégourou", "N'Dali Centre", 'Sontou'],
    'Nikki': ['Biro', 'Gninsy', 'Nikki Centre', 'Serekali', 'Tasso'],
    'Pèrèrè': ['Gando', 'Guinagourou', 'Pèrèrè Centre'],
    'Sinendé': ['Basso', 'Dunkassa', 'Sinendé Centre'],
    'Tchaourou': ['Alafiarou', 'Bétérou', 'Kika', 'Sanson', 'Tchaourou Centre'],
    // Alibori
    'Banikoara': ['Banikoara Centre', 'Founougo', 'Gomparou', 'Goumori', 'Ounet', 'Soroko'],
    'Gogounou': ['Bagou', 'Gogounou Centre', 'Sori', 'Wansirou'],
    'Kandi': ['Bensékou', 'Donwari', 'Kandi Centre', 'Kassakou', 'Saa'],
    'Karimama': ['Birni Lafia', 'Bogo-Bogo', 'Karimama Centre', 'Monsey'],
    'Malanville': ['Garou', 'Guéné', 'Madécali', 'Malanville Centre', 'Tomboutou'],
    'Ségbana': ['Liboussou', 'Lougou', 'Sampeto', 'Ségbana Centre'],
    // Atacora
    'Natitingou': ['Kotopounga', 'Kouandata', 'Natitingou Centre', 'Tchabicouma'],
    'Boukoumbé': ['Boukoumbé Centre', 'Cobly', 'Kouporgou', 'Manta'],
    'Cobly': ['Cobly Centre', 'Datori', 'Kountori', 'Tapoga'],
    'Kérou': ['Brignamaro', 'Firou', 'Guilmaro', 'Kérou Centre'],
    'Kouandé': ['Birni', 'Chabi-Couma', 'Fô-Bouré', 'Kouandé Centre'],
    'Matéri': ['Dassari', 'Gouandé', 'Matéri Centre', 'Nodi'],
    'Péhunco': ['Basso', 'Gnémasson', 'Péhunco Centre', 'Tobré'],
    'Tanguiéta': ['Batia', 'Nadobo', 'Taïacou', 'Tanguiéta Centre'],
    'Toukountouna': ['Fô-Tancé', 'Pabégou', 'Toukountouna Centre'],
    // Donga
    'Djougou': ['Barei', 'Bélèfoungou', 'Djougou Centre', 'Kolokondé', 'Partago', 'Pélébina', 'Sérou'],
    'Bassila': ['Alédjo', 'Bassila Centre', 'Manigri', 'Pénéssoulou'],
    'Copargo': ['Alédjo-Kpara', 'Copargo Centre', 'Gbégourou'],
    'Ouaké': ['Basso', 'Kpésséra', 'Ouaké Centre', 'Séméré'],
    // Collines
    'Dassa-Zoumé': ['Dassa-Zoumé Centre', 'Kèmon', 'Paouignan', 'Soclogbo'],
    'Glazoué': ['Assanté', 'Glazoué Centre', 'Magoumi', 'Thio'],
    'Bantè': ['Atokolibé', 'Bantè Centre', 'Bobè', 'Kpataba'],
    'Ouèssè': ['Kaboua', 'Okpara', 'Ouèssè Centre', 'Tchatchou'],
    'Savalou': ['Doumè', 'Kilibo', 'Kpataba', 'Lèmè', 'Logozohè', 'Ottola', 'Savalou Centre'],
    'Savè': ['Ikpinlè', 'Kaboua', 'Ouèssè', 'Savè Centre'],
    // Zou
    'Abomey': ['Abomey Centre', 'Agblomè', 'Djèllakoumèy', 'Gbècon', 'Kinkinhoué', 'Sèhoun'],
    'Agbangnizoun': ['Agbangnizoun Centre', 'Cové', 'Domè', 'Zèco'],
    'Bohicon': ['Avogbana', 'Bohicon Centre', 'Lissèzoun', 'Passagon', 'Saclo', 'Zan-Trou'],
    'Covè': ['Covè Centre', 'Domè', 'Kpinnou'],
    'Djidja': ['Agouna', 'Djidja Centre', 'Médji', 'Vossa'],
    'Ouinhi': ['Dasso', 'Gbèko', 'Ouinhi Centre', 'Yokon'],
    'Zagnanado': ['Bétékoukou', 'Damè', 'Zagnanado Centre'],
    'Za-Kpota': ['Kpohomè', 'Tanwé', 'Za-Kpota Centre'],
    'Zogbodomè': ['Lèkpa', 'Sèhoun', 'Zogbodomè Centre'],
    // Mono
    'Lokossa': ['Koudo', 'Lokossa Centre', 'Ouèdèmè-Adja', 'Oumbèga'],
    'Athiémé': ['Adohoun', 'Athiémé Centre', 'Kpinnou'],
    'Bopa': ['Ahozon', 'Bopa Centre', 'Dévé', 'Lobogo'],
    'Comè': ['Ahozon', 'Comè Centre', 'Houédoumè', 'Oumako'],
    'Grand-Popo': ['Agoué', 'Avlo', 'Djanglanmè', 'Gbécon-Fô', 'Grand-Popo Centre'],
    'Houéyogbé': ['Dédékpoe', 'Houéyogbé Centre', 'Possotomè'],
    // Couffo
    'Aplahoué': ['Aplahoué Centre', 'Djakotomey', 'Klouékanmè', 'Lalo'],
    'Djakotomey': ['Djakotomey Centre', 'Médji de Sékou', 'Sokouhoué'],
    'Dogbo': ['Azovè', 'Dogbo Centre', 'Madjrè', 'Totchangni'],
    'Klouékanmè': ['Houégamè', 'Klouékanmè Centre', 'Légbannon'],
    'Lalo': ['Dekpo', 'Gnizounmè', 'Lalo Centre', 'Toviklin'],
    'Toviklin': ['Agbokpa', 'Gohomey', 'Toviklin Centre'],
    // Plateau
    'Kétou': ['Adakplahoué', 'Djidja', 'Idigny', 'Kétou Centre'],
    'Adja-Ouèrè': ['Adja-Ouèrè Centre', 'Adjaouèrè', 'Issaba', 'Kpoulou'],
    'Ifangni': ['Daagbé', 'Ifangni Centre', 'Igana'],
    'Pobè': ['Ahoyéyé', 'Igana', 'Issaba', 'Pobè Centre'],
    'Sakété': ['Daffo', 'Gomè-Sota', 'Sakété Centre'],
  };

  // Coordonnées GPS approximatives (centre-ville) des principales communes
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

  static List<String> get cities {
    final list = citiesWithDistricts.keys.toList()..sort();
    return list;
  }

  // Retourne la liste ordonnée: [priorityCities en premier] + reste
  static List<String> orderedCities(List<String> priorityCities) {
    final all = citiesWithDistricts.keys.toList()..sort();
    final priority = priorityCities
        .where((c) => citiesWithDistricts.containsKey(c))
        .toList();
    final rest = all.where((c) => !priority.contains(c)).toList();
    return [...priority, ...rest];
  }

  static List<String> getDistricts(String? city) {
    if (city == null) return [];
    return citiesWithDistricts[city] ?? [];
  }
}
