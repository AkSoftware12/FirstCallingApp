class ApiRoutes {


  // Live  App Url
  // static const String baseUrl = "https://hospirenttest.akdesire.com/api";


// Local App Url
  static const String baseUrl = "http://192.168.1.20/firstcallingapp/api";



  static const String login = "$baseUrl/login";
  static const String verifyOtp = "$baseUrl/verifyOtp";
  static const String getProfile = "$baseUrl/get-profile";
  static const String getUpdateProfile = "$baseUrl/updateProfile";
  static const String getAllProducts = "$baseUrl/products";
  static const String addAddress = "$baseUrl/add-address";
  static const String getAddress = "$baseUrl/get-address";
  static const String deleteAddress = "$baseUrl/delete-address";
  static const String orderPlaced = "$baseUrl/order-store";
  static const String getOrderHistory = "$baseUrl/order-history";
  static const String qrCodeScan= "$baseUrl/scan/";
  static const String notifications = "$baseUrl/notifications";
}
