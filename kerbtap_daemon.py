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
                self.log_stream.write_line(f"[UPLINK] Pushing shielded payload to NNTP/DePIN Stargate.\n")
                
        except BlockingIOError:
            pass # No data in pipe, sleep silently

def main():
    app = KerbtapTUI()
    app.run()

if __name__ == "__main__":
    main()
