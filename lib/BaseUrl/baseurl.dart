class ApiRoutes {


  // Live  App Url
  // static const String baseUrl = "https://firstcallingapp.com/api";


// Local App Url
  static const String baseUrl = "http://192.168.1.5/firstcallingapp2/api";



  static const String login = "$baseUrl/login";
  static const String verifyOtp = "$baseUrl/verifyOtp";
  static const String qrVerifyOtp = "$baseUrl/qr/verifyOtp";
  static const String getProfile = "$baseUrl/get-profile";
  static const String getUpdateProfile = "$baseUrl/update-profile";
  static const String getAllProducts = "$baseUrl/products";
  static const String addAddress = "$baseUrl/add-address";
  static const String getAddress = "$baseUrl/get-address";
  static const String deleteAddress = "$baseUrl/delete-address";
  static const String orderPlaced = "$baseUrl/order-store";
  static const String getOrderHistory = "$baseUrl/order-history";
  static const String qrCodeScan= "$baseUrl/scan/";
  static const String qrCodeUpdate= "$baseUrl/qr/update";
  static const String qrCodeCheck= "$baseUrl/qr/check?qr_number=";
  static const String notifications = "$baseUrl/notifications";
  static const String agentDashboard = "$baseUrl/agent/dashboard";
  static const String agentItemList = "$baseUrl/agent/qr-list?type=";
}
