import 'package:flutter/material.dart';

class EventSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final Function(String) onCategorySelected;
  final List<String> categories;
  final String? selectedCategory;

  const EventSearchBar({
    super.key,
    required this.onSearch,
    required this.onCategorySelected,
    required this.categories,
    this.selectedCategory,
  });

  @override
  State<EventSearchBar> createState() => _EventSearchBarState();
}

class _EventSearchBarState extends State<EventSearchBar> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search events...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          onChanged: widget.onSearch,
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: const Text('All'),
                selected: widget.selectedCategory == null,
                onSelected: (_) => widget.onCategorySelected(''),
              ),
              const SizedBox(width: 8),
              ...widget.categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: category == widget.selectedCategory,
                    onSelected: (_) => widget.onCategorySelected(category),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
