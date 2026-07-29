class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final String relation;
  final String initials;

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.relation,
    this.initials = '',
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> j) {
    final rawName = (j['name'] ?? '').toString();
    final apiInitials = (j['initials'] ?? '').toString();
    final computed = apiInitials.isNotEmpty
        ? apiInitials
        : rawName.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).take(2)
            .map((w) => w[0].toUpperCase()).join();
    return EmergencyContact(
      id: (j['uuid'] ?? j['id'] ?? '').toString(),
      name: rawName,
      phone: (j['phone'] ?? j['phone_number'] ?? '').toString(),
      relation: (j['relation'] ?? j['relationship'] ?? '').toString(),
      initials: computed,
    );
  }
}

class SafetyContext {
  final bool sosActive;
  final bool tripShareActive;
  final String? tripShareCode;
  final List<EmergencyContact> contacts;

  const SafetyContext({
    required this.sosActive,
    required this.tripShareActive,
    this.tripShareCode,
    required this.contacts,
  });

  factory SafetyContext.fromJson(Map<String, dynamic> j) {
    final share = j['trip_share'] as Map?;
    return SafetyContext(
      sosActive: j['sos_active'] as bool? ?? false,
      tripShareActive: share?['active'] as bool? ?? false,
      tripShareCode: share?['code']?.toString(),
      contacts: ((j['emergency_contacts'] as List?) ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => EmergencyContact.fromJson(e))
          .toList(),
    );
  }
}
