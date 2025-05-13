import 'package:flutter/material.dart';
import 'package:daku/models/saving_goal.dart';
import 'package:hive/hive.dart';
import 'package:daku/screens/add_goal_screen.dart';
import 'package:daku/screens/goal_detail_screen.dart';
import 'package:daku/widgets/goal_card.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<SavingGoal> goalBox;

  @override
  void initState() {
    super.initState();
    goalBox = Hive.box<SavingGoal>('goals');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Color(0xFF0B192C),
      appBar: AppBar(
        backgroundColor: Color(0xFF0B192C),
        elevation: 0,
        title: Text(
          "DaKu",
          style: theme.textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(Icons.savings_rounded, color: Colors.white70, size: 28),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Text(
              "Halo, sudah nabung hari ini?",
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1E3E62),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 18),
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddGoalScreen()),
                  );
                  setState(() {});
                },
                child: Text(
                  "+ Tambah Target Baru",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: goalBox.listenable(),
                builder: (context, Box<SavingGoal> box, _) {
                  if (box.values.isEmpty) {
                    return Center(
                      child: Text(
                        "Belum ada tujuan nabung",
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: box.values.length,
                    separatorBuilder: (_, __) => SizedBox(height: 18),
                    itemBuilder: (context, i) {
                      final goal = box.values.elementAt(i);
                      final progress = goal.currentAmount / goal.targetAmount;
                      final percent = (progress * 100).clamp(0, 100).toInt();
                      final formatter = NumberFormat.decimalPattern('id');
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GoalDetailScreen(goal: goal),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF1E3E62),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          padding: EdgeInsets.all(18),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(goal.imagePath),
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      goal.title,
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      "Target: Rp${formatter.format(goal.targetAmount.toInt())}",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      "Terkumpul: Rp${formatter.format(goal.currentAmount.toInt())}",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 15,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Stack(
                                      children: [
                                        Container(
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: Color(0xFF35363C),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: 10,
                                          width:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.45 *
                                              progress.clamp(0.0, 1.0),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFF5EE2FF),
                                                Color(0xFF3A8DFF),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                "$percent%",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
