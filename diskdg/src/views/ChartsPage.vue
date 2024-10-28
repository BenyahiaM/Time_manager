<template>
  <div class="h-screen w-screen bg-red-500 flex justify-center items-center">
    <div class="bg-white rounded-lg shadow-lg p-6 max-w-5xl w-full">
      <h3 class="text-lg font-semibold mb-4 text-center text-black">Dashboard</h3>
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6"> 
        <div class="flex justify-center items-center">
          <PieChart />
        </div>
        <div class="flex justify-center items-center">
          <BarChart />
        </div>
        <div class="flex justify-center items-center">
          <LineChart />
        </div>
      </div>
    </div>
  </div>
</template>
<script>
import PieChart from '../components/PieChart.vue';
import BarChart from '../components/BarChart.vue';
import LineChart from '../components/LineChart.vue';
export default {
  name: 'ChartManager',
  components: {
    PieChart,
    BarChart,
    LineChart,
  },
};
</script>