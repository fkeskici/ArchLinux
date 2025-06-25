#!/bin/bash

# Arch Linux Sistem Bakım Scripti
# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # Renk sıfırla

# Banner
show_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                 ARCH LINUX SİSTEM BAKIM                     ║"
    echo "║                    Sistem Bakım Aracı                       ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Ana menü
show_menu() {
    echo -e "${BLUE}┌────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│                        ANA MENÜ                           │${NC}"
    echo -e "${BLUE}├────────────────────────────────────────────────────────────┤${NC}"
    echo -e "${YELLOW} 1)${NC} Geçici Dosyaları Temizle (/tmp)"
    echo -e "${YELLOW} 2)${NC} Önbellek Temizliği (~/.cache)"
    echo -e "${YELLOW} 3)${NC} Pacman Önbellek Temizliği (paccache)"
    echo -e "${YELLOW} 4)${NC} Sistem Günlükleri Temizliği (journalctl)"
    echo -e "${YELLOW} 5)${NC} Yetim Paketleri Temizle"
    echo -e "${YELLOW} 6)${NC} Sistem Güncelleme"
    echo -e "${YELLOW} 7)${NC} AUR Paketleri Güncelle (yay/paru)"
    echo -e "${YELLOW} 8)${NC} Paket Veritabanı Onarımı"
    echo -e "${YELLOW} 9)${NC} Disk Kullanım Analizi"
    echo -e "${YELLOW}10)${NC} Sistem Bilgileri"
    echo -e "${YELLOW}11)${NC} Çöp Dosyaları Temizle (Trash)"
    echo -e "${YELLOW}12)${NC} Thumbnails Temizle"
    echo -e "${YELLOW}13)${NC} Eski Çekirdekler Temizle"
    echo -e "${YELLOW}14)${NC} Flatpak Temizliği"
    echo -e "${YELLOW}15)${NC} Snap Temizliği"
    echo -e "${YELLOW}16)${NC} Tüm Temizlik İşlemleri (Otomatik)"
    echo -e "${YELLOW}17)${NC} Sistem Durumu Kontrolü"
    echo -e "${BLUE}├────────────────────────────────────────────────────────────┤${NC}"
    echo -e "${RED} 0)${NC} Çıkış"
    echo -e "${BLUE}└────────────────────────────────────────────────────────────┘${NC}"
    echo
}

# Başarı mesajı
success_msg() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Hata mesajı
error_msg() {
    echo -e "${RED}✗ $1${NC}"
}

# Bilgi mesajı
info_msg() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Devam etmek için bekle
wait_key() {
    echo
    echo -e "${CYAN}Devam etmek için herhangi bir tuşa basın...${NC}"
    read -n 1 -s
}

# Boyut hesaplama
get_size() {
    if [ -d "$1" ] || [ -f "$1" ]; then
        du -sh "$1" 2>/dev/null | cut -f1
    else
        echo "0B"
    fi
}

