#!/bin/bash

read -p "Kurulum yapılacak paketlerin bulunduğu dosya adını girin: " source_file

if [[ ! -f "$source_file" ]]; then
    echo "Hata: Dosya bulunamadı!" >&2
    exit 1
fi

grep -v '^#' "$source_file" | xargs sudo pacman -S --needed --noconfirm