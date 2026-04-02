/// OpenWeatherMap 날씨 설명 영→한 번역 매핑
class WeatherTranslations {
  static String translate(String description) {
    final key = description.toLowerCase().trim();
    return _translations[key] ?? description;
  }

  static const Map<String, String> _translations = {
    // Thunderstorm (2xx)
    'thunderstorm with light rain': '가벼운 비를 동반한 뇌우',
    'thunderstorm with rain': '비를 동반한 뇌우',
    'thunderstorm with heavy rain': '폭우를 동반한 뇌우',
    'light thunderstorm': '약한 뇌우',
    'thunderstorm': '뇌우',
    'heavy thunderstorm': '강한 뇌우',
    'ragged thunderstorm': '불규칙 뇌우',
    'thunderstorm with light drizzle': '가벼운 이슬비를 동반한 뇌우',
    'thunderstorm with drizzle': '이슬비를 동반한 뇌우',
    'thunderstorm with heavy drizzle': '강한 이슬비를 동반한 뇌우',

    // Drizzle (3xx)
    'light intensity drizzle': '가벼운 이슬비',
    'drizzle': '이슬비',
    'heavy intensity drizzle': '강한 이슬비',
    'light intensity drizzle rain': '가벼운 이슬비',
    'drizzle rain': '이슬비',
    'heavy intensity drizzle rain': '강한 이슬비',
    'shower rain and drizzle': '소나기와 이슬비',
    'heavy shower rain and drizzle': '강한 소나기와 이슬비',
    'shower drizzle': '소나기성 이슬비',

    // Rain (5xx)
    'light rain': '가벼운 비',
    'moderate rain': '보통 비',
    'heavy intensity rain': '강한 비',
    'very heavy rain': '매우 강한 비',
    'extreme rain': '극심한 비',
    'freezing rain': '어는 비',
    'light intensity shower rain': '약한 소나기',
    'shower rain': '소나기',
    'heavy intensity shower rain': '강한 소나기',
    'ragged shower rain': '불규칙 소나기',

    // Snow (6xx)
    'light snow': '가벼운 눈',
    'snow': '눈',
    'heavy snow': '폭설',
    'sleet': '진눈깨비',
    'light shower sleet': '약한 진눈깨비',
    'shower sleet': '진눈깨비 소나기',
    'light rain and snow': '가벼운 비와 눈',
    'rain and snow': '비와 눈',
    'light shower snow': '약한 소나기 눈',
    'shower snow': '소나기 눈',
    'heavy shower snow': '강한 소나기 눈',

    // Atmosphere (7xx)
    'mist': '안개',
    'smoke': '연기',
    'haze': '연무',
    'sand/dust whirls': '모래/먼지 회오리',
    'fog': '짙은 안개',
    'sand': '모래바람',
    'dust': '먼지',
    'volcanic ash': '화산재',
    'squalls': '돌풍',
    'tornado': '토네이도',

    // Clear (800)
    'clear sky': '맑음',

    // Clouds (80x)
    'few clouds': '구름 조금',
    'scattered clouds': '구름 약간',
    'broken clouds': '구름 많음',
    'overcast clouds': '흐림',

    // Korean descriptions from API (lang=ko already applied)
    '맑음': '맑음',
    '구름조금': '구름 조금',
    '안개': '안개',
  };
}
