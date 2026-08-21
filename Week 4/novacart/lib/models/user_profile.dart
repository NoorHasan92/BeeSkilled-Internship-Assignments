class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String phone;
  final String address;

  UserProfile({
    required this.uid,
    required this.email,
    this.displayName = '',
    this.phone = '',
    this.address = '',
  });

  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'phone': phone,
      'address': address,
    };
  }
}
