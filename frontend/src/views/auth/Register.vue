<template>
  <div class="min-h-screen bg-gradient-to-br from-blue-50 to-cyan-50 flex items-center justify-center p-4">
    <div class="w-full max-w-md">
      <div class="card">
        <!-- Header -->
        <div class="text-center mb-8">
          <div class="w-16 h-16 bg-primary rounded-lg flex items-center justify-center mx-auto mb-4">
            <Heart class="w-8 h-8 text-white" />
          </div>
          <h1 class="text-3xl font-bold text-foreground">Create Account</h1>
          <p class="text-gray-600 mt-2">Join MedSync Healthcare Platform</p>
        </div>

        <!-- Form -->
        <form @submit.prevent="handleRegister" class="space-y-4">
          <div>
            <label class="block text-sm font-semibold text-foreground mb-2">
              {{ role === 'pharmacy' ? 'Pharmacy Name' : 'Full Name' }}
            </label>
            <input
              v-if="role !== 'pharmacy'"
              v-model="fullName"
              type="text"
              class="input-field"
              placeholder="John Doe"
              required
            />
            <input
              v-else
              v-model="pharmacyName"
              type="text"
              class="input-field"
              placeholder="Acme Pharmacy"
              required
            />
          </div>

          <div>
            <label class="block text-sm font-semibold text-foreground mb-2">Email Address</label>
            <input
              v-model="email"
              type="email"
              class="input-field"
              placeholder="your@email.com"
              required
            />
          </div>

          <div>
            <label class="block text-sm font-semibold text-foreground mb-2">Phone Number</label>
            <input
              v-model="phoneNumber"
              type="tel"
              class="input-field"
              placeholder="+1 (555) 000-0000"
            />
          </div>

          <div>
            <label class="block text-sm font-semibold text-foreground mb-2">Select Your Role</label>
            <select v-model="role" class="input-field" required>
              <option value="">Choose a role...</option>
              <option value="patient">Patient</option>
              <option value="doctor">Doctor</option>
              <option value="pharmacy">Pharmacy</option>
            </select>
          </div>

          <!-- Doctor-specific fields -->
          <div v-if="role === 'doctor'">
            <label class="block text-sm font-semibold text-foreground mb-2">License Number</label>
            <input v-model="licenseNumber" type="text" class="input-field" placeholder="Example: DOC-LIC-1001" required />

            <label class="block text-sm font-semibold text-foreground mt-4 mb-2">Hospital ID</label>
            <select v-model="hospitalId" class="input-field" required>
              <option value="">Select a hospital...</option>
              <option v-for="h in validHospitalIds" :key="h" :value="h">{{ h }} — (example)</option>
            </select>
            <p class="text-xs text-gray-500 mt-1">Pick the hospital you belong to (examples: {{ validHospitalIds.join(', ') }}).</p>
          </div>

          <!-- Pharmacy-specific fields -->
          <div v-if="role === 'pharmacy'">
            <label class="block text-sm font-semibold text-foreground mb-2">License Number</label>
            <input v-model="pharmacyLicense" type="text" class="input-field" placeholder="PHAR-LIC-2001" required />
          </div>

          <div>
            <label class="block text-sm font-semibold text-foreground mb-2">Password</label>
            <div class="relative">
              <input
                v-model="password"
                :type="passwordVisible ? 'text' : 'password'"
                class="input-field pr-12"
                placeholder="••••••••"
                required
              />
              <button
                type="button"
                class="absolute right-2 top-1/2 -translate-y-1/2 p-1 rounded hover:bg-gray-100 transition"
                @click="passwordVisible = !passwordVisible"
                :aria-label="passwordVisible ? 'Hide password' : 'Show password'"
              >
                <EyeOff v-if="passwordVisible" class="w-5 h-5 text-gray-600 transform transition-transform duration-150 hover:scale-110" />
                <Eye v-else class="w-5 h-5 text-gray-600 transform transition-transform duration-150 hover:scale-110" />
              </button>
            </div>
            <p class="text-xs text-gray-600 mt-1">At least 8 characters recommended</p>
          </div>

          <div>
            <label class="flex items-center gap-2">
              <input v-model="agreeTerms" type="checkbox" class="w-4 h-4 rounded border-gray-300" required />
              <span class="text-sm text-gray-600">
                I agree to the
                <router-link to="/feedback#terms" class="text-primary hover:underline">Terms of Service</router-link>
                and
                <router-link to="/feedback#privacy" class="text-primary hover:underline">Privacy Policy</router-link>
              </span>
            </label>
          </div>

          <button 
            type="submit" 
            class="w-full btn-primary py-3 font-semibold" 
            :disabled="loading || !agreeTerms"
          >
            {{ loading ? 'Creating account...' : 'Create Account' }}
          </button>
        </form>

        <!-- Error Message -->
        <div v-if="error" class="mt-4 p-4 bg-red-50 border border-red-200 rounded-lg text-red-700 text-sm">
          <p class="font-semibold">Registration Failed</p>
          <p>{{ error }}</p>
        </div>

        <!-- Login Link -->
        <p class="text-center mt-6 text-gray-600">
          Already have an account?
          <router-link to="/login" class="text-primary font-semibold hover:underline">
            Login here
          </router-link>
        </p>
      </div>

      <!-- Footer Link -->
      <div class="text-center mt-6">
        <router-link to="/" class="text-gray-600 hover:text-foreground transition">
          ← Back to Home
        </router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { Heart, Eye, EyeOff } from 'lucide-vue-next'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()

