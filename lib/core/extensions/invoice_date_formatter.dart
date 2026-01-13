extension InvoiceDateFormatter on dynamic {
  String toInvoiceDate() {
    if (this == null) return '';

    try {
      final value = toString();

      if (value.contains('/')) {
        return value;
      }
      final date = DateTime.parse(value);
      return '${date.day}/${date.month}/${date.year}';
    } on Exception catch (_) {
      return toString();
    }
  }
}
