import 'package:chat_app/models/message.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  //get instnce of firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _auth = AuthService();

  // get user stream
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

// send message

  Future<void> sendMessage(String receiverId, message) async {
    //get current user info
    final String currentUserId = _auth.getCurrentUser()!.uid;
    final String currentUserEmail = _auth.getCurrentUser()!.email!;
    final Timestamp timestamp = Timestamp.now();

    // create new message
    Message newMessage = Message(
        receiverId: receiverId,
        senderId: currentUserId,
        senderEmail: currentUserEmail,
        message: message,
        timestamp: timestamp);

    //create chat room id for two users

    List<String> ids = [receiverId, currentUserId];
    ids.sort(); //sort the ids (chatRoomId need to same for any two people)
    String chatRoomId = ids.join("_");

    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .add(newMessage.toMap());

    //add new message to database
  }

// get message

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  // add 200 message for test
  Future<void> test200Message(String receiverId, message) async {
    //get current user info
    final String currentUserId = _auth.getCurrentUser()!.uid;
    final String currentUserEmail = _auth.getCurrentUser()!.email!;
    final Timestamp timestamp = Timestamp.now();

    for (int i = 1; i <= 200; i++) {
      // Generates a unique key for each record
// create new message
    Future.delayed(const Duration(seconds: 1),() async{
      Message newMessage = Message(
          receiverId: receiverId,
          senderId: currentUserId,
          senderEmail: currentUserEmail,
          message: "message $i",
          timestamp: timestamp);

      //create chat room id for two users

      List<String> ids = [receiverId, currentUserId];
      ids.sort(); //sort the ids (chatRoomId need to same for any two people)
      String chatRoomId = ids.join("_");

      await _firestore
          .collection("chat_rooms")
          .doc(chatRoomId)
          .collection("messages")
          .add(newMessage.toMap());

      //add new message to database
      if (i == 200) {
        // create new message
        Message newMessage = Message(
            receiverId: receiverId,
            senderId: currentUserId,
            senderEmail: currentUserEmail,
            message: "Last message",
            timestamp: timestamp);

        //create chat room id for two users

        List<String> ids = [receiverId, currentUserId];
        ids.sort(); //sort the ids (chatRoomId need to same for any two people)
        String chatRoomId = ids.join("_");

        await _firestore
            .collection("chat_rooms")
            .doc(chatRoomId)
            .collection("messages")
            .add(newMessage.toMap());

        //add new message to database
      }
    });
    }
  }

  // get message by limit

  Stream<QuerySnapshot> getInitialStream(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("message", descending: false)
        .limit(15)
        .snapshots();
  }

  Future<Query> loadMoreData(String userId, String otherUserId,
      DocumentSnapshot lastDoc, int limit) async {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");
    Query query = _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("message", descending: false)
        .startAfterDocument(lastDoc)
        .limit(limit);

    return query;
  }
}
