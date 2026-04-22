import 'package:flutter/material.dart';
import '../utils/food_calorie_data.dart';

class FoodCaloriePicker extends StatefulWidget {
  const FoodCaloriePicker({super.key});

  @override
  State<FoodCaloriePicker> createState() => _FoodCaloriePickerState();
}

class _FoodCaloriePickerState extends State<FoodCaloriePicker> {
  final _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;
  List<FoodCalorieItem> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchResults = FoodCalorieData.search(value);
    });
  }

  void _selectItem(FoodCalorieItem item) {
    Navigator.pop(context, (item.name, item.caloriesPer100g));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: '搜索食物名称',
                      border: InputBorder.none,
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (_searchController.text.isNotEmpty)
            Expanded(
              child: _buildSearchResults(),
            )
          else
            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    height: 44,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: FoodCalorieData.categories.length,
                      itemBuilder: (context, index) {
                        final category = FoodCalorieData.categories[index];
                        final selected = index == _selectedCategoryIndex;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 6,
                          ),
                          child: ChoiceChip(
                            label: Text(category.name),
                            selected: selected,
                            onSelected: (_) {
                              setState(() => _selectedCategoryIndex = index);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: _buildCategoryList(
                      FoodCalorieData.categories[_selectedCategoryIndex],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(child: Text('未找到相关食物'));
    }
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        return _buildFoodTile(item);
      },
    );
  }

  Widget _buildCategoryList(FoodCategory category) {
    return ListView.builder(
      itemCount: category.items.length,
      itemBuilder: (context, index) {
        final item = category.items[index];
        return _buildFoodTile(item);
      },
    );
  }

  Widget _buildFoodTile(FoodCalorieItem item) {
    return ListTile(
      dense: true,
      title: Text(item.name),
      subtitle: Text('${item.caloriesPer100g} 千卡/100克'),
      trailing: const Icon(Icons.add_circle_outline, color: Colors.green),
      onTap: () => _selectItem(item),
    );
  }
}
