<template>
  <div class="chart-container">
    <h3>Worked hours</h3>
    <canvas ref="barChart" width="400" height="300"></canvas>
  </div>
</template>

<script>
import { Chart, registerables } from 'chart.js';

export default {
  name: 'BarChart',
  methods: {
    renderChart() {
      const ctx = this.$refs.barChart.getContext('2d');
      this.chart = new Chart(ctx, {
        type: 'bar',
        data: {
          labels: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
          datasets: [
            {
              data: [8, 7, 6, 8, 5, 0, 0],
              backgroundColor: '#42A5F5',
            },
          ],
        },
        options: {
          responsive: true,
          scales: {
            y: {
              beginAtZero: true,
            },
          },
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
