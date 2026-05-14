// Flutter imports:
import 'package:flutter/material.dart';

/// Reusable auth form fields for login and register screens
class EmailField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool enabled;

  const EmailField({
    required this.controller,
    this.validator,
    this.enabled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'Enter your email',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.email),
      ),
      keyboardType: TextInputType.emailAddress,
      enabled: enabled,
      validator: validator,
    );
  }
}

/// Password field with icon
class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final String? Function(String?)? validator;
  final bool enabled;

  const PasswordField({
    required this.controller,
    this.label = 'Password',
    this.hintText = 'Enter your password',
    this.validator,
    this.enabled = true,
    super.key,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
      ),
      obscureText: _obscureText,
      enabled: widget.enabled,
      validator: widget.validator,
    );
  }
}

/// Name field for registration
class NameField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool enabled;

  const NameField({
    required this.controller,
    this.validator,
    this.enabled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Full Name',
        hintText: 'Enter your full name',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.person),
      ),
      enabled: enabled,
      validator: validator,
    );
  }
}

/// Role selection dropdown for registration
class RoleSelectionField extends StatefulWidget {
  final String selectedRole;
  final List<String> availableRoles;
  final ValueChanged<String> onChanged;
  final bool enabled;

  const RoleSelectionField({
    required this.selectedRole,
    required this.availableRoles,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  @override
  State<RoleSelectionField> createState() => _RoleSelectionFieldState();
}

class _RoleSelectionFieldState extends State<RoleSelectionField> {
  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Role',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.security),
        enabled: widget.enabled,
      ),
      child: DropdownButton<String>(
        value: widget.selectedRole,
        isExpanded: true,
        underline: const SizedBox(),
        items: widget.availableRoles.map((role) {
          return DropdownMenuItem(value: role, child: Text(role));
        }).toList(),
        onChanged: widget.enabled ? (value) => widget.onChanged(value!) : null,
      ),
    );
  }
}
