import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:http/http.dart' as http;

class TestScreen1 extends StatefulWidget {
  const TestScreen1({super.key});

  @override
  State<TestScreen1> createState() => _TestScreen1State();
}

class _TestScreen1State extends State<TestScreen1> {
  static const String esp32IpAddress = 'http://192.168.4.1';
  Timer? _debounce;

  double acceleration = 0;
  int steering = 0;
  int gear = 1;

  int operationMode = 1;
  bool ledState = false;

  int responseAcceleration = 0;
  int responseSteering = 0;
  int responseGear = 0;
  int responseOperationMode = 0;
  bool responseLedState = false;

  // If a timer is active, cancel it

  void _sendRequest(String endpoint, {int? value}) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 50), () async {
      final uri = Uri.parse('$esp32IpAddress/$endpoint?value=$value');
      try {
        final response = await http.get(uri);
        if (response.statusCode == 200) {
          var jsonResponse = jsonDecode(response.body);
          print('Request to $endpoint successful');
          // Update the UI based on the endpoint and the value returned
          setState(() {
            switch (endpoint) {
              case 'setAcceleration':
                responseAcceleration = jsonResponse['value'];
                break;
              case 'setSteering':
                responseSteering = jsonResponse['value'];
                break;
              case 'setGear':
                responseGear = jsonResponse['value'];
                break;
              case 'setOperationMode':
                responseOperationMode = jsonResponse['value'];
                break;
              case 'setLed':
                responseLedState = jsonResponse['value'] == 1;
                break;
              default:
                break;
            }
          });
        } else {
          print('Request to $endpoint failed with status: ${response.statusCode}');
        }
      } catch (e) {
        print('Request to $endpoint failed with error: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('ESP32 Controller'),
      // ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Joystick(
              mode: JoystickMode.horizontal,
              listener: (details) {
                print(details.x);
                // print(details.y);
                _sendRequest('setSteering', value: (details.x * 1000).toInt());
                // _sendRequest('setAcceleration', value: (details.y * 1000).toInt());
              },
            ),
            Slider(
              value: acceleration,
              min: -1000,
              max: 1000,
              divisions: 2000,
              label: acceleration.round().toString(),
              onChanged: (double value) {
                setState(() {
                  acceleration = value;
                });
                _sendRequest('setAcceleration', value: value.toInt());
              },
              onChangeEnd: (double value) {
                setState(() => acceleration = 0);
                _sendRequest('setAcceleration', value: 0);
              },
            ),
            ListTile(
              title: const Text('Toggle LED'),
              trailing: Switch(
                value: ledState,
                onChanged: (bool value) {
                  setState(() => ledState = value);
                  _sendRequest('setLed', value: value ? 1 : 0);
                },
              ),
            ),
            RadioListTile<int>(
              title: const Text('Mode 1'),
              value: 1,
              groupValue: operationMode,
              onChanged: (int? value) {
                setState(() => operationMode = value ?? 1);
                _sendRequest('setOperationMode', value: value);
              },
            ),
            RadioListTile<int>(
              title: const Text('Gear 1'),
              value: 1,
              groupValue: gear,
              onChanged: (int? value) {
                setState(() => gear = value ?? 1);
                _sendRequest('setGear', value: value);
              },
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Current Acceleration: $responseAcceleration'),
                  Text('Current Steering: $responseSteering'),
                  Text('Current Gear: $responseGear'),
                  Text('Current Operation Mode: $responseOperationMode'),
                  Text('LED State: ${responseLedState ? "On" : "Off"}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
