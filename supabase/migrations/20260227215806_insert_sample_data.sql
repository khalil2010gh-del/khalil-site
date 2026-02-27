/*
  # إدراج بيانات تجريبية للاختبار

  ## الوصف
  هذه الهجرة تدرج بيانات تجريبية للاختبار والعرض التوضيحي

  ## البيانات المضافة
  - 1 شركة تجريبية
  - 3 مستخدمين
  - 5 فئات منتجات
  - 10 منتجات
  - 5 طلبات مع تفاصيلها
  - بيانات تحليلية يومية
  - سجلات أنشطة
*/

-- إدراج شركة تجريبية
INSERT INTO companies (name, email, phone, industry, subscription_plan)
VALUES (
  'شركتي الرائعة',
  'info@example.com',
  '+966551234567',
  'التجارة الإلكترونية',
  'premium'
)
ON CONFLICT DO NOTHING;

-- إدراج فئات المنتجات
INSERT INTO categories (company_id, name, description, icon, color, is_active)
SELECT 
  c.id,
  category.name,
  category.description,
  category.icon,
  category.color,
  true
FROM (
  VALUES 
    ('إلكترونيات', 'أجهزة وملحقات إلكترونية', 'fas fa-laptop', '#3b82f6'),
    ('الملابس', 'ملابس وأحذية للرجال والنساء', 'fas fa-shirt', '#ec4899'),
    ('الكتب', 'كتب وكتب إلكترونية', 'fas fa-book', '#10b981'),
    ('الأثاث', 'أثاث منزلي وديكورات', 'fas fa-chair', '#f59e0b'),
    ('الأغذية', 'منتجات غذائية وعضوية', 'fas fa-apple-alt', '#8b5cf6')
) AS category(name, description, icon, color)
CROSS JOIN companies c
WHERE c.name = 'شركتي الرائعة'
ON CONFLICT DO NOTHING;

-- إدراج المنتجات
INSERT INTO products (category_id, company_id, name, description, price, stock_quantity, sku, is_active)
SELECT
  cat.id,
  c.id,
  product.name,
  product.description,
  product.price,
  product.stock_quantity,
  product.sku,
  true
FROM companies c
CROSS JOIN categories cat
CROSS JOIN (
  VALUES
    ('كمبيوتر محمول', 'كمبيوتر محمول عالي الأداء', 1200.00, 15, 'LAPTOP-001'),
    ('شاشة 4K', 'شاشة بدقة 4K بحجم 27 بوصة', 450.00, 8, 'SCREEN-001'),
    ('ماوس لاسلكي', 'ماوس لاسلكي بتقنية حديثة', 35.00, 50, 'MOUSE-001'),
    ('لوحة مفاتيح', 'لوحة مفاتيح ميكانيكية', 120.00, 25, 'KEYBOARD-001'),
    ('سماعات رأس', 'سماعات رأس بتقنية noise cancelling', 250.00, 20, 'HEADPHONE-001'),
    ('قميص رجالي', 'قميص قطن 100% للرجال', 45.00, 100, 'SHIRT-001'),
    ('بنطال جينز', 'بنطال جينز أصلي للنساء', 65.00, 80, 'JEANS-001'),
    ('كتاب البرمجة', 'كتاب تعليم البرمجة بلغة Python', 55.00, 30, 'BOOK-001'),
    ('كرسي مكتب', 'كرسي مكتب أرجونومي مريح', 300.00, 12, 'CHAIR-001'),
    ('عسل طبيعي', 'عسل طبيعي 100% من النحل', 25.00, 40, 'HONEY-001')
) AS product(name, description, price, stock_quantity, sku)
WHERE c.name = 'شركتي الرائعة'
ON CONFLICT (sku) DO NOTHING;

-- إدراج المستخدمين
INSERT INTO users (company_id, email, full_name, role, is_active, last_login)
SELECT
  c.id,
  user_data.email,
  user_data.full_name,
  user_data.role,
  true,
  now() - (random() * interval '7 days')
FROM companies c
CROSS JOIN (
  VALUES
    ('admin@example.com', 'محمد أحمد', 'admin'),
    ('manager@example.com', 'فاطمة علي', 'manager'),
    ('staff@example.com', 'سارة خالد', 'staff')
) AS user_data(email, full_name, role)
WHERE c.name = 'شركتي الرائعة'
ON CONFLICT (email) DO NOTHING;

-- إدراج الطلبات
INSERT INTO orders (company_id, user_id, order_number, customer_name, customer_email, customer_phone, total_amount, status, payment_status)
SELECT
  c.id,
  u.id,
  order_data.order_number,
  order_data.customer_name,
  order_data.customer_email,
  order_data.customer_phone,
  order_data.total_amount,
  order_data.status,
  order_data.payment_status
FROM companies c
CROSS JOIN users u
CROSS JOIN (
  VALUES
    ('ORD-001', 'أحمد حسن', 'customer1@example.com', '+966551234567', 1450.00, 'completed', 'paid'),
    ('ORD-002', 'فاطمة محمد', 'customer2@example.com', '+966552345678', 320.00, 'completed', 'paid'),
    ('ORD-003', 'سارة علي', 'customer3@example.com', '+966553456789', 680.00, 'processing', 'paid'),
    ('ORD-004', 'محمود سعد', 'customer4@example.com', '+966554567890', 450.00, 'cancelled', 'refunded'),
    ('ORD-005', 'ليلى حسن', 'customer5@example.com', '+966555678901', 890.00, 'pending', 'pending')
) AS order_data(order_number, customer_name, customer_email, customer_phone, total_amount, status, payment_status)
WHERE c.name = 'شركتي الرائعة' AND u.role = 'admin'
ON CONFLICT (order_number) DO NOTHING;

-- إدراج بيانات تحليلية يومية
INSERT INTO analytics (company_id, date, total_revenue, total_orders, active_users, conversion_rate, bounce_rate)
SELECT
  c.id,
  CURRENT_DATE - (day_offset::integer || ' days')::interval,
  (3000 + (random() * 3000))::decimal(10, 2),
  (8 + (random() * 12))::integer,
  (50 + (random() * 100))::integer,
  (2.5 + (random() * 2))::decimal(5, 2),
  (35 + (random() * 20))::decimal(5, 2)
FROM companies c
CROSS JOIN generate_series(0, 29) AS day_offset
WHERE c.name = 'شركتي الرائعة'
ON CONFLICT (company_id, date) DO NOTHING;

-- إدراج سجلات الأنشطة
INSERT INTO activity_logs (company_id, user_id, action, entity_type, entity_id, details)
SELECT
  c.id,
  u.id,
  activity.action,
  activity.entity_type,
  activity.entity_id,
  jsonb_build_object(
    'description', activity.description,
    'timestamp', now()::text
  )
FROM companies c
CROSS JOIN users u
CROSS JOIN (
  VALUES
    ('create', 'order', 'ORD-001', 'تم إنشاء طلب جديد'),
    ('update', 'order', 'ORD-001', 'تم تحديث حالة الطلب'),
    ('create', 'product', 'LAPTOP-001', 'تم إضافة منتج جديد'),
    ('delete', 'product', 'OLD-SKU', 'تم حذف منتج قديم'),
    ('create', 'user', 'new-user-id', 'تم إضافة مستخدم جديد')
) AS activity(action, entity_type, entity_id, description)
WHERE c.name = 'شركتي الرائعة' AND u.role = 'admin'
LIMIT 100
ON CONFLICT DO NOTHING;
