class Tags {
  final String id;
  final String name;

  Tags({
    required this.id,
    required this.name,
  });

  factory Tags.fromJson(Map<String, dynamic> json) {
    return Tags(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}
