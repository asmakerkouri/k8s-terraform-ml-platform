#!/usr/bin/env bash
# Send concurrent prediction requests to trigger autoscaling (needs the port-forward on :8000).
set -euo pipefail
URL=${URL:-http://localhost:8000/predict}
python3 - <<'PY'
import io, struct, zlib
# write a tiny 32x32 PNG without extra dependencies
w = h = 32
raw = b"".join(b"\x00" + b"\x80\x40\xc0" * w for _ in range(h))
def chunk(t, d): return struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d))
png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0)) \
      + chunk(b"IDAT", zlib.compress(raw)) + chunk(b"IEND", b"")
open("/tmp/sample.png", "wb").write(png)
PY
echo "Sending requests to $URL (Ctrl+C to stop)"
while true; do
  for _ in $(seq 1 20); do curl -s -o /dev/null -F "file=@/tmp/sample.png" "$URL" & done
  wait
done
