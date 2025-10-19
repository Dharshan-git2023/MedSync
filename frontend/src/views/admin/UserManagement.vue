<script setup>
import { ref, computed, onMounted } from 'vue'

// State
const users = ref([])
const page = ref(1)
const perPage = ref(10)
const q = ref('')
const roleFilter = ref('')
const statusFilter = ref('')

// Pagination computed
const totalPages = computed(() => Math.ceil(visibleTotal.value / perPage.value))
const pageStart = computed(() => (page.value - 1) * perPage.value + 1)
const pageEnd = computed(() => Math.min(page.value * perPage.value, visibleTotal.value))

// Filtered users computed
const filteredUsers = computed(() => {
  let result = [...users.value]
  if (q.value) {
    const query = q.value.toLowerCase()
    result = result.filter(user => 
      user.name?.toLowerCase().includes(query) ||
      user.email?.toLowerCase().includes(query) ||
      user.phone?.toLowerCase().includes(query)
    )
  }
  if (roleFilter.value) {
    result = result.filter(user => user.role === roleFilter.value)
  }
  if (statusFilter.value) {
    const isActive = statusFilter.value === 'active'
    result = result.filter(user => user.active === isActive)
  }
  return result
})

const visibleTotal = computed(() => filteredUsers.value.length)
const pagedUsers = computed(() => {
  const start = (page.value - 1) * perPage.value
  return filteredUsers.value.slice(start, start + perPage.value)
})

// Modal states
const showAdd = ref(false)
const editing = ref(false)
const viewing = ref(false)
const viewingUser = ref(null)
const editForm = ref({ user_id: '', name: '', email: '', role: '', phone: '', active: true })
const newUser = ref({
  full_name: '',
  email: '',
  role: 'doctor',
  phone_number: '',
  is_active: true,
  password: '',
  license_number: '',
  hospital_id: '',
  pharmacy_license: ''
})

const validHospitalIds = ['h1', 'h2', 'h3']

// Fetch users
const fetchUsers = async () => {
  try {
    const api = (await import('@/api/client')).default
    const response = await api.get('/api/users/admin/users')
    users.value = response.data.items.map(user => ({
      ...user,
      name: user.full_name,
      active: user.is_active
    }))
  } catch (error) {
    console.error('Failed to fetch users:', error)
    alert('Failed to load users: ' + (error?.response?.data?.detail || error.message))
  }
}

// User actions
const createUser = async () => {
  try {
    const api = (await import('@/api/client')).default
    const payload = {
      email: newUser.value.email,
      password: newUser.value.password,
      full_name: newUser.value.full_name,
      phone_number: newUser.value.phone_number,
      role: newUser.value.role
    }

    // Validation
    if (!payload.email || !payload.password || !payload.full_name) {
      alert('Please fill in all required fields')
      return
    }

    if (newUser.value.role === 'doctor' && (!newUser.value.license_number || !newUser.value.hospital_id)) {
      alert('Please provide license number and hospital ID for doctor')
      return
    }

    if (newUser.value.role === 'pharmacy' && !newUser.value.pharmacy_license) {
      alert('Please provide pharmacy license')
      return
    }

    const res = await api.post('/api/auth/register', payload)
    
    // Handle role-specific fields
    if (res.data.user_id) {
      const extraFields = {}
      if (newUser.value.role === 'doctor') {
        extraFields.license_number = newUser.value.license_number
        extraFields.hospital_id = newUser.value.hospital_id
      }
      if (newUser.value.role === 'pharmacy') {
        extraFields.pharmacy_name = newUser.value.full_name
        extraFields.license_number = newUser.value.pharmacy_license
      }
      if (Object.keys(extraFields).length) {
        await api.post(`/api/users/admin/users/${res.data.user_id}/extra`, extraFields)
      }
    }

    await fetchUsers()
    showAdd.value = false
    alert('User created successfully')
  } catch (error) {
    alert('Failed to create user: ' + (error?.response?.data?.detail || error.message))
  }
}

