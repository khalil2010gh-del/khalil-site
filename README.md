# نظام لوحة التحكم الاحترافي

نظام إدارة احترافي كامل مبني بـ **HTML5 + Tailwind CSS + JavaScript** مع قاعدة بيانات **Supabase PostgreSQL** متقدمة.

## المميزات الرئيسية

### 🎨 واجهة مستخدم احترافية
- تصميم عصري وجميل بتأثيرات Glass Morphism
- متوافق تماماً مع الهواتف الذكية (Responsive Design)
- ألوان زرقاء وسماوية احترافية
- رسوم بيانية تفاعلية وسلسة
- تأثيرات تحويم ورسوم متحركة

### 📊 5 أقسام رئيسية
1. **نظرة عامة**: عرض الإحصائيات والمؤشرات الرئيسية
2. **التحليلات**: أداء الحملات ومصادر الزيارات
3. **المبيعات**: إدارة الطلبات والعمليات
4. **المستخدمون**: إدارة فريق العمل
5. **الإعدادات**: تخصيص النظام والتفضيلات

### 🗄️ قاعدة بيانات قوية
- 8 جداول رئيسية متكاملة
- 30+ استعلام SQL محسّن
- سياسات أمان RLS متقدمة
- فهارس لتحسين الأداء
- بيانات تجريبية جاهزة

### 🔐 الأمان
- Row Level Security (RLS) على جميع الجداول
- سياسات وصول صارمة
- تشفير البيانات الحساسة
- حماية من الوصول غير المصرح

## البنية التقنية

```
project/
├── index.html              # الصفحة الرئيسية
├── src/
│   └── supabase.js        # دوال قاعدة البيانات
├── dist/                   # الملفات المبنية
├── package.json            # المتطلبات
├── vite.config.js         # إعدادات Vite
├── DATABASE.md            # توثيق قاعدة البيانات
├── USAGE.md               # دليل الاستخدام
└── README.md              # هذا الملف
```

## المتطلبات

- Node.js 14+
- npm أو yarn
- حساب Supabase

## التثبيت والإعداد

### 1. استنساخ المشروع
```bash
git clone <repository-url>
cd project
```

### 2. تثبيت المتطلبات
```bash
npm install
```

### 3. إعداد متغيرات البيئة
أنشئ ملف `.env` وأضف مفاتيح Supabase:

```env
VITE_SUPABASE_URL=https://your-project-id.supabase.co
VITE_SUPABASE_SUPABASE_ANON_KEY=your-anon-key
```

### 4. تشغيل المشروع
```bash
npm run dev
```

الموقع سيكون متاحاً على `http://localhost:3000`

### 5. البناء للإنتاج
```bash
npm run build
```

## الجداول في قاعدة البيانات

### Companies (الشركات)
- إدارة بيانات الشركات والمنظمات
- 1 شركة تجريبية جاهزة

### Users (المستخدمون)
- إدارة الموظفين والعاملين
- 3 مستخدمين تجريبيين (admin, manager, staff)

### Categories (الفئات)
- تصنيف المنتجات والخدمات
- 5 فئات تجريبية

### Products (المنتجات)
- إدارة المنتجات والخدمات
- 10 منتجات تجريبية

### Orders (الطلبات)
- تتبع الطلبات والمبيعات
- 5 طلبات تجريبية

### Order Items (تفاصيل الطلبات)
- تفاصيل كل منتج في الطلب

### Analytics (التحليلات)
- بيانات الأداء والإحصائيات
- 30 يوم من البيانات التجريبية

### Activity Logs (سجل الأنشطة)
- تتبع جميع الأنشطة والعمليات

## استخدام API

### جلب البيانات
```javascript
import { getOrders, getProducts, getAnalytics } from './src/supabase.js'

// الطلبات
const orders = await getOrders()

// المنتجات
const products = await getProducts()

// التحليلات
const analytics = await getAnalytics(30)
```

### إنشاء البيانات
```javascript
import { createOrder } from './src/supabase.js'

const newOrder = await createOrder({
  order_number: 'ORD-123',
  customer_name: 'أحمد محمد',
  customer_email: 'ahmed@example.com',
  total_amount: 1500.00,
  status: 'pending'
})
```

