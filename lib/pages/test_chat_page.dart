
import 'dart:async';
import 'package:chat_app/components/my_textfield.dart';
import 'package:chat_app/components/user_tile.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../components/chat_bubble.dart';

class TestChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverId;

  TestChatPage({super.key, required this.receiverEmail, required this.receiverId});

  @override
  State<TestChatPage> createState() => _TestChatPageState();
}

class _TestChatPageState extends State<TestChatPage> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  final FocusNode focusNode = FocusNode();
  final TextEditingController _messageTextController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<DocumentSnapshot> _messages = [];
  bool _loadingMore = false;
  bool _hasMoreMessages = true;
  DocumentSnapshot? _lastMessageDocument;
  final int _messageLimit = 10; // Pagination limit (how many messages to load at once)
  StreamSubscription<QuerySnapshot>? _messageSubscription;

  String chatRoomId = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();

    String currentUserId = _authService.getCurrentUser()!.uid;
    List<String> ids = [widget.receiverId, currentUserId];
    ids.sort(); //sort the ids (chatRoomId need to same for any two people)
    chatRoomId = ids.join("_");

    _getInitialMessages();

    // Attach scroll listener to load more messages when the user scrolls to the top
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.minScrollExtent && !_loadingMore && _hasMoreMessages) {
        _loadMoreMessages();
      }
    });

    // Set up real-time listener for new incoming messages
    _listenForNewMessages();
  }

  // Fetch the initial batch of messages
  void _getInitialMessages() async {
    QuerySnapshot initialSnapshot = await _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .limit(20)
        .get();

    setState(() {
      _messages = initialSnapshot.docs;
      if (_messages.isNotEmpty) {
        _lastMessageDocument = _messages.last;
      }
    });
  }

  // Load more messages when the user scrolls to the top
  void _loadMoreMessages() async {
    if (_lastMessageDocument == null || _loadingMore) return;

    setState(() {
      _loadingMore = true;
    });

    QuerySnapshot moreMessagesSnapshot = await _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .startAfterDocument(_lastMessageDocument!)
        .limit(_messageLimit)
        .get();

    if (moreMessagesSnapshot.docs.isNotEmpty) {
      setState(() {
        _messages.addAll(moreMessagesSnapshot.docs);
        _lastMessageDocument = moreMessagesSnapshot.docs.last;
      });
    } else {
      setState(() {
        _hasMoreMessages = false; // No more messages to load
      });
    }

    setState(() {
      _loadingMore = false;
    });
  }

  // Set up a real-time listener for new messages
  void _listenForNewMessages() {
    _messageSubscription = _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .limit(_messageLimit)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _messages = snapshot.docs;
          _lastMessageDocument = _messages.last;
        });
      }
    });
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverEmail)),
      body: Column(
        children: [
          Expanded(
            child: ReorderableListView.builder(
              scrollController: _scrollController,
              reverse: true,
              itemCount: _messages.length + (_loadingMore ? 1 : 0),
              onReorder: _onReorder,
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return const Center(
                    key: ValueKey('loading'),
                    child: CircularProgressIndicator(),
                  );
                }
                DocumentSnapshot doc = _messages[index];
                return _buildMessageItem(doc, index);
              },
            ),
          ),
          _messageField(),
        ],
      ),
    );
  }

  // Handle reordering of messages
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > _messages.length - 1) newIndex -= 1;

      final item = _messages.removeAt(oldIndex);
      _messages.insert(newIndex, item);
    });
  }

  // Build a single message bubble
  Widget _buildMessageItem(DocumentSnapshot doc, int index) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    bool isCurrentUser = data['senderId'] == _authService.getCurrentUser()!.uid;
    final alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      key: ValueKey(doc.id), // Ensure each message has a unique key for reordering
      alignment: alignment,
      child: ChatBubble(
        text: data['message'],
        isCurrentUser: isCurrentUser,
      ),
    );
  }

  // Message input field
  Widget _messageField() {
    return Row(
      children: [
        Expanded(
          child: MyTextField(
            focusNode: focusNode,
            controller: _messageTextController,
            obsecureText: false,
            hintText: 'Type a message...',
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          color: Theme.of(context).colorScheme.primary,
          child: IconButton(
            onPressed: sendMessage,
            icon: const Icon(Icons.send),
          ),
        ),
      ],
    );
  }

  // Send a message
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

  // Scroll to the bottom of the chat
  void _scrollDownPosition() {
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}



