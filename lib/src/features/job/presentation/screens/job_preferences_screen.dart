import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/preferences_provider.dart';
import '../../../../core/constants/job_categories.dart';

class JobPreferencesScreen extends ConsumerStatefulWidget {
  const JobPreferencesScreen({super.key});

  @override
  ConsumerState<JobPreferencesScreen> createState() =>
      _JobPreferencesScreenState();
}

class _JobPreferencesScreenState extends ConsumerState<JobPreferencesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _selectedCategories = <String>{};
  final _selectedLocations = <String>{};
  double? _minSalary;
  double? _maxSalary;

  static const _locations = [
    'Douala',
    'Yaoundé',
    'Bafoussam',
    'Bamenda',
    'Garoua',
    'Maroua',
    'Ngaoundéré',
    'Bertoua',
    'Limbé',
    'Kribi',
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialPreferences();
  }

  void _loadInitialPreferences() {
    final prefs = ref.read(preferencesProvider);
    setState(() {
      _selectedCategories.addAll(prefs.preferredCategories);
      _selectedLocations.addAll(prefs.preferredLocations);
      _minSalary = prefs.minimumSalary;
      _maxSalary = null; // maxSalary is not part of the new model
    });
  }

  Future<void> _savePreferences() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(preferencesProvider.notifier);
    notifier.updateCategories(_selectedCategories.toList());
    notifier.updateLocations(_selectedLocations.toList());
    notifier.updateSalaryRange(_minSalary, _maxSalary);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSetPreferences', true);

    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Preferences'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Select your preferred job categories',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: JobCategories.categories.map((category) {
                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(category.icon),
                      const SizedBox(width: 4),
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
                );
              }).toList(),
            ),
            if (_selectedCategories.isEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Please select at least one category',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              'Select preferred locations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _locations.map((location) {
                return FilterChip(
                  label: Text(location),
                  selected: _selectedLocations.contains(location),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedLocations.add(location);
                      } else {
                        _selectedLocations.remove(location);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            if (_selectedLocations.isEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Please select at least one location',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              'Salary Range (Optional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Minimum Salary',
                      prefixText: 'XAF ',
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: _minSalary?.toString(),
                    onChanged: (value) {
                      setState(() {
                        _minSalary = double.tryParse(value);
                      });
                    },
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final salary = double.tryParse(value);
                        if (salary == null) {
                          return 'Invalid number';
                        }
                        if (_maxSalary != null && salary > _maxSalary!) {
                          return 'Min cannot be greater than max';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Maximum Salary',
                      prefixText: 'XAF ',
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: _maxSalary?.toString(),
                    onChanged: (value) {
                      setState(() {
                        _maxSalary = double.tryParse(value);
                      });
                    },
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final salary = double.tryParse(value);
                        if (salary == null) {
                          return 'Invalid number';
                        }
                        if (_minSalary != null && salary < _minSalary!) {
                          return 'Max cannot be less than min';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed:
                    _selectedCategories.isEmpty || _selectedLocations.isEmpty
                        ? null
                        : _savePreferences,
                child: const Text('Save Preferences'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  ref.read(preferencesProvider.notifier).clearPreferences();
                  context.go('/home');
                },
                child: const Text('Skip for Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
