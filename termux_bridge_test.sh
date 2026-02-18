#!/data/data/com.termux/files/usr/bin/sh
# Manual bridge test for Termux. Run inside Termux app (not via Flutter).
# Pre-req: Termux:Tasker installed, storage permission granted, allow external apps ON.

LOG_DIR="$HOME/Download/SpotifyDownloader/termux"
mkdir -p "$LOG_DIR"
ID="manual_$(date +%s)"
STDOUT="$LOG_DIR/stdout_${ID}.log"
STDERR="$LOG_DIR/stderr_${ID}.log"
EXIT="$LOG_DIR/exit_${ID}.code"

cmd='echo termux_bridge_ok'

echo "[1] Direct shell run..."
sh -lc "$cmd" 1>"$STDOUT" 2>"$STDERR"
echo $? > "$EXIT"
echo "stdout: $(cat "$STDOUT" 2>/dev/null || true)"
echo "stderr: $(cat "$STDERR" 2>/dev/null || true)"
echo "exit : $(cat "$EXIT" 2>/dev/null || true)"

echo "[2] Simulate Tasker write..."
echo "termux_bridge_ok" > "$STDOUT"
echo "0" > "$EXIT"
echo "stdout after simulate: $(cat "$STDOUT")"
echo "exit after simulate : $(cat "$EXIT")"

echo "Done. Check files in $LOG_DIR"
