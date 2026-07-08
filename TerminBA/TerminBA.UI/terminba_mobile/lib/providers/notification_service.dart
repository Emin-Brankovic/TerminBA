import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:signalr_netcore/signalr_client.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  HubConnection? _hubConnection;
  final _storage = const FlutterSecureStorage();
  final _tokenKey = 'jwt_token';

  // Make sure this matches the base URL without /api/
  final String _baseUrl = const String.fromEnvironment(
    "baseUrl",
    defaultValue: "http://10.0.2.2:5078",
  ).replaceAll("/api/", "");

  final _joinRequestController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onJoinRequestReceived => _joinRequestController.stream;

  final _joinRequestRespondedController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onJoinRequestResponded => _joinRequestRespondedController.stream;

  final _joinRequestCancelledController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onJoinRequestCancelled => _joinRequestCancelledController.stream;

  Future<void> init() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null) return;

    final url = "$_baseUrl/notificationsHub";
    _hubConnection = HubConnectionBuilder()
        .withUrl(url, options: HttpConnectionOptions(
          accessTokenFactory: () async => token,
        ))
        .withAutomaticReconnect()
        .build();

    _hubConnection?.on('join_request_received', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final payload = arguments.first;
        if (payload is Map<String, dynamic>) {
          _joinRequestController.add(payload);
        } else if (payload is Map) {
          _joinRequestController.add(Map<String, dynamic>.from(payload));
        }
      }
    });

    _hubConnection?.on('join_request_responded', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final payload = arguments.first;
        if (payload is Map<String, dynamic>) {
          _joinRequestRespondedController.add(payload);
        } else if (payload is Map) {
          _joinRequestRespondedController.add(Map<String, dynamic>.from(payload));
        }
      }
    });

    _hubConnection?.on('join_request_cancelled', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final payload = arguments.first;
        if (payload is Map<String, dynamic>) {
          _joinRequestCancelledController.add(payload);
        } else if (payload is Map) {
          _joinRequestCancelledController.add(Map<String, dynamic>.from(payload));
        }
      }
    });

    try {
      await _hubConnection?.start();
    } catch (e) {
      print("Error starting SignalR connection: $e");
    }
  }

  Future<void> stop() async {
    await _hubConnection?.stop();
    _hubConnection = null;
  }
}
