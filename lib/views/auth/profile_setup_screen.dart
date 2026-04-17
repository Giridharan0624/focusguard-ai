import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _occupationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<AuthViewModel>().saveProfile(
      name: _nameController.text.trim(),
      age: int.tryParse(_ageController.text.trim()),
      occupation: _occupationController.text.trim().isNotEmpty
          ? _occupationController.text.trim()
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 68, height: 68,
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accent.withValues(alpha: 0.25),
                          blurRadius: 20, offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.person_rounded,
                        size: 36, color: AppTheme.onAccent),
                  ),
                  const SizedBox(height: 20),
                  Text('Set Up Your Profile',
                      style: Theme.of(context).textTheme.headlineLarge,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text('Help us personalize your experience',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 36),

                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      hintText: 'Your Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) => v != null && v.trim().isNotEmpty
                        ? null : 'Name is required',
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Age (optional)',
                      prefixIcon: Icon(Icons.cake_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _occupationController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      hintText: 'Occupation (optional)',
                      prefixIcon: Icon(Icons.work_outline),
                    ),
                  ),

                  if (authVM.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(authVM.errorMessage!,
                          style: const TextStyle(
                              color: AppTheme.riskCritical, fontSize: 13),
                          textAlign: TextAlign.center),
                    ),
                  const SizedBox(height: 24),

                  // Yellow pill continue
                  GestureDetector(
                    onTap: authVM.isLoading ? null : _saveProfile,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.accent,
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text('Continue',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.onAccent)),
                          ),
                          Container(
                            width: 36, height: 36,
                            decoration: const BoxDecoration(
                                color: AppTheme.onAccent,
                                shape: BoxShape.circle),
                            child: authVM.isLoading
                                ? const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppTheme.accent),
                                  )
                                : const Icon(Icons.arrow_forward_rounded,
                                    size: 18, color: AppTheme.accent),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
