#!/bin/bash

# Logovací soubor
USER_HOME=$(eval echo "~$SUDO_USER")
LOG_FILE="$USER_HOME/install_script.log"

# Uvítací obrazovka
clear
echo "========================================="
echo " Vítejte v postinstalačním skriptu pro openSUSE Tumbleweed"
echo " KDE Desktop"
echo "========================================="
sleep 2

# Kontrola spuštění skriptu jako root
if [ "$EUID" -ne 0 ]; then
    echo "Tento skript musí být spuštěn s právy root. Použijte sudo."
    exit 1
fi

# Funkce pro logování zpráv
log_message() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# Kontrola připojení k internetu
check_internet_connection() {
    log_message "Kontrola připojení k internetu..."
    if ping -c 1 opensuse.org &>/dev/null; then
        log_message "Internetové připojení je dostupné."
    else
        log_message "Internetové připojení není dostupné. Zkontrolujte připojení a spusťte skript znovu."
        exit 1
    fi
}

# Kontrola a instalace závislostí
check_dependencies() {
    log_message "Kontrola a instalace závislostí..."
    DEPENDENCIES=(wget flatpak kwriteconfig5)
    for dep in "${DEPENDENCIES[@]}"; do
        if ! command -v $dep &>/dev/null; then
            log_message "$dep není nainstalován. Instalace..."
            zypper -n in $dep
        fi
    done
}

# Univerzální funkce pro přidání repozitáře
add_repository() {
    local repo_name="$1"
    local repo_url="$2"
    local priority="${3:-99}"

    if zypper lr | grep -q "$repo_name"; then
        log_message "$repo_name repozitář již existuje."
    else
        log_message "Přidání $repo_name repozitáře..."
        zypper -n ar -cfp "$priority" -f "$repo_url" "$repo_name"
        if [ $? -eq 0 ]; then
            zypper --gpg-auto-import-keys ref
            log_message "$repo_name repozitář byl úspěšně přidán."
        else
            log_message "Chyba při přidávání $repo_name repozitáře."
        fi
    fi
}

# Přidání a preferování Packman repozitáře
add_packman_repo() {
    add_repository "packman" "https://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/" 90
    log_message "Nastavení Packman repozitáře jako preferovaného..."
    zypper --non-interactive dup --auto-agree-with-licenses --from packman --allow-vendor-change
}

# Povolení a zakázání automatického přijímání licencí
enable_auto_accept_license() {
    log_message "Povolení automatického přijímání licencí..."
    sed -i 's/# autoAgreeWithLicense = no/autoAgreeWithLicense = yes/' /etc/zypp/zypper.conf
}

disable_auto_accept_license() {
    log_message "Zakázání automatického přijímání licencí..."
    sed -i 's/autoAgreeWithLicense = yes/autoAgreeWithLicense = no/' /etc/zypp/zypper.conf
}

# Přidání NVIDIA repozitáře a instalace ovladačů
install_nvidia_drivers() {
    add_repository "NVIDIA" "https://download.nvidia.com/opensuse/tumbleweed"

    enable_auto_accept_license
    log_message "Instalace NVIDIA driverů..."
    zypper --non-interactive install-new-recommends --repo NVIDIA

    if [ $? -eq 0 ]; then
        log_message "NVIDIA drivery byly úspěšně nainstalovány."
    else
        log_message "Chyba při instalaci NVIDIA driverů."
    fi

    disable_auto_accept_license
}

# Instalace CUDA knihoven
install_cuda() {
    add_repository "CUDA" "http://developer.download.nvidia.com/compute/cuda/repos/opensuse15/x86_64/" 100
    log_message "Instalace CUDA toolkit..."
    sudo zypper --non-interactive in --auto-agree-with-licenses cuda-toolkit
    if [ $? -eq 0 ]; then
        log_message "CUDA toolkit byl úspěšně nainstalován."
    else
        log_message "Chyba při instalaci CUDA toolkit."
    fi
}

