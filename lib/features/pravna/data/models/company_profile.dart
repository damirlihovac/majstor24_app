class CompanyProfile {

  final String naziv;
  final String idBroj;
  final String email;
  final String telefon;
  final String adresa;
  final String grad;
  final String paket;

  CompanyProfile({
    required this.naziv,
    required this.idBroj,
    required this.email,
    required this.telefon,
    required this.adresa,
    required this.grad,
    required this.paket,
  });

  factory CompanyProfile.fromJson(
    Map<String,dynamic> json,
  ){

    return CompanyProfile(
      naziv: json["accountname"] ?? "",
      idBroj: json["cf_928"] ?? "", // ako postoji u drugom API
      email: json["email1"] ?? "",
      telefon: json["phone"] ?? "",
      adresa: json["bill_street"] ?? "",
      grad: json["bill_city"] ?? "",
      paket: json["package"] ?? "BizPlus",
    );
  }
}