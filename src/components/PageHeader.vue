<script setup lang="ts">
import { FontAwesomeIcon } from "@fortawesome/vue-fontawesome";

defineProps<{
  msg: string;
}>();
</script>

<template>
  <div class="greetings">
    <h1 class="green">
      Breno Teodoro
      <a class="no-hover" href="https://github.com/brenodt" target="_blank">
        <font-awesome-icon class="icon-button" icon="fa-brands fa-github" />
      </a>
    </h1>

    <h3>Software developer with an inkling for Fullstack.</h3>
  </div>
</template>

<style scoped>
h1 {
  font-weight: 500;
  font-size: 2.6rem;
  top: -10px;
}

h3 {
  font-size: 1.2rem;
}

.greetings h1,
.greetings h3 {
  text-align: center;
}

@media (min-width: 1024px) {
  .greetings h1,
  .greetings h3 {
    text-align: left;
  }
}

.no-hover,
.no-hover:hover {
  text-decoration: none;
  color: inherit;
  background-color: transparent;
}

.icon-button:hover {
  color: rgb(23, 159, 107);
}
</style>
