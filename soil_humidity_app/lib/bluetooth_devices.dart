import 'package:flutter/material.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'package:soil_humidity_app/bluetooth.dart';

class BluetoothDevices extends StatefulWidget {
  const BluetoothDevices({Key? key}) : super(key: key);

  @override
  _BluetoothDevicesState createState() => _BluetoothDevicesState();
}

class _BluetoothDevicesState extends State<BluetoothDevices> {
  late Future<List<Device>> _devicesFuture;
  Map<String, bool> _connectingDevices = {}; // Track connection states
  bool _connecting = false; // Flag to track if any device is connecting

  @override
  void initState() {
    super.initState();
    _devicesFuture = bluetooth.getPairedDevices();
  }

  Future<void> _refreshDevices() async {
    setState(() {
      _devicesFuture = bluetooth.getPairedDevices();
    });
  }

  Future<void> _connectToDevice(Device device) async {
    setState(() {
      _connectingDevices[device.address] = true; // Mark device as connecting
      _connecting = true; // Set overall connecting flag
    });

    try {
      await bluetooth.connect(
          device.address, "00001101-0000-1000-8000-00805f9b34fb");
      // If connected successfully, you might want to navigate or show a success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Connected to ${device.name ?? 'Unknown device'}'),
      ));
    } catch (e) {
      // If connection fails, show an error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Connection Failed'),
          content: Text(
              'Failed to connect to ${device.name ?? 'Unknown device'}. Error: $e'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _connectingDevices[device.address] = false; // Reset connection state
        _connecting = false; // Reset overall connecting flag
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paired Devices'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDevices,
        child: FutureBuilder<List<Device>>(
          future: _devicesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              List<Device> devices = snapshot.data!;
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: devices.length,
                      itemBuilder: (context, index) {
                        Device device = devices[index];
                        bool isConnecting =
                            _connectingDevices.containsKey(device.address)
                                ? _connectingDevices[device.address]!
                                : false;
                        bool isEnabled = !isConnecting &&
                            !_connecting; // Enable button if not already connecting
                        return ListTile(
                          title: Text(device.name ?? 'Unknown device'),
                          subtitle: Text(device.address),
                          trailing: isConnecting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(),
                                )
                              : ElevatedButton(
                                  onPressed: isEnabled
                                      ? () => _connectToDevice(device)
                                      : null,
                                  child: const Text('Connect'),
                                ),
                        );
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Note: This list displays only paired devices. '
                      'Please scan and pair using your phone\'s Bluetooth settings.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              );
            } else {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('No devices found'),
                    Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Note: Please make sure your devices are paired via '
                        'your phone\'s Bluetooth settings.',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
