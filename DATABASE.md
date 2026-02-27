# توثيق قاعدة البيانات - نظام لوحة التحكم

## نظرة عامة
قاعدة بيانات احترافية مبنية على **Supabase PostgreSQL** تدعم نظام إدارة لوحة تحكم متكامل مع 8 جداول رئيسية وسياسات أمان متقدمة.

---

## الجداول الرئيسية

### 1. جدول الشركات (Companies)
**الغرض**: تخزين بيانات الشركات والمنظمات

| العمود | النوع | الوصف |
|-------|-------|-------|
| `id` | UUID | معرّف فريد (مفتاح أساسي) |
| `name` | text | اسم الشركة |
| `email` | text | البريد الإلكتروني |
| `phone` | text | رقم الهاتف |
| `logo_url` | text | رابط الشعار |
| `industry` | text | نوع الصناعة |
| `subscription_plan` | text | نوع الاشتراك (free, premium) |
| `is_active` | boolean | حالة النشاط |
| `created_at` | timestamptz | تاريخ الإنشاء |
| `updated_at` | timestamptz | آخر تحديث |

**مثال SQL**:
```sql
SELECT * FROM companies
WHERE is_active = true AND subscription_plan = 'premium';
```

---

### 2. جدول المستخدمين (Users)
**الغرض**: إدارة العاملين والمستخدمين

| العمود | النوع | الوصف |
|-------|-------|-------|
| `id` | UUID | معرّف فريد |
| `company_id` | UUID | معرّف الشركة (مفتاح أجنبي) |
| `email` | text | البريد الإلكتروني (فريد) |
| `full_name` | text | الاسم الكامل |
| `role` | text | الدور (admin, manager, staff) |
| `avatar_url` | text | صورة الملف الشخصي |
| `is_active` | boolean | حالة النشاط |
| `last_login` | timestamptz | آخر تسجيل دخول |
| `created_at` | timestamptz | تاريخ الإنشاء |
| `updated_at` | timestamptz | آخر تحديث |

**استعلامات مفيدة**:
```sql
-- الحصول على المستخدمين النشطين
SELECT * FROM users
WHERE is_active = true AND company_id = 'company-uuid';

-- تحديث آخر تسجيل دخول
UPDATE users
SET last_login = now()
WHERE id = 'user-uuid';
```

---

### 3. جدول الفئات (Categories)
**الغرض**: تصنيف المنتجات والخدمات

| العمود | النوع | الوصف |
|-------|-------|-------|
| `id` | UUID | معرّف فريد |
| `company_id` | UUID | معرّف الشركة |
| `name` | text | اسم الفئة |
| `description` | text | وصف الفئة |
| `icon` | text | أيقونة FontAwesome |
| `color` | text | اللون بصيغة hex |
| `is_active` | boolean | حالة النشاط |
| `created_at` | timestamptz | تاريخ الإنشاء |
| `updated_at` | timestamptz | آخر تحديث |

**الفئات الموجودة**:
- إلكترونيات
- الملابس
- الكتب
- الأثاث
- الأغذية

---

### 4. جدول المنتجات (Products)
**الغرض**: إدارة المنتجات والخدمات

| العمود | النوع | الوصف |
|-------|-------|-------|
| `id` | UUID | معرّف فريد |
| `category_id` | UUID | معرّف الفئة |
| `company_id` | UUID | معرّف الشركة |
| `name` | text | اسم المنتج |
| `description` | text | وصف المنتج |
| `price` | decimal | السعر |
| `stock_quantity` | integer | كمية المخزون |
| `image_url` | text | رابط الصورة |
| `sku` | text | رمز المنتج (فريد) |
| `is_active` | boolean | حالة النشاط |
| `created_at` | timestamptz | تاريخ الإنشاء |
| `updated_at` | timestamptz | آخر تحديث |

**استعلامات مفيدة**:
```sql
-- منتجات بفئة معينة
SELECT * FROM products
WHERE category_id = 'category-uuid' AND is_active = true;

-- المنتجات بأقل مخزون
SELECT * FROM products
WHERE stock_quantity < 10
ORDER BY stock_quantity ASC;

-- إجمالي قيمة المخزون
SELECT SUM(price * stock_quantity) as inventory_value
FROM products;
```

