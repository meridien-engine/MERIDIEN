import 'package:flutter/material.dart';

/// App localization class for multi-language support
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  /// Get the current AppLocalizations instance from context
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  /// Check if current locale is Arabic
  bool get isArabic => locale.languageCode == 'ar';

  /// All translations map
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': _enTranslations,
    'ar': _arTranslations,
  };

  /// Get translated string
  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Convenience getters for common strings
  String get appName => translate('appName');
  String get appFullName => translate('appFullName');

  // Authentication
  String get login => translate('login');
  String get register => translate('register');
  String get logout => translate('logout');
  String get email => translate('email');
  String get password => translate('password');
  String get confirmPassword => translate('confirmPassword');
  String get firstName => translate('firstName');
  String get lastName => translate('lastName');
  String get tenantSlug => translate('tenantSlug');
  String get forgotPassword => translate('forgotPassword');
  String get dontHaveAccount => translate('dontHaveAccount');
  String get alreadyHaveAccount => translate('alreadyHaveAccount');
  String get signIn => translate('signIn');
  String get signUp => translate('signUp');
  String get welcome => translate('welcome');
  String get welcomeBack => translate('welcomeBack');

  // Dashboard
  String get dashboard => translate('dashboard');
  String get overview => translate('overview');
  String get quickActions => translate('quickActions');
  String get recentOrders => translate('recentOrders');
  String get lowStockAlerts => translate('lowStockAlerts');
  String get totalRevenue => translate('totalRevenue');
  String get totalOrders => translate('totalOrders');
  String get totalCustomers => translate('totalCustomers');
  String get totalProducts => translate('totalProducts');

  // Customers
  String get customers => translate('customers');
  String get customer => translate('customer');
  String get addCustomer => translate('addCustomer');
  String get editCustomer => translate('editCustomer');
  String get deleteCustomer => translate('deleteCustomer');
  String get customerDetails => translate('customerDetails');
  String get individual => translate('individual');
  String get business => translate('business');
  String get active => translate('active');
  String get inactive => translate('inactive');
  String get phone => translate('phone');
  String get address => translate('address');
  String get city => translate('city');
  String get state => translate('state');
  String get postalCode => translate('postalCode');
  String get country => translate('country');
  String get companyName => translate('companyName');
  String get taxId => translate('taxId');
  String get creditLimit => translate('creditLimit');

  // Products
  String get products => translate('products');
  String get product => translate('product');
  String get addProduct => translate('addProduct');
  String get editProduct => translate('editProduct');
  String get deleteProduct => translate('deleteProduct');
  String get productDetails => translate('productDetails');
  String get category => translate('category');
  String get sku => translate('sku');
  String get barcode => translate('barcode');
  String get price => translate('price');
  String get costPrice => translate('costPrice');
  String get sellingPrice => translate('sellingPrice');
  String get discountPrice => translate('discountPrice');
  String get stock => translate('stock');
  String get inStock => translate('inStock');
  String get lowStock => translate('lowStock');
  String get outOfStock => translate('outOfStock');
  String get featured => translate('featured');

  // Orders
  String get orders => translate('orders');
  String get order => translate('order');
  String get createOrder => translate('createOrder');
  String get orderDetails => translate('orderDetails');
  String get orderNumber => translate('orderNumber');
  String get orderDate => translate('orderDate');
  String get orderStatus => translate('orderStatus');
  String get paymentStatus => translate('paymentStatus');
  String get items => translate('items');
  String get quantity => translate('quantity');
  String get subtotal => translate('subtotal');
  String get tax => translate('tax');
  String get discount => translate('discount');
  String get shipping => translate('shipping');
  String get total => translate('total');
  String get paid => translate('paid');
  String get balance => translate('balance');
  String get recordPayment => translate('recordPayment');
  String get confirmOrder => translate('confirmOrder');
  String get shipOrder => translate('shipOrder');
  String get deliverOrder => translate('deliverOrder');
  String get cancelOrder => translate('cancelOrder');

  // Order Statuses
  String get draft => translate('draft');
  String get pending => translate('pending');
  String get confirmed => translate('confirmed');
  String get processing => translate('processing');
  String get shipped => translate('shipped');
  String get delivered => translate('delivered');
  String get cancelled => translate('cancelled');

  // Payment Statuses
  String get unpaid => translate('unpaid');
  String get partial => translate('partial');
  String get paymentPaid => translate('paymentPaid');
  String get refunded => translate('refunded');

  // Common Actions
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get add => translate('add');
  String get search => translate('search');
  String get filter => translate('filter');
  String get sort => translate('sort');
  String get refresh => translate('refresh');
  String get submit => translate('submit');
  String get confirm => translate('confirm');
  String get yes => translate('yes');
  String get no => translate('no');
  String get ok => translate('ok');
  String get close => translate('close');
  String get viewDetails => translate('viewDetails');

  // Messages
  String get loading => translate('loading');
  String get noDataFound => translate('noDataFound');
  String get somethingWentWrong => translate('somethingWentWrong');
  String get tryAgain => translate('tryAgain');
  String get success => translate('success');
  String get error => translate('error');
  String get warning => translate('warning');
  String get info => translate('info');
  String get deleteConfirmation => translate('deleteConfirmation');
  String get unsavedChanges => translate('unsavedChanges');

  // Validation
  String get fieldRequired => translate('fieldRequired');
  String get invalidEmail => translate('invalidEmail');
  String get passwordTooShort => translate('passwordTooShort');
  String get passwordMismatch => translate('passwordMismatch');
  String get invalidNumber => translate('invalidNumber');

  // Additional UI strings
  String get searchCustomers => translate('searchCustomers');
  String get searchProducts => translate('searchProducts');
  String get searchOrders => translate('searchOrders');
  String get newCustomer => translate('newCustomer');
  String get newProduct => translate('newProduct');
  String get newOrder => translate('newOrder');
  String get basicInformation => translate('basicInformation');
  String get billingAddress => translate('billingAddress');
  String get shippingAddress => translate('shippingAddress');
  String get sameAsBilling => translate('sameAsBilling');
  String get customerType => translate('customerType');
  String get status => translate('status');
  String get streetAddress => translate('streetAddress');
  String get postalCodeShort => translate('postalCodeShort');
  String get name => translate('name');
  String get description => translate('description');
  String get created => translate('created');
  String get pricing => translate('pricing');
  String get inventory => translate('inventory');
  String get stockStatus => translate('stockStatus');
  String get discountPriceShort => translate('discountPriceShort');
  String get trackInventory => translate('trackInventory');
  String get lowStockThreshold => translate('lowStockThreshold');
  String get selectCustomer => translate('selectCustomer');
  String get selectProduct => translate('selectProduct');
  String get addItem => translate('addItem');
  String get notes => translate('notes');
  String get orderSummary => translate('orderSummary');
  String get balanceDue => translate('balanceDue');
  String get filters => translate('filters');
  String get clearFilters => translate('clearFilters');
  String get applyFilters => translate('applyFilters');

  // Stores
  String get stores => translate('stores');
  String get addStore => translate('addStore');
  String get editStore => translate('editStore');
  String get deleteStore => translate('deleteStore');
  String get storeName => translate('storeName');
  String get noStoresYet => translate('noStoresYet');
  String get noStoresDesc => translate('noStoresDesc');
  String get storeCreated => translate('storeCreated');
  String get storeUpdated => translate('storeUpdated');
  String get storeDeleted => translate('storeDeleted');

  // Business
  String get selectBusiness => translate('selectBusiness');
  String get createBusiness => translate('createBusiness');
  String get joinBusiness => translate('joinBusiness');
  String get noBusiness => translate('noBusiness');
  String get noBusinessDescription => translate('noBusinessDescription');
  String get businessName => translate('businessName');
  String get businessSlug => translate('businessSlug');
  String get businessType => translate('businessType');
  String get singleBranch => translate('singleBranch');
  String get multiBranch => translate('multiBranch');
  String get businessCategory => translate('businessCategory');
  String get createYourBusiness => translate('createYourBusiness');
  String get switchBusiness => translate('switchBusiness');

  // Membership
  String get members => translate('members');
  String get joinRequests => translate('joinRequests');
  String get myJoinRequests => translate('myJoinRequests');
  String get pendingRequests => translate('pendingRequests');
  String get reviewedRequests => translate('reviewedRequests');
  String get findBusiness => translate('findBusiness');
  String get findBusinessBySlug => translate('findBusinessBySlug');
  String get found => translate('found');
  String get requestedRole => translate('requestedRole');
  String get messageOptional => translate('messageOptional');
  String get messageHint => translate('messageHint');
  String get sendJoinRequest => translate('sendJoinRequest');
  String get noJoinRequests => translate('noJoinRequests');
  String get noJoinRequestsDesc => translate('noJoinRequestsDesc');
  String get noMembers => translate('noMembers');
  String get inviteUser => translate('inviteUser');
  String get sendInvitation => translate('sendInvitation');
  String get invitation => translate('invitation');
  String get inviteInfo => translate('inviteInfo');
  String get role => translate('role');

  // POS
  String get pos => translate('pos');
  String get pointOfSale => translate('pointOfSale');
  String get posSessionHistory => translate('posSessionHistory');
  String get openCashSession => translate('openCashSession');
  String get posOpenSessionDesc => translate('posOpenSessionDesc');
  String get openingFloat => translate('openingFloat');
  String get openSession => translate('openSession');
  String get closeSession => translate('closeSession');
  String get closingCash => translate('closingCash');
  String get enterClosingCash => translate('enterClosingCash');
  String get scanBarcodeOrSku => translate('scanBarcodeOrSku');
  String get customerNameOptional => translate('customerNameOptional');
  String get walkin => translate('walkin');
  String get cartIsEmpty => translate('cartIsEmpty');
  String get cartIsEmptyHint => translate('cartIsEmptyHint');
  String get cashTendered => translate('cashTendered');
  String get checkout => translate('checkout');
  String get sessionOpened => translate('sessionOpened');
  String get posFloat => translate('posFloat');
  String get noSessionsFound => translate('noSessionsFound');
  String get dateOpened => translate('dateOpened');
  String get expectedCash => translate('expectedCash');
  String get actualCash => translate('actualCash');
  String get cashDifference => translate('cashDifference');
  String get saleComplete => translate('saleComplete');
  String get newSale => translate('newSale');
  String get viewOrder => translate('viewOrder');
  String get tendered => translate('tendered');
  String get change => translate('change');
  String get retry => translate('retry');
  String get anErrorOccurred => translate('anErrorOccurred');
}

