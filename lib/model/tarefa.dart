class Tarefa {
  int id;
  String title;
  int ok;

  Tarefa({required this.id, required this.title, required this.ok});

  factory Tarefa.fromMap(Map<String, Object?> json) => Tarefa(
        id: int.parse(json["id"] as String),
        title: json["title"] as String,
        ok: json["ok"] == true ? 1 : 0,
      );
  factory Tarefa.fromJson(Map<String, dynamic> json) => Tarefa(
        id: int.parse(json["id"]),
        title: json["title"],
        ok: json["ok"] == true ? 1 : 0,
      );

  Map<String, dynamic> toJson() =>
      {"id": id, "title": title, "ok": ok == 1 ? true : false};
}
