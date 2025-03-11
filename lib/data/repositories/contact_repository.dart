import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:messenger_app/data/models/user_model.dart';
import 'package:messenger_app/data/services/base_repository.dart';

class ContactRepository extends BaseRepository {
  @override
  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<bool> requestContactsPermission() async {
    return await FlutterContacts.requestPermission();
  }

  Future<List<Map<String, dynamic>>> getRegisteredContacts() async {
    try {
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );
      // log(contacts.toString());

      final phoneNumbers = contacts
          .where((contact) => contact.phones.isNotEmpty)
          .map((contact) => {
                'name': contact.displayName,
                'phoneNumber': contact.phones.first.number
                    .replaceAll(RegExp(r'[^\d+]'), ''),
                'photo': contact.photo,
              })
          .toList();
      // log(phoneNumbers.toString());

      final usersSnapshot = await firestore.collection("users").get();
      // log(usersSnapshot.docs.toString());

      final registeredUsers = usersSnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
      // log(registeredUsers.first.toString());

      final matchedContacts = phoneNumbers.where((contact) {
        String phoneNumber = contact["phoneNumber"].toString();
        // log("matchedcontacts= ${phoneNumber.toString()}");
        if (phoneNumber.startsWith("+91")) {
          phoneNumber = phoneNumber.substring(3);
        }
        return registeredUsers.any((user) =>
            user.phoneNumber == phoneNumber && user.uid != currentUserId);
      }).map((contact) {
        String phoneNumber = contact["phoneNumber"].toString();
        if (phoneNumber.startsWith("+91")) {
          phoneNumber = phoneNumber.substring(3);
        }
        final registeredUser = registeredUsers
            .firstWhere((user) => user.phoneNumber == phoneNumber);
        return {
          'id': registeredUser.uid,
          'name': contact["name"],
          'phoneNumber': contact["phoneNumber"],
        };
      }).toList();
      log(matchedContacts.toString());
      return matchedContacts;
    } catch (e) {
      print("Error getting registered users");
      return [];
    }
  }
}