# Aktualizace systému včetně Flatpaku
update_system() {
    log_message "Aktualizace systému..."
    zypper refresh
    zypper -n dup

    log_message "Aktualizace Flatpaku..."
    sudo -u $SUDO_USER flatpak update -y
}

# Záloha původního nastavení
backup_current_settings() {
    log_message "Záloha aktuálního nastavení..."
    sudo -u $SUDO_USER mkdir -p "$USER_HOME/.config-backup"
    sudo -u $SUDO_USER cp -r "$USER_HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" "$USER_HOME/.config-backup/" 2>/dev/null
    sudo -u $SUDO_USER cp -r "$USER_HOME/.config/kdeglobals" "$USER_HOME/.config-backup/" 2>/dev/null
    sudo -u $SUDO_USER cp -r "$USER_HOME/.local/share/color-schemes/" "$USER_HOME/.config-backup/" 2>/dev/null
}

# Interaktivní výběr vzhledu
select_appearance() {
    log_message "Výběr prvků vzhledu k instalaci."
    echo "Vyberte prvky vzhledu k instalaci (oddělené čárkou):"
    echo "1. Xela Breeze Darker (barevné schéma)"
    echo "2. Papirus Dark (ikony)"
    echo "3. Bibata Modern Dark (kurzor)"
    echo "4. Harmony 2 (zvuky)"
    echo "5. Tapeta"
    read -p "Zadejte čísla prvků vzhledu oddělená čárkou (např. 1,3,5): " appearance_choice
}

# Stažení a použití vzhledu Plasma
apply_selected_appearance() {
    backup_current_settings
    log_message "Použití vybraných prvků vzhledu..."
    IFS=',' read -r -a selected_appearance <<< "$appearance_choice"

    for index in "${selected_appearance[@]}"; do
        case $index in
            1)
                # Xela Breeze Darker
                log_message "Stahování Xela Breeze Darker..."
                mkdir -p "/usr/share/color-schemes"
                wget -O "/usr/share/color-schemes/XelaBreezeDarker.colors" https://github.com/xelaxefensor/xela-breeze-darker/raw/main/XelaBreezeDarker.colors
                if [ $? -eq 0 ]; then
                    log_message "Xela Breeze Darker byl úspěšně stažen."
                    # Aplikace barevného schématu pro uživatele
                    sudo -u $SUDO_USER kwriteconfig5 --file "$USER_HOME/.config/kdeglobals" --group General --key ColorScheme "XelaBreezeDarker"
                    sudo -u $SUDO_USER qdbus-qt5 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "location.reloadConfig()"
                else
                    log_message "Chyba při stahování Xela Breeze Darker."
                fi
                ;;
            2)
                # Papirus Dark
                log_message "Stahování Papirus Dark..."
                wget -O /tmp/papirus-icon-theme.tar.gz "https://github.com/PapirusDevelopmentTeam/papirus-icon-theme/archive/refs/tags/20240501.tar.gz"
                if [ $? -eq 0 ]; then
                    log_message "Stahování Papirus Dark proběhlo úspěšně."
                    mkdir -p "/usr/share/icons/"
                    tar --strip-components=1 -xvf /tmp/papirus-icon-theme.tar.gz -C "/usr/share/icons/"
                    # Aplikace ikonového tématu pro uživatele
                    sudo -u $SUDO_USER kwriteconfig5 --file "$USER_HOME/.config/kdeglobals" --group Icons --key Theme "Papirus-Dark"
                    sudo -u $SUDO_USER qdbus-qt5 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "location.reloadConfig()"
                else
                    log_message "Chyba při stahování ikon Papirus."
                fi
                ;;
            3)
                # Bibata Modern Dark
                log_message "Stahování Bibata Modern Dark..."
                wget -O /tmp/bibata-cursor.tar.xz https://github.com/ful1e5/Bibata_Cursor/releases/download/v2.0.7/Bibata-Modern-Classic.tar.xz
                if [ $? -eq 0 ]; then
                    log_message "Stahování Bibata Modern Dark proběhlo úspěšně."
                    mkdir -p "/usr/share/icons/"
                    tar -xvf /tmp/bibata-cursor.tar.xz -C "/usr/share/icons/"
                    # Aplikace kurzorového tématu pro uživatele
                    sudo -u $SUDO_USER kwriteconfig5 --file "$USER_HOME/.config/kcminputrc" --group Mouse --key cursorTheme "Bibata-Modern-Classic"
                    sudo -u $SUDO_USER qdbus-qt5 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "location.reloadConfig()"
                else
                    log_message "Chyba při stahování kurzoru Bibata."
                fi
                ;;
            4)
                # Harmony 2 zvuky
                log_message "Stahování Harmony 2 zvuků..."
                wget -O /tmp/harmony2-sounds.tar.gz https://git.gianmarco.gg/gianmarco/harmony2/releases/download/2.0.2/ds-harmony2-2.0.2.tar.gz
                if [ $? -eq 0 ]; then
                    log_message "Stahování Harmony 2 proběhlo úspěšně."
                    mkdir -p "/usr/share/sounds/harmony2"
                    tar -xvf /tmp/harmony2-sounds.tar.gz -C "/usr/share/sounds/harmony2"
                else
                    log_message "Chyba při stahování zvuků Harmony 2."
                fi
                ;;
            5)
                # Tapeta
                log_message "Stahování a nastavení tapety..."
                mkdir -p "/usr/share/wallpapers"
                wget -O "/usr/share/wallpapers/wallpaper.png" https://raw.githubusercontent.com/KDE/breeze/master/wallpapers/Next/contents/images_dark/base_size.png
                if [ $? -eq 0 ]; then
                    log_message "Tapeta byla úspěšně stažena."
                    # Použití kwriteconfig5 pro nastavení tapety pro uživatele
                    sudo -u $SUDO_USER kwriteconfig5 --file "$USER_HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" --group Containments --group 1 --group Wallpaper --group org.kde.image --group General --key Image "file:///usr/share/wallpapers/wallpaper.png"
                    sudo -u $SUDO_USER qdbus-qt5 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "location.reloadConfig()"
                else
                    log_message "Chyba při stahování tapety."
                fi
                ;;
            *)
                log_message "Neplatný výběr pro vzhled: $index"
                ;;
        esac
    done
}