const updateUser = async () => {
  try {
    const api = (await import('@/api/client')).default
    const payload = {
      full_name: editForm.value.name,
      phone_number: editForm.value.phone,
      role: editForm.value.role,
      is_active: editForm.value.active
    }
    await api.put(`/api/users/admin/users/${editForm.value.user_id}`, payload)
    await fetchUsers()
    editing.value = false
  } catch (error) {
    alert('Failed to update user: ' + (error?.response?.data?.detail || error.message))
  }
}

const deleteUser = async (user) => {
  if (!confirm(`Are you sure you want to delete ${user.name}?`)) return
  
  try {
    const api = (await import('@/api/client')).default
    await api.delete(`/api/users/admin/users/${user.user_id}`)
    await fetchUsers()
  } catch (error) {
    alert('Failed to delete user: ' + (error?.response?.data?.detail || error.message))
  }
}

const toggleActive = async (user) => {
  if (user.role === 'admin') {
    alert('Cannot deactivate admin users')
    return
  }

  try {
    const api = (await import('@/api/client')).default
    await api.put(`/api/users/admin/users/${user.user_id}/status`, {
      is_active: !user.active
    })
    user.active = !user.active
  } catch (error) {
    alert('Failed to update status: ' + (error?.response?.data?.detail || error.message))
  }
}

// Modal controls
const openAddUser = () => {
  newUser.value = {
    full_name: '',
    email: '',
    role: 'doctor',
    phone_number: '',
    is_active: true,
    password: '',
    license_number: '',
    hospital_id: '',
    pharmacy_license: ''
  }
  showAdd.value = true
}

const closeAdd = () => {
  showAdd.value = false
}

const openEdit = (user) => {
  editForm.value = {
    user_id: user.user_id,
    name: user.name,
    email: user.email,
    role: user.role,
    phone: user.phone,
    active: user.active
  }
  editing.value = true
}

const closeEdit = () => {
  editing.value = false
}

const viewUser = (user) => {
  viewingUser.value = { ...user }
  viewing.value = true
}

const closeView = () => {
  viewing.value = false
  viewingUser.value = null
}

// Pagination controls
const prevPage = () => {
  if (page.value > 1) page.value--
}

const nextPage = () => {
  if (page.value < totalPages.value) page.value++
}

const onPerPageChange = () => {
  page.value = 1
}

// Utility functions
const roleClass = (role) => {
  const classes = {
    admin: 'bg-purple-100 text-purple-800',
    doctor: 'bg-blue-100 text-blue-800',
    patient: 'bg-green-100 text-green-800',
    pharmacy: 'bg-orange-100 text-orange-800'
  }
  return `px-2 py-1 rounded-full text-xs font-semibold ${classes[role] || ''}`
}

const capitalize = (str) => str.charAt(0).toUpperCase() + str.slice(1)

// Initialize
onMounted(() => {
  fetchUsers()
})
</script>

