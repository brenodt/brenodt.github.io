<script setup lang="ts">
import ProjectItem from "./ProjectItem.vue";
import { FontAwesomeIcon } from "@fortawesome/vue-fontawesome";
</script>

<template>
  <ProjectItem>
    <template #icon>
      <font-awesome-icon icon="fa-solid fa-comments" />
    </template>
    <template #heading>Qaul</template>

    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce gravida
    sollicitudin massa sit amet convallis. Nullam eget pulvinar nibh.
  </ProjectItem>

  <ProjectItem>
    <template #icon>
      <font-awesome-icon icon="fa-solid fa-utensils" />
    </template>
    <template #heading>GoCoCo</template>

    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce gravida
    sollicitudin massa sit amet convallis. Nullam eget pulvinar nibh.
  </ProjectItem>

  <ProjectItem>
    <template #icon>
      <font-awesome-icon icon="fa-solid fa-headphones-simple" />
    </template>
    <template #heading>Mindbliss</template>

    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce gravida
    sollicitudin massa sit amet convallis. Nullam eget pulvinar nibh.
  </ProjectItem>
</template>
