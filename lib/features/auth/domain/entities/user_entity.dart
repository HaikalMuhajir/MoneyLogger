class UserEntity {
  final String uid;
  final String? email;
  final String? name;

  UserEntity({
    required this.uid,
    this.email,
    this.name,
  });

  // Metode untuk membuat salinan objek dengan properti yang diubah
  UserEntity copyWith({
    String? uid,
    String? email,
    String? name,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
    );
  }

  static UserEntity fromFirebaseUser(dynamic firebaseUser) {
    if (firebaseUser == null) {
      throw ArgumentError("Firebase User object cannot be null.");
    }

    return UserEntity(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      name: firebaseUser.displayName,
    );
  }

  @override
  String toString() {
    return 'UserEntity(uid: $uid, email: $email, name: $name)';
  }
}
