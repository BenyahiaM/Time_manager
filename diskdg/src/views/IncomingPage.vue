<template>
  <div class="container">
    <b-card class="team-card">
      <h3 class="text-center">{{ team.name }}</h3>
      <p class="text-center">Manager: {{ team.name_chef }}</p>  <!-- Updated to show the manager's name -->
      
      <b-table striped hover :items="users" :fields="fields" class="team-table">
        <template v-slot:table-caption>
          <h3>Team Members</h3>
        </template>
      </b-table>
    </b-card>
  </div>
</template>

<script>
import api from '../services/userApi'; 

export default {
  data() {
    return {
      users: [],           
      team: {},            
      fields: [
        { key: 'id', label: 'ID' },
        { key: 'name', label: 'Name' }
      ]                      
    };
  },
  mounted() {
    this.fetchUserTeam(); 
  },
  methods: {
    async fetchUserTeam() {
      try {
        const response = await api.getUserTeam();

        this.users = response.data.users;

        // Assuming the response includes the chef's name directly
        this.team = {
          ...response.data.team,
          name_chef: response.data.chef.username  // Assuming `chef` is included in the response
        };
      } catch (error) {
        console.error('Error fetching user team:', error);
      }
    }
  }
};
</script>

<style scoped>
.container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100vh;
  background-color: #f4f7fa;
  padding: 2rem;
}

.team-card {
  background-color: #ffffff;
  box-shadow: 0px 4px 12px rgba(0, 0, 0, 0.1);
  border-radius: 12px;
  padding: 1.5rem;
  margin: 1rem 0;
  width: 100%;
  max-width: 800px;
  text-align: center;
}

.team-table h3 {
  margin-bottom: 1rem;
  color: #2c3e50;
  font-weight: 600;
}

.b-table {
  border-collapse: separate;
  border-spacing: 0;
}
</style>
