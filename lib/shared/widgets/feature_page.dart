import 'package:flutter/material.dart';

class FeaturePage extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;

  const FeaturePage({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(description, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              const Text('Module en construction.'),
            ],
          ),
        ),
      ),
    );
  }
}
