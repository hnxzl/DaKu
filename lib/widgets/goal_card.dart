import 'dart:io';
import 'package:flutter/material.dart';
import 'package:daku/models/saving_goal.dart';

class GoalCard extends StatelessWidget {
  final SavingGoal goal;
  final VoidCallback onTap;

  const GoalCard({required this.goal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final progress = goal.currentAmount / goal.targetAmount;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        contentPadding: EdgeInsets.all(10),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(goal.imagePath),
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(goal.title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(value: progress.clamp(0.0, 1.0)),
            SizedBox(height: 4),
            Text(
              "Rp${goal.currentAmount.toInt()} / Rp${goal.targetAmount.toInt()}",
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
