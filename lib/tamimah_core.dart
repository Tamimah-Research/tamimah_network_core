// lib/tamimah_core.dart

// Import network components
import 'src/network/network_config.dart';
import 'src/network/network_manager.dart';

// Export network components
export 'src/network/network_service.dart';
export 'src/network/network_config.dart';
export 'src/network/network_exception.dart';
export 'src/network/network_manager.dart';
export 'src/network/network_models.dart';

/// Main class for Tamimah Core
class TamimahNetworkCore {
  /// Initialize the core services
  static void initialize({
    String? baseUrl,
    String? authToken,
    Map<String, dynamic>? defaultHeaders,
  }) {
    final config = NetworkConfig(
      baseUrl: baseUrl ?? 'https://api.example.com',
      authToken: authToken,
      defaultHeaders:
          defaultHeaders ??
          const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
    );

    NetworkManager.instance.initialize(config: config);
  }

  /// Get network manager instance
  static NetworkManager get network => NetworkManager.instance;

  /// Dispose all resources
  static void dispose() {
    NetworkManager.instance.dispose();
  }
}
