import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_manager/core/theme/app_theme.dart';

/// A styled, reusable text field with icon support and validation.
class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.maxLines = 1,
    this.inputFormatters,
    this.focusNode,
    this.onEditingComplete,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onFocusChange(bool focused) {
    setState(() => _isFocused = focused);
    if (focused) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Focus(
        onFocusChange: _onFocusChange,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.25),
                      blurRadius: 16,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            validator: widget.validator,
            maxLines: widget.maxLines,
            inputFormatters: widget.inputFormatters,
            onEditingComplete: widget.onEditingComplete,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w400,
            ),
            cursorColor: AppTheme.primary,
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  widget.prefixIcon,
                  size: 20,
                  color: _isFocused ? AppTheme.primaryLight : AppTheme.textHint,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
