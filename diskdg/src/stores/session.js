import { defineStore } from 'pinia';

export const useSessionStore = defineStore('session', {
  state: () => ({
    isConnected: false,
  }),
  actions: {
    setConnected(status) {
      this.isConnected = status;
    },
  },
});