# /tmp temizliği
clean_tmp() {
    echo -e "${PURPLE}=== GEÇİCİ DOSYALAR TEMİZLENİYOR ===${NC}"
    echo
    
    tmp_size=$(get_size "/tmp")
    info_msg "/tmp klasörü boyutu: $tmp_size"
    
    if [ "$tmp_size" != "0B" ]; then
        sudo rm -rf /tmp/* 2>/dev/null
        sudo rm -rf /tmp/.* 2>/dev/null
        success_msg "/tmp klasörü temizlendi"
    else
        info_msg "/tmp klasörü zaten temiz"
    fi
    
    # /var/tmp temizliği
    var_tmp_size=$(get_size "/var/tmp")
    info_msg "/var/tmp klasörü boyutu: $var_tmp_size"
    
    if [ "$var_tmp_size" != "0B" ]; then
        sudo rm -rf /var/tmp/* 2>/dev/null
        success_msg "/var/tmp klasörü temizlendi"
    else
        info_msg "/var/tmp klasörü zaten temiz"
    fi
    
    wait_key
}

# ~/.cache temizliği
clean_cache() {
    echo -e "${PURPLE}=== KULLANICI ÖNBELLEĞİ TEMİZLENİYOR ===${NC}"
    echo
    
    cache_size=$(get_size "$HOME/.cache")
    info_msg "Önbellek boyutu: $cache_size"
    
    if [ -d "$HOME/.cache" ]; then
        rm -rf "$HOME/.cache"/*
        success_msg "Kullanıcı önbelleği temizlendi"
    else
        info_msg "Önbellek klasörü bulunamadı"
    fi
    
    wait_key
}

# Pacman önbellek temizliği
clean_paccache() {
    echo -e "${PURPLE}=== PACMAN ÖNBELLEĞİ TEMİZLENİYOR ===${NC}"
    echo
    
    cache_size=$(get_size "/var/cache/pacman/pkg")
    info_msg "Pacman önbellek boyutu: $cache_size"
    
    # Son 3 sürümü koru
    if command -v paccache >/dev/null 2>&1; then
        sudo paccache -r
        success_msg "Eski paket sürümleri temizlendi (son 3 sürüm korundu)"
        
        # Kaldırılmış paketlerin önbelleğini temizle
        sudo paccache -ruk0
        success_msg "Kaldırılmış paketlerin önbelleği temizlendi"
    else
        error_msg "paccache bulunamadı. pacman-contrib paketini yükleyin."
    fi
    
    wait_key
}

# Sistem günlükleri temizliği
clean_logs() {
    echo -e "${PURPLE}=== SİSTEM GÜNLÜKLERİ TEMİZLENİYOR ===${NC}"
    echo
    
    # Journalctl boyutu
    journal_size=$(journalctl --disk-usage 2>/dev/null | grep -o '[0-9.]*[KMGT]B')
    info_msg "Journal boyutu: $journal_size"
    
    # Son 2 haftayı koru
    sudo journalctl --vacuum-time=2weeks
    success_msg "2 haftadan eski günlükler temizlendi"
    
    # /var/log klasörü
    log_size=$(get_size "/var/log")
    info_msg "/var/log boyutu: $log_size"
    
    # Eski log dosyalarını temizle
    sudo find /var/log -name "*.old" -delete 2>/dev/null
    sudo find /var/log -name "*.gz" -delete 2>/dev/null
    success_msg "Eski log dosyaları temizlendi"
    
    wait_key
}

# Yetim paketleri temizle
clean_orphans() {
    echo -e "${PURPLE}=== YETİM PAKETLER TEMİZLENİYOR ===${NC}"
    echo
    
    orphans=$(pacman -Qtdq)
    if [ -n "$orphans" ]; then
        echo "Bulunan yetim paketler:"
        echo "$orphans"
        echo
        read -p "Bu paketleri kaldırmak istiyor musunuz? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo pacman -Rns $orphans
            success_msg "Yetim paketler kaldırıldı"
        else
            info_msg "Yetim paketler korundu"
        fi
    else
        success_msg "Yetim paket bulunamadı"
    fi
    
    wait_key
}

# Sistem güncelleme
update_system() {
    echo -e "${PURPLE}=== SİSTEM GÜNCELLENİYOR ===${NC}"
    echo
    
    info_msg "Paket veritabanı güncelleniyor..."
    sudo pacman -Sy
    
    echo
    info_msg "Mevcut güncellemeler kontrol ediliyor..."
    updates=$(checkupdates 2>/dev/null | wc -l)
    
    if [ "$updates" -gt 0 ]; then
        info_msg "$updates güncelleme bulundu"
        sudo pacman -Su
        success_msg "Sistem güncellendi"
    else
        success_msg "Sistem zaten güncel"
    fi
    
    wait_key
}

# AUR güncelleme
update_aur() {
    echo -e "${PURPLE}=== AUR PAKETLERİ GÜNCELLENİYOR ===${NC}"
    echo
    
    if command -v yay >/dev/null 2>&1; then
        yay -Syu --noconfirm
        success_msg "AUR paketleri güncellendi (yay)"
    elif command -v paru >/dev/null 2>&1; then
        paru -Syu --noconfirm
        success_msg "AUR paketleri güncellendi (paru)"
    else
        error_msg "AUR helper (yay/paru) bulunamadı"
    fi
    
    wait_key
}

# Paket veritabanı onarımı
repair_db() {
    echo -e "${PURPLE}=== PAKET VERİTABANI ONARILIYOR ===${NC}"
    echo
    
    info_msg "Pacman veritabanı kilidi kontrol ediliyor..."
    if [ -f "/var/lib/pacman/db.lck" ]; then
        sudo rm /var/lib/pacman/db.lck
        success_msg "Pacman kilidi kaldırıldı"
    fi
    
    info_msg "Paket veritabanı onarılıyor..."
    sudo pacman-db-upgrade
    success_msg "Veritabanı onarımı tamamlandı"
    
    wait_key
}

# Disk kullanım analizi
disk_usage() {
    echo -e "${PURPLE}=== DİSK KULLANIM ANALİZİ ===${NC}"
    echo
    
    echo -e "${YELLOW}Disk Kullanımı:${NC}"
    df -h / /home 2>/dev/null | grep -v "tmpfs"
    echo
    
    echo -e "${YELLOW}En Büyük Klasörler (/):${NC}"
    sudo du -sh /* 2>/dev/null | sort -hr | head -10
    echo
    
    echo -e "${YELLOW}Ev Dizini Kullanımı:${NC}"
    du -sh "$HOME"/* 2>/dev/null | sort -hr | head -10
    
    wait_key
}

# Sistem bilgileri
system_info() {
    echo -e "${PURPLE}=== SİSTEM BİLGİLERİ ===${NC}"
    echo
    
    echo -e "${YELLOW}İşletim Sistemi:${NC} $(uname -a)"
    echo -e "${YELLOW}Çekirdek:${NC} $(uname -r)"
    echo -e "${YELLOW}Uptime:${NC} $(uptime -p)"
    echo -e "${YELLOW}Bellek Kullanımı:${NC}"
    free -h
    echo
    echo -e "${YELLOW}CPU Bilgisi:${NC}"
    lscpu | grep "Model name" | sed 's/Model name://g' | xargs
    echo
    echo -e "${YELLOW}Yüklü Paket Sayısı:${NC} $(pacman -Q | wc -l)"
    
    wait_key
}

# Çöp dosyaları temizle
clean_trash() {
    echo -e "${PURPLE}=== ÇÖP DOSYALARI TEMİZLENİYOR ===${NC}"
    echo
    
    trash_size=$(get_size "$HOME/.local/share/Trash")
    info_msg "Çöp kutusu boyutu: $trash_size"
    
    if [ -d "$HOME/.local/share/Trash" ]; then
        rm -rf "$HOME/.local/share/Trash"/*
        success_msg "Çöp kutusu temizlendi"
    else
        info_msg "Çöp kutusu bulunamadı"
    fi
    
    wait_key
}

# Thumbnails temizle
clean_thumbnails() {
    echo -e "${PURPLE}=== THUMBNAILS TEMİZLENİYOR ===${NC}"
    echo
    
    thumb_size=$(get_size "$HOME/.cache/thumbnails")
    info_msg "Thumbnails boyutu: $thumb_size"
    
    if [ -d "$HOME/.cache/thumbnails" ]; then
        rm -rf "$HOME/.cache/thumbnails"/*
        success_msg "Thumbnails temizlendi"
    else
        info_msg "Thumbnails klasörü bulunamadı"
    fi
    
    wait_key
}

# Eski çekirdekler temizle
clean_old_kernels() {
    echo -e "${PURPLE}=== ESKİ ÇEKİRDEKLER TEMİZLENİYOR ===${NC}"
    echo
    
    current_kernel=$(uname -r)
    info_msg "Mevcut çekirdek: $current_kernel"
    
    old_kernels=$(pacman -Q | grep -E "^linux[0-9]" | grep -v "$(echo $current_kernel | sed 's/-.*//g')")
    
    if [ -n "$old_kernels" ]; then
        echo "Eski çekirdekler:"
        echo "$old_kernels"
        echo
        read -p "Bu çekirdekleri kaldırmak istiyor musunuz? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "$old_kernels" | awk '{print $1}' | xargs sudo pacman -R --noconfirm
            success_msg "Eski çekirdekler kaldırıldı"
        fi
    else
        success_msg "Eski çekirdek bulunamadı"
    fi
    
    wait_key
}