<template>
  <div class="space-y-6">
    <div class="flex justify-between items-center">
      <div>
        <h1 class="text-3xl font-bold">User Management</h1>
        <p class="text-gray-600 mt-2">Manage all system users and permissions</p>
      </div>
      <button @click="openAddUser" class="btn-primary">Add New User</button>
    </div>

    <!-- Search and Filter -->
    <div class="card flex gap-4">
      <input 
        v-model="q" 
        type="text" 
        placeholder="Search users..." 
        class="input-field flex-1" 
      />
      <select 
        v-model="roleFilter" 
        class="input-field w-40"
      >
        <option value="">All Roles</option>
        <option value="doctor">Doctor</option>
        <option value="patient">Patient</option>
        <option value="pharmacy">Pharmacy</option>
        <option value="admin">Admin</option>
      </select>
      <select 
        v-model="statusFilter" 
        class="input-field w-40"
      >
        <option value="">All Status</option>
        <option value="active">Active</option>
        <option value="inactive">Inactive</option>
      </select>
    </div>

    <!-- Users Table -->
    <div class="card overflow-x-auto">
      <table class="w-full">
        <thead>
          <tr class="border-b border-gray-200">
            <th class="text-left py-3 px-4 font-semibold text-gray-700">User</th>
            <th class="text-left py-3 px-4 font-semibold text-gray-700">Email</th>
            <th class="text-left py-3 px-4 font-semibold text-gray-700">Role</th>
            <th class="text-left py-3 px-4 font-semibold text-gray-700">Status</th>
            <th class="text-left py-3 px-4 font-semibold text-gray-700">Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr 
            v-for="user in pagedUsers" 
            :key="user.user_id" 
            class="border-b border-gray-100 hover:bg-gray-50"
          >
            <td class="py-4 px-4">
              <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-full bg-gradient-to-br from-primary to-secondary flex items-center justify-center text-white font-bold">
                  {{ user.name?.charAt(0).toUpperCase() }}
                </div>
                <p class="font-semibold">{{ user.name }}</p>
              </div>
            </td>
            <td class="py-4 px-4 text-sm text-gray-600">{{ user.email }}</td>
            <td class="py-4 px-4">
              <span :class="roleClass(user.role)">
                {{ capitalize(user.role) }}
              </span>
            </td>
            <td class="py-4 px-4">
              <label 
                class="flex items-center gap-2" 
                :title="user.role === 'admin' ? 'Cannot change status for admin users' : ''"
              >
                <input 
                  type="checkbox" 
                  :checked="user.active"
                  @change="toggleActive(user)"
                  class="w-4 h-4 rounded border-gray-300" 
                  :disabled="user.role === 'admin'" 
                />
                <span 
                  class="text-sm"
                  :class="user.active ? 'text-green-600' : 'text-gray-600'"
                >
                  {{ user.active ? 'Active' : 'Inactive' }}
                </span>
              </label>
            </td>
            <td class="py-4 px-4">
              <div class="flex gap-2">
                <button 
                  @click="viewUser(user)" 
                  class="text-gray-700 hover:underline text-sm"
                >
                  View
                </button>
                <button 
                  @click="openEdit(user)" 
                  class="text-primary hover:underline text-sm font-semibold"
                >
                  Edit
                </button>
                <button 
                  @click="deleteUser(user)" 
                  class="text-red-600 hover:underline text-sm"
                >
                  Delete
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Pagination -->
    <div class="flex justify-between items-center mt-4">
      <p class="text-sm text-gray-600">Showing {{ pageStart }} to {{ pageEnd }} of {{ visibleTotal }} users</p>
      <div class="flex gap-2 items-center">
        <label class="text-sm">Per page</label>
        <select v-model="perPage" class="input-field w-20" @change="onPerPageChange">
          <option :value="5">5</option>
          <option :value="10">10</option>
          <option :value="20">20</option>
        </select>
        <button @click="prevPage" :disabled="page===1" class="px-3 py-1 border border-gray-300 rounded-lg text-sm">Previous</button>
        <button @click="nextPage" :disabled="page>=totalPages.value" class="px-3 py-1 border border-gray-300 rounded-lg text-sm">Next</button>
      </div>
    </div>

    <!-- Edit Modal -->
    <div v-if="editing" class="fixed inset-0 bg-black/40 flex items-start justify-center z-50 pt-24">
      <div class="bg-white rounded-lg shadow-lg w-[540px] p-6">
        <h3 class="text-lg font-semibold mb-4">Edit User</h3>
        <div class="space-y-3">
          <div>
            <label class="text-sm">Full name</label>
            <input v-model="editForm.name" class="input-field w-full" />
          </div>
          <div>
            <label class="text-sm">Email</label>
            <input v-model="editForm.email" class="input-field w-full" disabled />
          </div>
          <div class="flex gap-3">
            <div class="flex-1">
              <label class="text-sm">Role</label>
              <select v-model="editForm.role" class="input-field w-full">
                <option value="admin">Admin</option>
                <option value="doctor">Doctor</option>
                <option value="patient">Patient</option>
                <option value="pharmacy">Pharmacy</option>
              </select>
            </div>
            <div class="w-40">
              <label class="text-sm">Active</label>
              <input type="checkbox" v-model="editForm.active" class="ml-2" />
            </div>
          </div>
          <div>
            <label class="text-sm">Phone</label>
            <input v-model="editForm.phone" class="input-field w-full" />
          </div>
        </div>
        <div class="flex justify-end gap-2 mt-4">
          <button @click="closeEdit" class="btn-outline">Cancel</button>
          <button @click="saveEdit" class="btn-primary">Save</button>
        </div>
      </div>
    </div>

    <!-- Add User Modal -->
    <div v-if="showAdd" class="fixed inset-0 bg-black/40 flex items-start justify-center z-50 pt-24">
      <div class="bg-white rounded-lg shadow-lg w-[540px] p-6">
        <h3 class="text-lg font-semibold mb-4">Add New User</h3>
        <div class="space-y-3">
          <div>
            <label class="text-sm">Full name</label>
            <input v-model="newUser.full_name" class="input-field w-full" />
          </div>
          <div>
            <label class="text-sm">Email</label>
            <input v-model="newUser.email" class="input-field w-full" />
          </div>
          <div class="flex gap-3">
            <div class="flex-1">
              <label class="text-sm">Role</label>
              <select v-model="newUser.role" class="input-field w-full">
                <option value="admin">Admin</option>
                <option value="doctor">Doctor</option>
                <option value="patient">Patient</option>
                <option value="pharmacy">Pharmacy</option>
              </select>
            </div>
            <div class="w-40">
              <label class="text-sm">Active</label>
              <input type="checkbox" v-model="newUser.is_active" class="ml-2" />
            </div>
          </div>
          <div v-if="newUser.role === 'doctor'" class="space-y-3">
            <div>
              <label class="text-sm">License Number</label>
              <input v-model="newUser.license_number" class="input-field w-full" placeholder="Example: DOC-LIC-1001" />
            </div>
            <div>
              <label class="text-sm">Hospital ID</label>
              <select v-model="newUser.hospital_id" class="input-field w-full">
                <option value="">Select hospital (example: h1)</option>
                <option v-for="h in validHospitalIds" :key="h" :value="h">{{ h }} — (example)</option>
              </select>
              <p class="text-xs text-gray-500">Use one of: {{ validHospitalIds.join(', ') }}</p>
            </div>
          </div>
          <div v-if="newUser.role === 'pharmacy'" class="space-y-3">
            <div>
              <label class="text-sm">Pharmacy License</label>
              <input v-model="newUser.pharmacy_license" class="input-field w-full" placeholder="Example: PHAR-LIC-2001" />
            </div>
          </div>
          <div>
            <label class="text-sm">Phone</label>
            <input v-model="newUser.phone_number" class="input-field w-full" />
          </div>
          <div>
            <label class="text-sm">Password</label>
            <input v-model="newUser.password" type="password" class="input-field w-full" />
          </div>
        </div>
        <div class="flex justify-end gap-2 mt-4">
          <button @click="closeAdd" class="btn-outline">Cancel</button>
          <button @click="createUser" class="btn-primary">Create</button>
        </div>
      </div>
    </div>

    <!-- View User Modal -->
    <div v-if="viewing" class="fixed inset-0 bg-black/40 flex items-start justify-center z-50 pt-24">
      <div class="bg-white rounded-lg shadow-lg w-[540px] p-6">
        <h3 class="text-lg font-semibold mb-4">User Details</h3>
        <div class="space-y-3 text-sm text-gray-700">
          <p><strong>Name:</strong> {{ viewingUser.full_name || viewingUser.name }}</p>
          <p><strong>Email:</strong> {{ viewingUser.email }}</p>
          <p><strong>Role:</strong> {{ capitalize(viewingUser.role) }}</p>
          <p><strong>Status:</strong> <span :class="viewingUser.active ? 'text-green-600' : 'text-gray-600'">{{ viewingUser.active ? 'Active' : 'Inactive' }}</span></p>
          <p><strong>Phone:</strong> {{ viewingUser.phone || viewingUser.phone_number || '-' }}</p>
          <p><strong>User ID:</strong> {{ viewingUser.user_id || '-' }}</p>
          <p><strong>Created:</strong> {{ viewingUser.created_at || '-' }}</p>
        </div>
        <div class="flex justify-end gap-2 mt-4">
          <button @click="closeView" class="btn-outline">Close</button>
        </div>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

