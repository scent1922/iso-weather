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
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final weather = (current['weather'] as List).first as Map<String, dynamic>;

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
      ),
      sunset: DateTime.fromMillisecondsSinceEpoch(
        (current['sunset'] as int) * 1000,
      ),
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
    );
  }
}
