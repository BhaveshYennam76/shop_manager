import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shop_manager/core/theme/app_theme.dart';
import 'package:shop_manager/data/models/shop_model.dart';
import 'package:shop_manager/providers/shop_provider.dart';
import 'package:shop_manager/ui/widgets/custom_text_field.dart';
import 'package:shop_manager/ui/widgets/primary_button.dart';

/// Reusable screen for both adding a new shop and editing an existing one.
class AddEditShopScreen extends StatefulWidget {
  final Shop? shopToEdit;

  const AddEditShopScreen({super.key, this.shopToEdit});

  @override
  State<AddEditShopScreen> createState() => _AddEditShopScreenState();
}

class _AddEditShopScreenState extends State<AddEditShopScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _mobileCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _descCtrl;

  final _addressFocus = FocusNode();
  final _mobileFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _descFocus = FocusNode();

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  bool get _isEditing => widget.shopToEdit != null;

  @override
  void initState() {
    super.initState();

    final s = widget.shopToEdit;
    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _addressCtrl = TextEditingController(text: s?.address ?? '');
    _mobileCtrl = TextEditingController(text: s?.mobile ?? '');
    _emailCtrl = TextEditingController(text: s?.email ?? '');
    _descCtrl = TextEditingController(text: s?.description ?? '');

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _descCtrl.dispose();
    _addressFocus.dispose();
    _mobileFocus.dispose();
    _emailFocus.dispose();
    _descFocus.dispose();
    _animController.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'This field is required' : null;

  String? _validateMobile(String? v) {
    if (v == null || v.trim().isEmpty) return 'Mobile number is required';
    if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(v.trim())) {
      return 'Enter a valid mobile number';
    }
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(v.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    final shop = Shop(
      id: widget.shopToEdit?.id,
      name: _nameCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      mobile: _mobileCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      description: _descCtrl.text.trim(),
    );

    final provider = context.read<ShopProvider>();
    final bool success = _isEditing
        ? await provider.updateShop(shop)
        : await provider.addShop(shop);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      _showSuccessSnack();
      Navigator.of(context).pop();
    } else {
      _showErrorSnack(provider.error ?? 'Something went wrong');
    }
  }

  void _showSuccessSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditing ? 'Shop updated successfully' : 'Shop added successfully',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$msg'),
        backgroundColor: AppTheme.error.withOpacity(0.9),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                children: [
                  _buildTopBar(),
                  Expanded(child: _buildForm()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 24, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.divider, width: 1),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppTheme.primaryGradient.createShader(bounds),
                child: Text(
                  _isEditing ? 'Edit Shop' : 'New Shop',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              Text(
                _isEditing
                    ? 'Update shop details'
                    : 'Fill in the details below',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (_isEditing)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppTheme.primary.withOpacity(0.3), width: 1),
              ),
              child: Text(
                'Editing',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppTheme.primaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('Basic Information'),
            const SizedBox(height: 14),

            CustomTextField(
              controller: _nameCtrl,
              label: 'Shop Name',
              hint: 'e.g. Sunrise Electronics',
              prefixIcon: Icons.storefront_rounded,
              textInputAction: TextInputAction.next,
              validator: _required,
              onEditingComplete: () =>
                  FocusScope.of(context).requestFocus(_addressFocus),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _addressCtrl,
              label: 'Address',
              hint: 'e.g. 12 Main Street, Mumbai',
              prefixIcon: Icons.location_on_outlined,
              focusNode: _addressFocus,
              textInputAction: TextInputAction.next,
              validator: _required,
              onEditingComplete: () =>
                  FocusScope.of(context).requestFocus(_mobileFocus),
            ),

            const SizedBox(height: 28),

            _sectionLabel('Contact Details'),
            const SizedBox(height: 14),

            CustomTextField(
              controller: _mobileCtrl,
              label: 'Mobile Number',
              hint: 'e.g. +91 9876543210',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              focusNode: _mobileFocus,
              textInputAction: TextInputAction.next,
              validator: _validateMobile,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s()]')),
              ],
              onEditingComplete: () =>
                  FocusScope.of(context).requestFocus(_emailFocus),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _emailCtrl,
              label: 'Email Address',
              hint: 'e.g. shop@example.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              focusNode: _emailFocus,
              textInputAction: TextInputAction.next,
              validator: _validateEmail,
              onEditingComplete: () =>
                  FocusScope.of(context).requestFocus(_descFocus),
            ),

            const SizedBox(height: 28),

            _sectionLabel('Additional Info'),
            const SizedBox(height: 14),

            CustomTextField(
              controller: _descCtrl,
              label: 'Description',
              hint: 'Brief description of your shop…',
              prefixIcon: Icons.notes_rounded,
              maxLines: 4,
              focusNode: _descFocus,
              textInputAction: TextInputAction.done,
              validator: _required,
            ),

            const SizedBox(height: 36),

            PrimaryButton(
              label: _isEditing ? 'Update Shop' : 'Save Shop',
              icon: _isEditing
                  ? Icons.check_rounded
                  : Icons.add_business_rounded,
              isLoading: _isSaving,
              onPressed: _isSaving ? null : _save,
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
