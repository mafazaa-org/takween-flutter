class Entity {
  final int id;
  final String name;

  Entity({
    required this.id,
    required this.name,
  });

  factory Entity.fromJson(Map<String, dynamic> json) {
    return Entity(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