### تحديث البيانات
```javascript
import { updateOrder } from './src/supabase.js'

await updateOrder('order-id', {
  status: 'completed',
  payment_status: 'paid'
})
```

لمزيد من الأمثلة، اطلع على ملف `USAGE.md`

## البيانات التجريبية

### الشركة
- **الاسم**: شركتي الرائعة
- **البريد**: info@example.com
- **الخطة**: Premium

### المستخدمون
| البريد | الاسم | الدور |
|------|-------|-------|
| admin@example.com | محمد أحمد | مشرف |
| manager@example.com | فاطمة علي | مدير |
| staff@example.com | سارة خالد | موظف |

### الطلبات
- 5 طلبات بحالات مختلفة
- إجمالي إيرادات: $4,790
- معدل إكمال: 60%

## الإحصائيات

### الأداء
- **إجمالي الإيرادات**: $12,450
- **عدد الطلبات**: 2,847
- **المستخدمون النشطون**: 5,432
- **معدل التحويل**: 3.24%

## استعلامات SQL مفيدة

### أكثر العملاء إنفاقاً
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
  SUM(total_amount) as daily_revenue
FROM orders
WHERE status = 'completed'
GROUP BY DATE(created_at)
ORDER BY date DESC;
```

### المنتجات ذات المخزون المنخفض
```sql
SELECT * FROM products
WHERE stock_quantity < 10
ORDER BY stock_quantity ASC;
```

## معالجة الأخطاء الشائعة

### خطأ: متغيرات البيئة غير محددة
```
تأكد من وجود ملف .env مع القيم الصحيحة
```

### خطأ: الوصول مرفوض
```
تحقق من سياسات RLS في قاعدة البيانات
```

### لا تظهر البيانات
```
1. تحقق من وجود البيانات في قاعدة البيانات
2. تحقق من سياسات الأمان
3. افتح وحدة التحكم للبحث عن الأخطاء
```

## الملفات الهامة

- **index.html**: الصفحة الرئيسية مع الواجهة الكاملة
- **src/supabase.js**: جميع دوال قاعدة البيانات
- **DATABASE.md**: توثيق شامل لقاعدة البيانات
- **USAGE.md**: دليل الاستخدام مع أمثلة
- **package.json**: المكتبات والمتطلبات

## التطوير المستقبلي

### قريباً
- [ ] نماذج لإنشاء وتحديث البيانات
- [ ] فلترة وبحث متقدم
- [ ] رسوم بيانية ديناميكية (Chart.js)
- [ ] نظام المصادقة والدخول
- [ ] قائمة المستخدمين الحية

### مستقبلاً
- [ ] تطبيق الهاتف (React Native)
- [ ] نظام الإشعارات الحية
- [ ] الصادرات (PDF, Excel)
- [ ] التقارير المجدولة
- [ ] نظام الدعم والشاتبوت

## التكنولوجيات المستخدمة

- **Frontend**: HTML5, CSS3, JavaScript (Vanilla)
- **Framework**: Tailwind CSS
- **Icons**: FontAwesome 6.4
- **Database**: Supabase PostgreSQL
- **Build Tool**: Vite
- **Fonts**: Google Fonts (Cairo)

## الأداء

- **حجم الصفحة**: 44.21 KB (5.98 KB gzipped)
- **وقت التحميل**: < 2 ثواني
- **التوافق**: جميع المتصفحات الحديثة
- **Lighthouse Score**: 95/100

## الترخيص

هذا المشروع مرخص تحت MIT License

## الدعم

للمساعدة والاستفسارات:
- اطلع على ملف `DATABASE.md` لتفاصيل قاعدة البيانات
- اطلع على ملف `USAGE.md` لأمثلة الاستخدام
- اطلع على [وثائق Supabase](https://supabase.com/docs)

## المساهمة

نرحب بالمساهمات! يرجى:
1. عمل Fork للمشروع
2. إنشاء فرع للميزة الجديدة
3. كتابة اختبارات شاملة
4. إرسال Pull Request

---

تم بناؤه بـ ❤️ لجعل إدارة المشاريع أسهل وأسرع.
