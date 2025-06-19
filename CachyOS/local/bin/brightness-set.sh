#!/usr/bin/env bash

[ "$1" = 10 ] && percent="1" || percent="0.$1"

# Parlaklık ayarı
brightnessctl set "$1%"

# Bildirim
notify-send -t 3000 -h string:bgcolor:#ebcb8b "Parlaklık %$1 ayarlandı."
