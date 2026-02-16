enum ApplicationStatus {
  pending,
  reviewing,
  interviewed,
  accepted,
  rejected,
  withdrawn;

  static ApplicationStatus fromString(String status) {
    return ApplicationStatus.values.firstWhere(
      (e) => e.toString().split('.').last == status,
      orElse: () => ApplicationStatus.pending,
    );
  }
}
