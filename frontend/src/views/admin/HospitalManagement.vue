<template>
  <div class="space-y-6">
    <div class="flex justify-between items-center">
      <div>
        <h1 class="text-3xl font-bold">Hospital Management</h1>
        <p class="text-gray-600 mt-2">Manage hospital networks and collaborations</p>
      </div>
  <button @click="registerHospital" class="btn-primary">Register Hospital</button>
    </div>

    <!-- Hospitals Grid -->
    <div class="grid md:grid-cols-2 gap-6">
      <div v-for="h in hospitals" :key="h.hospital_id" class="card">
        <div class="flex justify-between items-start mb-4">
          <div>
            <h3 class="text-lg font-semibold">{{ h.hospital_name }}</h3>
            <p class="text-sm text-gray-600">License: {{ h.license_number }}</p>
          </div>
          <span class="px-3 py-1 rounded-full text-xs font-semibold" :class="h.is_active ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-600'">{{ h.is_active ? 'Active' : 'Inactive' }}</span>
        </div>
        <div class="space-y-2 text-sm text-gray-600 mb-4">
          <p>📍 {{ h.address }}</p>
          <p>📞 {{ h.contact_number }}</p>
          <p>👥 {{ h.admin_user_id || '-' }}</p>
        </div>
        <div class="flex gap-2 pt-4 border-t border-gray-200">
          <button @click="openEdit(h)" class="flex-1 btn-outline text-sm">Edit</button>
          <button @click="viewDetails(h)" class="flex-1 btn-outline text-sm">View Details</button>
        </div>
      </div>
    </div>

    <!-- Edit / View Modal -->
    <div v-if="editing" class="fixed inset-0 bg-black/40 flex items-start justify-center z-50 pt-24">
      <div class="bg-white rounded-lg shadow-lg w-[640px] p-6">
        <h3 class="text-lg font-semibold mb-4">{{ modalTitle }}</h3>
        <div class="space-y-3">
          <div>
            <label class="text-sm">Hospital Name</label>
            <input :disabled="viewingOnly" v-model="editForm.hospital_name" class="input-field w-full" />
          </div>
          <div>
            <label class="text-sm">Address</label>
            <input :disabled="viewingOnly" v-model="editForm.address" class="input-field w-full" />
          </div>
          <div class="flex gap-3">
            <div class="flex-1">
              <label class="text-sm">Contact</label>
              <input :disabled="viewingOnly" v-model="editForm.contact_number" class="input-field w-full" />
            </div>
            <div class="w-40">
              <label class="text-sm">Active</label>
              <input :disabled="viewingOnly" type="checkbox" v-model="editForm.is_active" class="ml-2" />
            </div>
          </div>
        </div>
        <div class="flex justify-end gap-2 mt-4">
          <button @click="closeEdit" class="btn-outline">Close</button>
          <button v-if="!viewingOnly" @click="saveHospital" class="btn-primary">Save</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const hospitals = ref([])
const loading = ref(false)

const fetchHospitals = async () => {
  loading.value = true
  try {
    const api = (await import('@/api/client')).default
    const res = await api.get('/api/hospitals/admin/list')
    hospitals.value = res.data || []
  } catch (e) {
    hospitals.value = []
  } finally {
    loading.value = false
  }
}

const editing = ref(false)
const viewingOnly = ref(false)
const modalTitle = ref('')
const editForm = ref({ hospital_id: '', hospital_name: '', address: '', contact_number: '', license_number: '', is_active: false })

const openEdit = (h) => {
  editForm.value = { ...h }
  editing.value = true
  viewingOnly.value = false
  modalTitle.value = 'Edit Hospital'
}

const viewDetails = (h) => {
  editForm.value = { ...h }
  editing.value = true
  viewingOnly.value = true
  modalTitle.value = 'Hospital Details'
}

const closeEdit = () => { editing.value = false }

const saveHospital = async () => {
  try {
    const api = (await import('@/api/client')).default
    // send only allowed fields
    const payload = {
      hospital_name: editForm.value.hospital_name,
      address: editForm.value.address,
      contact_number: editForm.value.contact_number,
      license_number: editForm.value.license_number,
      is_active: !!editForm.value.is_active
    }
    await api.put(`/api/hospitals/admin/${encodeURIComponent(editForm.value.hospital_id)}`, payload)
    await fetchHospitals()
    editing.value = false
  } catch (e) {
    const msg = e?.response?.data?.detail || e?.message || 'Failed to save hospital'
    alert(msg)
  }
}

const registerHospital = () => {
  router.push('/register-hospital')
}

onMounted(() => fetchHospitals())
</script>
