import 'package:flutter/material.dart';

class StatRow extends StatelessWidget {
  final String name;
  final int base;
  final int hard;
  final int extreme;
  final VoidCallback onTap;
  final TextEditingController controller;
  final ValueChanged<int> onBaseChanged;

  const StatRow({
    super.key,
    required this.name,
    required this.base,
    required this.hard,
    required this.extreme,
    required this.controller,
    required this.onBaseChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            SizedBox(
              width: 130,
              child: Text(
                name,
                maxLines: 2, // Allows up to 2 lines (or more if you want)
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(border: InputBorder.none),
                onChanged: (value) {
                  int? newValue = int.tryParse(value);
                  if (newValue != null && newValue >= 0) {
                    onBaseChanged(newValue);
                  }
                },
              ),
            ),
            SizedBox(
              width: 60,
              child: Text(
                hard.toString(),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: 60,
              child: Text(
                extreme.toString(),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
