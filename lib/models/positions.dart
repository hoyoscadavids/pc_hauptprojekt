class Positions {
  Positions(this.positions);
  final List<Pos> positions;

  Positions.fromJson(Map<String, dynamic> json)
      : positions = json['positions'].map((position) => Pos.fromJson(position));

  Map<String, dynamic> toJson() {
    return {
      'positions': positions.map((position) => position.toJson()).toList(),
    };
  }
}

class Pos {
  final double x;
  final double y;

  Pos(this.x, this.y);
  Pos.fromJson(Map<String, dynamic> json)
      : x = json['x'],
        y = json['y'];

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
    };
  }
}
