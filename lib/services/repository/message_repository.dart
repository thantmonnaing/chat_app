import 'dart:async';

import 'package:chat_app/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../auth/auth_service.dart';

class MessageRepository{
  final List<StreamSubscription> _messageSubscriptions = [];


  MessageRepository(){
    clearListeners();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _auth = AuthService();

  QuerySnapshot<Message>? messageQuerysnapshot;
  //List<Message> messages = [];
  ValueNotifier<List<Message>> messageNotifier = ValueNotifier<List<Message>>([]);

  Future<List<Message>> fetchUsers(int limitTo,String? userId,String? otherUserId ) async {
    List<String> ids = [userId!, otherUserId!];
    ids.sort();
    String chatRoomId = ids.join("_");
    try {
      final query = _firestore
          .collection("chat_rooms")
          .doc(chatRoomId)
          .collection("messages")
          .orderBy("message", descending: false)
          .limit(15)
          .withConverter<Message>(
        fromFirestore: (snapshot, _) => Message.fromMap(snapshot.data() ?? {}),
        toFirestore: (a, _) => a.toMap(),
      );

      if (messageQuerysnapshot == null) {
        final messageSubscription = query.snapshots().listen((event) {
          messageQuerysnapshot = event;
          addToMessage(event);
        });
        debugPrint('null running');
        _messageSubscriptions.add(messageSubscription);
      } else {
        final messageSubscription =
        query.startAfterDocument(messageQuerysnapshot?.docs.last as DocumentSnapshot).snapshots().listen((event) {
          messageQuerysnapshot = event;
          addToMessage(event);
        });
        _messageSubscriptions.add(messageSubscription);
        debugPrint('non null running');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return messageNotifier.value;
  }


  void addToMessage(QuerySnapshot<Message> event) {
    for (final messageDoc in event.docs) {
      final message = messageDoc.data();
      final index = messageNotifier.value.indexWhere((element) =>
      message.message == element.message);
      if (index != -1) {
        messageNotifier.value.removeAt(index);
        messageNotifier.value.insert(index, message);
      } else {
        messageNotifier.value.add(message);
      }
    }
  }

  void clearListeners() {
    for (final element in _messageSubscriptions) {
      element.cancel();
    }
    _messageSubscriptions.clear();
    messageNotifier.dispose();
  }

}

