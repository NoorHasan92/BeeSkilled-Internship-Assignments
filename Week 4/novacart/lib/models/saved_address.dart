class SavedAddress {
  final String id;
  final String label; // Home, Work, Other
  final String fullName;
  final String phone;
  final String addressLine;
  final String city;
  final String state;
  final String pinCode;
  final bool isDefault;

  SavedAddress({
    required this.id,
    required this.label,
    required this.fullName,
    required this.phone,
    required this.addressLine,
    required this.city,
    required this.state,
    required this.pinCode,
    this.isDefault = false,
  });

  factory SavedAddress.fromMap(String id, Map<String, dynamic> data) {
    return SavedAddress(
      id: id,
      label: data['label'] ?? 'Home',
      fullName: data['fullName'] ?? '',
      phone: data['phone'] ?? '',
      addressLine: data['addressLine'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      pinCode: data['pinCode'] ?? '',
      isDefault: data['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'fullName': fullName,
      'phone': phone,
      'addressLine': addressLine,
      'city': city,
      'state': state,
      'pinCode': pinCode,
      'isDefault': isDefault,
    };
  }
}
