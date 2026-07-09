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

  static List<String> get cities {
    final list = citiesWithDistricts.keys.toList()..sort();
    return list;
  }

  static List<String> getDistricts(String? city) {
    if (city == null) return [];
    return citiesWithDistricts[city] ?? [];
  }
}
