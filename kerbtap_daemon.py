import os
import time
import random
import hashlib
import subprocess
from dotenv import load_dotenv
from textual.app import App, ComposeResult
from textual.widgets import Header, Footer, Log

# 1. Load Configurations from .env
load_dotenv()
DEVICE_ID = os.getenv("DEVICE_ID", "Earthship_Node_01")
SECRET_SALT = os.getenv("SECRET_SALT", "eros_master_key")
TRANSPORT_MODE = os.getenv("TRANSPORT_MODE", "LOCAL_DEV").upper()

NNTP_SERVER = os.getenv("NNTP_SERVER","")
NNTP_USER = os.getenv("NNTP_USER","")
NNTP_PASS = os.getenv("NNTP_PASS","")

BASE_RHYTHM = float(os.getenv("BASE_RHYTHM", 3.0))

FIFO_PATH = '/tmp/eros_sensor_pipe'
SPOOL_DIR = '/tmp/kerbtap-spool'

# Ensure volatile sandbox directories exist
os.makedirs(SPOOL_DIR, exist_ok=True)
if not os.path.exists(FIFO_PATH):
    os.mkfifo(FIFO_PATH)

def get_64bit_target():
    """Generates the secure legacy NNTP/DePIN group routing hash"""
    raw_string = f"{DEVICE_ID}_{SECRET_SALT}".encode('utf-8')
    return hashlib.sha256(raw_string).hexdigest()[:16]

def cleanup_spool(self):
    """Purges the RAM-disk after successful transmission"""
    for filename in os.listdir(SPOOL_DIR):
        filepath = os.path.join(SPOOL_DIR, filename)
        if os.path.isfile(filepath):
            os.remove(filepath)

