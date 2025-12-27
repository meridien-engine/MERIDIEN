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
};
