# MERIDIEN - Translation Guide

**Complete guide for adding Arabic translations to all screens**

## Translation System Overview

✅ **Completed:**
- Full localization infrastructure
- 140+ translated strings (English + Arabic)
- Language toggle button
- RTL/LTR layout support
- Tajawal font for both languages

🚧 **In Progress:**
- Translating all screens (currently only Dashboard is fully translated)

---

## Quick Start: How to Translate a Screen

### Step 1: Import the localization extension

Replace this import:
```dart
import '../../../core/constants/app_strings.dart';
```

With this:
```dart
import '../../../core/localization/localization_extension.dart';
```

### Step 2: Replace hardcoded strings

**Before:**
```dart
Text('Customers')
Text('Search customers...')
Text('Add Customer')
```

**After:**
```dart
Text(context.loc.customers)
Text(context.loc.searchCustomers)
Text(context.loc.addCustomer)
```

---

## Available Translations (140+ strings)

### App Info
- `context.loc.appName` → "MERIDIEN" / "ميريديان"
- `context.loc.appFullName` → Full app name

### Authentication (14 strings)
- `context.loc.login` → "Login" / "تسجيل الدخول"
- `context.loc.register` → "Register" / "إنشاء حساب"
- `context.loc.logout` → "Logout" / "تسجيل الخروج"
- `context.loc.email` → "Email" / "البريد الإلكتروني"
- `context.loc.password` → "Password" / "كلمة المرور"
- `context.loc.confirmPassword` → "Confirm Password" / "تأكيد كلمة المرور"
- `context.loc.firstName` → "First Name" / "الاسم الأول"
- `context.loc.lastName` → "Last Name" / "اسم العائلة"
- `context.loc.tenantSlug` → "Tenant" / "المستأجر"
- `context.loc.forgotPassword` → "Forgot Password?" / "هل نسيت كلمة المرور؟"
- `context.loc.welcome` → "Welcome" / "مرحباً"
- `context.loc.welcomeBack` → "Welcome Back" / "مرحباً بعودتك"

### Dashboard (8 strings)
- `context.loc.dashboard` → "Dashboard" / "لوحة التحكم"
- `context.loc.overview` → "Overview" / "نظرة عامة"
- `context.loc.quickActions` → "Quick Actions" / "إجراءات سريعة"
- `context.loc.recentOrders` → "Recent Orders" / "الطلبات الأخيرة"
- `context.loc.totalRevenue` → "Total Revenue" / "إجمالي الإيرادات"
- `context.loc.totalOrders` → "Total Orders" / "إجمالي الطلبات"
- `context.loc.totalCustomers` → "Total Customers" / "إجمالي العملاء"
- `context.loc.totalProducts` → "Total Products" / "إجمالي المنتجات"

### Customers (13 strings)
- `context.loc.customers` → "Customers" / "العملاء"
- `context.loc.customer` → "Customer" / "عميل"
- `context.loc.addCustomer` → "Add Customer" / "إضافة عميل"
- `context.loc.editCustomer` → "Edit Customer" / "تعديل عميل"
- `context.loc.deleteCustomer` → "Delete Customer" / "حذف عميل"
- `context.loc.customerDetails` → "Customer Details" / "تفاصيل العميل"
- `context.loc.individual` → "Individual" / "فرد"
- `context.loc.business` → "Business" / "شركة"
- `context.loc.phone` → "Phone" / "الهاتف"
- `context.loc.address` → "Address" / "العنوان"
- `context.loc.city` → "City" / "المدينة"
- `context.loc.companyName` → "Company Name" / "اسم الشركة"
- `context.loc.taxId` → "Tax ID" / "الرقم الضريبي"

