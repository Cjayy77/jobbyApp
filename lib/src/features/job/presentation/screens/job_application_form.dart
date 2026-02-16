import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/job_applications_provider.dart';
import '../../../../core/widgets/error_dialog.dart';
import '../../../auth/providers/auth_provider.dart';

class JobApplicationForm extends ConsumerStatefulWidget {
  final String jobId;

  const JobApplicationForm({
    super.key,
    required this.jobId,
  });

  @override
  ConsumerState<JobApplicationForm> createState() => _JobApplicationFormState();
}

class _JobApplicationFormState extends ConsumerState<JobApplicationForm> {
  final _formKey = GlobalKey<FormState>();
  String? _resumePath;
  String _coverLetter = '';
  bool _isSubmitting = false;

  Future<void> _pickResume() async {
    final picker = ImagePicker();
    final result = await picker.pickMedia(
      imageQuality: 70,
      requestFullMetadata: false,
    );

    if (result != null) {
      setState(() {
        _resumePath = result.path;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_resumePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload your resume')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = ref.read(authProvider);
      if (user == null) throw Exception('User not authenticated');

      await ref.read(jobApplicationsProvider.notifier).submitApplication(
            jobId: widget.jobId,
            userId: user.uid,
            resumePath: _resumePath!,
            coverLetter: _coverLetter,
          );

      if (mounted) {
        Navigator.of(context).pop(true); // Return success
      }
    } catch (e) {
      if (mounted) {
        await ErrorDialog.show(
          context,
          error: e,
          title: 'Application Error',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply for Job'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Upload Resume',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _isSubmitting ? null : _pickResume,
              icon: const Icon(Icons.upload_file),
              label: Text(
                  _resumePath != null ? 'Resume Selected' : 'Select Resume'),
            ),
            const SizedBox(height: 24),
            Text(
              'Cover Letter',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: 'Write your cover letter...',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a cover letter';
                }
                if (value.length < 100) {
                  return 'Cover letter must be at least 100 characters';
                }
                return null;
              },
              onChanged: (value) => _coverLetter = value,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const CircularProgressIndicator()
                  : const Text('Submit Application'),
            ),
          ],
        ),
      ),
    );
  }
}
