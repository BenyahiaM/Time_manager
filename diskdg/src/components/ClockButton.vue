<script setup>
import { ref, onMounted } from 'vue';
import api from '../services/userApi'; // Adjust the path if necessary
import {
  ToastProvider,
  ToastRoot,
  ToastTitle,
  ToastViewport,
} from 'radix-vue';

const open = ref(false);
const timerRef = ref(0);
const isClockedIn = ref(false);
const toastMessage = ref('');
const loading = ref(false);

// Check the user's clock status on component load
async function checkClockStatus() {
  try {
    const response = await api.getUserClockStatus();
    if (response.status === 200) {
      isClockedIn.value = response.data.status;  // User is clocked in
    } else {
      isClockedIn.value = false; // User is clocked out
    }
  } catch (error) {
    console.error("Error fetching clock status:", error);
    toastMessage.value = 'Error fetching clock status';
    open.value = true;
  }
}

// Handle clock in/out using the createUserClock service
async function handleClick() {
  loading.value = true;
  const startTime = Date.now();
  const clockData = {
    clock: {
      time: new Date().toISOString(),
      status: !isClockedIn.value,
      user_id: 3 // Replace with the actual user ID if needed
    }
  };

  try {
    const response = await api.createUserClock(clockData);

    if (response.status === 201) {
      isClockedIn.value = !isClockedIn.value;
      toastMessage.value = isClockedIn.value ? 'Clocked In' : 'Clocked Out';
    } else {
      toastMessage.value = 'Error: Unable to clock in/out';
    }
  } catch (error) {
    toastMessage.value = 'Error: Unable to clock in/out';
    console.error(error);
  } finally {
    const elapsedTime = Date.now() - startTime;
    const remainingTime = 500 - elapsedTime;
    if (remainingTime > 0) {
      await new Promise(resolve => setTimeout(resolve, remainingTime));
    }
    loading.value = false;
    triggerToast();
  }
}

// Function to trigger toast notifications
function triggerToast() {
  open.value = false;
  window.clearTimeout(timerRef.value);
  timerRef.value = window.setTimeout(() => {
    open.value = true;
  }, 50);
}

// Check clock status when component is mounted
onMounted(checkClockStatus);
</script>

<template>
  <ToastProvider>
    <div class="translate-y-[2px]">
      <button
        :class="[
          'w-[15.4vh] h-[14vh] rounded-[100%] cursor-pointer',
          isClockedIn ? 'ring-5 ring-red-outline' : 'ring-5 ring-blue-outline'
        ]"
        @click="handleClick"
        :disabled="loading"
      >
        <span
          :class="[
            'rounded-[100%] absolute left-0 top-0 w-full h-full',
            isClockedIn ? 'bg-red-800' : 'bg-blue-800'
          ]"
        ></span>
        <span
          class="front rounded-[100%] absolute border left-0 top-0 w-full h-full flex items-center justify-center transform transition-transform duration-150 shadow-lg"
          :class="[
            { 'translate-y-[-15%]': !loading },
            isClockedIn ? 'border-red-800 bg-red-gradient' : 'border-blue-800 bg-blue-gradient'
          ]"
        ></span>
        <div
          class="flex w-full h-full justify-center items-center transform transition-transform duration-150"
          :class="{ 'translate-y-[-15%]': !loading }"
        >
          <span
            v-if="loading"
            class="btn-text font-bold relative leading-[0.5] text-[3vh]"
            :class="isClockedIn ? 'text-red-900' : 'text-blue-900'"
          >
            Clocking ...
          </span>
          <span
            v-else
            class="btn-text font-bold relative text-[3vh]"
            :class="isClockedIn ? 'text-red-900' : 'text-blue-900'"
          >
            {{ isClockedIn ? 'Clock Out' : 'Clock In' }}
          </span>
        </div>
      </button>
    </div>
    <ToastRoot
      v-model:open="open"
      class="bg-white rounded-md shadow-[hsl(206_22%_7%_/_35%)_0px_10px_38px_-10px,_hsl(206_22%_7%_/_20%)_0px_10px_20px_-15px] p-[15px] grid [grid-template-areas:_'title_action'_'description_action'] grid-cols-[auto_max-content] gap-x-[15px] items-center data-[state=open]:animate-slideIn data-[state=closed]:animate-hide data-[swipe=move]:translate-x-[var(--radix-toast-swipe-move-x)] data-[swipe=cancel]:translate-x-0 data-[swipe=cancel]:transition-[transform_200ms_ease-out] data-[swipe=end]:animate-swipeOut"
    >
      <ToastTitle
        class="[grid-area:_title] mb-[5px] font-medium text-slate12 text-[15px]"
      >
        {{ toastMessage }}
      </ToastTitle>
    </ToastRoot>
    <ToastViewport
      class="[--viewport-padding:_25px] transform translate-x-[0] translate-y-0 fixed bottom-0 right-0 flex flex-col p-[var(--viewport-padding)] gap-[10px] w-[390px] max-w-[100vw] m-0 list-none z-[2147483647] outline-none"
    />
  </ToastProvider>
</template>

<style scoped>
/* Add any custom styling if necessary */
</style>
