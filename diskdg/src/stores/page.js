import { defineStore } from 'pinia';

export const usePageStore = defineStore('page', {
  state: () => ({
    pageRef: '',
  }),
  actions: {
    setPageRef(page) {
      this.pageRef = page;
    },
  },
});