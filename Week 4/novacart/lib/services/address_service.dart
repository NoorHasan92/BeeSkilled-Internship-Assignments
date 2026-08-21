import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/saved_address.dart';

class AddressService {
  static final AddressService instance = AddressService._();
  AddressService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference get _addressesRef {
    if (_uid == null) throw Exception('User not logged in');
    return _firestore.collection('users').doc(_uid).collection('addresses');
  }

  Stream<List<SavedAddress>> streamAddresses() {
    if (_uid == null) return Stream.value([]);
    return _addressesRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => SavedAddress.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> addAddress(SavedAddress address) async {
    final data = address.toMap();
    if (address.isDefault) {
      await _clearOtherDefaults();
    }
    await _addressesRef.add(data);
  }

  Future<void> updateAddress(SavedAddress address) async {
    final data = address.toMap();
    if (address.isDefault) {
      await _clearOtherDefaults();
    }
    await _addressesRef.doc(address.id).update(data);
  }

  Future<void> deleteAddress(String id) async {
    await _addressesRef.doc(id).delete();
  }

  Future<void> setDefault(String id) async {
    await _clearOtherDefaults();
    await _addressesRef.doc(id).update({'isDefault': true});
  }

  Future<void> _clearOtherDefaults() async {
    final query = await _addressesRef.where('isDefault', isEqualTo: true).get();
    for (var doc in query.docs) {
      await doc.reference.update({'isDefault': false});
    }
  }
}