const q = ref('')
const roleFilter = ref('')
const statusFilter = ref('')

const users = ref([])
const loading = ref(false)

const totalUsers = ref(0)
const perPage = ref(10)

const fetchUsers = async () => {
  loading.value = true
  try {
    const api = (await import('@/api/client')).default
    const params = { page: page.value, per_page: perPage.value }
    if (roleFilter.value) params.role = roleFilter.value
    if (statusFilter.value) params.status = statusFilter.value
    if (q.value) params.q = q.value
    const res = await api.get('/api/users/admin/users', { params })
    const payload = res.data || { items: [], total: 0 }
    users.value = (payload.items || []).map(u => ({
      user_id: u.user_id || u.id || u.userId,
      name: u.full_name || u.fullName || u.name || '',
      email: u.email,
      role: u.role,
      active: u.is_active ?? u.active ?? true,
      phone: u.phone_number || u.phone || ''
    }))
    totalUsers.value = payload.total || (users.value.length)
  } catch (e) {
    users.value = []
    totalUsers.value = 0
  } finally {
    loading.value = false
  }
}

const page = ref(1)

const filtered = computed(() => users.value.filter(u => {
  if (roleFilter.value && u.role !== roleFilter.value) return false
  if (statusFilter.value) {
    const wantActive = statusFilter.value === 'active'
    if ((u.active || false) !== wantActive) return false
  }
  if (q.value) {
    const s = q.value.toLowerCase()
    return u.name.toLowerCase().includes(s) || u.email.toLowerCase().includes(s)
  }
  return true
}))