### Products (14 strings)
- `context.loc.products` → "Products" / "المنتجات"
- `context.loc.product` → "Product" / "منتج"
- `context.loc.addProduct` → "Add Product" / "إضافة منتج"
- `context.loc.editProduct` → "Edit Product" / "تعديل منتج"
- `context.loc.deleteProduct` → "Delete Product" / "حذف منتج"
- `context.loc.productDetails` → "Product Details" / "تفاصيل المنتج"
- `context.loc.category` → "Category" / "الفئة"
- `context.loc.sku` → "SKU" / "رمز المنتج"
- `context.loc.barcode` → "Barcode" / "الباركود"
- `context.loc.price` → "Price" / "السعر"
- `context.loc.costPrice` → "Cost Price" / "سعر التكلفة"
- `context.loc.sellingPrice` → "Selling Price" / "سعر البيع"
- `context.loc.stock` → "Stock" / "المخزون"
- `context.loc.featured` → "Featured" / "مميز"

### Orders (27 strings)
- `context.loc.orders` → "Orders" / "الطلبات"
- `context.loc.order` → "Order" / "طلب"
- `context.loc.createOrder` → "Create Order" / "إنشاء طلب"
- `context.loc.orderDetails` → "Order Details" / "تفاصيل الطلب"
- `context.loc.orderNumber` → "Order Number" / "رقم الطلب"
- `context.loc.orderDate` → "Order Date" / "تاريخ الطلب"
- `context.loc.orderStatus` → "Order Status" / "حالة الطلب"
- `context.loc.paymentStatus` → "Payment Status" / "حالة الدفع"
- `context.loc.items` → "Items" / "العناصر"
- `context.loc.quantity` → "Quantity" / "الكمية"
- `context.loc.subtotal` → "Subtotal" / "المجموع الفرعي"
- `context.loc.tax` → "Tax" / "الضريبة"
- `context.loc.discount` → "Discount" / "الخصم"
- `context.loc.shipping` → "Shipping" / "الشحن"
- `context.loc.total` → "Total" / "الإجمالي"
- `context.loc.paid` → "Paid" / "المدفوع"
- `context.loc.balance` → "Balance" / "الرصيد"
- `context.loc.recordPayment` → "Record Payment" / "تسجيل دفعة"
- `context.loc.confirmOrder` → "Confirm Order" / "تأكيد الطلب"
- `context.loc.shipOrder` → "Ship Order" / "شحن الطلب"
- `context.loc.deliverOrder` → "Deliver Order" / "توصيل الطلب"
- `context.loc.cancelOrder` → "Cancel Order" / "إلغاء الطلب"

### Order Statuses (7 strings)
- `context.loc.draft` → "Draft" / "مسودة"
- `context.loc.pending` → "Pending" / "قيد الانتظار"
- `context.loc.confirmed` → "Confirmed" / "مؤكد"
- `context.loc.processing` → "Processing" / "قيد المعالجة"
- `context.loc.shipped` → "Shipped" / "تم الشحن"
- `context.loc.delivered` → "Delivered" / "تم التوصيل"
- `context.loc.cancelled` → "Cancelled" / "ملغي"

### Payment Statuses (4 strings)
- `context.loc.unpaid` → "Unpaid" / "غير مدفوع"
- `context.loc.partial` → "Partial" / "مدفوع جزئياً"
- `context.loc.paymentPaid` → "Paid" / "مدفوع"
- `context.loc.refunded` → "Refunded" / "مسترد"

### Common Actions (15 strings)
- `context.loc.save` → "Save" / "حفظ"
- `context.loc.cancel` → "Cancel" / "إلغاء"
- `context.loc.delete` → "Delete" / "حذف"
- `context.loc.edit` → "Edit" / "تعديل"
- `context.loc.add` → "Add" / "إضافة"
- `context.loc.search` → "Search" / "بحث"
- `context.loc.filter` → "Filter" / "تصفية"
- `context.loc.sort` → "Sort" / "ترتيب"
- `context.loc.refresh` → "Refresh" / "تحديث"
- `context.loc.submit` → "Submit" / "إرسال"
- `context.loc.confirm` → "Confirm" / "تأكيد"
- `context.loc.yes` → "Yes" / "نعم"
- `context.loc.no` → "No" / "لا"
- `context.loc.ok` → "OK" / "موافق"
- `context.loc.close` → "Close" / "إغلاق"

