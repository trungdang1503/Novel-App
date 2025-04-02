import 'dart:io';

class Novel {
  final String id;
  final String title;
  final String description;
  final int chapter;
  final File? featuredImage; // File ảnh lưu local
  final String imageUrl; // URL ảnh từ API
  final List<String> tags;
  final int view;
  final String created;
  final String updated;

  Novel({
    required this.id,
    required this.title,
    required this.description,
    required this.chapter,
    this.featuredImage,
    this.imageUrl = '',
    required this.tags,
    required this.view,
    required this.created,
    required this.updated,
  });

  Novel copyWith({
    String? id,
    String? title,
    String? description,
    int? chapter,
    File? featuredImage,
    String? imageUrl,
    List<String>? tags,
    int? view,
    String? created,
    String? updated,
  }) {
    return Novel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      chapter: chapter ?? this.chapter,
      featuredImage: featuredImage ?? this.featuredImage,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      view: view ?? this.view,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  bool hasFeaturedImage() {
    return featuredImage != null || imageUrl.isNotEmpty;
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'chapter': chapter,
      'tag': tags,
      'view': view,
      'created': created,
      'updated': updated,
    };
  }

  factory Novel.fromJson(Map<String, dynamic> json) {
    return Novel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      chapter: json['chapter'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      view: json['view'] ?? 0,
      created: json['created'] ?? '',
      updated: json['updated'] ?? '',
    );
  }
}
