import 'package:flutter/material.dart';
import 'package:thoutha_mobile_app/core/networking/connectivity_service.dart';

class ConnectivityTestScreen extends StatefulWidget {
  const ConnectivityTestScreen({super.key});

  @override
  State<ConnectivityTestScreen> createState() => _ConnectivityTestScreenState();
}

class _ConnectivityTestScreenState extends State<ConnectivityTestScreen> {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isConnected = false;
  String _connectionStatus = 'Unknown';
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();

    // Listen to connectivity changes
    _connectivityService.connectionStream.listen((isConnected) {
      setState(() {
        _isConnected = isConnected;
        _connectionStatus = _connectivityService.getConnectionStatusText();
      });
    });
  }

  Future<void> _checkConnectivity() async {
    setState(() {
      _isChecking = true;
    });

    try {
      await _connectivityService.initialize();
      final isConnected = await _connectivityService.checkInitialConnection();
      final status = _connectivityService.getConnectionStatusText();

      setState(() {
        _isConnected = isConnected;
        _connectionStatus = status;
        _isChecking = false;
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
        _connectionStatus = 'Error: ${e.toString()}';
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connectivity Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      _isConnected ? Icons.wifi : Icons.wifi_off,
                      size: 64,
                      color: _isConnected ? Colors.green : Colors.red,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Connection Status',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 8),
                    Text(
                      _connectionStatus,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: _isConnected ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      _isConnected ? 'Connected' : 'Disconnected',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _isConnected ? Colors.green : Colors.red,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            if (_isChecking)
              CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _checkConnectivity,
                child: Text('Check Again'),
              ),
          ],
        ),
      ),
    );
  }
}
