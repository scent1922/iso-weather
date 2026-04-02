class ClothingConditions {
  final String tempRange;
  final List<String> weather;
  final List<String> wind;
  final List<String> humidity;

  ClothingConditions({
    required this.tempRange,
    required this.weather,
    required this.wind,
    required this.humidity,
  });

  factory ClothingConditions.fromJson(Map<String, dynamic> json) {
    return ClothingConditions(
      tempRange: json['temp_range'] as String,
      weather: List<String>.from(json['weather']),
      wind: List<String>.from(json['wind']),
      humidity: List<String>.from(json['humidity']),
    );
  }
}

class ClothingCase {
  final String id;
  final int priority;
  final ClothingConditions conditions;
  final List<String> messages;
  final List<String> items;

  ClothingCase({
    required this.id,
    required this.priority,
    required this.conditions,
    required this.messages,
    required this.items,
  });

  factory ClothingCase.fromJson(Map<String, dynamic> json) {
    return ClothingCase(
      id: json['id'] as String,
      priority: json['priority'] as int,
      conditions: ClothingConditions.fromJson(json['conditions']),
      messages: List<String>.from(json['messages']),
      items: List<String>.from(json['items']),
    );
  }
}
