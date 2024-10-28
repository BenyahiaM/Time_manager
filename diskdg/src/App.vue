<script setup>
  import { ref, watch, onMounted } from 'vue';
  import { useSessionStore } from './stores/session';
  import { usePageStore } from './stores/page';
  import { useSidebarStore } from './stores/sidebar';
  import MainPage from './views/MainPage.vue';
  import SideBar from './components/SideBar.vue';
  import ChartsPage from './views/ChartsPage.vue';
  import UserPage from './views/UserPage.vue';
  import PlanningPage from './views/PlanningPage.vue';
  import IncomingPage from './views/IncomingPage.vue';

  const token = ref(localStorage.getItem('token'));
  
  const redDiv = ref(null);
  const blueDiv = ref(null);
  const greenDiv = ref(null);
  const yellowDiv = ref(null);
  const mainPageDiv = ref(null);

  const sessionStore = useSessionStore();
  const pageStore = usePageStore();
  const sidebarStore = useSidebarStore();
  
  onMounted(() => {
    sidebarStore.setDisplay(pageStore.pageRef !== '');
    token.value = localStorage.getItem('token');
    if (!token.value) {
      blueDiv.value.scrollIntoView({ behavior: 'smooth' });
      sidebarStore.setDisplay(false);
    }
  });

  watch(() => sessionStore.isConnected, (isConnected) => {
    if (isConnected && mainPageDiv.value) {      
      mainPageDiv.value.scrollIntoView({ behavior: 'smooth' }); 
      token.value = localStorage.getItem('token');
    }
  });

  watch(() => pageStore.pageRef, (pageRef) => {    
      if (pageRef === 'div1' && redDiv.value) {
        redDiv.value.scrollIntoView({ behavior: 'smooth' });
        sidebarStore.setDisplay(true);
      } else if (pageRef === 'div2' && blueDiv.value) {
        blueDiv.value.scrollIntoView({ behavior: 'smooth' });
        sidebarStore.setDisplay(true);
      } else if (pageRef === 'div3' && greenDiv.value) {
        greenDiv.value.scrollIntoView({ behavior: 'smooth' });
        sidebarStore.setDisplay(true);
      } else if (pageRef === 'div4' && yellowDiv.value) {
        yellowDiv.value.scrollIntoView({ behavior: 'smooth' });
        sidebarStore.setDisplay(true);
      } else if (pageRef === '' && mainPageDiv.value) {
        mainPageDiv.value.scrollIntoView({ behavior: 'smooth' });
        sidebarStore.setDisplay(false);
      }
  });
</script>

<template>
  <SideBar />
  <div class="transition-transform duration-500 w-screen h-screen">
    <div ref="mainPageDiv"><MainPage /></div>
    <div ref="redDiv"><ChartsPage /></div>
    <div ref="blueDiv"><UserPage /></div>
    <div ref="greenDiv"><PlanningPage /></div>
    <div ref="yellowDiv"><IncomingPage /></div>
  </div>
</template>


