import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String receiverId;
  final String senderId;
  final String senderEmail;
  final String message;
  final Timestamp timestamp;

  Message(
      {required this.receiverId,
      required this.senderId,
      required this.senderEmail,
      required this.message,
      required this.timestamp});

  //convert to map

  Map<String, dynamic> toMap() {
    return {
      "receiverId": receiverId,
      "senderId": senderId,
      "senderEmail": senderEmail,
      "message": message,
      "timestamp": timestamp
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      receiverId: map['receiverId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderEmail: map['senderEmail'] ?? '',
      message: map['message'] ?? '',
      timestamp: map['timestamp'] ?? ''
    );
  }

}
