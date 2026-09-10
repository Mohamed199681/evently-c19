import 'package:flutter/material.dart';
class OnboardingPage extends StatelessWidget{
  final String image;
  final String title;
  final String description;
  const OnboardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.description,
});
  @override
  Widget build(BuildContext context) {
    return Padding
      (padding:const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
              child: Image.asset(image, fit: BoxFit.fitHeight),
          ),
          SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}