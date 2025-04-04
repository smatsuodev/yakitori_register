import '../../domain/model/product.dart';

class ProductRepository {
  // ダミーデータを返す（実際のアプリではAPIやデータベースから取得）
  List<Product> getProducts() {
    return [
      Product(id: '1', name: 'もも 甘口', price: 100),
      Product(id: '2', name: 'もも 中辛', price: 100),
      Product(id: '3', name: 'もも 辛口', price: 100),
      Product(id: '4', name: 'もも デスソース', price: 100),
      Product(id: '5', name: 'もも 塩', price: 100),
      Product(id: '6', name: 'かわ 甘口', price: 100),
      Product(id: '7', name: 'かわ 中辛', price: 100),
      Product(id: '8', name: 'かわ 辛口', price: 100),
      Product(id: '9', name: 'かわ デスソース', price: 100),
      Product(id: '10', name: 'かわ 塩', price: 100),
    ];
  }
}
