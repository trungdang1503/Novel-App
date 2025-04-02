class Chapter {
  final String id;
  final String title;
  late final String? content; // Lưu văn bản nhập
  final String? contentUrl; // Lưu URL file
  final String novelId;
  final int chapterNumber;
  final DateTime created;
  final DateTime updated;

  Chapter({
    required this.id,
    required this.title,
    this.content,
    this.contentUrl,
    required this.novelId,
    required this.chapterNumber,
    required this.created,
    required this.updated,
  }) : assert(chapterNumber > 0, 'Số chương phải lớn hơn 0');

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Không có tiêu đề',
      content: json['content'],
      contentUrl: json['content'] != null
          ? "http://your-pocketbase-url/api/files/${json['collectionId']}/${json['id']}/${json['content']}"
          : null,
      novelId: json['novel_id'] ?? '',
      chapterNumber:
          json['chapterNumber'] != null && json['chapterNumber'] is int
              ? json['chapterNumber']
              : 1,
      created: DateTime.tryParse(json['created'] ?? '') ?? DateTime.now(),
      updated: DateTime.tryParse(json['updated'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'novel_id': novelId,
      'chapterNumber': chapterNumber,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }

  Chapter copyWith({
    String? id,
    String? title,
    String? content,
    String? contentUrl,
    String? novelId,
    int? chapterNumber,
    DateTime? created,
    DateTime? updated,
  }) {
    return Chapter(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      contentUrl: contentUrl ?? this.contentUrl,
      novelId: novelId ?? this.novelId,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }
}
