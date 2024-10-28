import { defineStore } from 'pinia';

export const useSidebarStore = defineStore('sidebar', {
  state: () => ({
    isDisplayed: true,
  }),
  actions: {
    setDisplay(status) {
      this.isDisplayed = status;
    },
  },
});