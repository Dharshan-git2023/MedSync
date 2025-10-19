<template>
  <div class="min-h-screen bg-white">
    <div class="max-w-4xl mx-auto p-8">
      <h1 class="text-3xl font-bold mb-4">Contact & Feedback</h1>

      <div class="grid md:grid-cols-2 gap-8 mb-8">
        <div id="contact" class="card p-6">
          <h2 class="text-xl font-semibold mb-2">Contact Information</h2>
          <p class="text-gray-700">Email: <a href="mailto:info@medsync.com" class="text-primary">info@medsync.com</a></p>
          <p class="text-gray-700">Phone: +1 (555) 000-0000</p>
          <p class="text-gray-700">Support Hours: Mon–Fri 09:00–18:00</p>
        </div>

        <div class="card p-6">
          <h2 class="text-xl font-semibold mb-2">Send Feedback</h2>
          <form class="space-y-4" @submit.prevent="handleSubmit">
            <div>
              <label class="block text-sm font-medium mb-1">Your Name</label>
              <input v-model="name" class="input-field w-full" placeholder="Your full name" />
            </div>
            <div>
              <label class="block text-sm font-medium mb-1">Email</label>
              <input v-model="email" class="input-field w-full" placeholder="you@example.com" />
            </div>
            <div>
              <label class="block text-sm font-medium mb-1">Message</label>
              <textarea v-model="message" class="input-field w-full h-32" placeholder="How can we help?"></textarea>
            </div>
            <div>
              <button class="btn-primary" :disabled="loading" type="submit">
                <span v-if="loading">Sending...</span>
                <span v-else>Send Feedback</span>
              </button>
            </div>

            <div v-if="success" class="mt-2 p-3 rounded bg-green-50 text-green-700">Thank you — your message has been sent.</div>
            <div v-if="errorMsg" class="mt-2 p-3 rounded bg-red-50 text-red-700">{{ errorMsg }}</div>
          </form>
        </div>
      </div>

      <div id="terms" class="card p-6">
        <h2 class="text-2xl font-bold mb-4">Terms and Privacy</h2>
        <div class="prose max-w-none">
          <h3 id="terms-heading">🧾 Terms and Conditions</h3>
          <ol>
            <li><strong>Acceptance of Terms</strong> — By accessing or using MedSync, you agree to be bound by these Terms and Conditions. If you do not agree with any part of these terms, you may not access or use our services. These terms govern all users including patients, doctors, and healthcare providers.</li>
            <li><strong>Service Overview</strong> — MedSync provides an online platform for managing healthcare information, including patient records, e-prescriptions, and resource coordination. The platform is intended solely for informational and professional use and should not replace clinical judgment or emergency medical services.</li>
            <li><strong>User Responsibilities</strong> — Users are responsible for maintaining the confidentiality of their login credentials and ensuring that all information provided is accurate and up to date. Unauthorized access, data tampering, or misuse of the system is strictly prohibited and may result in account suspension or legal action.</li>
            <li><strong>Limitation of Liability</strong> — While MedSync strives to maintain data accuracy and system reliability, we do not guarantee uninterrupted or error-free service. MedSync is not liable for any indirect, incidental, or consequential damages resulting from your use or inability to use the platform.</li>
            <li><strong>Modification of Terms</strong> — MedSync reserves the right to update or modify these Terms and Conditions at any time without prior notice. Continued use of the platform after such changes constitutes your acceptance of the revised terms.</li>
          </ol>

          <h3 id="privacy">🔒 Privacy Policy</h3>
          <ol>
            <li><strong>Information We Collect</strong> — MedSync collects personal and medical information provided by users, such as name, contact details, medical history, and prescriptions. We may also gather system usage data to improve platform performance and security.</li>
            <li><strong>How We Use Your Information</strong> — Your data is used to facilitate healthcare coordination, manage prescriptions, and maintain secure patient records. Aggregated and anonymized data may be used for analytics and system optimization but will never identify individual users.</li>
            <li><strong>Data Protection and Security</strong> — We employ industry-standard encryption, access controls, and regular audits to protect user data from unauthorized access, alteration, or disclosure. However, no online system is completely secure, and users share information at their own risk.</li>
            <li><strong>Sharing of Information</strong> — MedSync does not sell or rent personal data. Information may be shared only with authorized healthcare providers or as required by law. Any third-party integrations are carefully vetted for compliance with data protection standards.</li>
            <li><strong>User Rights and Policy Updates</strong> — Users have the right to access, correct, or delete their personal information by contacting our support team. MedSync may update this Privacy Policy periodically, and changes will be communicated via the website or email notifications.</li>
          </ol>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const name = ref('')
const email = ref('')
const message = ref('')
const loading = ref(false)
const success = ref(false)
const errorMsg = ref('')

const handleSubmit = async () => {
  errorMsg.value = ''
  success.value = false

  if (!email.value || !message.value) {
    errorMsg.value = 'Please provide at least an email and a message.'
    return
  }

  loading.value = true
  try {
    const { default: api } = await import('@/api/client')
    await api.post('/api/feedback/', {
      name: name.value || null,
      email: email.value,
      phone: null,
      message: message.value
    })
    success.value = true
    name.value = ''
    email.value = ''
    message.value = ''
  } catch (e) {
    errorMsg.value = e.response?.data?.detail || 'Failed to send feedback. Please try again later.'
  } finally {
    loading.value = false
  }
}
</script>
