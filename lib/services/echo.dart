import 'dart:convert';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:front_end/services/api_config.dart';

class EchoService {
  final PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();
  Function(Map<String, dynamic>)? onNewMessage;
  String? _channelName;

  Future<void> init(int userId, String token) async {
    _channelName = 'private-tin-nhan.$userId';

    await pusher.init(
      apiKey: '319f897cf2317976038d', // Từ .env PUSHER_APP_KEY
      cluster: 'ap1',
      authEndpoint: '${ApiConfig.baseUrl}/broadcasting/auth',
      onAuthorizer: (channelName, socketId, _) async {
        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/broadcasting/auth'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'socket_id': socketId,
            'channel_name': channelName,
          }),
        );

        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else {
          print("❌ Auth thất bại: ${response.body}");
          throw Exception("Auth thất bại");
        }
      },
      onEvent: (PusherEvent event) {
        if (event.eventName == 'TinNhanEvent') {
          try {
            final data = jsonDecode(event.data!);
            onNewMessage?.call(data);
          } catch (e) {
            print('❌ Lỗi phân tích dữ liệu: $e');
          }
        }
      },
      onSubscriptionSucceeded: (channelName, data) {
        print("✅ Subscribed: $channelName");
      },
    );

    await pusher.subscribe(channelName: _channelName!);
    await pusher.connect();
  }

  void disconnect() {
    if (_channelName != null) {
      pusher.unsubscribe(channelName: _channelName!);
    }
    pusher.disconnect();
  }
}