# Flatpak temizliği
clean_flatpak() {
    echo -e "${PURPLE}=== FLATPAK TEMİZLENİYOR ===${NC}"
    echo
    
    if command -v flatpak >/dev/null 2>&1; then
        info_msg "Kullanılmayan Flatpak runtime'ları temizleniyor..."
        flatpak uninstall --unused -y
        success_msg "Flatpak temizliği tamamlandı"
    else
        info_msg "Flatpak yüklü değil"
    fi
    
    wait_key
}

# Snap temizliği
clean_snap() {
    echo -e "${PURPLE}=== SNAP TEMİZLENİYOR ===${NC}"
    echo
    
    if command -v snap >/dev/null 2>&1; then
        info_msg "Eski snap sürümleri temizleniyor..."
        snap list --all | awk '/disabled/{print $1, $3}' | while read snapname revision; do
            sudo snap remove "$snapname" --revision="$revision"
        done
        success_msg "Snap temizliği tamamlandı"
    else
        info_msg "Snap yüklü değil"
    fi
    
    wait_key
}

# Tüm temizlik işlemleri
full_cleanup() {
    echo -e "${PURPLE}=== TÜM TEMİZLİK İŞLEMLERİ BAŞLATIYOR ===${NC}"
    echo
    
    clean_tmp
    clean_cache
    clean_paccache
    clean_logs
    clean_orphans
    clean_trash
    clean_thumbnails
    clean_flatpak
    clean_snap
    
    success_msg "Tüm temizlik işlemleri tamamlandı!"
    wait_key
}

