import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/startup_model.dart';
import '../../providers/startup_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

const _industries = ['Technology', 'Design', 'Education', 'Marketing', 'Finance', 'Other'];

class CreateStartupProfileScreen extends ConsumerStatefulWidget {
  final StartupModel? existing;
  const CreateStartupProfileScreen({super.key, this.existing});

  @override
  ConsumerState<CreateStartupProfileScreen> createState() => _CreateStartupProfileScreenState();
}

class _CreateStartupProfileScreenState extends ConsumerState<CreateStartupProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController =
      TextEditingController(text: widget.existing?.name ?? '');
  late final _descController =
      TextEditingController(text: widget.existing?.description ?? '');
  late final _emailController =
      TextEditingController(text: widget.existing?.contactEmail ?? '');
  late String _industry = widget.existing?.industry ?? _industries.first;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(startupControllerProvider.notifier).saveProfile(
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          industry: _industry,
          contactEmail: _emailController.text.trim(),
        );
    if (ok && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Startup profile submitted for review.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(startupControllerProvider);

    ref.listen(startupControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (err, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err.toString()), backgroundColor: AppColors.error),
        ),
      );
    });

    final isEditing = widget.existing != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit startup profile' : 'Create startup profile')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                if (!isEditing)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Only startups recognized at ALU are allowed to post. '
                      'Your profile will be reviewed before you can publish '
                      'internships.',
                      style: TextStyle(color: AppColors.grey400, fontSize: 12),
                    ),
                  ),
                CustomTextField(
                  controller: _nameController,
                  hint: 'Startup name',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _industry,
                  dropdownColor: AppColors.charcoal,
                  style: const TextStyle(color: AppColors.white, fontSize: 13),
                  decoration: const InputDecoration(hintText: 'Industry'),
                  items: _industries
                      .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                      .toList(),
                  onChanged: (v) => setState(() => _industry = v ?? _industry),
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _emailController,
                  hint: 'Contact email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descController,
                  maxLines: 4,
                  style: const TextStyle(color: AppColors.white, fontSize: 13),
                  decoration: const InputDecoration(hintText: 'Briefly describe your startup'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Add a short description' : null,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: isEditing ? 'Save changes' : 'Submit for review',
                  isLoading: state.isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
