<script setup>
import UserProfile from '../components/UserProfile.vue';
import LoginPage from '../components/LoginPage.vue';
import sessionApi from '../services/sessionApi.js';
import { computed, watch } from 'vue';
import { useSessionStore } from '../stores/session';

const sessionStore = useSessionStore();
const isAuthenticated = computed(() => sessionApi.isAuthenticated());

watch(() => sessionStore.isConnected, () => {
    isAuthenticated.value = sessionApi.isAuthenticated();
});
</script>

<template>
  <div :class="['h-screen bg-blue-500 flex items-center justify-center', ]">
    <UserProfile v-if="isAuthenticated" />
    <LoginPage v-else />
  </div>
</template>