---

### 5. جدول الطلبات (Orders)
**الغرض**: تتبع الطلبات والمبيعات

| العمود | النوع | الوصف |
|-------|-------|-------|
| `id` | UUID | معرّف فريد |
| `company_id` | UUID | معرّف الشركة |
| `user_id` | UUID | معرّف المستخدم (العامل) |
| `order_number` | text | رقم الطلب (فريد) |
| `customer_name` | text | اسم العميل |
| `customer_email` | text | بريد العميل |
| `customer_phone` | text | هاتف العميل |
| `total_amount` | decimal | المبلغ الإجمالي |
| `status` | text | الحالة (pending, processing, completed, cancelled) |
| `payment_status` | text | حالة الدفع (unpaid, paid, refunded) |
| `notes` | text | ملاحظات إضافية |
| `created_at` | timestamptz | تاريخ الإنشاء |
| `updated_at` | timestamptz | آخر تحديث |

**استعلامات مفيدة**:
```sql
-- إجمالي المبيعات اليومية
SELECT DATE(created_at) as date, SUM(total_amount) as daily_revenue
FROM orders
WHERE status = 'completed' AND payment_status = 'paid'
GROUP BY DATE(created_at)
ORDER BY date DESC;

-- عدد الطلبات حسب الحالة
SELECT status, COUNT(*) as count
FROM orders
GROUP BY status;

-- أعلى عملاء من حيث الإنفاق
SELECT customer_name, SUM(total_amount) as total_spent
FROM orders
WHERE payment_status = 'paid'
GROUP BY customer_name
ORDER BY total_spent DESC
LIMIT 10;
```

---

### 6. جدول تفاصيل الطلب (Order Items)
**الغرض**: تخزين تفاصيل كل منتج في الطلب

| العمود | النوع | الوصف |
|-------|-------|-------|
| `id` | UUID | معرّف فريد |
| `order_id` | UUID | معرّف الطلب |
| `product_id` | UUID | معرّف المنتج |
| `quantity` | integer | الكمية المطلوبة |
| `unit_price` | decimal | سعر الوحدة |
| `subtotal` | decimal | المجموع الفرعي |
| `created_at` | timestamptz | تاريخ الإنشاء |

**استعلامات مفيدة**:
```sql
-- تفاصيل طلب محدد
SELECT oi.*, p.name as product_name
FROM order_items oi
JOIN products p ON oi.product_id = p.id
WHERE oi.order_id = 'order-uuid';

-- أكثر المنتجات مبيعاً
SELECT p.name, SUM(oi.quantity) as total_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.id
GROUP BY p.id, p.name
ORDER BY total_sold DESC
LIMIT 10;
```

---

### 7. جدول التحليلات (Analytics)
**الغرض**: تخزين بيانات الأداء والإحصائيات اليومية

| العمود | النوع | الوصف |
|-------|-------|-------|
| `id` | UUID | معرّف فريد |
| `company_id` | UUID | معرّف الشركة |
| `date` | date | تاريخ البيانات |
| `total_revenue` | decimal | إجمالي الإيرادات |
| `total_orders` | integer | عدد الطلبات |
| `active_users` | integer | عدد المستخدمين النشطين |
| `conversion_rate` | decimal | معدل التحويل |
| `bounce_rate` | decimal | معدل الارتداد |
| `created_at` | timestamptz | تاريخ الإنشاء |

**استعلامات مفيدة**:
```sql
-- متوسط الإيرادات الأسبوعية
SELECT
  DATE_TRUNC('week', date) as week,
  AVG(total_revenue) as avg_revenue,
  SUM(total_orders) as total_orders
FROM analytics
GROUP BY DATE_TRUNC('week', date)
ORDER BY week DESC;

-- نسبة النمو الشهري
SELECT
  DATE_TRUNC('month', date) as month,
  SUM(total_revenue) as monthly_revenue
FROM analytics
GROUP BY DATE_TRUNC('month', date)
ORDER BY month DESC;
```

