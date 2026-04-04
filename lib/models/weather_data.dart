class WeatherAlert {
  final String event;
  final String description;

  WeatherAlert({required this.event, required this.description});

  factory WeatherAlert.fromJson(Map<String, dynamic> json) {
    return WeatherAlert(
      event: json['event'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

class HourlyWeather {
  final DateTime time;
  final double temp;
  final double feelsLike;
  final int weatherId;
  final String weatherDescription;
  final int humidity;
  final double windSpeed;
  final double? windGust;
  final double? rain1h;
  final double? snow1h;
  final double pop;
  final double uvi;
  final double? dewPoint;
  final int? visibility;

  HourlyWeather({
    required this.time,
    required this.temp,
    required this.feelsLike,
    required this.weatherId,
    required this.weatherDescription,
    required this.humidity,
    required this.windSpeed,
    this.windGust,
    this.rain1h,
    this.snow1h,
    required this.pop,
    required this.uvi,
    this.dewPoint,
    this.visibility,
  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json, int timezoneOffset) {
    final weather = (json['weather'] as List).first as Map<String, dynamic>;
    final rain = json['rain'] as Map<String, dynamic>?;
    final snow = json['snow'] as Map<String, dynamic>?;
    return HourlyWeather(
      time: DateTime.fromMillisecondsSinceEpoch(
        (json['dt'] as int) * 1000,
        isUtc: true,
      ).add(Duration(seconds: timezoneOffset)),
      temp: (json['temp'] as num).toDouble(),
      feelsLike: (json['feels_like'] as num).toDouble(),
      weatherId: weather['id'] as int,
      weatherDescription: weather['description'] as String,
      humidity: json['humidity'] as int,
      windSpeed: (json['wind_speed'] as num).toDouble(),
      windGust: (json['wind_gust'] as num?)?.toDouble(),
      rain1h: rain != null ? (rain['1h'] as num?)?.toDouble() : null,
      snow1h: snow != null ? (snow['1h'] as num?)?.toDouble() : null,
      pop: (json['pop'] as num?)?.toDouble() ?? 0.0,
      uvi: (json['uvi'] as num?)?.toDouble() ?? 0.0,
      dewPoint: (json['dew_point'] as num?)?.toDouble(),
      visibility: json['visibility'] as int?,
    );
  }
}

class DailyWeather {
  final DateTime date;
  final double tempMin;
  final double tempMax;
  final int weatherId;
  final String weatherDescription;
  final int humidity;
  final double windSpeed;

  DailyWeather({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.weatherId,
    required this.weatherDescription,
    required this.humidity,
    required this.windSpeed,
  });

  factory DailyWeather.fromJson(Map<String, dynamic> json, int timezoneOffset) {
    final weather = (json['weather'] as List).first as Map<String, dynamic>;
    final temp = json['temp'] as Map<String, dynamic>;
    return DailyWeather(
      date: DateTime.fromMillisecondsSinceEpoch(
        (json['dt'] as int) * 1000,
        isUtc: true,
      ).add(Duration(seconds: timezoneOffset)),
      tempMin: (temp['min'] as num).toDouble(),
      tempMax: (temp['max'] as num).toDouble(),
      weatherId: weather['id'] as int,
      weatherDescription: weather['description'] as String,
      humidity: json['humidity'] as int,
      windSpeed: (json['wind_speed'] as num).toDouble(),
    );
  }
}

class WeatherData {
  final double temp;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final double uvi;
  final int weatherId;
  final String weatherDescription;
  final DateTime sunrise;
  final DateTime sunset;
  final int timezoneOffset;
  final int? pressure;
  final int? visibility;
  final double? dewPoint;
  final int? windDeg;
  final List<HourlyWeather> hourly;
  final List<DailyWeather> daily;
  final List<WeatherAlert> alerts;

  WeatherData({
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.uvi,
    required this.weatherId,
    required this.weatherDescription,
    required this.sunrise,
    required this.sunset,
    this.timezoneOffset = 0,
    this.pressure,
    this.visibility,
    this.dewPoint,
    this.windDeg,
    this.hourly = const [],
    this.daily = const [],
    this.alerts = const [],
  });

  DateTime get localNow =>
      DateTime.now().toUtc().add(Duration(seconds: timezoneOffset));

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final weather = (current['weather'] as List).first as Map<String, dynamic>;
    final tzOffset = json['timezone_offset'] as int? ?? 0;

    final hourlyList = (json['hourly'] as List?)
        ?.take(24)
        .map((h) => HourlyWeather.fromJson(h as Map<String, dynamic>, tzOffset))
        .toList() ?? [];

    final dailyList = (json['daily'] as List?)
        ?.take(7)
        .map((d) => DailyWeather.fromJson(d as Map<String, dynamic>, tzOffset))
        .toList() ?? [];

    final alertsList = (json['alerts'] as List?)
        ?.map((a) => WeatherAlert.fromJson(a as Map<String, dynamic>))
        .toList() ?? [];

    return WeatherData(
      temp: (current['temp'] as num).toDouble(),
      feelsLike: (current['feels_like'] as num).toDouble(),
      humidity: current['humidity'] as int,
      windSpeed: (current['wind_speed'] as num).toDouble(),
      uvi: (current['uvi'] as num).toDouble(),
      weatherId: weather['id'] as int,
      weatherDescription: weather['description'] as String,
      sunrise: DateTime.fromMillisecondsSinceEpoch(
        (current['sunrise'] as int) * 1000,
        isUtc: true,
      ).add(Duration(seconds: tzOffset)),
      sunset: DateTime.fromMillisecondsSinceEpoch(
        (current['sunset'] as int) * 1000,
        isUtc: true,
      ).add(Duration(seconds: tzOffset)),
      timezoneOffset: tzOffset,
      pressure: current['pressure'] as int?,
      visibility: current['visibility'] as int?,
      dewPoint: (current['dew_point'] as num?)?.toDouble(),
      windDeg: current['wind_deg'] as int?,
      hourly: hourlyList,
      daily: dailyList,
      alerts: alertsList,
    );
  }

  Map<String, dynamic> toJson() => {
    'temp': temp,
    'feelsLike': feelsLike,
    'humidity': humidity,
    'windSpeed': windSpeed,
    'uvi': uvi,
    'weatherId': weatherId,
    'weatherDescription': weatherDescription,
    'sunrise': sunrise.millisecondsSinceEpoch,
    'sunset': sunset.millisecondsSinceEpoch,
    'timezoneOffset': timezoneOffset,
    'pressure': pressure,
    'visibility': visibility,
    'dewPoint': dewPoint,
    'windDeg': windDeg,
  };

  factory WeatherData.fromCache(Map<String, dynamic> json) {
    return WeatherData(
      temp: (json['temp'] as num).toDouble(),
      feelsLike: (json['feelsLike'] as num).toDouble(),
      humidity: json['humidity'] as int,
      windSpeed: (json['windSpeed'] as num).toDouble(),
      uvi: (json['uvi'] as num).toDouble(),
      weatherId: json['weatherId'] as int,
      weatherDescription: json['weatherDescription'] as String,
      sunrise: DateTime.fromMillisecondsSinceEpoch(json['sunrise'] as int),
      sunset: DateTime.fromMillisecondsSinceEpoch(json['sunset'] as int),
      timezoneOffset: json['timezoneOffset'] as int? ?? 0,
      pressure: json['pressure'] as int?,
      visibility: json['visibility'] as int?,
      dewPoint: (json['dewPoint'] as num?)?.toDouble(),
      windDeg: json['windDeg'] as int?,
    );
  }
}
