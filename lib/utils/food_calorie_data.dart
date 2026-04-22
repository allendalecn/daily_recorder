class FoodCalorieItem {
  final String name;
  final int caloriesPer100g;
  final String? unit;

  const FoodCalorieItem({
    required this.name,
    required this.caloriesPer100g,
    this.unit,
  });
}

class FoodCategory {
  final String name;
  final List<FoodCalorieItem> items;

  const FoodCategory({required this.name, required this.items});
}

class FoodCalorieData {
  static const List<FoodCategory> categories = [
    FoodCategory(
      name: '主食',
      items: [
        FoodCalorieItem(name: '米饭', caloriesPer100g: 116),
        FoodCalorieItem(name: '馒头', caloriesPer100g: 223),
        FoodCalorieItem(name: '面条（煮）', caloriesPer100g: 110),
        FoodCalorieItem(name: '包子', caloriesPer100g: 227),
        FoodCalorieItem(name: '饺子', caloriesPer100g: 240),
        FoodCalorieItem(name: '馄饨', caloriesPer100g: 150),
        FoodCalorieItem(name: '煎饼', caloriesPer100g: 354),
        FoodCalorieItem(name: '油条', caloriesPer100g: 386),
        FoodCalorieItem(name: '粥（白米）', caloriesPer100g: 46),
        FoodCalorieItem(name: '全麦面包', caloriesPer100g: 246),
        FoodCalorieItem(name: '玉米', caloriesPer100g: 112),
        FoodCalorieItem(name: '红薯', caloriesPer100g: 86),
        FoodCalorieItem(name: '土豆', caloriesPer100g: 77),
        FoodCalorieItem(name: '燕麦片', caloriesPer100g: 377),
        FoodCalorieItem(name: '米粉', caloriesPer100g: 349),
      ],
    ),
    FoodCategory(
      name: '肉蛋',
      items: [
        FoodCalorieItem(name: '猪肉（瘦）', caloriesPer100g: 143),
        FoodCalorieItem(name: '猪肉（肥）', caloriesPer100g: 807),
        FoodCalorieItem(name: '五花肉', caloriesPer100g: 349),
        FoodCalorieItem(name: '牛肉（瘦）', caloriesPer100g: 106),
        FoodCalorieItem(name: '羊肉（瘦）', caloriesPer100g: 118),
        FoodCalorieItem(name: '鸡胸肉', caloriesPer100g: 133),
        FoodCalorieItem(name: '鸡腿肉', caloriesPer100g: 181),
        FoodCalorieItem(name: '鸡蛋', caloriesPer100g: 144),
        FoodCalorieItem(name: '鸭蛋', caloriesPer100g: 180),
        FoodCalorieItem(name: '火腿肠', caloriesPer100g: 212),
        FoodCalorieItem(name: '香肠', caloriesPer100g: 508),
        FoodCalorieItem(name: '腊肉', caloriesPer100g: 692),
        FoodCalorieItem(name: '鱼肉', caloriesPer100g: 113),
        FoodCalorieItem(name: '虾', caloriesPer100g: 93),
        FoodCalorieItem(name: '螃蟹', caloriesPer100g: 103),
      ],
    ),
    FoodCategory(
      name: '蔬菜',
      items: [
        FoodCalorieItem(name: '白菜', caloriesPer100g: 18),
        FoodCalorieItem(name: '菠菜', caloriesPer100g: 28),
        FoodCalorieItem(name: '生菜', caloriesPer100g: 15),
        FoodCalorieItem(name: '黄瓜', caloriesPer100g: 16),
        FoodCalorieItem(name: '番茄', caloriesPer100g: 20),
        FoodCalorieItem(name: '胡萝卜', caloriesPer100g: 41),
        FoodCalorieItem(name: '西兰花', caloriesPer100g: 34),
        FoodCalorieItem(name: '芹菜', caloriesPer100g: 14),
        FoodCalorieItem(name: '茄子', caloriesPer100g: 25),
        FoodCalorieItem(name: '青椒', caloriesPer100g: 22),
        FoodCalorieItem(name: '土豆泥', caloriesPer100g: 113),
        FoodCalorieItem(name: '豆腐', caloriesPer100g: 76),
        FoodCalorieItem(name: '豆腐干', caloriesPer100g: 140),
        FoodCalorieItem(name: '腐竹', caloriesPer100g: 460),
        FoodCalorieItem(name: '香菇', caloriesPer100g: 26),
      ],
    ),
    FoodCategory(
      name: '水果',
      items: [
        FoodCalorieItem(name: '苹果', caloriesPer100g: 52),
        FoodCalorieItem(name: '香蕉', caloriesPer100g: 89),
        FoodCalorieItem(name: '橙子', caloriesPer100g: 47),
        FoodCalorieItem(name: '梨', caloriesPer100g: 57),
        FoodCalorieItem(name: '葡萄', caloriesPer100g: 69),
        FoodCalorieItem(name: '西瓜', caloriesPer100g: 30),
        FoodCalorieItem(name: '草莓', caloriesPer100g: 32),
        FoodCalorieItem(name: '桃子', caloriesPer100g: 39),
        FoodCalorieItem(name: '芒果', caloriesPer100g: 60),
        FoodCalorieItem(name: '榴莲', caloriesPer100g: 147),
        FoodCalorieItem(name: '荔枝', caloriesPer100g: 66),
        FoodCalorieItem(name: '樱桃', caloriesPer100g: 50),
        FoodCalorieItem(name: '猕猴桃', caloriesPer100g: 61),
      ],
    ),
    FoodCategory(
      name: '零食饮品',
      items: [
        FoodCalorieItem(name: '牛奶', caloriesPer100g: 54),
        FoodCalorieItem(name: '酸奶', caloriesPer100g: 72),
        FoodCalorieItem(name: '豆浆', caloriesPer100g: 31),
        FoodCalorieItem(name: '可乐', caloriesPer100g: 43),
        FoodCalorieItem(name: '奶茶', caloriesPer100g: 65),
        FoodCalorieItem(name: '啤酒', caloriesPer100g: 43),
        FoodCalorieItem(name: '巧克力', caloriesPer100g: 546),
        FoodCalorieItem(name: '薯片', caloriesPer100g: 536),
        FoodCalorieItem(name: '饼干', caloriesPer100g: 502),
        FoodCalorieItem(name: '蛋糕', caloriesPer100g: 371),
        FoodCalorieItem(name: '冰淇淋', caloriesPer100g: 207),
        FoodCalorieItem(name: '坚果混合', caloriesPer100g: 607),
        FoodCalorieItem(name: '瓜子', caloriesPer100g: 597),
        FoodCalorieItem(name: '话梅', caloriesPer100g: 280),
      ],
    ),
    FoodCategory(
      name: '中式菜肴',
      items: [
        FoodCalorieItem(name: '麻婆豆腐', caloriesPer100g: 126),
        FoodCalorieItem(name: '宫保鸡丁', caloriesPer100g: 180),
        FoodCalorieItem(name: '鱼香肉丝', caloriesPer100g: 165),
        FoodCalorieItem(name: '番茄炒蛋', caloriesPer100g: 120),
        FoodCalorieItem(name: '红烧肉', caloriesPer100g: 470),
        FoodCalorieItem(name: '糖醋里脊', caloriesPer100g: 280),
        FoodCalorieItem(name: '清炒时蔬', caloriesPer100g: 60),
        FoodCalorieItem(name: '酸辣汤', caloriesPer100g: 45),
        FoodCalorieItem(name: '饺子（猪肉）', caloriesPer100g: 240),
        FoodCalorieItem(name: '馄饨（鲜肉）', caloriesPer100g: 150),
        FoodCalorieItem(name: '煎饺', caloriesPer100g: 280),
        FoodCalorieItem(name: '炒饭', caloriesPer100g: 188),
        FoodCalorieItem(name: '炒面', caloriesPer100g: 170),
        FoodCalorieItem(name: '火锅（均摊）', caloriesPer100g: 200),
        FoodCalorieItem(name: '凉皮', caloriesPer100g: 117),
        FoodCalorieItem(name: '肉夹馍', caloriesPer100g: 260),
        FoodCalorieItem(name: '煎饼果子', caloriesPer100g: 220),
        FoodCalorieItem(name: '小笼包', caloriesPer100g: 230),
        FoodCalorieItem(name: '热干面', caloriesPer100g: 165),
        FoodCalorieItem(name: '兰州拉面', caloriesPer100g: 140),
      ],
    ),
    FoodCategory(
      name: '快餐西餐',
      items: [
        FoodCalorieItem(name: '汉堡包', caloriesPer100g: 295),
        FoodCalorieItem(name: '薯条', caloriesPer100g: 312),
        FoodCalorieItem(name: '披萨', caloriesPer100g: 266),
        FoodCalorieItem(name: '炸鸡', caloriesPer100g: 290),
        FoodCalorieItem(name: '三明治', caloriesPer100g: 220),
        FoodCalorieItem(name: '意大利面', caloriesPer100g: 131),
        FoodCalorieItem(name: '牛排', caloriesPer100g: 250),
        FoodCalorieItem(name: '沙拉（配酱）', caloriesPer100g: 120),
        FoodCalorieItem(name: '寿司', caloriesPer100g: 143),
        FoodCalorieItem(name: '泡面', caloriesPer100g: 445),
        FoodCalorieItem(name: '关东煮', caloriesPer100g: 80),
      ],
    ),
  ];

  static List<FoodCalorieItem> get allItems {
    return categories.expand((c) => c.items).toList();
  }

  static List<FoodCalorieItem> search(String query) {
    if (query.isEmpty) return [];
    final lower = query.toLowerCase();
    return allItems
        .where((item) => item.name.toLowerCase().contains(lower))
        .toList();
  }
}
