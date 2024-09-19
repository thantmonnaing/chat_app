import 'package:get_it/get_it.dart';

import '../repository/message_repository.dart';

class GetItService{
  static final getIt = GetIt.instance;

  static Future<void> initialize() async{
    getIt.registerSingleton<MessageRepository>(MessageRepository());
  }
}

T locate<T extends Object>(){
  return GetItService.getIt<T>();
}