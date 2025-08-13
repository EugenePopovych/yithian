import 'package:flutter/material.dart';
import 'package:coc_sheet/models/sheet_status.dart';

class CreateCharacterRequest {
  final String name;
  final String occupation;
  final SheetStatus status;
  const CreateCharacterRequest({
    required this.name,
    required this.occupation,
    required this.status,
  });
}

Future<CreateCharacterRequest?> showCreateCharacterDialog(BuildContext context) {
  final nameCtrl = TextEditingController();
  final occCtrl = TextEditingController();
  SheetStatus status = SheetStatus.draft_classic;

  return showDialog<CreateCharacterRequest?>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Create Investigator'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: occCtrl,
                decoration: const InputDecoration(labelText: 'Occupation'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<SheetStatus>(
                value: status,
                decoration: const InputDecoration(labelText: 'Creation method'),
                items: const [
                  DropdownMenuItem(
                    value: SheetStatus.draft_classic,
                    child: Text('Classic (rolled)'),
                  ),
                  DropdownMenuItem(
                    value: SheetStatus.draft_points,
                    child: Text('Point-buy'),
                  ),
                  DropdownMenuItem(
                    value: SheetStatus.draft_free,
                    child: Text('Freeform'),
                  ),
                ],
                onChanged: (v) => status = v ?? SheetStatus.draft_classic,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final req = CreateCharacterRequest(
                name: nameCtrl.text.trim(),
                occupation: occCtrl.text.trim(),
                status: status,
              );
              Navigator.of(context).pop(req);
            },
            child: const Text('Create'),
          ),
        ],
      );
    },
  );
}
