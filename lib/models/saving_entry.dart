import 'package:hive/hive.dart';

part 'saving_entry.g.dart';

@HiveType(typeId: 1)
class SavingEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String goalId;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String? note;

  @HiveField(4)
  DateTime date;

  SavingEntry({
    required this.id,
    required this.goalId,
    required this.amount,
    this.note,
    required this.date,
  });
}
