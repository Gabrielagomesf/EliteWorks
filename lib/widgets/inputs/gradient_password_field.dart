import 'package:flutter/material.dart';
import 'gradient_text_field.dart';

class GradientPasswordField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool enabled;

  const GradientPasswordField({
    super.key,
    required this.label,
    this.controller,
    this.validator,
    this.enabled = true,
  });

  @override
  State<GradientPasswordField> createState() => _GradientPasswordFieldState();
}

class _GradientPasswordFieldState extends State<GradientPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return GradientTextField(
      label: widget.label,
      controller: widget.controller,
      validator: widget.validator,
      obscureText: _obscureText,
      enabled: widget.enabled,
      prefixIcon: Icons.lock_outlined,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: Colors.white.withOpacity(0.8),
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
    );
  }
}



