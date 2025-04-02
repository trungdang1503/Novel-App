import 'dart:io';

class User {
  final String id;
  final String email;
  final String? name;
  final String? description;
  final File? avatar; // File nội bộ
  final String imageUrl; // URL từ API

  User({
    required this.id,
    required this.email,
    this.name,
    this.description,
    this.avatar,
    this.imageUrl = '',
  });

  /// Copy một user mới từ user hiện tại
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? description,
    File? avatar,
    String? imageUrl,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      description: description ?? this.description,
      avatar: avatar ?? this.avatar,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  /// Kiểm tra người dùng có ảnh đại diện không
  bool hasFeaturedImage() {
    return avatar != null || imageUrl.isNotEmpty;
  }

  /// Convert từ object User sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'description': description,
    };
  }

  /// Tạo User từ JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
