import 'package:hive/hive.dart';

part 'saving_goal.g.dart';

@HiveType(typeId: 0)
class SavingGoal extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double targetAmount;

  @HiveField(3)
  String imagePath;

  @HiveField(4)
  double currentAmount;

  @HiveField(5)
  DateTime createdAt;

  SavingGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.imagePath,
    this.currentAmount = 0.0,
    required this.createdAt,
  });
}
