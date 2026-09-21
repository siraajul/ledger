import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/expense.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final Set<String> _selectedCategories = {};

  @override
  void initState() {
    super.initState();
    // Pre-select some defaults
    _selectedCategories.addAll(['Food', 'Transport', 'Shopping']);
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
    _saveCategories();
  }

  void _saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'preferred_categories',
      _selectedCategories.toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 2),
          const Text(
            'What do you\nspend on?',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Pick your main categories. You can always add more later.",
            style: TextStyle(
              fontSize: 17,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.6,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = _selectedCategories.contains(category.name);

                return GestureDetector(
                  onTap: () => _toggleCategory(category.name),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Color(category.color).withValues(alpha: 0.12)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? Color(category.color)
                            : Colors.grey[200]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          category.icon,
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          category.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? const Color(0xFF1A1A2E)
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_selectedCategories.length} selected',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}
