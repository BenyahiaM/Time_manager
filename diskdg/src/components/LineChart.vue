<template>
  <div class="chart-container">
    <h3>Worked Hours</h3>
    <canvas ref="lineChart" width="400" height="300"></canvas>
  </div>
</template>

<script>
import { Chart, registerables } from 'chart.js';

export default {
  name: 'LineChart',
  methods: {
    renderChart() {
      const ctx = this.$refs.lineChart.getContext('2d');
      this.chart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],          
            datasets: [
            {
              data: [40, 38, 42, 40, 35, 45, 48, 44, 36, 39, 41, 38],
              borderColor: '#FF6384',
              fill: false,
            },
          ],
        },
        options: {
          responsive: true,
        },
      });
    },
  },
  mounted() {
    Chart.register(...registerables);
    this.renderChart();
  },
  beforeUnmount() {
    if (this.chart) {
      this.chart.destroy();
    }
  },
};
</script>

<style scoped>
.chart-container {
  max-width: 600px;
  margin: 0 auto;
}
</style>
