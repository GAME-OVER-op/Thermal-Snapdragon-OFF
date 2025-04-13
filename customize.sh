#!/system/bin/sh

# --- Проверка и отображение информации о CPU ---
grep -qi "Qualcomm" /proc/cpuinfo || { echo "Snapdragon CPU не обнаружен."; exit 0; }

echo "####################################"
echo "# Snapdragon CPU обнаружен         #"
echo "# Техническая информация о CPU:    #"
echo "####################################"

grep -m1 "^Hardware" /proc/cpuinfo

for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
  cpu_num=$(echo "$cpu" | sed 's/.*cpu\([0-9]*\)$/\1/')
  freq_file="$cpu/cpufreq/scaling_cur_freq"
  if [ -f "$freq_file" ]; then
    freq=$(cat "$freq_file")
    echo "CPU$cpu_num: ${freq} kHz"
  fi
done

echo "===================================="

# --- Копирование thermal-файлов ---
SRC_DIR="/system/vendor/etc"
DEST_DIR="$MODPATH/system/vendor/etc"
mkdir -p "$DEST_DIR"

filelist=$(find "$SRC_DIR" -maxdepth 1 -type f -name "thermal*")
set -- $filelist
total=$#
[ "$total" -eq 0 ] && { printf "\rПрогресс: [####################] 100%%\n"; exit 0; }

current=0
bar_length=20

for file in "$SRC_DIR"/thermal*; do
  [ -f "$file" ] && {
    current=$((current + 1))
    FILE_NAME=$(basename "$file")
    DEST_FILE="$DEST_DIR/$FILE_NAME"
    echo "" > "$DEST_FILE"
    progress=$(( current * 100 / total ))
    filled=$(( progress * bar_length / 100 ))
    remainder=$(( bar_length - filled ))
    hashes=$(printf "%0.s#" $(seq 1 $filled))
    spaces=$(printf "%0.s-" $(seq 1 $remainder))
    printf "\rПрогресс: [%s%s] %3d%%" "$hashes" "$spaces" "$progress"
    sleep 0.2
  }
done
printf "\n"
