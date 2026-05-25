# ===================================================================
# EROS DYNAMICS: KERBTAP MAKE GOVERNANCE
# ===================================================================

CC = gcc
CFLAGS = -O3 -Wall

# Using Nuitka to translate Python to C and compile to machine code
PY_COMPILER = nuitka3
PY_FLAGS = --onefile --remove-output --assume-yes-for-downloads

# The default CI/CD deployment target
all: node_a_screamer node_c_engine

# -------------------------------------------------------------------
# NODE A: The C-Native Hardware Sensor
# -------------------------------------------------------------------
node_a_screamer: node_a_screamer.c
	@echo "[FORGE] Compiling Node A Screamer to optimized machine code..."
	$(CC) $(CFLAGS) -o screamer node_a_screamer.c

# -------------------------------------------------------------------
# NODE C: The RAM-Isolated Matrix Engine
# -------------------------------------------------------------------
node_c_engine: kerbtap_daemon.py
	@echo "[FORGE] Translating Python to C and compiling Node C..."
	# This prevents the system from re-interpreting Python on execution
	$(PY_COMPILER) $(PY_FLAGS) kerbtap_daemon.py
	@mv kerbtap_daemon.bin kerbtap_engine

# -------------------------------------------------------------------
# GOVERNANCE: Clean the Workspace
# -------------------------------------------------------------------
clean:
	@echo "[FORGE] Purging old machine code..."
	rm -f screamer kerbtap_engine
