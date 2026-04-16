import '../models/food_item.dart';

const List<FoodItem> kPresetFoods = [
  // Protein-rich
  FoodItem(id: 1,  name: 'Boiled Egg',        servingSize: 50,  protein: 6,  calories: 78,  carbs: 1,  fat: 5,  category: 'protein-rich', icon: '\u{1F95A}', unit: 'nos',   stepSize: 1),
  FoodItem(id: 2,  name: 'Grilled Chicken',    servingSize: 150, protein: 31, calories: 165, carbs: 0,  fat: 4,  category: 'protein-rich', icon: '\u{1F357}', unit: 'grams', stepSize: 50),
  FoodItem(id: 3,  name: 'Paneer',             servingSize: 100, protein: 18, calories: 265, carbs: 1,  fat: 21, category: 'protein-rich', icon: '\u{1F9C0}', unit: 'grams', stepSize: 50),
  FoodItem(id: 4,  name: 'Dal (Lentils)',       servingSize: 200, protein: 13, calories: 180, carbs: 30, fat: 1,  category: 'protein-rich', icon: '\u{1F372}', unit: 'ml',    stepSize: 100),
  FoodItem(id: 5,  name: 'Greek Yogurt',        servingSize: 150, protein: 15, calories: 100, carbs: 6,  fat: 1,  category: 'protein-rich', icon: '\u{1F95B}', unit: 'ml',    stepSize: 50),
  FoodItem(id: 19, name: 'Grilled Fish',        servingSize: 150, protein: 26, calories: 140, carbs: 0,  fat: 3,  category: 'protein-rich', icon: '\u{1F41F}', unit: 'grams', stepSize: 50),
  FoodItem(id: 23, name: 'Almonds',             servingSize: 30,  protein: 6,  calories: 170, carbs: 6,  fat: 15, category: 'protein-rich', icon: '\u{1F95C}', unit: 'grams', stepSize: 10),

  // Energy
  FoodItem(id: 6,  name: 'White Rice',          servingSize: 200, protein: 4,  calories: 260, carbs: 58, fat: 0,  category: 'energy',       icon: '\u{1F35A}', unit: 'grams', stepSize: 50),
  FoodItem(id: 7,  name: 'Chapati / Roti',      servingSize: 40,  protein: 3,  calories: 104, carbs: 18, fat: 3,  category: 'energy',       icon: '\u{1F956}', unit: 'nos',   stepSize: 1),
  FoodItem(id: 8,  name: 'Banana',              servingSize: 120, protein: 1,  calories: 105, carbs: 27, fat: 0,  category: 'energy',       icon: '\u{1F34C}', unit: 'nos',   stepSize: 1),
  FoodItem(id: 9,  name: 'Oats (cooked)',       servingSize: 200, protein: 5,  calories: 150, carbs: 27, fat: 3,  category: 'energy',       icon: '\u{1F35C}', unit: 'grams', stepSize: 50),
  FoodItem(id: 10, name: 'Peanut Butter',       servingSize: 32,  protein: 8,  calories: 190, carbs: 6,  fat: 16, category: 'energy',       icon: '\u{1F95C}', unit: 'grams', stepSize: 10),
  FoodItem(id: 25, name: 'Poha',                servingSize: 200, protein: 5,  calories: 250, carbs: 45, fat: 5,  category: 'energy',       icon: '\u{1F35A}', unit: 'grams', stepSize: 50),

  // Balanced
  FoodItem(id: 11, name: 'Mixed Veg Curry',     servingSize: 200, protein: 4,  calories: 120, carbs: 15, fat: 5,  category: 'balanced',     icon: '\u{1F35B}', unit: 'ml',    stepSize: 100),
  FoodItem(id: 12, name: 'Chicken Curry',       servingSize: 200, protein: 20, calories: 240, carbs: 8,  fat: 14, category: 'balanced',     icon: '\u{1F35B}', unit: 'ml',    stepSize: 100),
  FoodItem(id: 13, name: 'Egg Fried Rice',      servingSize: 250, protein: 10, calories: 320, carbs: 45, fat: 10, category: 'balanced',     icon: '\u{1F35A}', unit: 'grams', stepSize: 50),
  FoodItem(id: 14, name: 'Idli',                servingSize: 50,  protein: 2,  calories: 65,  carbs: 13, fat: 0,  category: 'balanced',     icon: '\u{1F958}', unit: 'nos',   stepSize: 1),
  FoodItem(id: 15, name: 'Dosa',                servingSize: 80,  protein: 3,  calories: 120, carbs: 20, fat: 3,  category: 'balanced',     icon: '\u{1F958}', unit: 'nos',   stepSize: 1),
  FoodItem(id: 21, name: 'Milk',                servingSize: 250, protein: 8,  calories: 150, carbs: 12, fat: 8,  category: 'balanced',     icon: '\u{1F95B}', unit: 'ml',    stepSize: 100),
  FoodItem(id: 24, name: 'Curd / Yogurt',       servingSize: 200, protein: 6,  calories: 120, carbs: 8,  fat: 6,  category: 'balanced',     icon: '\u{1F95B}', unit: 'ml',    stepSize: 50),

  // Light
  FoodItem(id: 16, name: 'Sprouts Salad',       servingSize: 150, protein: 9,  calories: 80,  carbs: 12, fat: 1,  category: 'light',        icon: '\u{1F331}', unit: 'grams', stepSize: 50),
  FoodItem(id: 17, name: 'Green Salad',         servingSize: 200, protein: 2,  calories: 35,  carbs: 7,  fat: 0,  category: 'light',        icon: '\u{1F957}', unit: 'grams', stepSize: 50),
  FoodItem(id: 18, name: 'Clear Soup',          servingSize: 250, protein: 3,  calories: 50,  carbs: 5,  fat: 2,  category: 'light',        icon: '\u{1F372}', unit: 'ml',    stepSize: 100),
  FoodItem(id: 20, name: 'Steamed Veggies',     servingSize: 200, protein: 3,  calories: 60,  carbs: 10, fat: 1,  category: 'light',        icon: '\u{1F966}', unit: 'grams', stepSize: 50),
  FoodItem(id: 22, name: 'Apple',               servingSize: 150, protein: 0,  calories: 78,  carbs: 21, fat: 0,  category: 'light',        icon: '\u{1F34E}', unit: 'nos',   stepSize: 1),
];
