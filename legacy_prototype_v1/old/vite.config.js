import { defineConfig } from 'vite'
import { createAppConfig } from '@nextcloud/vite-config'

export default defineConfig(
	createAppConfig({
		main: 'src/main.js',
		build: {
			outDir: 'js',
			lib: {
				entry: 'src/main.js',
				name: 'eros',
				fileName: 'eros-main',
				formats: ['iife'],
			},
			rollupOptions: {
				external: (id) => id.startsWith('@nextcloud/'),
				output: {
					assetFileNames: 'main.css',
				},
			},
			cssCodeSplit: false,
		},
	}),
)
