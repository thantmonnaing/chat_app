import 'package:chat_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../models/message.dart';
import '../chat/get_it_service.dart';
import '../repository/message_repository.dart';
import 'base_state.dart';

class ChatState extends BaseState{
  final MessageRepository _userRepo = locate<MessageRepository>();

  ScrollController? homeScrollController;
  List<Message> _messages = [];

  List<Message> get messages => _messages;

  bool isFetchingUsers = false;
  bool hasNextUser = true;

  bool hideFAB = false;

  int limitTo = 20;
  String userId ="";
  String otherUserId = '';

  void initialState(int limitTo,String? otherUserId) {
    limitTo = limitTo;
    userId = AuthService().getCurrentUser()!.uid;
    otherUserId = otherUserId;
    homeScrollController = ScrollController();
    _loadNextBatchUsers(limitTo,userId,otherUserId);

    homeScrollController?.addListener(_listenToHomeScroll);
  }

  void _listenToHomeScroll() {
    if (homeScrollController == null) return;

    final reachMaxExtent = homeScrollController!.offset >= homeScrollController!.position.maxScrollExtent / 2;
    final outOfRange = !homeScrollController!.position.outOfRange && homeScrollController!.position.pixels != 0;
    if (reachMaxExtent && outOfRange) {
      _loadNextBatchUsers(limitTo,userId,otherUserId);
    }
  }

  void _loadNextBatchUsers(int limitTo,String? userId,String? otherUserId) async {
    if (hasNextUser && !isFetchingUsers) {
      isFetchingUsers = true;
      int previousLength = _userRepo.messageNotifier.value.length;

      await _userRepo.fetchUsers(limitTo,userId,otherUserId);
      await Future.delayed(const Duration(milliseconds: 2000));
      int newLength = _userRepo.messageNotifier.value.length;

      if (newLength == previousLength && hasNextUser) hasNextUser = false;
      isFetchingUsers = false;

      if (newLength > previousLength) {
        _userListeners();
      }
    }
  }

  void _userListeners() {
    _messages = _userRepo.messageNotifier.value;
    notifyListeners();
  }
}