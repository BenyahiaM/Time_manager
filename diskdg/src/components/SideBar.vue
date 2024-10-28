<script setup>
import { ref, onMounted, computed } from 'vue';
import { usePageStore } from '../stores/page';
import { useSidebarStore } from '../stores/sidebar';
import api from '../services/userApi'; 

const pageStore = usePageStore();
const sidebarStore = useSidebarStore();

const username = ref('');
const email = ref('');

function handleLogoClick() {
  pageStore.setPageRef('');
}

const sidebarClasses = computed(() => {
  return sidebarStore.isDisplayed ? 'translate-x-0 delay-500' : '-translate-x-56 delay-0';
});

async function fetchUserProfile() {
  try {
    const response = await api.getUserProfile(); 
    console.log('User Profile Response:', response); 
    username.value = response.data.data.username; 
    email.value = response.data.data.email;
  } catch (error) {
    console.error('Error fetching user profile:', error);
  }
}



onMounted(() => {
  fetchUserProfile();
});
</script>

<template>
  <div :class="['bg-gray-800 h-screen w-56 fixed top-0 left-0 transition-transform duration-500 rounded-tr-3xl', sidebarClasses]">
    <img @click="handleLogoClick" src="../img/teamer_logo.svg" alt="Teamer Logo" class="w-full p-4 cursor-pointer hover:scale-105 duration-300" />
    <div class="absolute bottom-0 w-full p-4 text-center overflow-hidden">
      <h1 class="text-white text-lg truncate">{{ username }}</h1> 
      <h2 class="text-gray-400 text-base truncate">{{ email }}</h2>  
    </div>
  </div>
</template>

