// src/services/managerApi.js

import api from './api'; 

const ManagerApi = {
  getUsersUnderManager() {
    return api.get('/manager/user');
  },

  assignUserToTeam(userID, teamID) {
    return api.put(`/manager/${userID}/${teamID}`);
  },

  getUserClock(userID) {
    return api.get(`/manager/clock/${userID}`);
  },

  updateUserClock(userID, clockID, clockData) {
    return api.put(`/manager/clock/${userID}/${clockID}`, clockData);
  },

};

export default ManagerApi;