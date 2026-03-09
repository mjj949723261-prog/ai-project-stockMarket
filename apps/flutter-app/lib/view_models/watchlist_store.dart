import 'package:flutter/foundation.dart';

class WatchlistStore extends ChangeNotifier {
  final List<String> _items = ['600519'];

  List<String> get items => List.unmodifiable(_items);

  bool contains(String code) => _items.contains(code);

  void toggle(String code) {
    if (_items.contains(code)) {
      _items.remove(code);
    } else {
      _items.add(code);
    }
    notifyListeners();
  }
}

