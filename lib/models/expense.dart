class Expense {
  const Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    this.note = '',
  });

  final int? id;
  final String title;
  final double amount;
  final DateTime date;
  final int categoryId;
  final String note;

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'title': title,
        'amount': amount,
        'date': date.millisecondsSinceEpoch,
        'note': note,
        'category_id': categoryId,
      };

  factory Expense.fromMap(Map<String, Object?> m) => Expense(
        id: m['id'] as int,
        title: m['title'] as String,
        amount: (m['amount'] as num).toDouble(),
        date: DateTime.fromMillisecondsSinceEpoch(m['date'] as int),
        note: (m['note'] as String?) ?? '',
        categoryId: m['category_id'] as int,
      );
}
