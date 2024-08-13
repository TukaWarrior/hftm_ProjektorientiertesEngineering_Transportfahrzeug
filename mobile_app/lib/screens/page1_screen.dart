import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ESP32ScreenOld extends StatefulWidget {
  const ESP32ScreenOld({super.key});

  @override
  State<ESP32ScreenOld> createState() => _ESP32ScreenOldState();
}

class _ESP32ScreenOldState extends State<ESP32ScreenOld> {
  final String esp32IpAddress = 'http://192.168.4.1'; // Use the default IP for ESP32 AP mode
  double speed = 0; // Initial speed value
  double steering = 0; // Initial steering value
  Timer? _debounce; // Timer variable for debounce logic
  // int speedInt = 0;
  // int steeringInt =0;

  void _sendRequest(String endpoint, {int? value}) {
    // If a timer is active, cancel it
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 50), () {
      // Create URL and send HTTP request
      final url = Uri.parse('$esp32IpAddress/$endpoint?value=$value');
      http.get(url).then((response) {
        if (response.statusCode == 200) {
          print('Request to $endpoint successful');
        } else {
          print('Request to $endpoint failed with status: ${response.statusCode}');
        }
      }).catchError((e) {
        print('Request to $endpoint failed with error: $e');
      });
    });
  }

  void _turnOnLed() {
    _sendRequest('setLed', value: 1);
  }

  void _turnOffLed() {
    _sendRequest('setLed', value: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.secondary,
      //   title: const Text('Flutter ESP32 Control'),
      // ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _turnOnLed,
              child: const Text('Turn On LED'),
            ),
            ElevatedButton(
              onPressed: _turnOffLed,
              child: const Text('Turn Off LED'),
            ),
            const SizedBox(height: 20),
            Text('Speed: ${speed.toStringAsFixed(1)}'),
            Slider(
              min: -1000,
              max: 1000,
              value: speed,
              onChanged: (newValue) {
                setState(() {
                  speed = newValue;
                  _sendRequest('setSpeed', value: speed.toInt());
                });
              },
            ),
            const SizedBox(height: 20),
            Text('Steering: ${steering.toStringAsFixed(1)}'),
            Slider(
              min: -1000,
              max: 1000,
              value: steering,
              onChanged: (newValue) {
                setState(() {
                  steering = newValue;
                  _sendRequest('setSteering', value: steering.toInt());
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose the timer when the widget is disposed
    _debounce?.cancel();
    super.dispose();
  }
}
