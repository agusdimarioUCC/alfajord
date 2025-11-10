class AppRoutes {
  static const loading = '/loading';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const profile = '/profile';
  static const review = '/review';
  static const alfajorBase = '/alfajor';

  static String alfajorDetail(String id) => '$alfajorBase/$id';
}