# Interaktivní výběr softwaru
select_software() {
    log_message "Výběr softwaru k instalaci."
    echo "Vyberte software k instalaci (oddělené čárkou):"
    echo "1. Steam"
    echo "2. Lutris"
    echo "3. protonup-qt"  # Pokud je k dispozici v zypper
    echo "4. vesktop"       # Pokud je k dispozici v zypper
    echo "5. GIMP"
    echo "6. MPV"
    echo "7. Audacity"
    echo "8. Kdenlive"
    echo "9. Krita"
    echo "10. Blender"
    echo "11. Thunderbird"
    echo "12. OBS Studio"
    echo "13. Inkscape"
    echo "14. KDE Connect (kdeconnect-kde)"
    read -p "Zadejte čísla softwaru oddělená čárkou (např. 1,3,5): " software_choice
}

# Instalace vybraného softwaru
install_selected_software() {
    IFS=',' read -r -a selected_software <<< "$software_choice"
    declare -A software_packages=(
        [1]="steam"
        [2]="lutris"
        [3]="protonup-qt"
        [4]="vesktop"
        [5]="gimp"
        [6]="mpv"
        [7]="audacity"
        [8]="kdenlive"
        [9]="krita"
        [10]="blender"
        [11]="thunderbird"
        [12]="obs-studio"
        [13]="inkscape"
        [14]="kdeconnect-kde"
    )

    log_message "Instalace vybraného softwaru."
    for index in "${selected_software[@]}"; do
        package_name=${software_packages[$index]}
        # Instalace pomocí zypper
        if sudo zypper se -n $package_name &> /dev/null; then
            sudo zypper -n in $package_name
        else
            log_message "$package_name není dostupný v repozitáři."
        fi
    done
}

