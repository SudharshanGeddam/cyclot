/// Dashboard statistics model for admin analytics
class DashboardStats {
  final int totalBikes;
  final int allocatedBikes;
  final int availableBikes;
  final int damagedBikes;
  final int undamagedBikes;
  final int activeAllocations;
  final int returnedAllocations;

  DashboardStats({
    required this.totalBikes,
    required this.allocatedBikes,
    required this.availableBikes,
    required this.damagedBikes,
    required this.undamagedBikes,
    required this.activeAllocations,
    required this.returnedAllocations,
  });

  factory DashboardStats.empty() {
    return DashboardStats(
      totalBikes: 0,
      allocatedBikes: 0,
      availableBikes: 0,
      damagedBikes: 0,
      undamagedBikes: 0,
      activeAllocations: 0,
      returnedAllocations: 0,
    );
  }
}
