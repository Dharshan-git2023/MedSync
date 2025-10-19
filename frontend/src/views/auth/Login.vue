<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { Heart, Eye, EyeOff } from 'lucide-vue-next'

const router = useRouter()
const authStore = useAuthStore()

const email = ref('')
const password = ref('')
const passwordVisible = ref(false)
const loading = ref(false)
const error = ref('')

const handleLogin = async () => {
  loading.value = true
  error.value = ''
  
  try {
    await authStore.login(email.value, password.value)
    const role = authStore.user.role
    router.push(`/${role}/dashboard`)
  } catch (err) {
    // show explicit admin-block message when backend returns it
    const detail = err.response?.data?.detail
    if (detail && detail.toLowerCase().includes('blocked by')) {
      error.value = detail
    } else {
      error.value = detail || 'Login failed. Please check your credentials.'
    }
  } finally {
    loading.value = false
  }
}

const quickLogin = async (role) => {
  const demoCredentials = {
    doctor: { email: 'doctor1@medsync.com', password: 'doctor123' },
  patient: { email: 'patient1@medsync.com', password: 'patient123' },
    admin: { email: 'admin@demo.com', password: 'demo123' },
    pharmacy: { email: 'pharmacy@demo.com', password: 'demo123' }
  }
  
  const creds = demoCredentials[role]
  if (creds) {
    email.value = creds.email
    password.value = creds.password
    await handleLogin()
  }
}
</script>

<template>
  <div class="min-h-screen bg-gradient-to-br from-blue-50 to-cyan-50 flex items-center justify-center p-4">
    <div class="w-full max-w-md">
      <div class="card">
        <!-- Header -->
        <div class="text-center mb-8">
          <div class="w-16 h-16 bg-primary rounded-lg flex items-center justify-center mx-auto mb-4">
            <Heart class="w-8 h-8 text-white" />
          </div>
          <h1 class="text-3xl font-bold text-foreground">MedSync</h1>
          <p class="text-gray-600 mt-2">Healthcare Management System</p>
        </div>

        <!-- Form -->
        <form @submit.prevent="handleLogin" class="space-y-4">
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
          </div>

          <div class="flex items-center justify-between text-sm">
            <label class="flex items-center gap-2">
              <input type="checkbox" class="w-4 h-4 rounded border-gray-300" />
              <span class="text-gray-600">Remember me</span>
            </label>
            <a href="#" class="text-primary hover:underline">Forgot password?</a>
          </div>

          <button 
            type="submit" 
            class="w-full btn-primary py-3 font-semibold" 
            :disabled="loading"
          >
            {{ loading ? 'Logging in...' : 'Login' }}
          </button>
        </form>

        <!-- Divider -->
        <div class="relative my-6">
          <div class="absolute inset-0 flex items-center">
            <div class="w-full border-t border-gray-300"></div>
          </div>
          <div class="relative flex justify-center text-sm">
            <span class="px-2 bg-white text-gray-500">Or continue as</span>
          </div>
        </div>

        <!-- Quick Role Selection -->
        <div class="grid grid-cols-2 gap-3 mb-6">
          <button 
            type="button"
            @click="quickLogin('doctor')"
            class="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition text-sm font-medium"
          >
            Doctor Demo
          </button>
          <button 
            type="button"
            @click="quickLogin('patient')"
            class="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition text-sm font-medium"
          >
            Patient Demo
          </button>
        </div>

        <!-- Error Message -->
        <div v-if="error" class="p-4 bg-red-50 border border-red-200 rounded-lg text-red-700 text-sm">
          <p class="font-semibold">Login Failed</p>
          <p>{{ error }}</p>
        </div>

        <!-- Register Link -->
        <p class="text-center mt-6 text-gray-600">
          Don't have an account?
          <router-link to="/register" class="text-primary font-semibold hover:underline">
            Create one now
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
