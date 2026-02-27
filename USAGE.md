# دليل الاستخدام - الربط بقاعدة البيانات

## البدء السريع

### 1. تثبيت المكتبات
```bash
npm install
```

### 2. إعداد متغيرات البيئة
قم بنسخ معرفات Supabase في ملف `.env`:

```env
VITE_SUPABASE_URL=https://your-project-id.supabase.co
VITE_SUPABASE_SUPABASE_ANON_KEY=your-anon-key
```

### 3. تشغيل المشروع
```bash
npm run dev
```

---

## أمثلة الاستخدام

### جلب الطلبات
```javascript
import { getOrders } from './src/supabase.js'

const orders = await getOrders()
console.log('الطلبات:', orders)
```

### جلب المنتجات
```javascript
import { getProducts } from './src/supabase.js'

const products = await getProducts()
products.forEach(product => {
  console.log(`${product.name}: $${product.price}`)
})
```

### إنشاء طلب جديد
```javascript
import { createOrder } from './src/supabase.js'

const newOrder = await createOrder({
  order_number: 'ORD-006',
  customer_name: 'أحمد محمود',
  customer_email: 'ahmed@example.com',
  customer_phone: '+966551234567',
  total_amount: 1500.00,
  status: 'pending',
  payment_status: 'unpaid'
})

console.log('تم إنشاء الطلب:', newOrder)
```

### تحديث حالة الطلب
```javascript
import { updateOrder, logActivity } from './src/supabase.js'

await updateOrder('order-uuid', {
  status: 'completed',
  payment_status: 'paid',
  updated_at: new Date()
})

// تسجيل النشاط
await logActivity('update', 'order', 'order-uuid', {
  description: 'تم تحديث حالة الطلب إلى مكتمل',
  previous_status: 'processing'
})
```

### الحصول على الإحصائيات
```javascript
import { getSalesStats } from './src/supabase.js'

const stats = await getSalesStats()
console.log(`إجمالي الإيرادات: $${stats.totalRevenue}`)
console.log(`عدد الطلبات: ${stats.totalOrders}`)
console.log(`متوسط قيمة الطلب: $${stats.averageOrderValue}`)
```

### جلب بيانات التحليلات
```javascript
import { getAnalytics } from './src/supabase.js'

const analytics = await getAnalytics(30) // آخر 30 يوم
analytics.forEach(day => {
  console.log(`${day.date}: ${day.total_orders} طلبات، إيرادات: $${day.total_revenue}`)
})
```

### الاستماع للتحديثات الفورية
```javascript
import { subscribeToOrders } from './src/supabase.js'

const subscription = await subscribeToOrders((payload) => {
  console.log('تحديث جديد:', payload)
  if (payload.eventType === 'INSERT') {
    console.log('تم إنشاء طلب جديد:', payload.new)
  }
})

// للإلغاء لاحقاً
subscription.unsubscribe()
```

---

## أمثلة استعلامات SQL المباشرة

### جلب أكثر العملاء إنفاقاً
```sql
SELECT customer_name, SUM(total_amount) as total_spent
FROM orders
WHERE payment_status = 'paid'
GROUP BY customer_name
ORDER BY total_spent DESC
LIMIT 10;
```

### متوسط الإيرادات اليومية
```sql
SELECT
  DATE(created_at) as date,
  SUM(total_amount) as daily_revenue,
  COUNT(*) as order_count,
  AVG(total_amount) as avg_order_value
FROM orders
WHERE status = 'completed' AND payment_status = 'paid'
GROUP BY DATE(created_at)
ORDER BY date DESC;
```

### المنتجات ذات المخزون المنخفض
```sql
SELECT name, sku, stock_quantity, price
FROM products
WHERE stock_quantity < 10
ORDER BY stock_quantity ASC;
```

### نسبة النمو الشهري
```sql
SELECT
  DATE_TRUNC('month', created_at) as month,
  SUM(total_amount) as monthly_revenue,
  COUNT(*) as total_orders
FROM orders
WHERE status = 'completed'
GROUP BY DATE_TRUNC('month', created_at)
ORDER BY month DESC;
```