/// English translations
const Map<String, String> _enTranslations = {
  // App Info
  'appName': 'MERIDIEN',
  'appFullName': 'Multi-tenant Enterprise Retail & Inventory Digital Intelligence Engine',
  'appVersion': '1.0.0',

  // Authentication
  'login': 'Login',
  'register': 'Register',
  'logout': 'Logout',
  'email': 'Email',
  'password': 'Password',
  'confirmPassword': 'Confirm Password',
  'firstName': 'First Name',
  'lastName': 'Last Name',
  'tenantSlug': 'Tenant',
  'forgotPassword': 'Forgot Password?',
  'dontHaveAccount': "Don't have an account?",
  'alreadyHaveAccount': 'Already have an account?',
  'signIn': 'Sign In',
  'signUp': 'Sign Up',
  'welcome': 'Welcome',
  'welcomeBack': 'Welcome Back',

  // Dashboard
  'dashboard': 'Dashboard',
  'overview': 'Overview',
  'quickActions': 'Quick Actions',
  'recentOrders': 'Recent Orders',
  'lowStockAlerts': 'Low Stock Alerts',
  'totalRevenue': 'Total Revenue',
  'totalOrders': 'Total Orders',
  'totalCustomers': 'Total Customers',
  'totalProducts': 'Total Products',

  // Customers
  'customers': 'Customers',
  'customer': 'Customer',
  'addCustomer': 'Add Customer',
  'editCustomer': 'Edit Customer',
  'deleteCustomer': 'Delete Customer',
  'customerDetails': 'Customer Details',
  'individual': 'Individual',
  'business': 'Business',
  'active': 'Active',
  'inactive': 'Inactive',
  'phone': 'Phone',
  'address': 'Address',
  'city': 'City',
  'state': 'State',
  'postalCode': 'Postal Code',
  'country': 'Country',
  'companyName': 'Company Name',
  'taxId': 'Tax ID',
  'creditLimit': 'Credit Limit',

  // Products
  'products': 'Products',
  'product': 'Product',
  'addProduct': 'Add Product',
  'editProduct': 'Edit Product',
  'deleteProduct': 'Delete Product',
  'productDetails': 'Product Details',
  'category': 'Category',
  'sku': 'SKU',
  'barcode': 'Barcode',
  'price': 'Price',
  'costPrice': 'Cost Price',
  'sellingPrice': 'Selling Price',
  'discountPrice': 'Discount Price',
  'stock': 'Stock',
  'inStock': 'In Stock',
  'lowStock': 'Low Stock',
  'outOfStock': 'Out of Stock',
  'featured': 'Featured',

  // Orders
  'orders': 'Orders',
  'order': 'Order',
  'createOrder': 'Create Order',
  'orderDetails': 'Order Details',
  'orderNumber': 'Order Number',
  'orderDate': 'Order Date',
  'orderStatus': 'Order Status',
  'paymentStatus': 'Payment Status',
  'items': 'Items',
  'quantity': 'Quantity',
  'subtotal': 'Subtotal',
  'tax': 'Tax',
  'discount': 'Discount',
  'shipping': 'Shipping',
  'total': 'Total',
  'paid': 'Paid',
  'balance': 'Balance',
  'recordPayment': 'Record Payment',
  'confirmOrder': 'Confirm Order',
  'shipOrder': 'Ship Order',
  'deliverOrder': 'Deliver Order',
  'cancelOrder': 'Cancel Order',

  // Order Statuses
  'draft': 'Draft',
  'pending': 'Pending',
  'confirmed': 'Confirmed',
  'processing': 'Processing',
  'shipped': 'Shipped',
  'delivered': 'Delivered',
  'cancelled': 'Cancelled',

  // Payment Statuses
  'unpaid': 'Unpaid',
  'partial': 'Partial',
  'paymentPaid': 'Paid',
  'refunded': 'Refunded',

  // Common Actions
  'save': 'Save',
  'cancel': 'Cancel',
  'delete': 'Delete',
  'edit': 'Edit',
  'add': 'Add',
  'search': 'Search',
  'filter': 'Filter',
  'sort': 'Sort',
  'refresh': 'Refresh',
  'submit': 'Submit',
  'confirm': 'Confirm',
  'yes': 'Yes',
  'no': 'No',
  'ok': 'OK',
  'close': 'Close',
  'viewDetails': 'View Details',

  // Messages
  'loading': 'Loading...',
  'noDataFound': 'No data found',
  'somethingWentWrong': 'Something went wrong',
  'tryAgain': 'Try Again',
  'success': 'Success',
  'error': 'Error',
  'warning': 'Warning',
  'info': 'Info',
  'deleteConfirmation': 'Are you sure you want to delete?',
  'unsavedChanges': 'You have unsaved changes',

  // Validation
  'fieldRequired': 'This field is required',
  'invalidEmail': 'Please enter a valid email',
  'passwordTooShort': 'Password must be at least 8 characters',
  'passwordMismatch': 'Passwords do not match',
  'invalidNumber': 'Please enter a valid number',

  // Additional UI strings
  'searchCustomers': 'Search customers...',
  'searchProducts': 'Search products...',
  'searchOrders': 'Search orders...',
  'newCustomer': 'New Customer',
  'newProduct': 'New Product',
  'newOrder': 'New Order',
  'basicInformation': 'Basic Information',
  'billingAddress': 'Billing Address',
  'shippingAddress': 'Shipping Address',
  'sameAsBilling': 'Same as billing',
  'customerType': 'Customer Type',
  'status': 'Status',
  'streetAddress': 'Street Address',
  'postalCodeShort': 'Postal Code',
  'name': 'Name',
  'description': 'Description',
  'created': 'Created',
  'pricing': 'Pricing',
  'inventory': 'Inventory',
  'stockStatus': 'Stock Status',
  'discountPriceShort': 'Discount Price',
  'trackInventory': 'Track Inventory',
  'lowStockThreshold': 'Low Stock Threshold',
  'selectCustomer': 'Select Customer',
  'selectProduct': 'Select Product',
  'addItem': 'Add Item',
  'notes': 'Notes',
  'orderSummary': 'Order Summary',
  'balanceDue': 'Balance Due',
  'filters': 'Filters',
  'clearFilters': 'Clear Filters',
  'applyFilters': 'Apply Filters',

  // Stores
  'stores': 'Stores',
  'addStore': 'Add Store',
  'editStore': 'Edit Store',
  'deleteStore': 'Delete Store',
  'storeName': 'Store Name',
  'noStoresYet': 'No stores yet',
  'noStoresDesc': 'Add your first store branch to get started.',
  'storeCreated': 'Store created successfully',
  'storeUpdated': 'Store updated successfully',
  'storeDeleted': 'Store deleted',

  // Business
  'selectBusiness': 'Select Business',
  'createBusiness': 'Create Business',
  'joinBusiness': 'Join Business',
  'noBusiness': 'No Business Yet',
  'noBusinessDescription': "You don't belong to any business yet. Create a new business or ask an admin to invite you.",
  'businessName': 'Business Name',
  'businessSlug': 'Slug (URL identifier)',
  'businessType': 'Business Type',
  'singleBranch': 'Single Branch',
  'multiBranch': 'Multi Branch',
  'businessCategory': 'Business Category',
  'createYourBusiness': 'Create Your Business',
  'switchBusiness': 'Switch Business',

  // Membership
  'members': 'Members',
  'joinRequests': 'Join Requests',
  'myJoinRequests': 'My Join Requests',
  'pendingRequests': 'Pending',
  'reviewedRequests': 'Reviewed',
  'findBusiness': 'Find Business',
  'findBusinessBySlug': 'Search business by slug',
  'found': 'Found',
  'requestedRole': 'Requested Role',
  'messageOptional': 'Message (optional)',
  'messageHint': 'Why do you want to join?',
  'sendJoinRequest': 'Send Join Request',
  'noJoinRequests': 'No join requests yet',
  'noJoinRequestsDesc': 'Search for a business by its slug to request to join.',
  'noMembers': 'No members found',
  'inviteUser': 'Invite User',
  'sendInvitation': 'Send Invitation',
  'invitation': 'Invitation',
  'inviteInfo': 'An invitation link will be generated. Share it with the user so they can join.',
  'role': 'Role',

  // POS
  'pos': 'POS',
  'pointOfSale': 'Point of Sale',
  'posSessionHistory': 'POS Session History',
  'openCashSession': 'Open Cash Session',
  'posOpenSessionDesc': 'Enter the opening cash float to start a new session.',
  'openingFloat': 'Opening Float (EGP)',
  'openSession': 'Open Session',
  'closeSession': 'Close Session',
  'closingCash': 'Closing Cash (EGP)',
  'enterClosingCash': 'Enter the actual cash in the drawer:',
  'scanBarcodeOrSku': 'Scan barcode or enter SKU',
  'customerNameOptional': 'Customer Name (optional)',
  'walkin': 'Walk-in',
  'cartIsEmpty': 'Cart is empty',
  'cartIsEmptyHint': 'Cart is empty\nScan a product to start',
  'cashTendered': 'Cash Tendered (EGP)',
  'checkout': 'CHECKOUT',
  'sessionOpened': 'Session opened',
  'posFloat': 'Float',
  'noSessionsFound': 'No sessions found',
  'dateOpened': 'Date Opened',
  'expectedCash': 'Expected',
  'actualCash': 'Actual',
  'cashDifference': 'Diff',
  'saleComplete': 'Sale Complete!',
  'newSale': 'New Sale',
  'viewOrder': 'View Order',
  'tendered': 'Tendered',
  'change': 'Change',
  'retry': 'Retry',
  'anErrorOccurred': 'An error occurred',
};

