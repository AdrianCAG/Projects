#!/bin/sh

# Minimal serial logger with timestamps for macOS.
# Usage:
#   ./serial_timestamp_logger.sh /dev/cu.usbmodem142301 9600 sensor_log.csv
#   # baud and output file are optional (defaults: 9600, sensor_log.csv)

PORT="$1"

# On macOS, /dev/tty.* devices are for dial-in and can conflict.
# /dev/cu.* are for call-out and are generally what you want for serial communication.
# If a /dev/tty. device is provided, convert it to /dev/cu. (POSIX-compliant)
case "$PORT" in
    /dev/tty.*)
        CONVERTED_PORT="/dev/cu.${PORT#/dev/tty.}"
        if [ -e "$CONVERTED_PORT" ]; then
            echo "Warning: Converting $PORT to $CONVERTED_PORT for better compatibility on macOS." >&2
            PORT="$CONVERTED_PORT"
        fi
        ;;
esac
BAUD="$2"
OUTSPEC="$3"

if [ -z "$PORT" ]; then
    echo "Usage: $0 <serial_device> [baud=9600] [outfile=sensor_log.txt]" >&2
    exit 2
fi

if [ -z "$BAUD" ]; then
    BAUD=9600
fi

if [ -z "$OUTSPEC" ]; then
    OUTSPEC="sensor_log.csv"
fi

# Check device exists
if [ ! -e "$PORT" ]; then
    echo "Serial device not found: $PORT" >&2
    exit 3
fi

# Check if busy (non-fatal, but we warn)
if command -v lsof >/dev/null 2>&1; then
    if lsof -nP "$PORT" >/dev/null 2>&1; then
        echo "Warning: $PORT appears to be in use. Close Arduino Serial Monitor or other tools." >&2
    fi
fi

# Configure serial line
if ! stty -f "$PORT" "$BAUD" raw -echo 2>/dev/null; then
    echo "Failed to configure $PORT (is it busy?)." >&2
    exit 4
fi

current_date="$(date +%F)"

# CSV header to prepend on new rotated files
CSV_HEADER="timestamp,mq2_raw,mq3_raw,mq135_raw,mq4_raw,mq5_raw,mq6_raw,mq7_raw,mq8_raw,mq9_raw,mq139_raw,dht11_1_temp_c,dht11_1_humidity_pct,dht11_1_heatindex_c,dht11_2_temp_c,dht11_2_humidity_pct,dht11_2_heatindex_c,bmp180_temp_c,bmp180_sealevel_pressure_hpa,ky028_temp_c"

# Resolve output file path for a given date, keeping user's base name/extension
resolve_outfile_for_date() {
    local date_part="$1"
    local spec="$2"

    # If spec ends with a slash, treat it as directory and use default base
    if [ "${spec%/}" != "$spec" ]; then
        local dir="${spec%/}"
        mkdir -p "$dir" 2>/dev/null || true
        echo "$dir/sensor_log-$date_part.csv"
        return
    fi

    # If spec contains a directory portion, ensure it exists
    local dir
    dir="$(dirname -- "$spec")"
    if [ "$dir" != "." ]; then
        mkdir -p "$dir" 2>/dev/null || true
    fi

    # Split base and extension if present
    local filename base ext
    filename="$(basename -- "$spec")"
    if [ "$filename" = "." ] || [ -z "$filename" ]; then
        filename="sensor_log.csv"
    fi

    # Use parameter expansion to detect and split extension safely
    if [ "${filename%.*}" != "$filename" ]; then
        base="${filename%.*}"
        ext=".${filename##*.}"
    else
        base="$filename"
        ext=".csv"
    fi

    # Compose path: base-YYYY-MM-DD.ext
    if [ "$dir" = "." ]; then
        echo "${base}-$date_part$ext"
    else
        echo "$dir/${base}-$date_part$ext"
    fi
}

OUTFILE_CURRENT="$(resolve_outfile_for_date "$current_date" "$OUTSPEC")"

echo "Logging $PORT @ $BAUD to $OUTFILE_CURRENT (rotates daily) (Ctrl-C to stop)..."

cleanup() {
    # Nothing specific to cleanup for device; placeholder for future use
    :
}
trap cleanup INT TERM EXIT

# Read line-by-line with timestamps; append to file and echo to stdout
# Use stdbuf for line-buffered cat if available
if command -v stdbuf >/dev/null 2>&1; then
    READER="stdbuf -oL cat \"$PORT\""
else
    READER="cat \"$PORT\""
fi

first_line=1
sh -c "$READER" | while IFS= read -r line; do
    now_date=$(date +%F)
    if [ "$now_date" != "$current_date" ]; then
        current_date="$now_date"
        OUTFILE_CURRENT="$(resolve_outfile_for_date "$current_date" "$OUTSPEC")"
        echo "--- Rotating log: $OUTFILE_CURRENT ---" >&2
        # Ensure header is written at the top of every new/empty rotated file
        if [ ! -s "$OUTFILE_CURRENT" ]; then
            printf "%s\n" "$CSV_HEADER" >> "$OUTFILE_CURRENT"
        fi
    fi
    if [ "$first_line" -eq 1 ]; then
        # Write the first line without a timestamp
        printf "%s\n" "$line" | tee -a "$OUTFILE_CURRENT"
        first_line=0
    else
        ts=$(date +%FT%T)
        printf "%s,%s\n" "$ts" "$line" | tee -a "$OUTFILE_CURRENT"
    fi
done