### أداء الفئات
```sql
SELECT
  c.name as category_name,
  COUNT(oi.id) as total_items_sold,
  SUM(oi.subtotal) as category_revenue,
  AVG(p.price) as avg_price
FROM categories c
LEFT JOIN products p ON c.id = p.category_id
LEFT JOIN order_items oi ON p.id = oi.product_id
GROUP BY c.id, c.name
ORDER BY category_revenue DESC;
```

---

## دوال مساعدة مفيدة

### تحويل التاريخ
```javascript
// تحويل التاريخ لصيغة قابلة للقراءة
function formatDate(date) {
  return new Date(date).toLocaleDateString('ar-SA', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}
```

### تنسيق العملة
```javascript
// تنسيق الأرقام كعملة
function formatCurrency(amount) {
  return new Intl.NumberFormat('ar-SA', {
    style: 'currency',
    currency: 'SAR'
  }).format(amount)
}
```

### حساب النسبة المئوية
```javascript
function calculatePercentage(value, total) {
  return ((value / total) * 100).toFixed(2)
}
```

---

## معالجة الأخطاء

```javascript
async function safeQuery(queryFunction) {
  try {
    const data = await queryFunction()
    return { success: true, data }
  } catch (error) {
    console.error('خطأ في الاستعلام:', error.message)
    return { success: false, error: error.message }
  }
}

// الاستخدام
const result = await safeQuery(() => getOrders())
if (result.success) {
  console.log('البيانات:', result.data)
} else {
  console.log('الخطأ:', result.error)
}
```

---

## أفضل الممارسات

### 1. تخزين البيانات في الكاش
```javascript
let ordersCache = null
let cacheTime = null

async function getCachedOrders() {
  const now = Date.now()
  if (ordersCache && cacheTime && (now - cacheTime) < 60000) {
    return ordersCache
  }

  ordersCache = await getOrders()
  cacheTime = now
  return ordersCache
}
```

### 2. البحث والتصفية
```javascript
async function searchOrders(keyword) {
  const orders = await getOrders()
  return orders.filter(order =>
    order.customer_name.includes(keyword) ||
    order.order_number.includes(keyword)
  )
}
```

### 3. الترتيب والتصفية
```javascript
async function getSortedOrders(sortBy = 'created_at', ascending = false) {
  const orders = await getOrders()
  return orders.sort((a, b) => {
    const aVal = a[sortBy]
    const bVal = b[sortBy]

    if (aVal < bVal) return ascending ? -1 : 1
    if (aVal > bVal) return ascending ? 1 : -1
    return 0
  })
}
```

### 4. تجميع البيانات
```javascript
async function groupOrdersByStatus() {
  const orders = await getOrders()
  return orders.reduce((grouped, order) => {
    if (!grouped[order.status]) {
      grouped[order.status] = []
    }
    grouped[order.status].push(order)
    return grouped
  }, {})
}
```

---

## حل مشاكل شائعة

### خطأ: "متغيرات البيئة غير محددة"
```
التحقق من وجود ملف .env مع القيم الصحيحة
```

### خطأ: "CORS"
```
تأكد من السماح بنطاقك في إعدادات Supabase
```

### خطأ: "Row Level Security"
```
تحقق من سياسات الأمان في قاعدة البيانات
```

### عدم ظهور البيانات
```
- تأكد من أن البيانات موجودة في قاعدة البيانات
- تحقق من سياسات RLS
- استخدم وحدة التحكم للتحقق من الأخطاء
```

---

## الخطوات التالية

1. ربط لوحة التحكم بالبيانات الحقيقية
2. إضافة نماذج لإنشاء وتحديث البيانات
3. تنفيذ الفلترة والبحث
4. إضافة الرسوم البيانية الديناميكية
5. تنفيذ المصادقة والأمان

---

## موارد إضافية

- [وثائق Supabase](https://supabase.com/docs)
- [JavaScript Client Library](https://supabase.com/docs/reference/javascript/introduction)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)
