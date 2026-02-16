import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/search_provider.dart';
import '../../../../core/services/analytics_service.dart';

class JobSearchBar extends ConsumerStatefulWidget {
  const JobSearchBar({super.key});

  @override
  ConsumerState<JobSearchBar> createState() => _JobSearchBarState();
}

class _JobSearchBarState extends ConsumerState<JobSearchBar> {
  final _searchController = TextEditingController();
  late final _analyticsService = ref.read(analyticsServiceProvider);
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) async {
    final currentFilters = ref.read(searchFiltersProvider);
    ref.read(searchFiltersProvider.notifier).state = currentFilters.copyWith(
      query: query,
    );
    await _analyticsService.logSearch(query);
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(searchFiltersProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search jobs...',
                    border: InputBorder.none,
                    icon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearch('');
                            },
                          )
                        : null,
                  ),
                  onChanged: _onSearch,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color: _showFilters ? Theme.of(context).primaryColor : null,
                ),
                onPressed: _toggleFilters,
              ),
            ],
          ),
        ),
        if (_showFilters) ...[
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'Remote Only',
                  selected: filters.isRemote ?? false,
                  onSelected: (selected) {
                    ref.read(searchFiltersProvider.notifier).state =
                        filters.copyWith(isRemote: selected);
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Full Time',
                  selected: filters.jobTypes?.contains('Full Time') ?? false,
                  onSelected: (selected) {
                    final jobTypes = filters.jobTypes?.toList() ?? [];
                    if (selected) {
                      jobTypes.add('Full Time');
                    } else {
                      jobTypes.remove('Full Time');
                    }
                    ref.read(searchFiltersProvider.notifier).state =
                        filters.copyWith(jobTypes: jobTypes);
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Part Time',
                  selected: filters.jobTypes?.contains('Part Time') ?? false,
                  onSelected: (selected) {
                    final jobTypes = filters.jobTypes?.toList() ?? [];
                    if (selected) {
                      jobTypes.add('Part Time');
                    } else {
                      jobTypes.remove('Part Time');
                    }
                    ref.read(searchFiltersProvider.notifier).state =
                        filters.copyWith(jobTypes: jobTypes);
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
    );
  }
}
