<template>
  <div class="space-y-6">
    <div class="flex justify-between items-center">
      <div>
        <h1 class="text-3xl font-bold">Pharmacy Management</h1>
        <p class="text-gray-600 mt-2">Manage pharmacy registrations and operations</p>
      </div>
      <button @click="registerPharmacy" class="btn-primary">Register Pharmacy</button>
    </div>
    
    <!-- Edit / View Modal -->
    <div v-if="editing" class="fixed inset-0 bg-black/40 flex items-start justify-center z-50 pt-24">
      <div class="bg-white rounded-lg shadow-lg w-[640px] p-6">
        <h3 class="text-lg font-semibold mb-4">{{ viewingOnly ? 'Pharmacy Details' : 'Edit Pharmacy' }}</h3>
        <div class="space-y-3">
          <div>
            <label class="text-sm">Pharmacy Name</label>
            <input :disabled="viewingOnly" v-model="editForm.pharmacy_name" class="input-field w-full" />
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
              <label class="text-sm">Delivery</label>
              <input :disabled="viewingOnly" type="checkbox" v-model="editForm.delivery_available" class="ml-2" />
            </div>
          </div>
          <div>
            <label class="text-sm">License Number</label>
            <input :disabled="viewingOnly" v-model="editForm.license_number" class="input-field w-full" />
          </div>
        </div>
        <div class="flex justify-end gap-2 mt-4">
          <button @click="closeEdit" class="btn-outline">Close</button>
          <button v-if="!viewingOnly" @click="savePharmacy" class="btn-primary">Save</button>
        </div>
      </div>
    </div>

    <!-- Pharmacies Grid -->
    <div class="grid md:grid-cols-2 gap-6">
      <div v-for="p in pharmacies" :key="p.pharmacy_id" class="card">
        <div class="flex justify-between items-start mb-4">
          <div>
            <h3 class="text-lg font-semibold">{{ p.pharmacy_name }}</h3>
            <p class="text-sm text-gray-600">License: {{ p.license_number }}</p>
          </div>
          <span class="px-3 py-1 rounded-full text-xs font-semibold" :class="p.delivery_available ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-600'">{{ p.delivery_available ? 'Delivery' : 'No Delivery' }}</span>
        </div>
        <div class="space-y-2 text-sm text-gray-600 mb-4">
          <p>📍 {{ p.address }}</p>
          <p>📞 {{ p.contact_number || '-' }}</p>
          <p>� Inventory: {{ p.inventory_count || '-' }}</p>
        </div>
        <div class="flex gap-2 pt-4 border-t border-gray-200">
          <button @click="openEdit(p)" class="flex-1 btn-outline text-sm">Edit</button>
          <button @click="viewDetails(p)" class="flex-1 btn-outline text-sm">View Details</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const pharmacies = ref([])
const loading = ref(false)

const fetchPharmacies = async () => {
  loading.value = true
  try {
    const api = (await import('@/api/client')).default
    const res = await api.get('/api/pharmacy/admin/list')
    pharmacies.value = res.data || []
  } catch (e) {
    pharmacies.value = []
  } finally {
    loading.value = false
  }
}

const editing = ref(false)
const viewingOnly = ref(false)
const editForm = ref({ pharmacy_id: '', pharmacy_name: '', address: '', license_number: '', delivery_available: false, contact_number: '' })

const openEdit = (p) => {
  editForm.value = { ...p }
  editing.value = true
  viewingOnly.value = false
}

const viewDetails = (p) => {
  editForm.value = { ...p }
  editing.value = true
  viewingOnly.value = true
}

const closeEdit = () => { editing.value = false }

const savePharmacy = async () => {
  try {
    const api = (await import('@/api/client')).default
    const payload = {
      pharmacy_name: editForm.value.pharmacy_name,
      address: editForm.value.address,
      license_number: editForm.value.license_number,
      delivery_available: !!editForm.value.delivery_available,
      contact_number: editForm.value.contact_number
    }
    await api.put(`/api/pharmacy/admin/${encodeURIComponent(editForm.value.pharmacy_id)}`, payload)
    await fetchPharmacies()
    editing.value = false
  } catch (e) {
    alert(e?.response?.data?.detail || 'Failed to save pharmacy')
  }
}

const registerPharmacy = () => { router.push('/register-pharmacy') }

onMounted(() => fetchPharmacies())
</script>
