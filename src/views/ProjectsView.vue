<script setup lang="ts">
import ProjectList from "../components/ProjectsList.vue";

const projects = [
  {
    name: "GoCoCo",
    range: "Sep/2022 - Present",
    description:
        "Mobile app that helps users to find healthy recipes and track their daily nutrition intake.",
    url: "https://elcoco.es/",
    icon: "fa-solid fa-utensils",
  },
  {
    name: "qaul.net",
    range: "Nov/2021 - Present",
    description:
        "Qaul is a decentralized, peer-to-peer, and secure communication platform.",
    url: "https://github.com/qaul/qaul.net",
    icon: "fa-solid fa-comments",
  },
  {
    name: "Mindbliss",
    range: "Dec/2020 - Jun/2021",
    description:
        "Tailored meditations and breathing exercises to reduce anxiety and increase well-being.",
    url: "https://mindbliss.com/",
    icon: "fa-solid fa-headphones-simple",
  },
];
</script>

<template>
  <main>
    <ProjectList :projects="projects"/>
  </main>
</template>
