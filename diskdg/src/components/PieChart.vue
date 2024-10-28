<template>
  <div class="chart-container">
    <h3>Worked Hours</h3>
    <canvas ref="pieChart" width="300" height="300"></canvas>
  </div>
</template>

<script>
import { Chart, registerables } from 'chart.js';

export default {
  name: 'PieChart',
  methods: {
    renderChart() {
      const ctx = this.$refs.pieChart.getContext('2d');
      this.chart = new Chart(ctx, {
        type: 'pie',
        data: {
          labels: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
          datasets: [
            {
              data: [8, 7, 6, 8, 5, 0, 0],
              backgroundColor: ['#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0', '#9966FF', '#FF9F40', '#CCCCCC'],
            },
          ],
        },
        options: {
          responsive: true,
          plugins: {
            legend: {
              position: 'bottom',
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
  max-width: 400px;
  margin: 0 auto;
}
</style>
