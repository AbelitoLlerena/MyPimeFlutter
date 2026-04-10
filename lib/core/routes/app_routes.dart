class AppRoutes {
  static const login = '/login';
  static const home = '/home';
  static const dashboard = '/dashboard';
  static const pos = '/pos';
  static const inventory = '/inventory';
  static const sales = '/sales';
  static String user(int id) => '/user/$id';

  static const categories = '/categories';
  static const categoryNew = '/categories/new';
  static String categoryEdit(String id) => '/categories/$id/edit';

  static const products = '/products';
  static const productNew = '/products/new';
  static String productEdit(String id) => '/products/$id/edit';
}
