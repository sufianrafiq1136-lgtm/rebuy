class User {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final int itemsListed;
  final int itemsSold;
  final int itemsBought;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.itemsListed = 0,
    this.itemsSold = 0,
    this.itemsBought = 0,
    required this.createdAt,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    int? itemsListed,
    int? itemsSold,
    int? itemsBought,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      itemsListed: itemsListed ?? this.itemsListed,
      itemsSold: itemsSold ?? this.itemsSold,
      itemsBought: itemsBought ?? this.itemsBought,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

typedef UserModel = User;

