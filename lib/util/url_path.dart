class UrlPath {
  static const LoginUrl loginUrl = LoginUrl();
  static const GetUrl getUrl = GetUrl();
  static const PostUrl postUrl = PostUrl();
}

class LoginUrl {
  const LoginUrl();
  final String sendOTP = 'consumer/login';
  final String otpVerify = 'consumer/verify-otp';
  //  final String sendOTP = 'farmsSentOtp';
  //  final String otpVerify = 'farmsVerifyOtp';

  final String createProfile = 'farmsAddUser';
  final String deleteOrderAddress = 'farmsDeleteOrderAddress';
  final String addWishlist = 'farmsAddWishlist';

  final String updateProfile = 'farmsEditUser';
}

class PostUrl {
  const PostUrl();
  //wishlist
  final String addWishList ='consumer/wishList/add';
  final String removeWishList ='consumer/wishList/remove';
  //cart
  final String addToCart= 'consumer/cart/add';
  final String updateCart ='consumer/cart/update';
  final String removeCart = 'consumer/cart/remove';
  //Orders
  final String createOrder='consumer/order/create';

}


class GetUrl {
  const GetUrl();

  //address..
  final String getAddress='consumer/address/get';
  //carts..
  final String getCart ='consumer/cart/getList';

  final String updateCart = 'farmsUpdateCart';
  final String addToCart = 'farmsAddToCart';

  //fruits..
  final String getFruits = 'farmsGetAllFruits';
  final String getFruitCategories = 'farmsGetFruitsByCategory';

  //dairy
  final String getDairy = 'farmsGetAllDiaryproduct';
  final String getDairyCategories = 'farmsGetDiaryproductByCategory';

  //vegetable
  final String getVegetable = 'farmsGetAllVegetables';
  final String getVegetableCategories = 'farmsGetVegetablesByCategory';

  //Grocery
  final String getGrocery = 'farmsGetAllGrocery';
  final String getGroceryCategories = 'farmsGetGroceryByCategory';

  //foodcorts
  final String getfoodcorts = 'farmsGetAllFoodcourt';
  final String getfoodcortscategories = 'farmsGetFoodcourtByCategory';

  //random product
  final String getrandomproduct = 'farmsGetItemsCart';

  //get user
  final String getUser = 'farmsGetUser';

  //Address
  final String addAddress = 'consumer/address/add';
 // final String addAddress = 'farmsAddOrderAddress';
 // final String getAddress = 'farmsGetAllOrderAddress';

  //DailySlot & Pre Booking
  final String getDailySlot = 'farmsGetDailyBookslot';
  final String getPreSlot = 'farmsGetPreBookslot';

  //WishList

  final String getWishlist='consumer/wishList/getWishList';

  // banner image
  final String getBanner = 'farmsGetBanners';

  //get all category

  //final String getAllCatgeory = 'farmsGetCategory';
  final String getAllCatgeory = 'products/list/group-by-category';
  //get all product
  final String getAllProduct = 'farmsGetAllProduct';

  //get all sun product
  final String getAllSubProduct = 'farmsGetProductById';

  //add booking order

  final String addBookingOrder = 'farmsAddOrderHistory';

  // get order history
  final String getOrderHistory = 'farmsGetOrderHistory';
  //get all subscription
  final String getAllSubscription = 'farmsGetSubscription';
  //get all weekly subscription

  final String getAllWeeklySubscription = 'farmsGetWeeklySubscription';
  // get all weekly package
  final String getAllWeeklyPackage = 'farmsGetWeeklyPackages';

  //booking week subscription
  final String bookingWeekSubscription = 'farmsAddWeeklyBooking';
}
