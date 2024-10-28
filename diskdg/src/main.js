import { createApp } from 'vue';
import BootstrapVue3 from 'bootstrap-vue-3';
import 'bootstrap/dist/css/bootstrap.css';
import 'bootstrap-vue-3/dist/bootstrap-vue-3.css';
import App from './App.vue';
import { createPinia } from 'pinia';
import './global.css';


const app = createApp(App);
const pinia = createPinia();
app.use(pinia);
app.use(BootstrapVue3);
app.mount('#app');
