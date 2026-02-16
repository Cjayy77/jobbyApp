import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/job_categories.dart';
import '../../models/job_duration.dart';

class JobCreationScreen extends StatefulWidget {
  const JobCreationScreen({super.key});

  @override
  State<JobCreationScreen> createState() => _JobCreationScreenState();
}

class _JobCreationScreenState extends State<JobCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _position = '';
  String _companyName = '';
  JobDuration _duration = JobDuration.fullTime;
  String _location = '';
  double? _salary;
  String _description = '';
  final Set<String> _selectedCategories = {};
  XFile? _imageFile;
  final _imagePicker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate() || _selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    _formKey.currentState!.save();

    // Create job object
    final job = {
      'position': _position,
      'companyName': _companyName,
      'duration': _duration,
      'location': _location,
      'salary': _salary,
      'description': _description,
      'categories': _selectedCategories.toList(),
      'imageFile': _imageFile?.path,
    };

    // Navigate to confirmation screen with job data
    Navigator.of(context).pushNamed(
      '/job-confirmation',
      arguments: job,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a Job'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Position *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the position';
                }
                return null;
              },
              onSaved: (value) => _position = value!.trim(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Company Name *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the company name';
                }
                return null;
              },
              onSaved: (value) => _companyName = value!.trim(),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<JobDuration>(
              decoration: const InputDecoration(
                labelText: 'Duration *',
                border: OutlineInputBorder(),
              ),
              value: _duration,
              items: JobDuration.values.map((duration) {
                return DropdownMenuItem(
                  value: duration,
                  child: Text(duration.toString().split('.').last),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _duration = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Location *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the location';
                }
                return null;
              },
              onSaved: (value) => _location = value!.trim(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Salary (Optional)',
                border: OutlineInputBorder(),
                prefixText: 'XAF ',
              ),
              keyboardType: TextInputType.number,
              onSaved: (value) {
                if (value != null && value.isNotEmpty) {
                  _salary = double.tryParse(value);
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Job Description *',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the job description';
                }
                return null;
              },
              onSaved: (value) => _description = value!.trim(),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Job Categories *',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: JobCategories.categories.map((category) {
                    return FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(category.icon),
                          const SizedBox(width: 8),
                          Text(category.name),
                        ],
                      ),
                      selected: _selectedCategories.contains(category.id),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedCategories.add(category.id);
                          } else {
                            _selectedCategories.remove(category.id);
                          }
                        });
                      },
                      selectedColor:
                          Theme.of(context).primaryColor.withOpacity(0.2),
                      checkmarkColor: Theme.of(context).primaryColor,
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: _imageFile != null
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.image_outlined),
              title: const Text('Company Logo or Job Image (Optional)'),
              subtitle: _imageFile != null
                  ? Text(_imageFile!.name)
                  : const Text('Tap to upload an image'),
              trailing: _imageFile != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _imageFile = null;
                        });
                      },
                    )
                  : null,
              onTap: _pickImage,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Preview & Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