### Messages (10 strings)
- `context.loc.loading` → "Loading..." / "جاري التحميل..."
- `context.loc.noDataFound` → "No data found" / "لا توجد بيانات"
- `context.loc.somethingWentWrong` → "Something went wrong" / "حدث خطأ ما"
- `context.loc.tryAgain` → "Try Again" / "حاول مرة أخرى"
- `context.loc.success` → "Success" / "نجح"
- `context.loc.error` → "Error" / "خطأ"
- `context.loc.warning` → "Warning" / "تحذير"
- `context.loc.deleteConfirmation` → "Are you sure you want to delete?" / "هل أنت متأكد من الحذف؟"

### Validation (5 strings)
- `context.loc.fieldRequired` → "This field is required" / "هذا الحقل مطلوب"
- `context.loc.invalidEmail` → "Please enter a valid email" / "الرجاء إدخال بريد إلكتروني صحيح"
- `context.loc.passwordTooShort` → "Password must be at least 8 characters" / "يجب أن تكون كلمة المرور 8 أحرف على الأقل"
- `context.loc.passwordMismatch` → "Passwords do not match" / "كلمات المرور غير متطابقة"
- `context.loc.invalidNumber` → "Please enter a valid number" / "الرجاء إدخال رقم صحيح"

### Additional UI Strings (34 strings)
- `context.loc.searchCustomers` → "Search customers..." / "البحث عن العملاء..."
- `context.loc.searchProducts` → "Search products..." / "البحث عن المنتجات..."
- `context.loc.searchOrders` → "Search orders..." / "البحث عن الطلبات..."
- `context.loc.newCustomer` → "New Customer" / "عميل جديد"
- `context.loc.newProduct` → "New Product" / "منتج جديد"
- `context.loc.newOrder` → "New Order" / "طلب جديد"
- `context.loc.basicInformation` → "Basic Information" / "المعلومات الأساسية"
- `context.loc.billingAddress` → "Billing Address" / "عنوان الفواتير"
- `context.loc.shippingAddress` → "Shipping Address" / "عنوان الشحن"
- `context.loc.sameAsBilling` → "Same as billing" / "نفس عنوان الفواتير"
- `context.loc.customerType` → "Customer Type" / "نوع العميل"
- `context.loc.status` → "Status" / "الحالة"
- `context.loc.streetAddress` → "Street Address" / "عنوان الشارع"
- `context.loc.postalCodeShort` → "Postal Code" / "الرمز البريدي"
- `context.loc.name` → "Name" / "الاسم"
- `context.loc.description` → "Description" / "الوصف"
- `context.loc.created` → "Created" / "تاريخ الإنشاء"
- `context.loc.pricing` → "Pricing" / "التسعير"
- `context.loc.inventory` → "Inventory" / "المخزون"
- `context.loc.stockStatus` → "Stock Status" / "حالة المخزون"
- `context.loc.trackInventory` → "Track Inventory" / "تتبع المخزون"
- `context.loc.lowStockThreshold` → "Low Stock Threshold" / "حد المخزون المنخفض"
- `context.loc.selectCustomer` → "Select Customer" / "اختر عميل"
- `context.loc.selectProduct` → "Select Product" / "اختر منتج"
- `context.loc.addItem` → "Add Item" / "إضافة عنصر"
- `context.loc.notes` → "Notes" / "ملاحظات"
- `context.loc.orderSummary` → "Order Summary" / "ملخص الطلب"
- `context.loc.balanceDue` → "Balance Due" / "الرصيد المستحق"
- `context.loc.filters` → "Filters" / "الفلاتر"
- `context.loc.clearFilters` → "Clear Filters" / "مسح الفلاتر"
- `context.loc.applyFilters` → "Apply Filters" / "تطبيق الفلاتر"