# Sistem durumu kontrolü
system_status() {
    echo -e "${PURPLE}=== SİSTEM DURUMU KONTROLÜ ===${NC}"
    echo
    
    echo -e "${YELLOW}Servis Durumu:${NC}"
    systemctl --failed --no-pager
    echo
    
    echo -e "${YELLOW}Güncel olmayan paketler:${NC}"
    checkupdates 2>/dev/null | wc -l | xargs echo
    echo
    
    echo -e "${YELLOW}Disk Durumu:${NC}"
    df -h / | tail -1 | awk '{print "Kullanım: " $5 " (" $3 "/" $2 ")"}'
    echo
    
    echo -e "${YELLOW}Bellek Durumu:${NC}"
    free -h | grep "Mem:" | awk '{print "Kullanım: " $3 "/" $2}'
    
    wait_key
}

# Ana döngü
main() {
    while true; do
        show_banner
        show_menu
        
        echo -ne "${CYAN}Seçiminizi yapın [0-17]: ${NC}"
        read choice
        
        case $choice in
            1) clean_tmp ;;
            2) clean_cache ;;
            3) clean_paccache ;;
            4) clean_logs ;;
            5) clean_orphans ;;
            6) update_system ;;
            7) update_aur ;;
            8) repair_db ;;
            9) disk_usage ;;
            10) system_info ;;
            11) clean_trash ;;
            12) clean_thumbnails ;;
            13) clean_old_kernels ;;
            14) clean_flatpak ;;
            15) clean_snap ;;
            16) full_cleanup ;;
            17) system_status ;;
            0) 
                echo -e "${GREEN}Güle güle!${NC}"
                exit 0
                ;;
            *)
                error_msg "Geçersiz seçim! Lütfen 0-17 arası bir sayı girin."
                wait_key
                ;;
        esac
    done
}

# Scripti çalıştır
main