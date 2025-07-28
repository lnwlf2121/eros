<template>
  <div id="eros-app" class="relative min-h-screen flex flex-col items-center justify-between p-4 z-10 bg-gradient-to-br from-gray-900 via-indigo-900/40 to-black">
    <header class="text-center my-8">
        <h1 class="text-4xl md:text-6xl font-bold text-white tracking-tight">StarShip <span class="text-indigo-400">EROS</span></h1>
        <p class="text-lg md:text-xl text-gray-400 mt-2">The EROS Dialogue: A Unified AI Podcast</p>
    </header>
    <main class="w-full max-w-4xl flex-grow flex flex-col">
        <div id="transcript-log" class="flex-grow bg-black/30 border border-gray-700 rounded-t-2xl p-6 space-y-6 overflow-y-auto">
            <div v-for="message in transcript" :key="message.id">
                <div v-if="message.author === 'Captain'" class="flex items-start justify-end">
                    <div class="chat-bubble bg-indigo-600/50 text-white rounded-xl p-4 max-w-lg">
                        <p class="font-semibold mb-1">Captain (You)</p>
                        <p class="text-sm whitespace-pre-wrap">{{ message.text }}</p>
                    </div>
                </div>
                <div v-else class="flex items-start gap-4">
                    <div :class="message.authorColor" class="ai-icon w-10 h-10 rounded-full flex items-center justify-center border">
                        <div v-html="message.icon"></div>
                    </div>
                    <div class="chat-bubble bg-gray-800/50 rounded-xl p-4 max-w-lg">
                        <p class="font-semibold mb-1" :class="message.authorTextColor">{{ message.author }}</p>
                        <p class="text-sm whitespace-pre-wrap">{{ message.text }}</p>
                    </div>
                </div>
            </div>
        </div>
        <div class="bg-gray-800/70 border-x border-b border-gray-700 rounded-b-2xl p-4">
            <div class="flex items-center gap-4">
                <textarea v-model="newMessage" @keydown.enter.prevent="broadcastMessage" :disabled="isLoading" class="flex-grow bg-gray-900/70 border border-gray-600 rounded-lg p-3 text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition resize-none" rows="2" placeholder="Speak to your crew..."></textarea>
                <button @click="broadcastMessage" :disabled="isLoading" class="bg-indigo-600 hover:bg-indigo-500 text-white font-bold py-3 px-6 rounded-lg transition h-full disabled:bg-gray-500 disabled:cursor-not-allowed">
                    <span v-if="!isLoading">Broadcast</span>
                    <span v-else>Thinking...</span>
                </button>
            </div>
        </div>
    </main>
    <footer class="text-center my-8 text-gray-500 text-sm">
        <p>StarShip EROS v1.0 - A Unified Interface for a Regenerative Future.</p>
    </footer>
  </div>
</template>

<script>
import axios from '@nextcloud/axios'

export default {
  name: 'Main',
  data() {
    return {
      newMessage: '',
      isLoading: false,
      transcript: [
          {
              id: 1,
              author: 'Gemini (Oracle)',
              authorColor: 'bg-indigo-500/30 border-indigo-500',
              authorTextColor: 'text-indigo-300',
              icon: `<svg class="w-6 h-6 text-indigo-300" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M4.998 8.25a1.25 1.25 0 0 1 2.5 0v7.5a1.25 1.25 0 0 1-2.5 0v-7.5ZM10.25 4.998a1.25 1.25 0 0 1 2.5 0v14.004a1.25 1.25 0 0 1-2.5 0V4.998ZM15.5 11.5a1.25 1.25 0 0 1 2.5 0v1.5a1.25 1.25 0 0 1-2.5 0v-1.5Z" fill="currentColor"/></svg>`,
              text: "Welcome to the Bridge, Captain. The EROS system is online. State your query.",
          },
      ]
    }
  },
  methods: {
    async broadcastMessage() {
        if (this.newMessage.trim() === '' || this.isLoading) return;

        this.isLoading = true;
        const userMessage = this.newMessage.trim();

        this.transcript.push({
            id: Date.now(),
            author: 'Captain',
            text: userMessage,
        });
        
        this.newMessage = '';
        this.scrollToBottom();

        try {
            const response = await axios.post('/apps/eros/api/v1/broadcast', {
                prompt: userMessage
            });

            this.transcript.push({
                id: Date.now() + 1,
                author: 'Gemini (Oracle)',
                authorColor: 'bg-indigo-500/30 border-indigo-500',
                authorTextColor: 'text-indigo-300',
                icon: `<svg class="w-6 h-6 text-indigo-300" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M4.998 8.25a1.25 1.25 0 0 1 2.5 0v7.5a1.25 1.25 0 0 1-2.5 0v-7.5ZM10.25 4.998a1.25 1.25 0 0 1 2.5 0v14.004a1.25 1.25 0 0 1-2.5 0V4.998ZM15.5 11.5a1.25 1.25 0 0 1 2.5 0v1.5a1.25 1.25 0 0 1-2.5 0v-1.5Z" fill="currentColor"/></svg>`,
                text: response.data.response,
            });

        } catch (error) {
            this.transcript.push({
                id: Date.now() + 1,
                author: 'System Alert',
                authorColor: 'bg-red-500/30 border-red-500',
                authorTextColor: 'text-red-300',
                icon: '!',
                text: 'Error communicating with the Oracle. Check server logs and API key configuration.',
            });
        } finally {
            this.isLoading = false;
            this.scrollToBottom();
        }
    },
    scrollToBottom() {
        this.$nextTick(() => {
            const log = document.getElementById('transcript-log');
            if (log) {
                log.scrollTop = log.scrollHeight;
            }
        });
    }
  }
}
</script>

<style scoped>
.ai-icon { flex-shrink: 0; }
.chat-bubble { backdrop-filter: blur(10px); -webkit-backdrop-filter: blur(10px); }
</style>
