import api from './api'; 

const sessionApi = {
  // Login user
  login(credentials) {
    return api.post('/sessions', credentials);
  },

  // Register new user
  signUp(userData) {
    return api.post('/createAdmin', userData); 
  },

  // Logout user
  logout() {
    localStorage.removeItem('authToken'); 
  },
  
  // Save token to localStorage
  saveToken(token) {
    localStorage.setItem('token', token);
  },

  // Check if user is authenticated by checking the token
  isAuthenticated() {
    return !!localStorage.getItem('token'); 
  }
};

// Make sure to export the correct object
export default sessionApi;