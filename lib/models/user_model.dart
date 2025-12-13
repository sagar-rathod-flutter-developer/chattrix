class UserModel {
  final String id;
  final String name;
  final String email;
  final bool isOnline;
  final String imageUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.isOnline,
    required this.imageUrl,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      isOnline: data['isOnline'] ?? false,
      imageUrl: data['imageUrl'] ?? '', // ✅ SAFE
    );
  }
}
