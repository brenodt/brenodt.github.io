import { defineConfig } from 'astro/config'
import mdx from '@astrojs/mdx'
import sitemap from '@astrojs/sitemap'
import image from '@astrojs/image'
import tailwind from '@astrojs/tailwind'
import react from '@astrojs/react'
import addClasses from 'rehype-add-classes'
import astroI18next from 'astro-i18next';

// https://astro.build/config
export default defineConfig({
  site: 'https://brenodt.dev',
  integrations: [
    mdx(),
    sitemap({
      i18n: {
        defaultLocale: 'en',   // All urls that don't contain `es` or `fr` after `https://stargazers.club/` will be treated as default locale, i.e. `en`
        locales: {
          en: 'en-US',         // The `defaultLocale` value must present in `locales` keys
          br: 'pt-BR'
        }
      }
    }),
    image(),
    tailwind(),
    react(),
    astroI18next()
  ],
  markdown: {
    extendDefaultPlugins: true,
    rehypePlugins: [
      [
        addClasses,
        {
          h1: 'text-4xl font-bold font-ubuntu mb-4 mt-4',
          h2: 'text-2xl font-bold font-ubuntu mb-4 mt-4',
          h3: 'text-xl font-bold font-ubuntu mb-4 mt-4',
          h4: 'text-lg font-bold font-ubuntu mb-4 mt-4',
          h5: 'font-bold font-ubuntu mb-4 mt-4',
          h6: 'font-bold font-ubuntu mb-4 mt-4',
          img: 'border border-slate-300 dark:border-zinc-700 rounded-xl mb-6',
          p: 'mb-6',
          a: 'underline underline-offset-2 hover:text-sky-500 decoration-sky-500',
          // blockquote: 'border-l-4 border-slate-300 dark:border-zinc-700 pl-4 mb-6',
          blockquote: 'text-lg italic mb-6 border border-slate-300 dark:border-zinc-700 rounded-xl p-4',
          sup: 'p-2'
        }
      ]
    ]
  }
})
