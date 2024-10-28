<template>
  <div class="flex flex-col items-center justify-center w-full max-w-md bg-white p-6 rounded shadow-lg">
    <h2 class="text-2xl font-semibold mb-4">User Profile</h2>
    
    <form @submit.prevent="updateProfile">
      <div class="mb-4">
        <label for="username" class="block text-gray-700 font-semibold">Username</label>
        <input
          type="text"
          id="username"
          v-model="form.username"
          class="w-full px-3 py-2 border border-gray-300 rounded"
        />
      </div>
      
      <div class="mb-4">
        <label for="email" class="block text-gray-700 font-semibold">Email</label>
        <input
          type="email"
          id="email"
          v-model="form.email"
          class="w-full px-3 py-2 border border-gray-300 rounded"
        />
      </div>
      
      <button
        type="submit"
        class="w-full bg-blue-500 text-white py-2 rounded hover:bg-blue-600 transition"
      >
        Save Changes
      </button>
      
      <div v-if="message" class="mt-4 text-green-500">{{ message }}</div>
      <div v-if="error" class="mt-4 text-red-500">{{ error }}</div>
    </form>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import UserApi from '../services/userApi.js';

const form = ref({
  username: '',
  email: '',
});

const message = ref(null);
const error = ref(null);

// Load user data on mount
onMounted(async () => {
  try {
    const user = await UserApi.getUserProfile();

  } catch (err) {
    error.value = 'Failed to load user data';
  }
});

// Update user profile
async function updateProfile() {
  try {
    message.value = null;
    error.value = null;
    const response = await UserApi.updateUserProfile({ user: { username: form.value.username, email: form.value.email } });
    message.value = 'Profile updated successfully!';
  } catch (err) {
    if (err.response && err.response.data && err.response.data.errors) {
      // Detailed error message from backend
      error.value = err.response.data.errors.join(', ');
    } else {
      // Generic error message
      error.value = 'Failed to update profile';
    }
    console.error(err);
  }
}
</script>
