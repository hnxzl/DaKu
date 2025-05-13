import 'package:flutter/material.dart';
import 'package:daku/models/saving_entry.dart';
import 'package:daku/models/saving_goal.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:daku/widgets/entry_tile.dart';
import 'package:daku/screens/add_entry_screen.dart';
import 'package:daku/screens/add_goal_screen.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class GoalDetailScreen extends StatefulWidget {
  final SavingGoal goal;

  const GoalDetailScreen({required this.goal});

  @override
  _GoalDetailScreenState createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  late Box<SavingEntry> entryBox;

  @override
  void initState() {
    super.initState();
    entryBox = Hive.box<SavingEntry>('entries');
  }

  List<SavingEntry> getEntries() {
    return entryBox.values.where((e) => e.goalId == widget.goal.id).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  void _deleteGoal() async {
    final confirm = await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Color(0xFF1E3E62),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                SizedBox(width: 8),
                Text(
                  "Hapus Tujuan?",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              "Yakin mau hapus '${widget.goal.title}' beserta semua catatannya?",
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Batal", style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                child: Text(
                  "Hapus",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
    );
    if (confirm == true) {
      // Hapus semua entry terkait
      final related =
          entryBox.values.where((e) => e.goalId == widget.goal.key).toList();
      for (var e in related) {
        await e.delete();
      }
      await widget.goal.delete();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = getEntries();
    final progress = widget.goal.currentAmount / widget.goal.targetAmount;
    final percent = (progress * 100).clamp(0, 100).toInt();
    final formatter = NumberFormat.decimalPattern('id');
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Color(0xFF0B192C),
      appBar: AppBar(
        backgroundColor: Color(0xFF0B192C),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Tujuan: ${widget.goal.title}',
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white70),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddGoalScreen(goalToEdit: widget.goal),
                  ),
                ).then((_) => setState(() {})),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF1E3E62),
              borderRadius: BorderRadius.circular(18),
            ),
            padding: EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(widget.goal.imagePath),
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.goal.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Text('🎯 ', style: TextStyle(fontSize: 18)),
                              Text(
                                'Target: Rp${formatter.format(widget.goal.targetAmount.toInt())}',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text('💰 ', style: TextStyle(fontSize: 18)),
                              Text(
                                'Terkumpul: Rp${formatter.format(widget.goal.currentAmount.toInt())}',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18),
                Stack(
                  children: [
                    Container(
                      height: 18,
                      decoration: BoxDecoration(
                        color: Color(0xFF35363C),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Container(
                      height: 18,
                      width:
                          MediaQuery.of(context).size.width *
                          0.7 *
                          progress.clamp(0.0, 1.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF5EE2FF), Color(0xFF3A8DFF)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: Text(
                          '$percent%',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                if (widget.goal.currentAmount < widget.goal.targetAmount)
                  Text(
                    'Kurang: Rp${formatter.format((widget.goal.targetAmount - widget.goal.currentAmount).ceil())}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                if (widget.goal.currentAmount >= widget.goal.targetAmount)
                  Container(
                    margin: EdgeInsets.only(top: 6, bottom: 2),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF3A8DFF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.emoji_events, color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Tercapai 🎉',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 18),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                        size: 28,
                      ),
                      tooltip: 'Hapus / Reset Tujuan',
                      onPressed: _deleteGoal,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              widget.goal.currentAmount >=
                                      widget.goal.targetAmount
                                  ? Colors.grey
                                  : Color(0xFF3A8DFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: Icon(Icons.add, color: Colors.white),
                        label: Text(
                          'Tambah Catatan Nabung',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed:
                            widget.goal.currentAmount >=
                                    widget.goal.targetAmount
                                ? () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Color(0xFF1E3E62),
                                      content: Text('Target sudah tercapai!'),
                                    ),
                                  );
                                }
                                : () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) =>
                                              AddEntryScreen(goal: widget.goal),
                                    ),
                                  );
                                  if (result == true) setState(() {});
                                },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 28),
          Text(
            '📜 Riwayat:',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 10),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text(
                  'Belum ada catatan nabung',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ),
          ...entries.map((e) {
            final dateStr = DateFormat("dd MMM yyyy", 'id_ID').format(e.date);
            return GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) =>
                            AddEntryScreen(goal: widget.goal, entryToEdit: e),
                  ),
                );
                if (result == true) setState(() {});
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF1E3E62),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.sticky_note_2_rounded,
                      color: Color(0xFF5EE2FF),
                      size: 22,
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateStr,
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              'Rp${formatter.format(e.amount.toInt())}',
                              style: TextStyle(
                                color: Color(0xFF5EE2FF),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 0.2,
                              ),
                            ),
                            if (e.note?.isNotEmpty == true) ...[
                              SizedBox(width: 8),
                              Text(
                                '•',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                e.note!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
      // Floating action button is not needed since we have a prominent add button
    );
  }
}
