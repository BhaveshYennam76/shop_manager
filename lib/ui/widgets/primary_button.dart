import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_manager/core/theme/app_theme.dart';

/// Shop card widget.
class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 54,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.04,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _controller.forward();
  void _onTapUp(_) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: isDisabled ? null : _onTapDown,
      onTapUp: isDisabled ? null : _onTapUp,
      onTapCancel: isDisabled ? null : _onTapCancel,
      onTap: isDisabled ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: isDisabled
                ? LinearGradient(
                    colors: [
                      AppTheme.primary.withOpacity(0.4),
                      AppTheme.primaryDark.withOpacity(0.4),
                    ],
                  )
                : AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isDisabled ? [] : AppTheme.buttonShadow,
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, size: 20, color: Colors.white),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
