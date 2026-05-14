class RoleManager {
  static String? _role;

  /* ==========================================
     SET ROLE
  ========================================== */
  static void setRole(String role) {
    _role = role;
    print("ROLE SET: $_role");
  }

  /* ==========================================
     GET ROLE (fallback zaštita)
  ========================================== */
  static String get role {
    if (_role == null) {
      print("ROLE NULL → fallback na fizicka");
    }
    return _role ?? "fizicka";
  }

  /* ==========================================
     BASE URL PO ROLE
  ========================================== */
  static String get baseUrl {
    switch (role) {
      case "pravna":
        return "https://www.majstor24.ba/pravna/api";
      case "izvrsilac":
        return "https://www.majstor24.ba/izvrsilac/api";
      case "fizicka":
      default:
        return "https://www.majstor24.ba/api";
    }
  }

  /* ==========================================
     RESET ROLE (za buduće opcije)
  ========================================== */
  static void clear() {
    print("ROLE CLEARED");
    _role = null;
  }
}