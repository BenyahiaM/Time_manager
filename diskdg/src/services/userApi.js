// src/services/userApi.js

import api from './api'; // Import the base Axios instance

const UserApi = {
  // Fetch the current user's profile
  getUserProfile() {
    return api.get('/user');
  },

  // Update the current user's profile
  updateUserProfile(userData) {
    return api.put('/user', userData);
  },

  // Clock in or clock out for a user
  createUserClock(clockData) {
    return api.post('/user/clock', clockData);
  },

  // Get the user's clock status
  getUserClockStatus() {
    return api.get('/user/clockStatus');
  },

  // Fetch the current user's working time
  getWorkingTime() {
    return api.get('/user/workingtime');
  },

  // Fetch user team
  getUserTeam() {
    return api.get('/user/team');
  },

};

export default UserApi;