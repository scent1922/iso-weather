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
    // 대한민국 주요 도시
    City(id: 'busan', nameKo: '부산광역시', nameEn: 'Busan', lat: 35.1796, lon: 129.0756),
    City(id: 'daegu', nameKo: '대구광역시', nameEn: 'Daegu', lat: 35.8714, lon: 128.6014),
    City(id: 'incheon', nameKo: '인천광역시', nameEn: 'Incheon', lat: 37.4563, lon: 126.7052),
    City(id: 'daejeon', nameKo: '대전광역시', nameEn: 'Daejeon', lat: 36.3504, lon: 127.3845),
    City(id: 'gwangju', nameKo: '광주광역시', nameEn: 'Gwangju', lat: 35.1595, lon: 126.8526),
    City(id: 'ulsan', nameKo: '울산광역시', nameEn: 'Ulsan', lat: 35.5384, lon: 129.3114),
    City(id: 'jeju', nameKo: '제주특별자치도', nameEn: 'Jeju', lat: 33.4996, lon: 126.5312),
    City(id: 'sejong', nameKo: '세종특별자치시', nameEn: 'Sejong', lat: 36.4800, lon: 127.2590),
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
      final distance = calculateDistance(lat, lon, city.lat, city.lon);
      if (distance < minDistance) {
        minDistance = distance;
        closest = city;
      }
    }

    return closest;
  }

  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;
    return dLat * dLat + dLon * dLon;
  }
}
