import 'package:flutter/material.dart';
import 'package:daku/models/saving_entry.dart';
import 'package:intl/intl.dart';

class EntryTile extends StatelessWidget {
  final SavingEntry entry;

  const EntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat("dd MMM yyyy").format(entry.date);

    return ListTile(
      title: Text(
        "Rp${entry.amount.toInt()}",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(entry.note?.isNotEmpty == true ? entry.note! : "-"),
      trailing: Text(dateStr, style: TextStyle(fontSize: 12)),
    );
  }
}
