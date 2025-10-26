// dar formato de dd/mm/yyyy
String formatDate(DateTime? date) {
  if (date == null) return '';
  String day = date.day.toString().padLeft(2, '0');
  String month = date.month.toString().padLeft(2, '0');
  String year = date.year.toString();
  return '$day/$month/$year';
}
