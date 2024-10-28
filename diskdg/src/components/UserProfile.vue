<script setup>
import axios from 'axios';
import { ref } from 'vue';
import {
  ToastProvider,
  ToastRoot,
  ToastTitle,
  ToastViewport,
} from 'radix-vue';

// State variables
const user = ref({
  username: '',
  email: '',
  address: ''
});
const editMode = ref(false);
const open = ref(false);
const toastMessage = ref('');
const loading = ref(false);

// Fetch user info from the server
async function fetchUserData() {
  loading.value = true;
  try {
    const response = await axios.get('http://localhost:4000/api/user', {
      headers: {
        'Authorization': `Bearer ${localStorage.getItem('token')}`
      }
    });
    if (response.status === 200) {
      user.value = response.data;
      toastMessage.value = 'User data loaded successfully';
    } else {
      toastMessage.value = 'Error loading user data';
    }
  } catch (error) {
    toastMessage.value = 'Error loading user data';
    console.error(error);
  } finally {
    loading.value = false;
    triggerToast();
  }
}

// Save updated user info
async function saveUserData() {
  loading.value = true;
  try {
    const response = await axios.put('http://localhost:4000/api/user', {
      username: user.value.username,
      email: user.value.email,
      address: user.value.address,
    }, {
      headers: {
        'Authorization': `Bearer ${localStorage.getItem('token')}`
      }
    });
    if (response.status === 200) {
      toastMessage.value = 'User data updated successfully';
      editMode.value = false;
    } else {
      toastMessage.value = 'Error updating user data';
    }
  } catch (error) {
    toastMessage.value = 'Error updating user data';
    console.error(error);
  } finally {
    loading.value = false;
    triggerToast();
  }
}

// Trigger toast notification
function triggerToast() {
  open.value = false;
  setTimeout(() => open.value = true, 50);
}
</script>

<template>
  <div class="container">
    <div class="profile-card">
      <h1 class="title">User Profile</h1>
      
      <!-- Display User Info -->
      <div v-if="!editMode">
        <p><strong>Username:</strong> {{ user.username }}</p>
        <p><strong>Email:</strong> {{ user.email }}</p>
        <p><strong>Address:</strong> {{ user.address }}</p>
        <button @click="editMode = true" class="btn-edit">Edit Profile</button>
      </div>

      <!-- Edit User Info Form -->
      <form v-else @submit.prevent="saveUserData" class="form">
        <label class="label" for="username">Username</label>
        <input
          type="text"
          id="username"
          v-model="user.username"
          class="input"
          required
          :disabled="loading"
        />

        <label class="label" for="email">Email</label>
        <input
          type="email"
          id="email"
          v-model="user.email"
          class="input"
          required
          :disabled="loading"
        />

        <label class="label" for="address">Address</label>
        <input
          type="text"
          id="address"
          v-model="user.address"
          class="input"
          required
          :disabled="loading"
        />

        <button type="submit" class="btn-save" :disabled="loading">
          <span v-if="loading" class="loader"></span>
          <span v-else>Save Changes</span>
        </button>
        <button type="button" class="btn-cancel" @click="editMode = false">
          Cancel
        </button>
      </form>

      <!-- Toast Notification -->
      <ToastProvider>
        <ToastRoot v-model:open="open" class="toast-root">
          <ToastTitle class="toast-title">{{ toastMessage }}</ToastTitle>
        </ToastRoot>
        <ToastViewport class="toast-viewport" />
      </ToastProvider>
    </div>
  </div>
</template>

<style scoped>
/* Container */
.container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: linear-gradient(135deg, #4a90e2, #9013fe);
  font-family: Arial, sans-serif;
  padding: 20px;
}

/* Profile Card */
.profile-card {
  background: #fff;
  padding: 30px 40px;
  border-radius: 12px;
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
  text-align: center;
  max-width: 400px;
  width: 100%;
}

/* Title */
.title {
  font-size: 1.8em;
  font-weight: bold;
  color: #333;
  margin-bottom: 1em;
}

/* Form Labels */
.label {
  display: block;
  text-align: left;
  font-size: 0.9em;
  color: #555;
  margin-top: 1em;
}

/* Input Fields */
.input {
  width: 100%;
  padding: 10px;
  margin-top: 0.5em;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 1em;
  color: #333;
  outline: none;
  transition: border-color 0.3s;
}

.input:focus {
  border-color: #9013fe;
}

/* Edit Button */
.btn-edit {
  background: #9013fe;
  color: white;
  padding: 10px 15px;
  font-size: 1em;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  margin-top: 1.5em;
  transition: background 0.3s;
}

.btn-edit:hover {
  background: #7c10d8;
}

/* Save and Cancel Buttons */
.btn-save, .btn-cancel {
  background: #9013fe;
  color: white;
  padding: 10px 15px;
  font-size: 1em;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  margin-top: 1.5em;
  transition: background 0.3s;
  width: 48%;
  display: inline-block;
}

.btn-cancel {
  background: #d1d1d1;
}

.btn-save:hover {
  background: #7c10d8;
}

/* Loader */
.loader {
  border: 3px solid #f3f3f3;
  border-top: 3px solid #9013fe;
  border-radius: 50%;
  width: 16px;
  height: 16px;
  animation: spin 0.6s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* Toast Notification */
.toast-root {
  background-color: #333;
  color: #fff;
  padding: 15px;
  border-radius: 8px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
  animation: fadeIn 0.3s ease-out;
}

.toast-title {
  font-size: 1em;
}

.toast-viewport {
  position: fixed;
  bottom: 20px;
  right: 20px;
  display: flex;
  flex-direction: column;
  gap: 10px;
  width: 300px;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}
</style>
