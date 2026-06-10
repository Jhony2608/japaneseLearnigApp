import 'package:flutter_riverpod/flutter_riverpod.dart';

class IsPremiumNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setPremium() {
    state = true;
  }
}

// Provider simulado para gestionar el estado premium localmente durante la sesión
final isPremiumProvider = NotifierProvider<IsPremiumNotifier, bool>(() {
  return IsPremiumNotifier();
});
