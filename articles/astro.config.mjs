import { defineConfig } from 'astro/config';
import mdx from '@astrojs/mdx';
import sitemap from '@astrojs/sitemap';
import vue from '@astrojs/vue';
import image from '@astrojs/image';
import tailwind from "@astrojs/tailwind";

// https://astro.build/config
export default defineConfig({
  site: 'https://brenodt.dev/articles',
  integrations: [mdx(), sitemap(), vue(), image(), tailwind()]
});
