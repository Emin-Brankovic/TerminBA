import 'package:flutter/material.dart';
import 'package:terminba_mobile/providers/play_request_provider.dart';
import 'package:terminba_mobile/providers/cancelation_notification_provider.dart';

class NotificationProvider with ChangeNotifier {
  final PlayRequestProvider _playRequestProvider;
  final CancelationNotificationProvider _cancelationNotificationProvider;
  int _unseenReceivedCount = 0;
  int _unseenSentCount = 0;
  int _unseenCancelationCount = 0;

  NotificationProvider(this._playRequestProvider, this._cancelationNotificationProvider);

  int get unseenCount => _unseenReceivedCount + _unseenSentCount;
  int get unseenCancelationCount => _unseenCancelationCount;

  Future<void> fetchUnseenCount() async {
    try {
      _unseenReceivedCount = await _playRequestProvider.getUnseenCount();
      _unseenSentCount = await _playRequestProvider.getUnseenResponsesCount();
      _unseenCancelationCount = await _cancelationNotificationProvider.getUnseenCount();
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

  void incrementUnseenCancelationCount() {
    _unseenCancelationCount++;
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

  void decrementUnseenCancelationCount() {
    if (_unseenCancelationCount > 0) {
      _unseenCancelationCount--;
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

  Future<void> markCancelationAsSeen(int id) async {
    try {
      await _cancelationNotificationProvider.markAsSeen(id);
      decrementUnseenCancelationCount();
    } catch (e) {
      print("Failed to mark cancelation as seen: $e");
      rethrow;
    }
  }
}