---

## Screen-by-Screen Translation Checklist

### ✅ Completed Screens
- [x] Dashboard Screen
- [x] Customer List Screen (AppBar + Search only)

### 🚧 Screens to Translate

#### Customer Module
- [ ] Customer Form Screen (New/Edit)
- [ ] Customer Detail Screen
- [ ] Customer Card Widget

#### Product Module
- [ ] Product List Screen
- [ ] Product Form Screen (New/Edit)
- [ ] Product Detail Screen
- [ ] Product Card Widget

#### Order Module
- [ ] Order List Screen
- [ ] Create Order Screen
- [ ] Order Detail Screen
- [ ] Order Card Widget
- [ ] Record Payment Dialog

#### Auth Module
- [ ] Login Screen
- [ ] Register Screen

---

## Common Translation Patterns

### AppBar Titles
```dart
// Before
AppBar(title: const Text('Customers'))

// After
AppBar(title: Text(context.loc.customers))
```

### Search Fields
```dart
// Before
TextField(decoration: InputDecoration(hintText: 'Search customers...'))

// After
TextField(decoration: InputDecoration(hintText: context.loc.searchCustomers))
```

### Buttons
```dart
// Before
ElevatedButton(child: const Text('Save'), onPressed: _save)

// After
ElevatedButton(child: Text(context.loc.save), onPressed: _save)
```

### Form Labels
```dart
// Before
TextFormField(
  decoration: InputDecoration(labelText: 'First Name'),
)

// After
TextFormField(
  decoration: InputDecoration(labelText: context.loc.firstName),
)
```

### Section Headers
```dart
// Before
Text('Basic Information', style: Theme.of(context).textTheme.titleMedium)

// After
Text(context.loc.basicInformation, style: Theme.of(context).textTheme.titleMedium)
```

---

## Adding New Translations

If you need a translation that doesn't exist:

### 1. Add to app_localizations.dart

Add a getter in the `AppLocalizations` class:
```dart
String get myNewString => translate('myNewString');
```

### 2. Add English translation
In `_enTranslations` map:
```dart
'myNewString': 'My New String',
```

### 3. Add Arabic translation
In `_arTranslations` map:
```dart
'myNewString': 'النص الجديد',
```

### 4. Use it
```dart
Text(context.loc.myNewString)
```

---

## Tips

1. **Always test both languages** - Click the language toggle button to verify
2. **Check RTL layout** - Ensure the layout looks good when switched to Arabic
3. **Keep strings short** - Long Arabic text may overflow on small screens
4. **Use context.loc everywhere** - Never hardcode strings in UI
5. **Gradual migration** - You can translate screens one at a time

---

## Priority Order for Translation

**High Priority** (User-facing screens):
1. Login Screen
2. Customer List & Form
3. Product List & Form
4. Order List & Create

**Medium Priority**:
5. Order Detail Screen
6. Customer/Product Detail Screens
7. Dialogs and modals

**Low Priority**:
8. Error screens
9. Settings (not yet implemented)
10. Reports (not yet implemented)

---

## Testing Checklist

For each translated screen:

- [ ] Import `localization_extension.dart`
- [ ] Replace all hardcoded strings with `context.loc.*`
- [ ] Test in English (default)
- [ ] Click language toggle button
- [ ] Test in Arabic
- [ ] Check RTL layout
- [ ] Verify no text overflow
- [ ] Check form validation messages
- [ ] Test button labels
- [ ] Verify dialog messages

---

## Support

If you encounter any issues or need help:
1. Check that the translation exists in `app_localizations.dart`
2. Ensure you imported `localization_extension.dart`
3. Verify you're using `context.loc.*` not `AppStrings.*`
4. Make sure the widget has access to `BuildContext`

---

**Last Updated:** December 27, 2025  
**Translation Coverage:** 140+ strings  
**Languages:** English (en), Arabic (ar)  
**Status:** Infrastructure Complete, Screens In Progress
