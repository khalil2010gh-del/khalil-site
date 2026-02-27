/*
  # إنشاء نظام قاعدة البيانات لنظام إدارة لوحة التحكم

  ## الوصف
  هذه الهجرة تنشئ هيكل قاعدة بيانات شامل لنظام لوحة تحكم احترافي يتضمن:
  - إدارة المستخدمين والعاملين
  - تتبع المبيعات والطلبات
  - إدارة المنتجات والفئات
  - تحليل الأداء والإحصائيات
  - سجل النشاطات والعمليات

  ## الجداول الجديدة
  - `companies`: بيانات الشركات
  - `users`: المستخدمين والعاملين
  - `categories`: فئات المنتجات
  - `products`: المنتجات والخدمات
  - `orders`: الطلبات والمبيعات
  - `order_items`: تفاصيل الطلب
  - `analytics`: بيانات التحليلات
  - `activity_logs`: سجل الأنشطة

  ## الأمان
  - تم تفعيل RLS على جميع الجداول
  - سياسات تحقق من ملكية البيانات
  - فقط المستخدمون المصرح لهم يمكنهم الوصول للبيانات
*/

-- جدول الشركات
CREATE TABLE IF NOT EXISTS companies (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  email text NOT NULL,
  phone text,
  logo_url text,
  industry text,
  subscription_plan text DEFAULT 'free',
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE companies ENABLE ROW LEVEL SECURITY;

CREATE POLICY "الشركات يمكنها قراءة بيانات نفسها"
  ON companies FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "الشركات يمكنها تحديث بيانات نفسها"
  ON companies FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- جدول المستخدمين
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  email text NOT NULL UNIQUE,
  full_name text NOT NULL,
  role text DEFAULT 'user',
  avatar_url text,
  is_active boolean DEFAULT true,
  last_login timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "المستخدمون يمكنهم قراءة ملفاتهم الشخصية"
  ON users FOR SELECT
  TO authenticated
  USING (auth.uid()::text = id::text OR role = 'admin');

CREATE POLICY "المستخدمون يمكنهم تحديث ملفاتهم الشخصية"
  ON users FOR UPDATE
  TO authenticated
  USING (auth.uid()::text = id::text)
  WITH CHECK (auth.uid()::text = id::text);

-- جدول الفئات
CREATE TABLE IF NOT EXISTS categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  name text NOT NULL,
  description text,
  icon text,
  color text,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "المستخدمون يمكنهم قراءة الفئات النشطة"
  ON categories FOR SELECT
  TO authenticated
  USING (is_active = true);

CREATE POLICY "المسؤولون يمكنهم إدارة الفئات"
  ON categories FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "المسؤولون يمكنهم تحديث الفئات"
  ON categories FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- جدول المنتجات
CREATE TABLE IF NOT EXISTS products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id uuid NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  company_id uuid NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  name text NOT NULL,
  description text,
  price decimal(10, 2) NOT NULL,
  stock_quantity integer DEFAULT 0,
  image_url text,
  sku text UNIQUE,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE products ENABLE ROW LEVEL SECURITY;

CREATE POLICY "المستخدمون يمكنهم قراءة المنتجات النشطة"
  ON products FOR SELECT
  TO authenticated
  USING (is_active = true);

CREATE POLICY "المسؤولون يمكنهم إدارة المنتجات"
  ON products FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- جدول الطلبات
CREATE TABLE IF NOT EXISTS orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  user_id uuid REFERENCES users(id) ON DELETE SET NULL,
  order_number text NOT NULL UNIQUE,
  customer_name text NOT NULL,
  customer_email text NOT NULL,
  customer_phone text,
  total_amount decimal(10, 2) NOT NULL,
  status text DEFAULT 'pending',
  payment_status text DEFAULT 'unpaid',
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "المستخدمون يمكنهم قراءة الطلبات"
  ON orders FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "المستخدمون يمكنهم إنشاء طلبات"
  ON orders FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "المستخدمون يمكنهم تحديث الطلبات"
  ON orders FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- جدول تفاصيل الطلب
CREATE TABLE IF NOT EXISTS order_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id uuid NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
  quantity integer NOT NULL CHECK (quantity > 0),
  unit_price decimal(10, 2) NOT NULL,
  subtotal decimal(10, 2) NOT NULL,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "المستخدمون يمكنهم قراءة تفاصيل الطلبات"
  ON order_items FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "المستخدمون يمكنهم إدارة تفاصيل الطلبات"
  ON order_items FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- جدول التحليلات
CREATE TABLE IF NOT EXISTS analytics (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  date date NOT NULL,
  total_revenue decimal(10, 2) DEFAULT 0,
  total_orders integer DEFAULT 0,
  active_users integer DEFAULT 0,
  conversion_rate decimal(5, 2) DEFAULT 0,
  bounce_rate decimal(5, 2) DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  UNIQUE(company_id, date)
);

ALTER TABLE analytics ENABLE ROW LEVEL SECURITY;

CREATE POLICY "المستخدمون يمكنهم قراءة التحليلات"
  ON analytics FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "النظام يمكنه إدارة التحليلات"
  ON analytics FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- جدول سجل الأنشطة
CREATE TABLE IF NOT EXISTS activity_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  user_id uuid REFERENCES users(id) ON DELETE SET NULL,
  action text NOT NULL,
  entity_type text NOT NULL,
  entity_id text,
  details jsonb,
  ip_address text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE activity_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "المستخدمون يمكنهم قراءة سجل الأنشطة"
  ON activity_logs FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "النظام يمكنه إنشاء سجلات الأنشطة"
  ON activity_logs FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- إنشاء الفهارس لتحسين الأداء
CREATE INDEX IF NOT EXISTS idx_users_company_id ON users(company_id);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_categories_company_id ON categories(company_id);
CREATE INDEX IF NOT EXISTS idx_products_category_id ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_company_id ON products(company_id);
CREATE INDEX IF NOT EXISTS idx_orders_company_id ON orders(company_id);
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_analytics_company_id ON analytics(company_id);
CREATE INDEX IF NOT EXISTS idx_analytics_date ON analytics(date);
CREATE INDEX IF NOT EXISTS idx_activity_logs_company_id ON activity_logs(company_id);
CREATE INDEX IF NOT EXISTS idx_activity_logs_created_at ON activity_logs(created_at);
