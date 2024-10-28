<script setup>
  import { ref, onMounted, watch } from 'vue'
  import { useSessionStore } from '../stores/session';
  import sessionApi from '../services/sessionApi';
  import VueCal from 'vue-cal'
  import axios from 'axios';
  import 'vue-cal/dist/vuecal.css'

  const status = ref('');
  const events = ref([])
  const sessionStore = useSessionStore();

  const fetchDatas = async () => {
    if (sessionApi.isAuthenticated()) {
    try {
      const response = await axios.get('http://localhost:4000/api/user/workingtime', {
      headers: {
        'Authorization': `Bearer ${localStorage.getItem('token')}`
      }
    });
      if (response.status === 200) {
        status.value = 'Success';
        events.value = response.data.data.map(item => ({
          start: new Date(item.start),
          end: new Date(item.end),
        }));
      } else {
        status.value = 'Error';
      }
    } catch (error) {
      status.value = 'Error';
    }
    }
  }

  onMounted(() => {
    fetchDatas();
    window.addEventListener('load', fetchDatas);
  });
  
  watch(() => sessionStore.isConnected, (newVal) => {
    if (newVal) {
      fetchDatas();
    }
  });
</script>

<template>
  <div class="h-screen w-screendiv flex justify-center items-center ml-56 text-gray-600">
    <div v-if="status === ''">Loading...</div>
    <div v-else-if="status === 'Success'" class="h-full w-full text-white">
      <vue-cal
            hide-view-selector
            view="week"
            :time-step="60"
            :hide-weekdays="[7]"
            :events="events"
            :min-event-width=100
          >
      </vue-cal>
    </div>
    <div v-else-if="status === 'Error'">Error loading data</div>
  </div>
</template>

<style>
    .vuecal__event.in {background-color: rgba(60, 130, 246, 0.9);border: 1px solid rgb(60, 150, 255);}
    .vuecal__event.out {background-color: rgba(239, 68, 68, 0.9);border: 1px solid rgb(255, 88, 88);}
</style>