# Nastavení Power Limit pro NVIDIA GPU
set_nvidia_power_limit() {
    # Kontrola, jestli je nainstalován nvidia-utils-G06
    if ! rpm -q nvidia-utils-G06 &> /dev/null; then
        log_message "nvidia-utils-G06 není nainstalován. Instalace..."
        sudo zypper -n in --auto-agree-with-licenses nvidia-utils-G06
        if [ $? -eq 0 ]; then
            log_message "nvidia-utils-G06 byl úspěšně nainstalován."
        else
            log_message "Chyba při instalaci nvidia-utils-G06."
            return 1
        fi
    else
        log_message "nvidia-utils-G06 je již nainstalován."
    fi

    # Použijeme předem zadaný Power Limit
    power_limit=$1

    # Vytvoření skriptu pro nastavení power limitu
    log_message "Vytváření skriptu pro nastavení power limitu..."
    sudo bash -c "echo '#!/bin/bash' > /usr/local/bin/set_nvidia_power_limit.sh"
    sudo bash -c "echo 'nvidia-smi -pl $power_limit' >> /usr/local/bin/set_nvidia_power_limit.sh"
    sudo chmod +x /usr/local/bin/set_nvidia_power_limit.sh

    # Vytvoření systemd služby
    log_message "Vytváření systemd služby pro nastavení power limitu..."
    sudo bash -c "cat <<EOL > /etc/systemd/system/nvidia-power-limit.service
[Unit]
Description=Set NVIDIA GPU Power Limit
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/set_nvidia_power_limit.sh
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOL"

    # Povolení a spuštění služby
    sudo systemctl enable nvidia-power-limit.service
    sudo systemctl start nvidia-power-limit.service

    log_message "Power Limit pro NVIDIA GPU byl nastaven na ${power_limit}W."
}

# Hlavní skript
check_internet_connection
check_dependencies

echo "Vyberte akce, které chcete provést:"
echo "1. Přidat a preferovat Packman repozitář"
echo "2. Přidat NVIDIA repozitář a nainstalovat ovladače"
echo "3. Zaktualizovat systém včetně Flatpaku"
echo "4. Vybrat a použít vzhled Plasma"
echo "5. Vybrat a nainstalovat software"
echo "6. Nastavit Power Limit pro NVIDIA GPU"
echo "7. Restartovat systém na závěr"

read -p "Zadejte čísla akcí oddělená čárkou (např. 1,3,4): " actions

IFS=',' read -r -a selected_actions <<< "$actions"

# Výběr podkategorií před spuštěním hlavních akcí
for action in "${selected_actions[@]}"; do
    case $action in
        2)
            # Zeptat se na instalaci CUDA
            read -p "Chcete nainstalovat také CUDA? (y/n): " install_cuda_choice
            ;;
        4) select_appearance ;;
        5) select_software ;;
        6)
            # Zeptat se na hodnotu Power Limit
            read -p "Zadejte Power Limit pro NVIDIA GPU (ve wattech): " power_limit_value
            ;;
        *) ;;
    esac
done

# Spuštění hlavních akcí
for action in "${selected_actions[@]}"; do
    case $action in
        1) add_packman_repo ;;
        2)
            install_nvidia_drivers
            if [[ $install_cuda_choice == "y" || $install_cuda_choice == "Y" ]]; then
                install_cuda
            fi
            ;;
        3) update_system ;;
        4) apply_selected_appearance ;;
        5) install_selected_software ;;
        6) set_nvidia_power_limit $power_limit_value ;;
        7) RESTART="yes" ;;
        *) log_message "Neplatná akce: $action" ;;
    esac
done

if [[ $RESTART == "yes" ]]; then
    log_message "Restartování systému..."
    sudo reboot
fi

log_message "Hotovo."
