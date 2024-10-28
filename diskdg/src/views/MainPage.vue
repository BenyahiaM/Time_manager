<script setup>
import ClockButton from '../components/ClockButton.vue';
import { usePageStore } from '../stores/page';

const pageStore = usePageStore();

function handleClick(value) {
  pageStore.setPageRef(value);
}
</script>

<template>
  <div class="grid grid-cols-2 gap-4 w-screen h-screen">
    <div @click="handleClick('div1')" class="flex">
      <div class="w-full mt-12 ml-12 m-4 bg-gray-800 rounded-xl hover:scale-[102%] hover:-translate-x-[1%] hover:-translate-y-[1%] duration-300 shadow-[hsl(206_22%_7%_/_35%)_0px_10px_38px_-10px,_hsl(206_22%_7%_/_20%)_0px_10px_20px_-15px] relative">
        <img src="../img/blurry_stats.png" alt="Image 1" class="absolute top-0 left-0 w-full h-full object-cover rounded-xl" />
      </div>
    </div>
    
    <div @click="handleClick('div2')" class="flex">
      <div class="w-full mt-12 mr-12 m-4 bg-gray-800 rounded-xl hover:scale-[102%] hover:translate-x-[1%] hover:-translate-y-[1%] duration-300 shadow-[hsl(206_22%_7%_/_35%)_0px_10px_38px_-10px,_hsl(206_22%_7%_/_20%)_0px_10px_20px_-15px] relative">
        <img src="../img/profile.png" alt="Image 2" class="absolute top-0 left-0 w-full h-full object-cover rounded-xl" />
      </div>
    </div>
    
    <div @click="handleClick('div3')" class="flex">
      <div class="w-full mb-12 ml-12 m-4 bg-gray-800 rounded-xl hover:scale-[102%] hover:-translate-x-[1%] hover:translate-y-[1%] duration-300 shadow-[hsl(206_22%_7%_/_35%)_0px_10px_38px_-10px,_hsl(206_22%_7%_/_20%)_0px_10px_20px_-15px] relative">
        <img src="../img/calendar.png" alt="Image 3" class="absolute top-0 left-0 w-full h-full object-cover rounded-xl" />
      </div>
    </div>
    
    <div @click="handleClick('div4')" class="flex">
      <div class="w-full mb-12 mr-12 m-4 bg-gray-800 rounded-xl hover:scale-[102%] hover:translate-x-[1%] hover:translate-y-[1%] duration-300 shadow-[hsl(206_22%_7%_/_35%)_0px_10px_38px_-10px,_hsl(206_22%_7%_/_20%)_0px_10px_20px_-15px] relative">
        <img src="../img/teams_blurry.png" alt="Image 4" class="absolute top-0 left-0 w-full h-full object-cover rounded-xl" />
      </div>
    </div>

    <div class="absolute top-button-custom-top left-button-custom-left">
      <div class="rounded-full bg-gray-900 p-12">
        <ClockButton />
      </div>
    </div>
  </div>
</template>
