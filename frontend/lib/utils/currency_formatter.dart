import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String formatVND(dynamic price) {
    // Bước 1: Kiểm tra và làm sạch dữ liệu
    if (price == null) return '0đ';

    // Bước 2: Chuyển đổi thành số
    final num parsedValue;
    if (price is num) {
      parsedValue = price;
    } else if (price is String) {
      // Loại bỏ tất cả ký tự không phải số và dấu chấm
      final cleanString = price.replaceAll(RegExp(r'[^0-9.]'), '');
      parsedValue = double.tryParse(cleanString) ?? 0;
    } else {
      parsedValue = 0;
    }

    // Bước 3: Định dạng thành tiền Việt
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    ).format(parsedValue);
  }
}
