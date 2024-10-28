<script setup>
import axios from 'axios';
import { ref } from 'vue';
import { useSessionStore } from '../stores/session';
import {
  ToastProvider,
  ToastRoot,
  ToastTitle,
  ToastViewport,
} from 'radix-vue';
import sessionApi from '../services/sessionApi';

const form = ref({
  email: "",
  password: "",
});

const open = ref(false);
const toastMessage = ref('');
const loading = ref(false);
const timerRef = ref(0);
const sessionStore = useSessionStore();

async function handleSubmit() {
  loading.value = true;
  try {    
    const response = await sessionApi.login({
      "session": {
          "email": form.value.email,
          "password": form.value.password
        }
    });
    if (response.status === 200) {
      sessionApi.saveToken(response.data.jwt);
      toastMessage.value = 'Login successful';
      sessionStore.setConnected(true);
      getUserData();
    } else {
      toastMessage.value = 'Error: Unable to login';
    }
  } catch (err) {
    toastMessage.value = 'Error: Unable to login';
    console.log(err);
  } finally {
    loading.value = false;
  }

  open.value = false;
  window.clearTimeout(timerRef.value);
  timerRef.value = window.setTimeout(() => {
    open.value = true;
  }, 50);
};

async function getUserData() {
  try {
    const response = await axios.get('http://localhost:4000/api/user', {
      headers: {
        'Authorization': `Bearer ${localStorage.getItem('token')}`
      }
    });
    
    if (response.status === 200) {
      toastMessage.value = 'User data loaded';
    } else {
      toastMessage.value = 'Error: Unable to load user data';
    }
  } catch (err) {
    toastMessage.value = 'Error: Unable to load user data';
  }

  open.value = false;
  window.clearTimeout(timerRef.value);
  timerRef.value = window.setTimeout(() => {
    open.value = true;
  }, 50);
}
</script>

<template>
  <div class="container">
    <div class="login-card">
      <h1 class="title">Login</h1>
      <form @submit.prevent="handleSubmit" class="form">
        <!-- Email Input -->
        <label class="label" for="email">Email:</label>
        <input
          type="email"
          id="email"
          v-model="form.email"
          class="input"
          placeholder="Enter your email"
          :disabled="loading"
          required
        />

        <!-- Password Input -->
        <label class="label" for="password">Password:</label>
        <input
          type="password"
          id="password"
          v-model="form.password"
          class="input"
          placeholder="Enter your password"
          :disabled="loading"
          required
        />

        <!-- Submit Button -->
        <button class="btn-submit" type="submit" :disabled="loading">
          <span v-if="loading" class="loader"></span>
          <span v-else>Login</span>
        </button>
      </form>

      <!-- Toast Notification -->
      <ToastProvider>
        <ToastRoot
          v-model:open="open"
          class="toast-root"
        >
          <ToastTitle class="toast-title">
            {{ toastMessage }}
          </ToastTitle>
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

/* Login Card */
.login-card {
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

/* Button */
.btn-submit {
  display: flex;
  justify-content: center;
  align-items: center;
  width: 100%;
  background: #9013fe;
  color: white;
  padding: 12px;
  font-size: 1em;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  margin-top: 1.5em;
  transition: background 0.3s, transform 0.1s;
}

.btn-submit:hover {
  background: #7c10d8;
}

.btn-submit:active {
  transform: scale(0.98);
}

.btn-submit:disabled {
  background: #d1d1d1;
  cursor: not-allowed;
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
