import '../mocks/mock_stocks.dart';
import '../models/stock.dart';

class StockRepository {
  const StockRepository();

  List<Stock> loadStocks() => mockStocks;

  Stock? findStock(String code) {
    for (final stock in mockStocks) {
      if (stock.code == code) return stock;
    }
    return null;
  }
}

