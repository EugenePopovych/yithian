import 'package:flutter/material.dart';
import '../models/attribute.dart';

class AttributeWidget extends StatelessWidget {
  final Attribute attribute;
  final VoidCallback onTap;

  const AttributeWidget({super.key, required this.attribute, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("🎲 ${attribute.name}:"),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: TextEditingController(text: attribute.base.toString()),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                int? newValue = int.tryParse(value);
                if (newValue != null && newValue >= 0) {
                  attribute.base = newValue;
                }
              },
            ),
          ),
          Expanded(
            child: TextField(
              controller: TextEditingController(text: attribute.hard.toString()),
              readOnly: true,
              decoration: InputDecoration(border: InputBorder.none),
            ),
          ),
          Expanded(
            child: TextField(
              controller: TextEditingController(text: attribute.extreme.toString()),
              readOnly: true,
              decoration: InputDecoration(border: InputBorder.none),
            ),
          ),
        ],
      ),
    );
  }
}
