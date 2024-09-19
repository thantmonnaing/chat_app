import 'dart:async';

import 'package:chat_app/components/my_textfield.dart';
import 'package:chat_app/components/user_tile.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../components/chat_bubble.dart';
import '../components/my_drawer.dart';

class Test1ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverId;

  Test1ChatPage(
      {super.key, required this.receiverEmail, required this.receiverId});

  @override
  State<Test1ChatPage> createState() => _Test1ChatPageState();
}

class _Test1ChatPageState extends State<Test1ChatPage> {
  // chat & auth services
  final ChatService _chatService = ChatService();

  final AuthService _authService = AuthService();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FocusNode focusNode = FocusNode();

  //message textField
  TextEditingController _messageTextController = TextEditingController();

  List<DocumentSnapshot> _documents = [];
  DocumentSnapshot? _lastDocument;
  bool _loadingMore = false;
  int _limit = 10;
  bool _hasMoreData = true;
  String chatRoomId = '';
  int _messageLimit = 20;

  final StreamController<List<DocumentSnapshot>> _streamController =
      StreamController<List<DocumentSnapshot>>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    String currentUserId = _authService.getCurrentUser()!.uid;
    List<String> ids = [widget.receiverId, currentUserId];
    ids.sort(); //sort the ids (chatRoomId need to same for any two people)
    chatRoomId = ids.join("_");
    _getInitialData();

    // textField focus scroll position
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        Future.delayed(
            const Duration(milliseconds: 500), () => _scrollDownPosition());
      }
    });

    // Attach the scroll listener
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_loadingMore &&
          _hasMoreData) {
        _loadMoreData();
      }
    });
  }

  _getInitialData() async {
    String senderId = _authService.getCurrentUser()!.uid;
    _chatService
        .getInitialStream(senderId, widget.receiverId)
        .listen((snapshot) {
      List<DocumentSnapshot> docs = snapshot.docs;
      if (_documents.isEmpty) {
        setState(() {
          _documents = docs;
          _lastDocument = docs.isNotEmpty ? docs.last : null;
        });
      } else {
        setState(() {
          _documents.addAll(snapshot.docs);
        });
      }
      _streamController.add(_documents);
    });
  }

  Future<void> _loadMoreData() async {
    String senderId = _authService.getCurrentUser()!.uid;
    if (_lastDocument == null || !_hasMoreData) return;

    setState(() {
      _loadingMore = true;
    });


    QuerySnapshot moreMessagesSnapshot = await _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .startAfterDocument(_lastDocument!)
        .limit(_messageLimit)
        .get();

    if (moreMessagesSnapshot.docs.isNotEmpty) {
      setState(() {
        _documents.addAll(moreMessagesSnapshot.docs);
        _lastDocument = moreMessagesSnapshot.docs.last;
      });
    } else {
      setState(() {
        _hasMoreData = false; // No more messages to load
      });
    }



    /*Query query = await _chatService.loadMoreData(
        senderId, widget.receiverId, _lastDocument!, _limit);

    QuerySnapshot querySnapshot = await query.get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        _documents.addAll(querySnapshot.docs);
        _lastDocument = querySnapshot.docs.last;
        _loadingMore = false;
      });
      _streamController.add(_documents);
    } else {
      setState(() {
        _hasMoreData = false;
        _loadingMore = false; // No more data to load
      });
    }*/

    setState(() {
      _loadingMore = false;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    focusNode.dispose();
    _messageTextController.dispose();
    _scrollController.dispose();
    _streamController.close();
    super.dispose();
  }

  ScrollController _scrollController = ScrollController();

  void _scrollDownPosition() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1), curve: Curves.fastOutSlowIn);
  }

  //send message function
  void sendMessage() async {
    if (_messageTextController.text.isNotEmpty) {
      await _chatService
          .sendMessage(widget.receiverId, _messageTextController.text)
          .then((_) {
        _messageTextController.clear();
        _scrollDownPosition();
      });
    }
  }

  //send message function
  void test200Message() async {
    await _chatService
        .test200Message(widget.receiverId, _messageTextController.text)
        .then((_) {
      _messageTextController.clear();
      //_scrollDownPosition();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(widget.receiverEmail),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      body: Column(
        children: [
          //message list
          Expanded(child: _buildMessageList()),
          _messageField(),
          const SizedBox(
            height: 30,
          ),

          /*Container(
            color: Theme.of(context).colorScheme.primary,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: IconButton(
              onPressed: test200Message,
              icon: const Icon(Icons.send),
            ),
          )*/

          //message text field
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
        stream: _streamController.stream,
        builder: (context, snapshot) {
          //error
          if (snapshot.hasError) {
            return const Text("Error...");
          }

          // loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading...");
          }

          if (snapshot.data!.isEmpty) {
            _hasMoreData = false;
            return Container();
          }

          List<DocumentSnapshot> docs =
              snapshot.data!; // Store the last document for pagination

          return ReorderableListView.builder(
            onReorder: (int oldIndex, int newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final item = docs.removeAt(oldIndex);
                docs.insert(newIndex, item);
                print(docs);
              });
            },
            scrollController: _scrollController,
            itemCount: docs.length + (_loadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == docs.length) {
                return Center(
                  key: UniqueKey(),
                    child: const CircularProgressIndicator());
              }

              DocumentSnapshot doc = docs[index];
              return _buildMessageItem(doc);
            },
          );

          /*ListView.builder(
            controller: _scrollController,
            itemCount: docs.length + (_loadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == docs.length) {
                return const Center(child: CircularProgressIndicator());
              }

              DocumentSnapshot doc = docs[index];
              return _buildMessageItem(doc);
            },
          ); */
        });
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    //is currentuser?

    bool isCurrentUser = data["senderId"] == _authService.getCurrentUser()!.uid;

    final aligment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      key: ValueKey(doc),
      alignment: aligment,
      child: ChatBubble(
        text: data["message"],
        isCurrentUser: isCurrentUser,
      ),
    );
  }

  // message text field

  Widget _messageField() {
    return Row(
      children: [
        Expanded(
            child: MyTextField(
                focusNode: focusNode,
                controller: _messageTextController,
                obsecureText: false,
                hintText: "Type a message...")),
        Container(
          color: Theme.of(context).colorScheme.primary,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: IconButton(
            onPressed: sendMessage,
            icon: const Icon(Icons.send),
          ),
        )
      ],
    );
  }
}
