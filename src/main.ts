import { createApp } from "vue";
import App from "./App.vue";
import router from "./router";
import { library } from "@fortawesome/fontawesome-svg-core";
import {
  faComments,
  faHeadphonesSimple,
  faUtensils,
} from "@fortawesome/free-solid-svg-icons";
import { faGithub } from "@fortawesome/free-brands-svg-icons";

import "./assets/main.css";

library.add(faComments, faHeadphonesSimple, faUtensils, faGithub);

const app = createApp(App);

app.use(router);

app.mount("#app");