const totalPages = computed(() => Math.max(1, Math.ceil(filtered.value.length / perPage.value)))
const pagedUsers = computed(() => {
  const start = (page.value - 1) * perPage.value
  return filtered.value.slice(start, start + perPage.value)
})
const pageStart = computed(() => filtered.value.length ? ((page.value-1)*perPage.value) + 1 : 0)
const pageEnd = computed(() => Math.min(filtered.value.length, page.value*perPage.value))
const visibleTotal = computed(() => filtered.value.length)

const prevPage = () => { if (page.value>1) { page.value--; fetchUsers(); } }
const nextPage = () => { if (page.value<totalPages.value) { page.value++; fetchUsers(); } }

const onPerPageChange = () => { page.value = 1; fetchUsers() }

const capitalize = (s) => s ? s.charAt(0).toUpperCase()+s.slice(1) : ''
const roleClass = (role) => ({
  doctor: 'bg-blue-100 text-blue-700 px-3 py-1 rounded-full text-xs font-semibold',
  patient: 'bg-green-100 text-green-700 px-3 py-1 rounded-full text-xs font-semibold',
  pharmacy: 'bg-orange-100 text-orange-700 px-3 py-1 rounded-full text-xs font-semibold',
  admin: 'bg-red-100 text-red-700 px-3 py-1 rounded-full text-xs font-semibold'
}[role] || 'bg-gray-100 text-gray-700 px-3 py-1 rounded-full text-xs font-semibold')

const addUser = () => { router.push('/admin/users/new') }
// Edit modal state
const editing = ref(false)
const editForm = ref({ user_id: '', name: '', email: '', role: '', phone: '', active: true })

// Add user modal and view modal
const showAdd = ref(false)
const viewing = ref(false)
const viewingUser = ref(null)
const newUser = ref({ full_name: '', email: '', role: 'doctor', phone_number: '', is_active: true, password: '' })

const openAddUser = () => {
  newUser.value = { full_name: '', email: '', role: 'doctor', phone_number: '', is_active: true, password: '' }
  showAdd.value = true
}
const closeAdd = () => { showAdd.value = false }

const viewUser = (user) => {
  viewingUser.value = { ...user }
  viewing.value = true
}
const closeView = () => { viewing.value = false; viewingUser.value = null }

