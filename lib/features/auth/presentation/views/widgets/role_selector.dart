import 'package:flutter/material.dart';

class RoleSelector extends StatelessWidget {
  final String? selectedRole;
  final ValueChanged<String?> onChanged;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Radio<String>(
          value: 'owner',
          groupValue: selectedRole,
          onChanged: onChanged,
        ),
        Text("مالك", style: TextStyle(color: Colors.teal[900])),
        const SizedBox(width: 20),
        Radio<String>(
          value: 'renter',
          groupValue: selectedRole,
          onChanged: onChanged,
        ),
        Text("مستأجر", style: TextStyle(color: Colors.teal[900])),
      ],
    );
  }
}
