import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_SUPABASE_ANON_KEY

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

// دوال مساعدة للعمليات الشائعة

export async function getOrders() {
  try {
    const { data, error } = await supabase
      .from('orders')
      .select('*')
      .order('created_at', { ascending: false })
      .limit(100)

    if (error) throw error
    return data
  } catch (error) {
    console.error('خطأ في جلب الطلبات:', error.message)
    return []
  }
}

export async function getProducts() {
  try {
    const { data, error } = await supabase
      .from('products')
      .select('*, categories(name)')
      .eq('is_active', true)
      .limit(100)

    if (error) throw error
    return data
  } catch (error) {
    console.error('خطأ في جلب المنتجات:', error.message)
    return []
  }
}

export async function getAnalytics(days = 30) {
  try {
    const { data, error } = await supabase
      .from('analytics')
      .select('*')
      .gte('date', new Date(Date.now() - days * 24 * 60 * 60 * 1000).toISOString().split('T')[0])
      .order('date', { ascending: true })

    if (error) throw error
    return data
  } catch (error) {
    console.error('خطأ في جلب البيانات التحليلية:', error.message)
    return []
  }
}

export async function getUsers() {
  try {
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('is_active', true)

    if (error) throw error
    return data
  } catch (error) {
    console.error('خطأ في جلب المستخدمين:', error.message)
    return []
  }
}

export async function createOrder(orderData) {
  try {
    const { data, error } = await supabase
      .from('orders')
      .insert([orderData])
      .select()

    if (error) throw error
    return data[0]
  } catch (error) {
    console.error('خطأ في إنشاء الطلب:', error.message)
    return null
  }
}

export async function updateOrder(orderId, updates) {
  try {
    const { data, error } = await supabase
      .from('orders')
      .update(updates)
      .eq('id', orderId)
      .select()

    if (error) throw error
    return data[0]
  } catch (error) {
    console.error('خطأ في تحديث الطلب:', error.message)
    return null
  }
}

export async function getActivityLogs(limit = 50) {
  try {
    const { data, error } = await supabase
      .from('activity_logs')
      .select('*, users(full_name)')
      .order('created_at', { ascending: false })
      .limit(limit)

    if (error) throw error
    return data
  } catch (error) {
    console.error('خطأ في جلب سجل الأنشطة:', error.message)
    return []
  }
}

export async function logActivity(action, entityType, entityId, details) {
  try {
    const { error } = await supabase
      .from('activity_logs')
      .insert([{
        action,
        entity_type: entityType,
        entity_id: entityId,
        details
      }])

    if (error) throw error
    return true
  } catch (error) {
    console.error('خطأ في تسجيل النشاط:', error.message)
    return false
  }
}

export async function getSalesStats() {
  try {
    const { data: orders, error } = await supabase
      .from('orders')
      .select('total_amount, status, payment_status')
      .eq('status', 'completed')
      .eq('payment_status', 'paid')

    if (error) throw error

    const totalRevenue = orders.reduce((sum, order) => sum + parseFloat(order.total_amount), 0)
    const totalOrders = orders.length

    return {
      totalRevenue: totalRevenue.toFixed(2),
      totalOrders,
      averageOrderValue: totalOrders > 0 ? (totalRevenue / totalOrders).toFixed(2) : 0
    }
  } catch (error) {
    console.error('خطأ في جلب إحصائيات المبيعات:', error.message)
    return {
      totalRevenue: 0,
      totalOrders: 0,
      averageOrderValue: 0
    }
  }
}

export async function getTopProducts() {
  try {
    const { data, error } = await supabase
      .from('order_items')
      .select('product_id, quantity, products(name)')
      .order('quantity', { ascending: false })
      .limit(10)

    if (error) throw error
    return data
  } catch (error) {
    console.error('خطأ في جلب أفضل المنتجات:', error.message)
    return []
  }
}

export async function getCompanyData(companyId) {
  try {
    const { data, error } = await supabase
      .from('companies')
      .select('*')
      .eq('id', companyId)
      .single()

    if (error) throw error
    return data
  } catch (error) {
    console.error('خطأ في جلب بيانات الشركة:', error.message)
    return null
  }
}

export async function subscribeToOrders(callback) {
  return supabase
    .from('orders')
    .on('*', payload => {
      callback(payload)
    })
    .subscribe()
}

export async function subscribeToAnalytics(callback) {
  return supabase
    .from('analytics')
    .on('*', payload => {
      callback(payload)
    })
    .subscribe()
}
