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

# my suggestion...
#   def on_ready(self) -> None:
#        # Minted ONCE at boot. Never recalculated.
#        self.static_target_hash = get_64bit_target() 
#        
#        self.log_stream = self.query_one("#console_log", Log)
#        self.log_stream.write_line(f"==========================================")
#        self.log_stream.write_line(f"[SYSTEM] EROS Node C Engine Online.")
#        self.log_stream.write_line(f"[SYSTEM] Static Target Hash Locked: comp.os.eros.vfs.{self.static_target_hash}")
##        self.log_stream.write_line(f"==========================================")
#        
#        self.set_interval(0.5, self.process_pipeline)

    def on_ready(self) -> None:
        self.log_stream = self.query_one("#console_log", Log)
        self.log_stream.write_line(f"==========================================")
        self.log_stream.write_line(f"[SYSTEM] EROS Node C Engine Online.")
        self.log_stream.write_line(f"[SYSTEM] Target Hash: comp.os.eros.vfs.{get_64bit_target()}")
        self.log_stream.write_line(f"==========================================")
        # Poll the pipe every 0.5s asynchronously
        self.set_interval(0.5, self.process_pipeline)

    def process_and_shield(self, data_payload):
        """Executes the FAST RAM-to-RAM compression and PAR2 generation"""
        start_time = time.time()
        
        payload_file = f"{SPOOL_DIR}/raw_payload.dat"
        with open(payload_file, 'wb') as f:
            f.write(data_payload)
            
        self.log_stream.write_line("[MATRIX SHIELD] Slicing data via RAR with FAST (-m1) compression...")
        subprocess.run(["rar", "a", "-m1", f"{SPOOL_DIR}/mosaic.rar", payload_file], capture_output=True)
        
        self.log_stream.write_line("[MATRIX SHIELD] Generating 10% PAR2 Forward Error Correction...")
        subprocess.run(["par2", "c", "-r10", f"{SPOOL_DIR}/mosaic.rar.par2", f"{SPOOL_DIR}/mosaic.rar"], capture_output=True)
        
        return time.time() - start_time

    def process_pipeline(self) -> None:
        try:
            # 2. Aggressive Non-Blocking Read: Drops excess to floor if choking
            fd = os.open(FIFO_PATH, os.O_RDONLY | os.O_NONBLOCK)
            data = os.read(fd, 1048576) # Rip up to 1MB from the buffer
            os.close(fd)

            if data:
                self.log_stream.write_line(f"\n[NODE C] Harvested {len(data)} bytes of sensor entropy.")
                
                # 3. CPU-Aware Processing
                proc_time = self.process_and_shield(data)
                
                # 4. The Optimized Temporal Masking Delay
                jitter_entropy = random.uniform(0.1, 1.0)
                sleep_time = max(0, BASE_RHYTHM - proc_time) + jitter_entropy
                
                self.log_stream.write_line(f"[SKID PLATE] CPU compression took {proc_time:.2f}s.")
                self.log_stream.write_line(f"[SKID PLATE] Masking signature. Delaying {sleep_time:.2f}s...")
                
                # In real network logic, the async thread awaits sleep_time before socket push
                self.log_stream.write_line(f"[UPLINK] Pushing shielded payload to NNTP/DePIN Stargate.\n")
                
        except BlockingIOError:
            pass # No data in pipe, sleep silently

def main():
    app = KerbtapTUI()
    app.run()

if __name__ == "__main__":
    main()
