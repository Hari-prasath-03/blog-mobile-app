import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

abstract interface class ConnectionChecker {
  Future<bool> get isConnected;
}

class ConnectionCheckerImpl implements ConnectionChecker {
  final InternetConnection _internetConnection;
  const ConnectionCheckerImpl({required this._internetConnection});

  @override
  Future<bool> get isConnected async =>
      await _internetConnection.hasInternetAccess;
}
