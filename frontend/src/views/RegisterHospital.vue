<template>
  <div class="max-w-2xl mx-auto py-12">
    <h1 class="text-2xl font-bold mb-4">Register Hospital</h1>
    <div class="card p-6">
      <div class="space-y-4">
        <div>
          <label class="text-sm">Hospital Name</label>
          <input v-model="form.hospital_name" class="input-field w-full" />
        </div>
        <div>
          <label class="text-sm">Address</label>
          <input v-model="form.address" class="input-field w-full" />
        </div>
        <div>
          <label class="text-sm">Contact Number</label>
          <input v-model="form.contact_number" class="input-field w-full" />
        </div>
        <div>
          <label class="text-sm">License Number</label>
          <input v-model="form.license_number" class="input-field w-full" />
        </div>
        <div class="flex justify-end">
          <button @click="submit" class="btn-primary">Register</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const form = ref({ hospital_name: '', address: '', contact_number: '', license_number: '' })

const submit = async () => {
  try {
    const api = (await import('@/api/client')).default
    await api.post('/api/hospitals/', form.value)
    alert('Registration submitted — your hospital will be reviewed by admin')
    router.push('/')
  } catch (e) {
    alert('Failed to register hospital')
  }
}
</script>
