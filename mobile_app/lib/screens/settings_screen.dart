import 'package:flutter/material.dart';
import 'package:mobile_app/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Settings"),
      // ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Settings",
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text(
                "App Theme",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Radio<ThemeMode>(
                      value: ThemeMode.light,
                      groupValue: Provider.of<ThemeProvider>(context).themeMode,
                      onChanged: (ThemeMode? value) {
                        if (value != null) {
                          Provider.of<ThemeProvider>(context, listen: false).setThemeMode(value);
                        }
                      },
                    ),
                    const SizedBox(height: 4),
                    const Text("Light"),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Radio<ThemeMode>(
                      value: ThemeMode.dark,
                      groupValue: Provider.of<ThemeProvider>(context).themeMode,
                      onChanged: (ThemeMode? value) {
                        if (value != null) {
                          Provider.of<ThemeProvider>(context, listen: false).setThemeMode(value);
                        }
                      },
                    ),
                    const SizedBox(height: 4),
                    const Text("Dark"),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Radio<ThemeMode>(
                      value: ThemeMode.system,
                      groupValue: Provider.of<ThemeProvider>(context).themeMode,
                      onChanged: (ThemeMode? value) {
                        if (value != null) {
                          Provider.of<ThemeProvider>(context, listen: false).setThemeMode(value);
                        }
                      },
                    ),
                    const SizedBox(height: 4),
                    const Text("System"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
