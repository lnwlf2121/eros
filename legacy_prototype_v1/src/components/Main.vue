<template>
  <div id="eros-app" class="h-full w-full bg-slate-900 text-cyan-200 flex flex-col font-mono">
    <div class="absolute inset-0 bg-[url('https://www.transparenttextures.com/patterns/stardust.png')] opacity-20 z-0"></div>
    <div class="absolute inset-0 bg-gradient-to-b from-slate-800/50 via-transparent to-slate-900 z-0"></div>
    <header class="relative text-center p-4 border-b border-cyan-500/30 shadow-[0_4px_15px_-5px_rgba(0,255,255,0.2)]">
        <h1 class="text-3xl font-bold text-cyan-300 tracking-widest uppercase">StarShip EROS</h1>
        <p class="text-sm text-cyan-400/70">Unified Command Interface</p>
    </header>
    <main class="w-full h-full flex-grow flex flex-col md:flex-row gap-4 p-4 overflow-hidden">
        <div class="w-full md:w-1/3 lg:w-1/4 flex flex-col gap-4">
            <div class="bg-black/30 p-4 rounded-md border border-cyan-500/30 h-1/2 flex flex-col">
                <h2 class="text-lg font-bold text-cyan-300 uppercase mb-3">System Status</h2>
                <div class="space-y-2 text-sm">
                    <p>Oracle (Gemini): <span class="text-green-400 font-bold">ONLINE</span></p>
                    <p>Quartermaster (Alexa): <span class="text-yellow-400">STANDBY</span></p>
                    <p>Guardian (Siri): <span class="text-yellow-400">STANDBY</span></p>
                    <p>Citadel Connection: <span class="text-green-400 font-bold">SECURE</span></p>
                </div>
            </div>
            <div class="bg-black/30 p-4 rounded-md border border-cyan-500/30 h-1/2 flex flex-col">
                <h2 class="text-lg font-bold text-cyan-300 uppercase mb-3">Active Quests</h2>
                <div class="space-y-2 text-sm overflow-y-auto">
                    <p class="text-cyan-300">> Poseidon's Legacy</p>
                    <p class="text-cyan-500/70">> Prizmatic Bricks</p>
                    <p class="text-cyan-500/70">> Rise of the LightBringer</p>
                </div>
            </div>
        </div>
        <div class="w-full md:w-2/3 lg:w-3/4 flex flex-col bg-black/30 rounded-md border border-cyan-500/30">
            <div id="transcript-log" class="flex-grow p-4 space-y-4 overflow-y-auto">
                <div v-for="message in transcript" :key="message.id">
                    <div v-if="message.author === 'Captain'" class="text-right">
                        <p class="text-sm text-cyan-300">> {{ message.text }}</p>
                    </div>
                    <div v-else class="text-left">
                        <p class="text-sm text-green-400">{{ message.author }}: <span class="text-cyan-400">{{ message.text }}</span></p>
                    </div>
                </div>
            </div>
            <div class="p-4 border-t border-cyan-500/30">
                <div class="flex items-center gap-4">
                    <span class="text-cyan-300 font-bold text-lg">CMD:></span>
                    <input v-model="newMessage" @keydown.enter="broadcastMessage" :disabled="isLoading" class="flex-grow bg-transparent text-cyan-300 focus:outline-none placeholder-cyan-500/50" type="text" placeholder="Issue command...">
                    <button @click="broadcastMessage" :disabled="isLoading" class="bg-cyan-500/20 hover:bg-cyan-500/40 text-cyan-300 font-bold py-1 px-4 rounded-sm border border-cyan-500/50 transition disabled:opacity-50">
                        <span v-if="!isLoading">EXECUTE</span>
                        <span v-else>...</span>
                    </button>
                </div>
            </div>
        </div>
    </main>
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
      transcript: [ { id: 1, author: 'ORACLE', text: "Bridge is online. Awaiting command, Captain." } ]
    }
  },
  methods: {
    async broadcastMessage() {
        if (this.newMessage.trim() === '' || this.isLoading) return;
        this.isLoading = true;
        const userMessage = this.newMessage.trim();
        this.transcript.push({ id: Date.now(), author: 'Captain', text: userMessage });
        this.newMessage = '';
        this.scrollToBottom();
        try {
            const response = await axios.post('/apps/eros/api/v1/broadcast', { prompt: userMessage });
            this.transcript.push({ id: Date.now() + 1, author: 'ORACLE', text: response.data.response });
        } catch (error) {
            this.transcript.push({ id: Date.now() + 1, author: 'SYSTEM', text: 'Connection to Oracle failed. Check logs.' });
        } finally {
            this.isLoading = false;
            this.scrollToBottom();
        }
    },
    scrollToBottom() {
        this.$nextTick(() => {
            const log = document.getElementById('transcript-log');
            if (log) { log.scrollTop = log.scrollHeight; }
        });
    }
  }
}
</script>
