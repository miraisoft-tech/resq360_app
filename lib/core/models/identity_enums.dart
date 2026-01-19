enum IdentityEnums {
  passport('PASSPORT'),
  nationalId('NATIONAL_ID'),
  driversLicense('DRIVERS_LICENSE'),
  cac('CAC');

  const IdentityEnums(this.name);
  final String name;
}