const fullName = ref('')
const pharmacyName = ref('')
const email = ref('')
const phoneNumber = ref('')
const role = ref('')
const password = ref('')
const passwordVisible = ref(false)
const agreeTerms = ref(false)
const loading = ref(false)
const error = ref('')

// Extra fields for doctor / pharmacy
const licenseNumber = ref('')
const pharmacyLicense = ref('')
const hospitalId = ref('')

// In lieu of an API call here, derive valid hospital IDs from the sample data in the project.
// Keep this list small and stable so validation is predictable during local/dev runs.
const validHospitalIds = ['h1', 'h2']

// Only these roles are allowed to self-register from the frontend.
const allowedRoles = ['patient', 'doctor', 'pharmacy']
const initialRole = Array.isArray(route.query.role) ? route.query.role[0] : route.query.role
role.value = allowedRoles.includes(String(initialRole)) ? String(initialRole) : ''

const handleRegister = async () => {
  loading.value = true
  error.value = ''
  
    try {
    // Validate role on the client to prevent self-registration as 'admin'.
    if (!allowedRoles.includes(role.value)) {
      throw new Error('Please select a valid role to register (Patient, Doctor, or Pharmacy).')
    }

      // Role-specific validation
      if (role.value === 'doctor') {
        if (!licenseNumber.value) throw new Error('Please provide your medical license number.')
        if (!hospitalId.value) throw new Error('Please provide your hospital ID.')
        if (!validHospitalIds.includes(hospitalId.value)) throw new Error('Hospital ID is invalid. Please use one of: ' + validHospitalIds.join(', '))
      }

      if (role.value === 'pharmacy') {
        if (!pharmacyName.value) throw new Error('Please provide your pharmacy name.')
        if (!pharmacyLicense.value) throw new Error('Please provide your pharmacy license number.')
      }
    // Build payload and include role-specific fields
    const payloadFullName = role.value === 'pharmacy' ? pharmacyName.value : fullName.value

    // Note: authStore.register accepts (email, password, fullName, phoneNumber, role)
    // We'll pass the base fields and then call the backend endpoints directly with extras if needed.
    await authStore.register(email.value, password.value, payloadFullName, phoneNumber.value, role.value)

    // If there are extra role-specific fields, attempt to patch the newly created user record via a simple endpoint
    // This keeps backward compatibility: if backend doesn't accept extra fields during register, we send them separately.
    try {
      const { default: api } = await import('@/api/client')
      const patchBody = {}
      if (role.value === 'doctor') {
        patchBody.license_number = licenseNumber.value
        patchBody.hospital_id = hospitalId.value
      }
      if (role.value === 'pharmacy') {
        patchBody.pharmacy_name = pharmacyName.value
        patchBody.license_number = pharmacyLicense.value
      }
      // Only attempt patch if we have fields to send
      if (Object.keys(patchBody).length) {
        await api.post('/api/users/me/extra', patchBody).catch(() => {})
      }
    } catch (e) {
      // ignore; this is optional and non-blocking for registration flow
    }
    router.push(`/${role.value}/dashboard`)
  } catch (err) {
    error.value = err.response?.data?.detail || 'Registration failed. Please try again.'
  } finally {
    loading.value = false
  }
}
</script>
