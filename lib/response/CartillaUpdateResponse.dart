class CartillaUpdateResponse {
  String status;
  int code;
  String comment;
  String cartilla;

  CartillaUpdateResponse({
    required this.status,
    required this.code,
    required this.comment,
    required this.cartilla,
  });

  factory CartillaUpdateResponse.fromJson(Map<String, dynamic> json) => CartillaUpdateResponse(
    status: json["status"],
    code: json["code"],
    comment: json["comment"],
    cartilla: json["cartilla"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "code": code,
    "comment": comment,
    "cartilla": cartilla,
  };
}
