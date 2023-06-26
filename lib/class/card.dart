class Card {
  int? id;
  int? category = 0;
  String? value = "0";

  Card({int? id, this.category, this.value}) {
    this.id = id ?? DateTime.now().millisecondsSinceEpoch;
  }
}