class KerbtapTUI(App):
    CSS = """
    Screen { background: #121212; }
    Log { height: 1fr; border: solid #10b981; color: #10b981; }
    """
    BINDINGS = [("q", "quit", "Quit Kerbtap")]

    def compose(self) -> ComposeResult:
        yield Header()
        yield Log(id="console_log")
        yield Footer()

    def on_ready(self) -> None:
        self.static_target_hash = get_64bit_target() 
        
        self.log_stream = self.query_one("#console_log", Log)
        self.log_stream.write_line(f"==========================================")
        self.log_stream.write_line(f"[SYSTEM] EROS Node C Engine Online.")
        self.log_stream.write_line(f"[SYSTEM] Target Hash: comp.os.eros.vfs.{self.static_target_hash}")
        self.log_stream.write_line(f"==========================================")
        
        # FIX: Open the pipe persistently so the Screamer always sees an active reader
        self.persistent_fd = os.open(FIFO_PATH, os.O_RDONLY | os.O_NONBLOCK)
        
        self.set_interval(0.5, self.process_pipeline)

    def process_and_shield(self, data_payload):
        """Executes FAST RAM-to-RAM Gzip compression, Splitting, and PAR2 generation"""
        start_time = time.time()

        # 1. Write the raw entropy to the RAM-disk
        payload_file = f"{SPOOL_DIR}/raw_payload.dat"
        with open(payload_file, 'wb') as f:
            f.write(data_payload)

        # 2. Compress using GZIP (-1 means fastest RAM-to-RAM compression)
        self.log_stream.write_line("[MATRIX SHIELD] Zipping data via native Gzip...")
        subprocess.run(["gzip", "-f", "-1", payload_file], capture_output=True)

        # 3. Slice the zipped file into uniform chunks for NNTP using Linux 'split'
        # -b 500K slices it into 500 Kilobyte pieces named mosaic_chunk_aa, ab, etc.
        self.log_stream.write_line("[MATRIX SHIELD] Slicing payload for legacy NNTP transport...")
        zipped_file = f"{payload_file}.gz"
        subprocess.run(["split", "-b", "500K", zipped_file, f"{SPOOL_DIR}/mosaic_chunk_"], capture_output=True)

        # 4. Generate the 10% Forward Error Correction Shield
        self.log_stream.write_line("[MATRIX SHIELD] Generating 10% PAR2 Parity Shield...")
        subprocess.run(["par2", "c", "-r10", f"{SPOOL_DIR}/mosaic.par2", f"{SPOOL_DIR}/mosaic_chunk_*"], capture_output=True)

        # Calculate how long the CPU worked so we can absorb it into the 3-6-9 skid plate wait time
        return time.time() - start_time
    
    def post_to_local(self, target_hash):
        """Simulates the network drop for local developmetn"""
        self.log_stream.write_line(f"[UPLINK] LOCAL_DEV mode active Routing into internal void...")
        # In a real dev test, you might move this to a permanent folder to inspect the gz/par2 files.
        # For now, we just purge it to simulate a successful send.
        self.cleanup_spool()
        self.log_stream.write_line("[SYSTEM] Local Dev transmission complete. RAM spool cleared.")
    
    def post_to_nntp(self, target_hash):
        """Pushes the shielded payload to the legacy NNTP Stargate"""
        group_name = f"comp.os.eros.vfs.{target_hash}"
        try:
            server = nntplib.NNTP(NNTP_SERVER, user=NNTP_USER, password=NNTP_PASS)
            for filename in os.listdir(SPOOL_DIR):
                filepath = os.path.join(SPOOL_DIR, filename)
                if os.path.isfile(filepath):
                    with open(filepath, "rb") as f:
                        encoded_payload = base64.b64encode(f.read()).decode('utf-8')

                    msg = Message()
                    msg['From'] = f"node_c@{DEVICE_ID}.eros"
                    msg['Newsgroups'] = group_name
                    msg['Subject'] = f"EROS_METRIC_BLOCK [{filename}]"
                    msg.set_payload(encoded_payload)

                    self.log_stream.write_line(f"[UPLINK] Transmitting {filename} to NNTP...")
                    server.post(msg.as_bytes())

            server.quit()
            self.cleanup_spool()
            self.log_stream.write_line("[SYSTEM] NNTP transmission complete. RAM spool cleared.")
        except Exception as e:
            self.log_stream.write_line(f"[ERROR] NNTP Stargate failure: {e}")

    def post_to_depin(self, target_hash):
        """The future DePIN / IPFS PubSub mesh broadcast"""
        self.log_stream.write_line(f"[UPLINK] DEPIN mode active. Initiating IPFS PubSub handshake...")
        self.log_stream.write_line(f"[UPLINK] Broadcasting to sovereign mesh topic: {target_hash}")
        
        # Dummy delay to simulate the peer-to-peer network broadcast
        time.sleep(1) 
        
        self.cleanup_spool()
        self.log_stream.write_line("[SYSTEM] DePIN transmission complete. RAM spool cleared.")

    def process_pipeline(self) -> None:
        try:
            # FIX: Read directly from the persistent connection. No opening or closing here!
            data = os.read(self.persistent_fd, 1048576) 

            if data:
                self.log_stream.write_line(f"\n[NODE C] Harvested {len(data)} bytes of sensor entropy.")
                
                # 3. CPU-Aware Processing
                proc_time = self.process_and_shield(data)
                
                # 4. The Optimized Temporal Masking Delay
                jitter_entropy = random.uniform(0.1, 1.0)
                sleep_time = max(0, BASE_RHYTHM - proc_time) + jitter_entropy
                
                self.log_stream.write_line(f"[SKID PLATE] CPU compression took {proc_time:.2f}s.")
                self.log_stream.write_line(f"[SKID PLATE] Masking signature. Delaying {sleep_time:.2f}s...")
                #self.log_stream.write_line(f"[UPLINK] Pushing shielded payload to NNTP/DePIN Stargate.\n")
                time.sleep(sleep_time)

                # 5. The Switchboard (Routing based on .env)
                if TRANSPORT_MODE == "NNTP":
                    self.post_to_nntp(self.static_target_hash)
                elif TRANSPORT_MODE == "DEPIN":
                    self.post_to_depin(self.static_target_hash)
                else:
                    self.post_to_local(self.static_target_hash)

                self.log_stream.write_line(f"[SYSTEM] Pipeline ready for next burst.\n")

                
        except BlockingIOError:
            pass # No data in pipe, sleep silently

def main():
    app = KerbtapTUI()
    app.run()

if __name__ == "__main__":
    main()
