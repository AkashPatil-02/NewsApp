import 'package:riverpod/legacy.dart';

class data {
  final String uid;
  final String name;
  data({required this.name, required this.uid});
}

class UserNotifier extends StateNotifier<data?> {
  UserNotifier() : super(null);

  void setUser({required String uid, required String name}) {
    print('UserNotifier: $uid $name');
    state = data(name: name, uid: uid);
  }

  void deleteUser() {
    state = null;
  }
}

final userNotifierProvider = StateNotifierProvider<UserNotifier, data?>((ref) {
  return UserNotifier();
});
