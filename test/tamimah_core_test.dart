import 'package:flutter_test/flutter_test.dart';

import 'package:tamimah_network_core/tamimah_core.dart';

void main() {
  group('TamimahCore Tests', () {
    test('should initialize successfully', () {
      TamimahNetworkCore.initialize(
        baseUrl: 'https://api.test.com',
        authToken: 'test-token',
      );

      expect(TamimahNetworkCore.network, isNotNull);
      expect(TamimahNetworkCore.network.config, isNotNull);
      expect(
        TamimahNetworkCore.network.config?.baseUrl,
        equals('https://api.test.com'),
      );
      expect(TamimahNetworkCore.network.config?.authToken, equals('test-token'));
    });

    test('should dispose resources', () {
      TamimahNetworkCore.initialize();
      expect(TamimahNetworkCore.network, isNotNull);

      TamimahNetworkCore.dispose();
      // After dispose, the network manager should be reset
      expect(TamimahNetworkCore.network, isNotNull);
    });
  });
}
