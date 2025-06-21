#!/usr/bin/env bash

# Parlaklık ayarı
if ! brightnessctl set "$1%"; then

# Hata durumunda bildirim gönder
notify-send -t 5000 -u critical "Parlaklık ayarlanırken bir hata oluştu!" "Lütfen 'brightnessctl' komutunun doğru çalıştığından ve izinlerinizin olduğundan emin olun."

else

# Başarılı bildirim
notify-send -t 3000 -h string:bgcolor:#ebcb8b "Parlaklık %$1 ayarlandı."

fi
