// src/services/api.js

import axios from 'axios';

// Base Axios instance
const api = axios.create({
  baseURL: 'https://time-manager-irre.onrender.com/api',
  headers: {
    'Content-Type': 'application/json',
  },
});

api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers['Authorization'] = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Interceptor for error handling
api.interceptors.response.use(
  (response) => response,
  (error) => {
    const { status } = error.response;    
    if (status === 401) {
      console.log('Unauthorized, redirect to login');
    } else if (status === 403) {
      console.log('Forbidden, insufficient permissions');
    } else if (status === 404) {
      console.log('Resource not found');
    } else {
      console.log('An error occurred');
    }
    return Promise.reject(error);
  }
);

export default api;