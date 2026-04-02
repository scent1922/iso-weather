class City {
  final String id;
  final String nameKo;
  final String nameEn;
  final double lat;
  final double lon;

  const City({
    required this.id,
    required this.nameKo,
    required this.nameEn,
    required this.lat,
    required this.lon,
  });

  static const List<City> supportedCities = [
    City(id: 'seoul', nameKo: '서울특별시', nameEn: 'Seoul', lat: 37.5665, lon: 126.9780),
    City(id: 'tokyo', nameKo: '도쿄', nameEn: 'Tokyo', lat: 35.6762, lon: 139.6503),
    City(id: 'beijing', nameKo: '베이징', nameEn: 'Beijing', lat: 39.9042, lon: 116.4074),
    City(id: 'shanghai', nameKo: '상하이', nameEn: 'Shanghai', lat: 31.2304, lon: 121.4737),
    City(id: 'newyork', nameKo: '뉴욕', nameEn: 'New York', lat: 40.7128, lon: -74.0060),
    City(id: 'sydney', nameKo: '시드니', nameEn: 'Sydney', lat: -33.8688, lon: 151.2093),
    City(id: 'paris', nameKo: '파리', nameEn: 'Paris', lat: 48.8566, lon: 2.3522),
    City(id: 'london', nameKo: '런던', nameEn: 'London', lat: 51.5074, lon: -0.1278),
    City(id: 'berlin', nameKo: '베를린', nameEn: 'Berlin', lat: 52.5200, lon: 13.4050),
    City(id: 'madrid', nameKo: '마드리드', nameEn: 'Madrid', lat: 40.4168, lon: -3.7038),
    City(id: 'barcelona', nameKo: '바르셀로나', nameEn: 'Barcelona', lat: 41.3851, lon: 2.1734),
  ];

  static City findById(String id) {
    return supportedCities.firstWhere(
      (city) => city.id == id,
      orElse: () => supportedCities.first,
    );
  }

  static City? findClosest(double lat, double lon) {
    City? closest;
    double minDistance = double.infinity;

    for (final city in supportedCities) {
      final distance = _calculateDistance(lat, lon, city.lat, city.lon);
      if (distance < minDistance) {
        minDistance = distance;
        closest = city;
      }
    }

    return closest;
  }

  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;
    return dLat * dLat + dLon * dLon;
  }
}
