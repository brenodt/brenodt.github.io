<script setup lang="ts">
import ProjectItem from "./ProjectItem.vue";
import { FontAwesomeIcon } from "@fortawesome/vue-fontawesome";

type Project = {
  name: string;
  range: string;
  description: string;
  url: string;
  icon: string;
};

defineProps<{
  projects: Project[];
}>();
</script>

<template>
  <ProjectItem v-for="project in projects" :key="project.name">
    <template #icon>
      <font-awesome-icon :icon="project.icon" />
    </template>

    <template #heading>
      <a :href="project.url" target="_blank" >
        {{ project.name }}
      </a>
      · {{ project.range }}
    </template>

    {{ project.description }}
  </ProjectItem>
</template>
