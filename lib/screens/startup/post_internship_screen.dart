import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/internship_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

const _availableSkills = [
  'Flutter', 'Dart', 'Firebase', 'UI/UX', 'Research',
  'Marketing', 'Content', 'Data', 'Business', 'Design',
];

class PostInternshipScreen extends ConsumerStatefulWidget {
  const PostInternshipScreen({super.key});

  @override
  ConsumerState<PostInternshipScreen> createState() => _PostInternshipScreenState();
}

class _PostInternshipScreenState extends ConsumerState<PostInternshipScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _positionsController = TextEditingController(text: '1');
  final Set<String> _selectedSkills = {};
  bool _remote = true;
  bool _paid = true;
  DateTime _deadline = DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _positionsController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one required skill.')),
      );
      return;
    }

    final ok = await ref.read(internshipControllerProvider.notifier).post(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          skills: _selectedSkills.toList(),
          location: _remote ? 'Remote' : _locationController.text.trim(),
          remote: _remote,
          paid: _paid,
          deadline: _deadline,
          positions: int.tryParse(_positionsController.text) ?? 1,
        );

    if (ok && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Internship posted! Students can see it now.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(internshipControllerProvider);

    ref.listen(internshipControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (err, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err.toString()), backgroundColor: AppColors.error),
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Post an internship')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                CustomTextField(
                  controller: _titleController,
                  hint: 'Role title (e.g. Flutter Developer)',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descController,
                  maxLines: 4,
                  style: const TextStyle(color: AppColors.white, fontSize: 13),
                  decoration: const InputDecoration(
                      hintText: 'Describe the role and responsibilities'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Add a description' : null,
                ),
                const SizedBox(height: 18),
                const Text('Skills required',
                    style: TextStyle(
                        color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableSkills.map((skill) {
                    final selected = _selectedSkills.contains(skill);
                    return FilterChip(
                      label: Text(skill, style: const TextStyle(fontSize: 11)),
                      selected: selected,
                      selectedColor: AppColors.primaryRed,
                      backgroundColor: AppColors.charcoal,
                      labelStyle: TextStyle(
                          color: selected ? AppColors.white : AppColors.grey400),
                      side: BorderSide.none,
                      onSelected: (sel) => setState(() {
                        sel ? _selectedSkills.add(skill) : _selectedSkills.remove(skill);
                      }),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Remote', style: TextStyle(color: AppColors.white, fontSize: 13)),
                  value: _remote,
                  activeColor: AppColors.primaryRed,
                  onChanged: (v) => setState(() => _remote = v),
                ),
                if (!_remote) ...[
                  const SizedBox(height: 4),
                  CustomTextField(
                    controller: _locationController,
                    hint: 'Location (e.g. Kigali campus)',
                    validator: (v) => (!_remote && (v == null || v.trim().isEmpty))
                        ? 'Enter a location'
                        : null,
                  ),
                  const SizedBox(height: 14),
                ],
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Paid position', style: TextStyle(color: AppColors.white, fontSize: 13)),
                  value: _paid,
                  activeColor: AppColors.primaryRed,
                  onChanged: (v) => setState(() => _paid = v),
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _positionsController,
                  hint: 'Number of positions',
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    return (n == null || n < 1) ? 'Enter a valid number' : null;
                  },
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: _pickDeadline,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.charcoal,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 16, color: AppColors.grey400),
                        const SizedBox(width: 10),
                        Text(
                          'Deadline: ${_deadline.day}/${_deadline.month}/${_deadline.year}',
                          style: const TextStyle(color: AppColors.white, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Post internship',
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