const createUser = async () => {
  try {
    const api = (await import('@/api/client')).default
    // Use register endpoint to create proper user and related records
    const payload = {
      email: newUser.value.email,
      password: newUser.value.password,
      full_name: newUser.value.full_name,
      phone_number: newUser.value.phone_number,
      role: newUser.value.role
    }
    // validation for role-specific fields
    if (newUser.value.role === 'doctor') {
      if (!newUser.value.license_number) return alert('Please provide license number for doctor')
      if (!newUser.value.hospital_id) return alert('Please select hospital ID for doctor')
    }
    if (newUser.value.role === 'pharmacy') {
      if (!newUser.value.pharmacy_license) return alert('Please provide pharmacy license')
    }

    const res = await api.post('/api/auth/register', payload)
    // refresh list
    // attempt to patch extra fields (non-blocking)
    try {
      const patchBody = {}
      if (newUser.value.role === 'doctor') {
        patchBody.license_number = newUser.value.license_number
        patchBody.hospital_id = newUser.value.hospital_id
      }
      if (newUser.value.role === 'pharmacy') {
        patchBody.pharmacy_name = newUser.value.full_name || newUser.value.email
        patchBody.license_number = newUser.value.pharmacy_license
      }
      if (Object.keys(patchBody).length) {
        await api.post('/api/users/me/extra', patchBody).catch(() => {})
      }
    } catch (e) {}

    await fetchUsers()
    showAdd.value = false
    // optionally show a success toast
  } catch (e) {
    alert(e?.response?.data?.detail || 'Failed to create user')
  }
}

const openEdit = (user) => {
  editForm.value = { ...user }
  editing.value = true
}

const closeEdit = () => { editing.value = false }

const saveEdit = async () => {
  try {
    const api = (await import('@/api/client')).default
    const payload = {
      full_name: editForm.value.name,
      phone_number: editForm.value.phone,
      role: editForm.value.role,
      is_active: editForm.value.active
    }
    await api.put(`/api/users/admin/users/${encodeURIComponent(editForm.value.user_id)}`, payload)
    // update local list
    const idx = users.value.findIndex(u => u.user_id === editForm.value.user_id)
    if (idx !== -1) users.value[idx] = { ...users.value[idx], ...editForm.value }
    editing.value = false
  } catch (e) {
    alert('Failed to save user: ' + (e?.response?.data?.detail || e.message))
  }
}

const editUser = (user) => openEdit(user)
const deleteUser = async (user) => {
  if (!confirm('Delete ' + user.name + '?')) return
  try {
    const api = (await import('@/api/client')).default
    // try delete endpoint if present
    await api.delete(`/api/users/admin/users/${encodeURIComponent(user.user_id)}`)
    const idx = users.value.findIndex(u => u.user_id === user.user_id)
    if (idx !== -1) users.value.splice(idx, 1)
  } catch (e) {
    // fallback: remove locally
    const idx = users.value.findIndex(u => u.user_id === user.user_id)
    if (idx !== -1) users.value.splice(idx, 1)
  }
}

const toggleActive = async (user) => {
  if (user.role === 'admin') {
    alert('Admin accounts cannot be deactivated')
    return
  }
  const newVal = !user.active
  try {
    const api = (await import('@/api/client')).default
    await api.put(`/api/users/admin/users/${encodeURIComponent(user.user_id)}`, { is_active: newVal })
    user.active = newVal
  } catch (e) {
    user.active = !newVal // revert on error
    alert('Failed to update status: ' + (e?.response?.data?.detail || e?.message))
  }
}

import { onMounted, onBeforeUnmount } from 'vue'
onMounted(() => fetchUsers())



// keep page within bounds when filters or list changes
import { watch } from 'vue'
watch([() => q.value, () => roleFilter.value, () => statusFilter.value, () => users.value.length], () => {
  const tp = totalPages.value
  if (page.value > tp) page.value = tp
  if (page.value < 1) page.value = 1
})

// trigger server fetch when paging or filters change
watch([() => page.value, () => perPage.value, () => roleFilter.value, () => statusFilter.value, () => q.value], () => {
  fetchUsers()
})

// Export needed methods and refs for template
const exposed = {
  users,
  q,
  roleFilter,
  statusFilter,
  page,
  perPage,
  pageStart,
  pageEnd,
  visibleTotal,
  totalPages,
  pagedUsers,
  showAdd,
  editing,
  editForm,
  viewing,
  viewingUser,
  newUser,
  validHospitalIds,
  openAddUser,
  closeAdd,
  createUser,
  viewUser,
  closeView,
  editUser,
  deleteUser,
  openEdit,
  closeEdit,
  saveEdit,
  toggleActive,
  onPerPageChange,
  prevPage,
  nextPage,
  roleClass,
  capitalize
}

defineExpose(exposed)
</script>