---

### 8. جدول سجل الأنشطة (Activity Logs)
**الغرض**: تتبع جميع الأنشطة والعمليات

| العمود | النوع | الوصف |
|-------|-------|-------|
| `id` | UUID | معرّف فريد |
| `company_id` | UUID | معرّف الشركة |
| `user_id` | UUID | معرّف المستخدم |
| `action` | text | نوع الإجراء (create, update, delete) |
| `entity_type` | text | نوع الكيان (order, product, user) |
| `entity_id` | text | معرّف الكيان |
| `details` | jsonb | بيانات إضافية بصيغة JSON |
| `ip_address` | text | عنوان IP |
| `created_at` | timestamptz | تاريخ الإنشاء |

---

## سياسات الأمان (RLS)

### Row Level Security (RLS) مفعّل على جميع الجداول

**أمثلة على السياسات**:

```sql
-- سياسة لقراءة البيانات الخاصة بك فقط
CREATE POLICY "Users can read own data"
  ON users FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

-- سياسة لمنع الوصول غير المصرح
CREATE POLICY "No public access"
  ON products FOR SELECT
  TO authenticated
  USING (is_active = true);
```

---

## الفهارس (Indexes)

تم إنشاء فهارس لتحسين الأداء على الأعمدة التي يتم البحث عليها بكثرة:

```sql
CREATE INDEX idx_users_company_id ON users(company_id);
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_analytics_date ON analytics(date);
```

---

## البيانات التجريبية

### الشركة التجريبية
```
الاسم: شركتي الرائعة
البريد: info@example.com
الهاتف: +966551234567
الصناعة: التجارة الإلكترونية
الخطة: Premium
```

### المستخدمون التجريبيون
| البريد | الاسم | الدور |
|------|-------|-------|
| admin@example.com | محمد أحمد | admin |
| manager@example.com | فاطمة علي | manager |
| staff@example.com | سارة خالد | staff |

### المنتجات التجريبية
- 10 منتجات متنوعة عبر 5 فئات
- الأسعار تتراوح من $25 إلى $1200

### الطلبات التجريبية
- 5 طلبات بحالات مختلفة (معلق، قيد المعالجة، مكتمل، ملغي)

---

## الاتصال بقاعدة البيانات

### متغيرات البيئة المطلوبة
```env
VITE_SUPABASE_URL=https://[project-id].supabase.co
VITE_SUPABASE_SUPABASE_ANON_KEY=[your-anon-key]
```

### مثال JavaScript للاتصال
```javascript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  import.meta.env.VITE_SUPABASE_URL,
  import.meta.env.VITE_SUPABASE_SUPABASE_ANON_KEY
)

// جلب الطلبات
const { data, error } = await supabase
  .from('orders')
  .select('*')
  .eq('status', 'completed')
```

---

## نصائح الأداء

### 1. استخدم الفهارس بحكمة
```sql
-- سريع (محفهرس)
SELECT * FROM orders WHERE status = 'completed';

-- بطيء (بدون فهرس)
SELECT * FROM orders WHERE total_amount > 1000;
```

### 2. استخدم الإسقاط (Select)
```sql
-- سريع (أعمدة محددة)
SELECT id, customer_name, total_amount FROM orders;

-- بطيء (جميع الأعمدة)
SELECT * FROM orders;
```

### 3. استخدم LIMIT
```sql
-- دائماً أضف حد للنتائج
SELECT * FROM orders LIMIT 100;
```

---

## الصيانة الدورية

### تنظيف البيانات القديمة
```sql
-- حذف سجلات النشاط القديمة
DELETE FROM activity_logs
WHERE created_at < CURRENT_DATE - INTERVAL '90 days';
```

### تحديث الإحصائيات
```sql
-- إعادة حساب الإحصائيات
SELECT COUNT(*) FROM orders WHERE status = 'completed';
```

---

## الدعم والمساعدة

للمزيد من المعلومات:
- [توثيق Supabase](https://supabase.com/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
