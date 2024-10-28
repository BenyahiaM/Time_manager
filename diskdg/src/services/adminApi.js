import api from './adminApi'; 

const AdminApi = {
  getAllUsers() {
    return api.get('/admin/user');
  },

  getUserById(userID) {
    return api.get(`/admin/user/${userID}`);
  },

  createUser(userData) {
    return api.post('/admin/user', userData);
  },

  updateUser(userID, userData) {
    return api.put(`/admin/user/${userID}`, userData);
  },

  deleteUser(userID) {
    return api.delete(`/admin/user/${userID}`);
  },

  getAllTeams() {
    return api.get('/admin/team');
  },

};

export default AdminApi;