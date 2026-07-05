import 'package:flutter/material.dart';
import 'package:terminba_mobile/providers/play_request_provider.dart';

class NotificationProvider with ChangeNotifier {
  final PlayRequestProvider _playRequestProvider;
  int _unseenReceivedCount = 0;
  int _unseenSentCount = 0;

  NotificationProvider(this._playRequestProvider);

  int get unseenCount => _unseenReceivedCount + _unseenSentCount;

  Future<void> fetchUnseenCount() async {
    try {
      _unseenReceivedCount = await _playRequestProvider.getUnseenCount();
      _unseenSentCount = await _playRequestProvider.getUnseenResponsesCount();
      notifyListeners();
    } catch (e) {
      print("Failed to fetch unseen count: $e");
    }
  }

  void incrementUnseenReceivedCount() {
    _unseenReceivedCount++;
    notifyListeners();
  }

  void incrementUnseenSentCount() {
    _unseenSentCount++;
    notifyListeners();
  }

  void decrementUnseenReceivedCount() {
    if (_unseenReceivedCount > 0) {
      _unseenReceivedCount--;
      notifyListeners();
    }
  }

  void decrementUnseenSentCount() {
    if (_unseenSentCount > 0) {
      _unseenSentCount--;
      notifyListeners();
    }
  }

  Future<void> markAsSeen(int requestId) async {
    try {
      await _playRequestProvider.markAsSeen(requestId);
      decrementUnseenReceivedCount();
    } catch (e) {
      print("Failed to mark as seen: $e");
    }
  }

  Future<void> markResponseAsSeen(int requestId) async {
    try {
      await _playRequestProvider.markResponseAsSeen(requestId);
      decrementUnseenSentCount();
    } catch (e) {
      print("Failed to mark response as seen: $e");
    }
  }
}
