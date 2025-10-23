// lib/features/photo_attachment/domain/entities/photo_attachment_entity.dart
class PhotoAttachment {
  final String id;
  final String expenseId;
  final String userId;
  final String fileName;
  final String filePath;
  final String? thumbnailPath;
  final int fileSize;
  final String mimeType;
  final DateTime createdAt;
  final String? description;

  PhotoAttachment({
    required this.id,
    required this.expenseId,
    required this.userId,
    required this.fileName,
    required this.filePath,
    this.thumbnailPath,
    required this.fileSize,
    required this.mimeType,
    required this.createdAt,
    this.description,
  });

  PhotoAttachment copyWith({
    String? id,
    String? expenseId,
    String? userId,
    String? fileName,
    String? filePath,
    String? thumbnailPath,
    int? fileSize,
    String? mimeType,
    DateTime? createdAt,
    String? description,
  }) {
    return PhotoAttachment(
      id: id ?? this.id,
      expenseId: expenseId ?? this.expenseId,
      userId: userId ?? this.userId,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'expenseId': expenseId,
      'userId': userId,
      'fileName': fileName,
      'filePath': filePath,
      'thumbnailPath': thumbnailPath,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'createdAt': createdAt.toIso8601String(),
      'description': description,
    };
  }

  factory PhotoAttachment.fromMap(Map<String, dynamic> map) {
    return PhotoAttachment(
      id: map['id'] as String,
      expenseId: map['expenseId'] as String,
      userId: map['userId'] as String,
      fileName: map['fileName'] as String,
      filePath: map['filePath'] as String,
      thumbnailPath: map['thumbnailPath'] as String?,
      fileSize: map['fileSize'] as int,
      mimeType: map['mimeType'] as String,
      createdAt: DateTime.parse(map['createdAt']),
      description: map['description'] as String?,
    );
  }
}
