class Category {
  final String id;
  final String name;
  final String colorHex;
  final bool isPending;
  final String? userId;
  final DateTime? lastModified; // Tambahkan ini agar sinkronisasi tidak error

  Category({
    required this.id,
    required this.name,
    required this.colorHex,
    this.isPending = false,
    this.userId,
    this.lastModified,
  });

  // Diperlukan oleh CategoryRepositoryImpl untuk menandai data sync
  Category copyWith({
    String? userId,
    bool? isPending,
    DateTime? lastModified,
  }) {
    return Category(
      id: id,
      name: name,
      colorHex: colorHex,
      isPending: isPending ?? this.isPending,
      userId: userId ?? this.userId,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  // Placeholder untuk konversi ke format data
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'colorHex': colorHex,
        'userId': userId,
        'lastModified': lastModified?.toIso8601String(),
      };

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      colorHex: map['colorHex'] as String,
      userId: map['userId'] as String?,
      // Ini hanya dummy, implementasi penuh akan ada di Data Layer
      isPending: false,
      lastModified: map['lastModified'] != null
          ? DateTime.parse(map['lastModified'])
          : null,
    );
  }
}
