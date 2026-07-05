class LatLngData {
  const LatLngData({required this.lat, required this.lng});
  final double lat;
  final double lng;

  factory LatLngData.fromJson(Map<String, dynamic> j) => LatLngData(
        lat: (j['lat'] as num?)?.toDouble() ?? 0.0,
        lng: (j['lng'] as num?)?.toDouble() ?? 0.0,
      );
}

class MapStopData {
  const MapStopData({
    required this.id,
    required this.type,
    required this.status,
    required this.passengerName,
    required this.address,
    required this.eta,
    required this.latlng,
  });

  final String id; // also used as bookingUuid for stop-done endpoint
  final String type;   // 'pickup' | 'dropoff'
  final String status; // 'pending' | 'approaching' | 'done'
  final String passengerName;
  final String address;
  final String eta;
  final LatLngData latlng;

  factory MapStopData.fromJson(Map<String, dynamic> j) => MapStopData(
        id: j['id'] as String? ?? '',
        type: j['type'] as String? ?? 'pickup',
        status: j['status'] as String? ?? 'pending',
        passengerName: j['passenger_name'] as String? ?? '',
        address: j['address'] as String? ?? '',
        eta: j['eta'] as String? ?? '',
        latlng: LatLngData.fromJson(j['latlng'] as Map<String, dynamic>? ?? {}),
      );
}

class MapDataModel {
  const MapDataModel({
    required this.driverPosition,
    required this.stops,
    required this.routePolyline,
    required this.routeDistance,
    required this.routeEta,
    required this.routeFuel,
    required this.currentStopIndex,
    required this.completedStops,
    required this.totalStops,
  });

  final LatLngData driverPosition;
  final List<MapStopData> stops;
  final List<LatLngData> routePolyline;
  final String routeDistance;
  final String routeEta;
  final String routeFuel;
  final int currentStopIndex;
  final int completedStops;
  final int totalStops;

  factory MapDataModel.fromJson(Map<String, dynamic> j) => MapDataModel(
        driverPosition:
            LatLngData.fromJson(j['driver_position'] as Map<String, dynamic>? ?? {}),
        stops: (j['stops'] as List<dynamic>? ?? [])
            .map((e) => MapStopData.fromJson(e as Map<String, dynamic>))
            .toList(),
        routePolyline: (j['route_polyline'] as List<dynamic>? ?? [])
            .map((e) => LatLngData.fromJson(e as Map<String, dynamic>))
            .toList(),
        routeDistance: j['route_distance'] as String? ?? '',
        routeEta: j['route_eta'] as String? ?? '',
        routeFuel: j['route_fuel'] as String? ?? '',
        currentStopIndex: j['current_stop_index'] as int? ?? 0,
        completedStops: j['completed_stops'] as int? ?? 0,
        totalStops: j['total_stops'] as int? ?? 0,
      );
}

class StopDoneResult {
  const StopDoneResult({
    required this.stopId,
    required this.pickedUpAt,
    required this.nextStopIndex,
  });
  final String stopId;
  final String pickedUpAt;
  final int nextStopIndex;

  factory StopDoneResult.fromJson(Map<String, dynamic> j) => StopDoneResult(
        stopId: j['stop_id'] as String? ?? '',
        pickedUpAt: j['picked_up_at'] as String? ?? '',
        nextStopIndex: j['next_stop_index'] as int? ?? 0,
      );
}

class RecalculateResult {
  const RecalculateResult({
    required this.optimized,
    required this.stops,
    required this.routePolyline,
    required this.routeDistance,
    required this.routeEta,
    required this.routeFuel,
    required this.currentStopIndex,
  });

  final bool optimized;
  final List<MapStopData> stops;
  final List<LatLngData> routePolyline;
  final String routeDistance;
  final String routeEta;
  final String routeFuel;
  final int currentStopIndex;

  factory RecalculateResult.fromJson(Map<String, dynamic> j) => RecalculateResult(
        optimized: j['optimized'] as bool? ?? false,
        stops: (j['stops'] as List<dynamic>? ?? [])
            .map((e) => MapStopData.fromJson(e as Map<String, dynamic>))
            .toList(),
        routePolyline: (j['route_polyline'] as List<dynamic>? ?? [])
            .map((e) => LatLngData.fromJson(e as Map<String, dynamic>))
            .toList(),
        routeDistance: j['route_distance'] as String? ?? '',
        routeEta: j['route_eta'] as String? ?? '',
        routeFuel: j['route_fuel'] as String? ?? '',
        currentStopIndex: j['current_stop_index'] as int? ?? 0,
      );
}
