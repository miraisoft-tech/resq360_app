enum AdminIssueType {
  generalInquiry('GENERAL_INQUIRY', 'General Inquiry'),
  technicalIssue('TECHNICAL_ISSUE', 'Technical Issue'),
  paymentIssue('PAYMENT_ISSUE', 'Payment Issue'),
  billingIssue('BILLING_ISSUE', 'Billing Issue'),
  serviceComplaint('SERVICE_COMPLAINT', 'Service Complaint'),
  serviceIssue('SERVICE_ISSUE', 'Service Issue'),
  accountIssue('ACCOUNT_ISSUE', 'Account Issue'),
  providerIssue('PROVIDER_ISSUE', 'Provider Issue'),
  appBug('APP_BUG', 'App Bug'),
  featureRequest('FEATURE_REQUEST', 'Feature Request'),
  bugReport('BUG_REPORT', 'Bug Report'),
  billingInquiry('BILLING_INQUIRY', 'Billing Inquiry'),
  complaint('COMPLAINT', 'Complaint'),
  refundRequest('REFUND_REQUEST', 'Refund Request'),
  emergency('EMERGENCY', 'Emergency'),
  other('OTHER', 'Other');

  const AdminIssueType(this.value, this.label);

  final String value;

  final String label;
}


extension AdminIssuePriority on AdminIssueType {
  String get priority {
    switch (this) {
      case AdminIssueType.paymentIssue:
      case AdminIssueType.billingIssue:
      case AdminIssueType.billingInquiry:
      case AdminIssueType.refundRequest:
        return 'HIGH';

      case AdminIssueType.emergency:
        return 'URGENT';

      case AdminIssueType.generalInquiry:
      case AdminIssueType.technicalIssue:
      case AdminIssueType.serviceComplaint:
      case AdminIssueType.serviceIssue:
      case AdminIssueType.accountIssue:
      case AdminIssueType.providerIssue:
      case AdminIssueType.appBug:
      case AdminIssueType.featureRequest:
      case AdminIssueType.bugReport:
      case AdminIssueType.complaint:
      case AdminIssueType.other:
        return 'LOW';
    }
  }
}
