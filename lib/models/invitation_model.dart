class Invitation {
  final String fullname;
  final String city;

  Invitation({
    this.fullname,
    this.city,
  });

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      fullname: json['fullname'],
      city: json['city'],
    );
  }
}
