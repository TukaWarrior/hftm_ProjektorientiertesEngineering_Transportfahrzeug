import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:http/http.dart' as http;

class ESP32Screen extends StatefulWidget {
  const ESP32Screen({super.key});

  @override
  State<ESP32Screen> createState() => _ESP32ScreenState();
}

class _ESP32ScreenState extends State<ESP32Screen> {
  static const String esp32IpAddress = 'http://192.168.4.1';
  Timer? _debounce;

  double acceleration = 0;
  int steering = 0;
  int? gear = 1;
  int operationMode = 1;
  bool ledState = false;

  int responseAcceleration = 0;
  int responseSteering = 0;
  int responseGear = 0;
  int responseOperationMode = 0;
  bool responseLedState = false;

  void _sendRequest(String endpoint, {int? value}) {
    _debounce?.cancel();
    print(value);
    _debounce = Timer(const Duration(milliseconds: 50), () async {
      final uri = Uri.parse('$esp32IpAddress/$endpoint?value=$value');
      try {
        final response = await http.get(uri);
        if (response.statusCode == 200) {
          var jsonResponse = jsonDecode(response.body);
          print('Request to $endpoint successful');
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

  void calculateSpeed(int value) {
    switch (gear) {
      case 1:
        _sendRequest('setAcceleration', value: (value).toInt());
        break;
      case 2:
        _sendRequest('setAcceleration', value: (value / 2).toInt());
        break;
      case 3:
        _sendRequest('setAcceleration', value: (value / 5).toInt());
        break;

      default:
        print('Value is something else');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          // Gears and Modes
          Padding(padding: const EdgeInsets.symmetric(vertical: 10)),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text('Gear'),
                  Row(
                    children: [
                      Radio<int>(
                        value: 1,
                        groupValue: gear,
                        onChanged: (int? value) {
                          setState(() => gear = value ?? 1);
                          gear = value;
                          // _sendRequest('setGear', value: value);
                        },
                      ),
                      Radio<int>(
                        value: 2,
                        groupValue: gear,
                        onChanged: (int? value) {
                          setState(() => gear = value ?? 1);
                          gear = value;
                          // _sendRequest('setGear', value: value);
                        },
                      ),
                      Radio<int>(
                        value: 3,
                        groupValue: gear,
                        onChanged: (int? value) {
                          setState(() => gear = value ?? 1);
                          gear = value;
                          // _sendRequest('setGear', value: value);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  Text('Mode'),
                  Row(
                    children: [
                      Radio<int>(
                        value: 1,
                        groupValue: operationMode,
                        onChanged: (int? value) {
                          setState(() => operationMode = value ?? 1);
                          _sendRequest('setOperationMode', value: value);
                        },
                      ),
                      Radio<int>(
                        value: 2,
                        groupValue: operationMode,
                        onChanged: (int? value) {
                          setState(() => operationMode = value ?? 1);
                          _sendRequest('setOperationMode', value: value);
                        },
                      ),
                      Radio<int>(
                        value: 3,
                        groupValue: operationMode,
                        onChanged: (int? value) {
                          setState(() => operationMode = value ?? 1);
                          _sendRequest('setOperationMode', value: value);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          Padding(padding: const EdgeInsets.symmetric(vertical: 20)),

          // Joysticks
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Joystick(
                mode: JoystickMode.horizontal,
                listener: (details) {
                  print(details.x);
                  _sendRequest('setSteering', value: (details.x * 1000).toInt());
                },
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Current Acceleration: $responseAcceleration'),
                    Text('Current Steering: $responseSteering'),
                    // Text('Current Gear: $responseGear'),
                    Text('Current Gear: $gear'),
                    Text('Current Operation Mode: $responseOperationMode'),
                    // Text('LED State: ${responseLedState ? "On" : "Off"}'),
                  ],
                ),
              ),
              Joystick(
                mode: JoystickMode.vertical,
                listener: (details) {
                  print(details.y);
                  calculateSpeed(((details.y * -1) * 1000).toInt());
                  // _sendRequest('setAcceleration', value: ((details.y * -1) * 1000).toInt());
                },
              ),
            ],
          ),

          // LED Toggle
          // ListTile(
          //   title: const Text('Toggle LED'),
          //   trailing: Switch(
          //     value: ledState,
          //     onChanged: (bool value) {
          //       setState(() => ledState = value);
          //       _sendRequest('setLed', value: value ? 1 : 0);
          //     },
          //   ),
          // ),

          // Response Display

          // Padding(
          //   padding: const EdgeInsets.all(20.0),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: <Widget>[
          //       Text('Current Acceleration: $responseAcceleration'),
          //       Text('Current Steering: $responseSteering'),
          //       Text('Current Gear: $responseGear'),
          //       Text('Current Operation Mode: $responseOperationMode'),
          //       Text('LED State: ${responseLedState ? "On" : "Off"}'),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