/// Arabic translations
const Map<String, String> _arTranslations = {
  // App Info
  'appName': 'ميريديان',
  'appFullName': 'نظام ذكي متعدد المستأجرين لإدارة التجزئة والمخزون',
  'appVersion': '1.0.0',

  // Authentication
  'login': 'تسجيل الدخول',
  'register': 'إنشاء حساب',
  'logout': 'تسجيل الخروج',
  'email': 'البريد الإلكتروني',
  'password': 'كلمة المرور',
  'confirmPassword': 'تأكيد كلمة المرور',
  'firstName': 'الاسم الأول',
  'lastName': 'اسم العائلة',
  'tenantSlug': 'المستأجر',
  'forgotPassword': 'هل نسيت كلمة المرور؟',
  'dontHaveAccount': 'ليس لديك حساب؟',
  'alreadyHaveAccount': 'لديك حساب بالفعل؟',
  'signIn': 'تسجيل الدخول',
  'signUp': 'إنشاء حساب',
  'welcome': 'مرحباً',
  'welcomeBack': 'مرحباً بعودتك',

  // Dashboard
  'dashboard': 'لوحة التحكم',
  'overview': 'نظرة عامة',
  'quickActions': 'إجراءات سريعة',
  'recentOrders': 'الطلبات الأخيرة',
  'lowStockAlerts': 'تنبيهات المخزون المنخفض',
  'totalRevenue': 'إجمالي الإيرادات',
  'totalOrders': 'إجمالي الطلبات',
  'totalCustomers': 'إجمالي العملاء',
  'totalProducts': 'إجمالي المنتجات',

  // Customers
  'customers': 'العملاء',
  'customer': 'عميل',
  'addCustomer': 'إضافة عميل',
  'editCustomer': 'تعديل عميل',
  'deleteCustomer': 'حذف عميل',
  'customerDetails': 'تفاصيل العميل',
  'individual': 'فرد',
  'business': 'شركة',
  'active': 'نشط',
  'inactive': 'غير نشط',
  'phone': 'الهاتف',
  'address': 'العنوان',
  'city': 'المدينة',
  'state': 'المنطقة',
  'postalCode': 'الرمز البريدي',
  'country': 'الدولة',
  'companyName': 'اسم الشركة',
  'taxId': 'الرقم الضريبي',
  'creditLimit': 'الحد الائتماني',

  // Products
  'products': 'المنتجات',
  'product': 'منتج',
  'addProduct': 'إضافة منتج',
  'editProduct': 'تعديل منتج',
  'deleteProduct': 'حذف منتج',
  'productDetails': 'تفاصيل المنتج',
  'category': 'الفئة',
  'sku': 'رمز المنتج',
  'barcode': 'الباركود',
  'price': 'السعر',
  'costPrice': 'سعر التكلفة',
  'sellingPrice': 'سعر البيع',
  'discountPrice': 'سعر مخفض',
  'stock': 'المخزون',
  'inStock': 'متوفر',
  'lowStock': 'مخزون منخفض',
  'outOfStock': 'غير متوفر',
  'featured': 'مميز',

  // Orders
  'orders': 'الطلبات',
  'order': 'طلب',
  'createOrder': 'إنشاء طلب',
  'orderDetails': 'تفاصيل الطلب',
  'orderNumber': 'رقم الطلب',
  'orderDate': 'تاريخ الطلب',
  'orderStatus': 'حالة الطلب',
  'paymentStatus': 'حالة الدفع',
  'items': 'العناصر',
  'quantity': 'الكمية',
  'subtotal': 'المجموع الفرعي',
  'tax': 'الضريبة',
  'discount': 'الخصم',
  'shipping': 'الشحن',
  'total': 'الإجمالي',
  'paid': 'المدفوع',
  'balance': 'الرصيد',
  'recordPayment': 'تسجيل دفعة',
  'confirmOrder': 'تأكيد الطلب',
  'shipOrder': 'شحن الطلب',
  'deliverOrder': 'توصيل الطلب',
  'cancelOrder': 'إلغاء الطلب',

  // Order Statuses
  'draft': 'مسودة',
  'pending': 'قيد الانتظار',
  'confirmed': 'مؤكد',
  'processing': 'قيد المعالجة',
  'shipped': 'تم الشحن',
  'delivered': 'تم التوصيل',
  'cancelled': 'ملغي',

  // Payment Statuses
  'unpaid': 'غير مدفوع',
  'partial': 'مدفوع جزئياً',
  'paymentPaid': 'مدفوع',
  'refunded': 'مسترد',

  // Common Actions
  'save': 'حفظ',
  'cancel': 'إلغاء',
  'delete': 'حذف',
  'edit': 'تعديل',
  'add': 'إضافة',
  'search': 'بحث',
  'filter': 'تصفية',
  'sort': 'ترتيب',
  'refresh': 'تحديث',
  'submit': 'إرسال',
  'confirm': 'تأكيد',
  'yes': 'نعم',
  'no': 'لا',
  'ok': 'موافق',
  'close': 'إغلاق',
  'viewDetails': 'عرض التفاصيل',

  // Messages
  'loading': 'جاري التحميل...',
  'noDataFound': 'لا توجد بيانات',
  'somethingWentWrong': 'حدث خطأ ما',
  'tryAgain': 'حاول مرة أخرى',
  'success': 'نجح',
  'error': 'خطأ',
  'warning': 'تحذير',
  'info': 'معلومات',
  'deleteConfirmation': 'هل أنت متأكد من الحذف؟',
  'unsavedChanges': 'لديك تغييرات غير محفوظة',

  // Validation
  'fieldRequired': 'هذا الحقل مطلوب',
  'invalidEmail': 'الرجاء إدخال بريد إلكتروني صحيح',
  'passwordTooShort': 'يجب أن تكون كلمة المرور 8 أحرف على الأقل',
  'passwordMismatch': 'كلمات المرور غير متطابقة',
  'invalidNumber': 'الرجاء إدخال رقم صحيح',

  // Additional UI strings
  'searchCustomers': 'البحث عن العملاء...',
  'searchProducts': 'البحث عن المنتجات...',
  'searchOrders': 'البحث عن الطلبات...',
  'newCustomer': 'عميل جديد',
  'newProduct': 'منتج جديد',
  'newOrder': 'طلب جديد',
  'basicInformation': 'المعلومات الأساسية',
  'billingAddress': 'عنوان الفواتير',
  'shippingAddress': 'عنوان الشحن',
  'sameAsBilling': 'نفس عنوان الفواتير',
  'customerType': 'نوع العميل',
  'status': 'الحالة',
  'streetAddress': 'عنوان الشارع',
  'postalCodeShort': 'الرمز البريدي',
  'name': 'الاسم',
  'description': 'الوصف',
  'created': 'تاريخ الإنشاء',
  'pricing': 'التسعير',
  'inventory': 'المخزون',
  'stockStatus': 'حالة المخزون',
  'discountPriceShort': 'السعر المخفض',
  'trackInventory': 'تتبع المخزون',
  'lowStockThreshold': 'حد المخزون المنخفض',
  'selectCustomer': 'اختر عميل',
  'selectProduct': 'اختر منتج',
  'addItem': 'إضافة عنصر',
  'notes': 'ملاحظات',
  'orderSummary': 'ملخص الطلب',
  'balanceDue': 'الرصيد المستحق',
  'filters': 'الفلاتر',
  'clearFilters': 'مسح الفلاتر',
  'applyFilters': 'تطبيق الفلاتر',

  // Stores
  'stores': 'المتاجر',
  'addStore': 'إضافة متجر',
  'editStore': 'تعديل متجر',
  'deleteStore': 'حذف متجر',
  'storeName': 'اسم المتجر',
  'noStoresYet': 'لا توجد متاجر بعد',
  'noStoresDesc': 'أضف فرع متجرك الأول للبدء.',
  'storeCreated': 'تم إنشاء المتجر بنجاح',
  'storeUpdated': 'تم تحديث المتجر بنجاح',
  'storeDeleted': 'تم حذف المتجر',

  // Business
  'selectBusiness': 'اختر النشاط التجاري',
  'createBusiness': 'إنشاء نشاط تجاري',
  'joinBusiness': 'الانضمام لنشاط تجاري',
  'noBusiness': 'لا يوجد نشاط تجاري بعد',
  'noBusinessDescription': 'لا تنتمي إلى أي نشاط تجاري حتى الآن. أنشئ نشاطاً تجارياً جديداً أو اطلب من المسؤول دعوتك.',
  'businessName': 'اسم النشاط التجاري',
  'businessSlug': 'المعرف (رابط URL)',
  'businessType': 'نوع النشاط التجاري',
  'singleBranch': 'فرع واحد',
  'multiBranch': 'متعدد الفروع',
  'businessCategory': 'فئة النشاط التجاري',
  'createYourBusiness': 'أنشئ نشاطك التجاري',
  'switchBusiness': 'تغيير النشاط التجاري',

  // Membership
  'members': 'الأعضاء',
  'joinRequests': 'طلبات الانضمام',
  'myJoinRequests': 'طلباتي',
  'pendingRequests': 'قيد الانتظار',
  'reviewedRequests': 'تمت المراجعة',
  'findBusiness': 'البحث عن نشاط تجاري',
  'findBusinessBySlug': 'ابحث عن النشاط التجاري بالمعرف',
  'found': 'موجود',
  'requestedRole': 'الدور المطلوب',
  'messageOptional': 'رسالة (اختياري)',
  'messageHint': 'لماذا تريد الانضمام؟',
  'sendJoinRequest': 'إرسال طلب الانضمام',
  'noJoinRequests': 'لا توجد طلبات انضمام بعد',
  'noJoinRequestsDesc': 'ابحث عن نشاط تجاري باستخدام المعرف لطلب الانضمام.',
  'noMembers': 'لا يوجد أعضاء',
  'inviteUser': 'دعوة مستخدم',
  'sendInvitation': 'إرسال الدعوة',
  'invitation': 'دعوة',
  'inviteInfo': 'سيتم إنشاء رابط دعوة. شاركه مع المستخدم للانضمام.',
  'role': 'الدور',

  // POS
  'pos': 'نقطة البيع',
  'pointOfSale': 'نقطة البيع',
  'posSessionHistory': 'سجل جلسات نقطة البيع',
  'openCashSession': 'فتح جلسة نقدية',
  'posOpenSessionDesc': 'أدخل مبلغ الصندوق الافتتاحي لبدء جلسة جديدة.',
  'openingFloat': 'رصيد الصندوق الافتتاحي (ج.م.)',
  'openSession': 'فتح الجلسة',
  'closeSession': 'إغلاق الجلسة',
  'closingCash': 'النقد الختامي (ج.م.)',
  'enterClosingCash': 'أدخل المبلغ النقدي الفعلي في الصندوق:',
  'scanBarcodeOrSku': 'امسح الباركود أو أدخل رمز المنتج',
  'customerNameOptional': 'اسم العميل (اختياري)',
  'walkin': 'عميل عابر',
  'cartIsEmpty': 'السلة فارغة',
  'cartIsEmptyHint': 'السلة فارغة\nامسح منتجاً للبدء',
  'cashTendered': 'المبلغ المدفوع (ج.م.)',
  'checkout': 'إتمام البيع',
  'sessionOpened': 'بدأت الجلسة',
  'posFloat': 'الرصيد',
  'noSessionsFound': 'لم يتم العثور على جلسات',
  'dateOpened': 'تاريخ الفتح',
  'expectedCash': 'المتوقع',
  'actualCash': 'الفعلي',
  'cashDifference': 'الفرق',
  'saleComplete': 'تمت عملية البيع!',
  'newSale': 'بيع جديد',
  'viewOrder': 'عرض الطلب',
  'tendered': 'المبلغ المدفوع',
  'change': 'الباقي',
  'retry': 'إعادة المحاولة',
  'anErrorOccurred': 'حدث خطأ',
};
