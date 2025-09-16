abstract interface class LocalNotification {
  Future<void> setupLocalNotification();
  void showLocalNotification(String title, String body);
}
