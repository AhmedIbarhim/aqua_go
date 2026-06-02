class Invoice {
  String? invoiceUuid;
  String? invoiceNumber;
  String? qrTlvBase64;
  String? reportStatus;
  String? reportedAt;
  String? pdfUrl;
  String? pdfUrlExpiresAt;

  Invoice({
    this.invoiceUuid,
    this.invoiceNumber,
    this.qrTlvBase64,
    this.reportStatus,
    this.reportedAt,
    this.pdfUrl,
    this.pdfUrlExpiresAt,
  });

  Invoice.fromJson(Map<String, dynamic> json) {
    invoiceUuid = json['invoiceUuid'];
    invoiceNumber = json['invoiceNumber'];
    qrTlvBase64 = json['qrTlvBase64'];
    reportStatus = json['reportStatus'];
    reportedAt = json['reportedAt'];
    pdfUrl = json['pdfUrl'];
    pdfUrlExpiresAt = json['pdfUrlExpiresAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['invoiceUuid'] = invoiceUuid;
    data['invoiceNumber'] = invoiceNumber;
    data['qrTlvBase64'] = qrTlvBase64;
    data['reportStatus'] = reportStatus;
    data['reportedAt'] = reportedAt;
    data['pdfUrl'] = pdfUrl;
    data['pdfUrlExpiresAt'] = pdfUrlExpiresAt;
    return data;
  }
}
