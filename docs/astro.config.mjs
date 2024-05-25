import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
    site: 'https://tracemachina.github.io',
    base: 'rules_mojo',
	integrations: [
		starlight({
			title: '🔥 rules_mojo',
            editLink: {
                baseURL: 'https://github.com/TraceMachina/rules_mojo/edit/main/docs/',
            },
			social: {
				github: 'https://github.com/TraceMachina/rules_mojo',
			},
			sidebar: [
				{
					label: 'Guides',
					items: [
						{ label: 'Setup', link: '/guides/setup/' },
					],
				},
				{
					label: 'Rules',
                    items: [
                        { label: '@rules_mojo//mojo:defs.bzl', link: '/rules/defs/' },
                    ],
				},
				{
					label: 'Reference',
					autogenerate: { directory: 'reference' },
				},
			],
		}),
	],
});
