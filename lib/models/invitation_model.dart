class Invitation {
  final String fullname;
  final String city;
  final bool isVip;

  Invitation({
    this.fullname,
    this.city,
    this.isVip,
  });

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      fullname: json['fullname'],
      city: json['city'],
      isVip: json['isVip'] ?? false,
    );
  }
}
