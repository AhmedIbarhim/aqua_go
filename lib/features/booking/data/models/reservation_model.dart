class ReservationModel {
  final String id;
  final String carId;
  final String carName;
  final String carImage;
  final String packageId;
  final String packageName;
  final String packageImage;
  final String additionalServiceId;
  final String additionalServiceName;
  final String additionalServiceImage;
  final String reservationDateTime;
  final String reservationStatus;

  ReservationModel({
    required this.id,
    required this.carId,
    required this.carName,
    required this.carImage,
    required this.packageId,
    required this.packageName,
    required this.packageImage,
    required this.additionalServiceId,
    required this.additionalServiceName,
    required this.additionalServiceImage,
    required this.reservationDateTime,
    required this.reservationStatus,
  });
}
