enum PersistantStorageKeys {
  username('username'),
  env('env'),
  isLoggedIn('isLoggedIn');

  final String value;

  const PersistantStorageKeys(this.value);
}
