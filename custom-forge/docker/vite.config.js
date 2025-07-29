import { defineConfig } from 'vite'
import { createAppConfig } from '@nextcloud/vite-config'

export default defineConfig(createAppConfig({
	main: 'src/main.js'
}))
