#!/bin/bash

network()(

  network_test(){

    for ((i = 0 ; i <= 100 ; i+=25)); do
        ping -q -c 1 archlinux.org &>/dev/null
        local exitcode=$?
        echo $i
        sleep 1
    done | whiptail --gauge "Checking network connection..." 6 50 0

    if [ "$?" != "0" ]; then
      whiptail --title "ERROR" --msgbox "Network unreachable.\Exit status: ${?}" 8 78
      network_connect
    fi

    dialog

  }

  network_connect(){

    nmcli radio wifi on

    # List WiFi devices: nmcli device wifi list

    ssid=$(whiptail --inputbox "Network SSID" --title "Network connection" 8 39 3>&1 1>&2 2>&3)

      if [ $? != "0" ]; then
        whiptail --title "ERROR" --msgbox "Invalid network SSID.\Exit status: ${?}" 8 78
        network_connect
      fi

    password=$(whiptail --passwordbox "Network passphrase" 8 78 --title "Network connection" 3>&1 1>&2 2>&3)

      if [ $? != "0" ]; then
        whiptail --title "ERROR" --msgbox "Invalid network password.\Exit status: ${?}" 8 78
        network_connect
      fi

    nmcli device wifi connect ${ssid} password ${password}

    if [ "$?" != "0" ]; then
      whiptail --title "ERROR" --msgbox "cannot connect to network.\nExit status: ${?}" 8 78
      exit $1
    fi

    dialog

  }

  network_test

)

dialog()(

  aur(){

    options=()
    options+=("Paru" "[Rust]")
    options+=("Pikaur" "[Python]")
    options+=("Yay" "[Go]")

    aurhelper=$(whiptail --title "AUR helper" --menu "Select AUR helper" --default-item "Paru" --noitem --cancel-button "Exit" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" == "0" ]; then
        case ${aurhelper} in
          "Paru")
            aurhelper="paru"
            aurhelper_package="paru-bin"
            ;;
          "Pikaur")
            aurhelper="pikaur"
            aurhelper_package="pikaur"
            ;;
          "Yay")
            aurhelper="yay"
            aurhelper_package="yay-bin"
            ;;
        esac
        bw_client
      else
        case ${exitcode} in
          1)
            clear
            exit ${exitcode}
            ;;
          *)
            echo "Exit status ${exitcode}"
            exit ${exitcode}
            ;;
        esac
    fi

  }

  bw_client(){

    options=()
    options+=("Bitwarden_CLI" "[Bitwarden]")
    options+=("rbw" "[Bitwarden]")

    bwcli=$(whiptail --title "Bitwarden CLI" --menu "Select Bitwarden CLI" --default-item "rbw" --cancel-button "Back" --noitem 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" == "0" ]; then
        case ${bwcli} in
          "Bitwarden_CLI")
            whiptail --title "ERROR" --msgbox "The official Bitwarden CLI is not supported yet." 8 78
            bw_client
            ;;
        esac
      bw_email
      else
        case ${exitcode} in
          1)
            aur
            ;;
          *)
            echo "Exit status ${exitcode}"
            exit ${exitcode}
            ;;
        esac
    fi

  }

  bw_email(){

    bw_email=$(whiptail --inputbox "Bitwarden CLI" --title "Bitwarden e-mail" --cancel-button "Back" 8 39 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      case ${exitcode} in
        1)
          bw_client
          ;;
        *)
          echo "Exit status ${exitcode}"
          exit $?
          ;;
      esac
    fi

    if [ ! ${bw_email} ]; then
      whiptail --title "ERROR" --msgbox "Bitwarden e-mail cannot be empty." 8 78
      bw_email
    fi

    github_email

  }

  github_email(){

    gh_email=$(whiptail --inputbox "GitHub e-mail" --title "GitHub" --cancel-button "Back" 8 39 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      case ${exitcode} in
        1)
          bw_email
          ;;
        *)
          echo "Exit status $?"
          exit $?
          ;;
      esac
    fi

    if [ ! ${gh_email} ]; then
      whiptail --title "ERROR" --msgbox "GitHub e-mail cannot be empty." 8 78
      github_email
    fi

    github_pubkey

  }

  github_username(){

    gh_username=$(whiptail --inputbox "GitHub username" --title "GitHub" --cancel-button "Back" 8 39 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      case ${exitcode} in
        1)
          github_email
          ;;
        *)
          echo "Exit status $?"
          exit $?
          ;;
      esac
    fi

    if [ ! ${gh_username} ] ; then
      whiptail --title "ERROR" --msgbox "GitHub username cannot be empty." 8 78
      github_username
    fi

    github_pubkey

  }

  github_pubkey(){

    gh_pubkeyname=$(whiptail --inputbox "GitHub" --title "GitHub SSH key" --cancel-button "Back" 8 39 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      case ${exitcode} in
        1)
          github_email
          ;;
        *)
          echo "Exit status $?"
          exit $?
          ;;
      esac
    fi

    if [ ! ${gh_pubkeyname} ] ; then
      whiptail --title "ERROR" --msgbox "GitHub SSH key name cannot be empty." 8 78
      github_pubkey
    fi

    ssh_passphrase

  }

  ssh_passphrase(){

    ssh_passphrase=$(whiptail --passwordbox "SSH passphrase" --title "SSH" --nocancel 8 78 3>&1 1>&2 2>&3)

    ssh_passphrase_confirm=$(whiptail --passwordbox "SSH passphrase [confirm]" --title "SSH" --nocancel 8 78 3>&1 1>&2 2>&3)

    if [ ! ${ssh_passphrase} ] || [ ! ${ssh_passphrase_confirm} ]; then
      whiptail --title "ERROR" --msgbox "SSH passphrase cannot be empty." 8 78
      ssh_passphrase
    fi

    if [ ${ssh_passphrase} != ${ssh_passphrase_confirm} ]; then
      whiptail --title "ERROR" --msgbox "SSH passphrase did not match." 8 78
      ssh_passphrase
    fi

    window_manager

  }

  window_manager(){

    options=()
    options+=("dwm" "[C]")
    options+=("i3" "[C]")
    options+=("LeftWM" "[Rust]") # bar dependency
    options+=("OpenBox" "[C]") # bar dependency
    options+=("Qtile" "[Python]")

    windowmanager=$(whiptail --title "Window Manager" --menu "Select a window manager" --default-item "Qtile" --cancel-button "Back" --noitem 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
        case ${exitcode} in
          1)
            github_email
            ;;
          *)
            echo "Exit status ${exitcode}"
            exit $?
            ;;
        esac
    fi

    terminal

  }

  terminal(){

    options=()
    options+=("Alacritty" "[Rust]")
    options+=("kitty" "[Python]")
    options+=("None" "[-]")

    terminal_select=$(whiptail --title "Terminal" --menu "Select a terminal emulator" --default-item "Alacritty" --noitem --cancel-button "Back" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      case ${exitcode} in
        1)
          window_manager
          ;;
        *)
          echo "Exit status ${exitcode}"
          exit ${exitcode}
          ;;
      esac
    fi

    browser

  }

  browser(){

    options=()
    options+=("Chromium" "[Chromium]")
    options+=("LibreWolf" "[Firefox]")
    options+=("qutebrowser" "[qt5]")
    options+=("None" "[-]")

    browser_select=$(whiptail --title "Browser" --menu "Select a browser" --default-item "LibreWolf" --noitem --cancel-button "Back" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      case ${exitcode} in
        1)
          terminal
          ;;
        *)
          echo "Exit status ${exitcode}"
          exit ${exitcode}
          ;;
      esac
    fi

    ide

  }

  ide(){

    options=()
    options+=("Visual_Studio_Code" "[Visual_Studio_Code]")
    options+=("VSCodium" "[Visual_Studio_Code]")
    options+=("None" "[-]")

    ide_select=$(whiptail --title "IDE" --menu "Select an IDE" --default-item "VSCodium" --noitem --cancel-button "Back" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      case ${exitcode} in
        1)
          browser
          ;;
        *)
          echo "Exit status ${exitcode}"
          exit ${exitcode}
          ;;
      esac
    fi

    texteditor

  }

  texteditor(){

    options=()
    options+=("Emacs" "[Emacs]")
    options+=("Nano" "[Console]")
    options+=("Neovim" "[Vi]")
    options+=("Vi" "[Vi]")
    options+=("Vim" "[Vi]")
    options+=("None" "[-]")

    texteditor_select=$(whiptail --title "Text editor" --menu "Select a text editor" --default-item "Neovim" --noitem --cancel-button "Back" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
        case ${exitcode} in
          1)
            ide
            ;;
          *)
            echo "Exit status ${exitcode}"
            exit ${exitcode}
            ;;
        esac
    fi

    application_launcher

  }

  application_launcher(){

    options=()
    options+=("dmenu" "[Suckless]")
    options+=("dmenu2" "[Suckless]")
    options+=("dmenu-rs" "[Shizcow]")
    options+=("rofi" "[davatorium]")
    options+=("None" "[-]")

    applauncher_select=$(whiptail --title "Application launcher" --menu "Select application launcher" --default-item "dmenu-rs" --noitem --cancel-button "Back" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
        case ${exitcode} in
          1)
            texteditor
            ;;
          *)
            echo "Exit status ${exitcode}"
            exit ${exitcode}
            ;;
        esac
    fi

    task_manager

  }

  task_manager()(

    options=()
    options+=("bpytop" "[aristocratos]")
    options+=("htop" "[htop-dev]")
    options+=("None" "[-]")

    sysmonitor_select=$(whiptail --title "Task manager" --menu "Select a task manager" --default-item "htop" --noitem --cancel-button "Back" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
        case ${exitcode} in
          1)
            application_launcher
            ;;
          *)
            echo "Exit status ${exitcode}"
            exit ${exitcode}
            ;;
        esac
    fi

    system_monitor

  )

  system_monitor()(

    options=()
    options+=("Conky" "[Emacs]")
    options+=("None" "[-]")

    texteditor_select=$(whiptail --title "System monitor" --menu "Select a systemmonitor" --default-item "Conky" --noitem --cancel-button "Back" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
        case ${exitcode} in
          1)
            task_manager
            ;;
          *)
            echo "Exit status ${exitcode}"
            exit ${exitcode}
            ;;
        esac
    fi

    audio

  )

  audio(){

    options=()
    options+=("ALSA" "[Advanced_Linux_Sound_Architecture]")
    options+=("PipeWire" "[PipeWire]")

    audio_select=$(whiptail --title "Audio" --menu "Select audio backend" --default-item "PipWire" --noitem 25 78 17 --cancel-button "Back" ${options[@]} 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
        case ${exitcode} in
          1)
            system_monitor
            ;;
          *)
            echo "Exit status ${exitcode}"
            exit ${exitcode}
            ;;
        esac
    fi

    music

  }

  music(){

    options=()
    options+=("Spotify" "[Spotify_GmbH]")
    options+=("Spotify_TUI" "[Spotifyd]")
    options+=("None" "[-]")

    music_select=$(whiptail --title "Music" --menu "Select music streaming client" --default-item "Spotify TUI" --noitem 25 78 17 --cancel-button "Back" ${options[@]} 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
        case ${exitcode} in
          1)
            audio
            ;;
          *)
            echo "Exit status ${exitcode}"
            exit ${exitcode}
            ;;
        esac
    fi

    #x11
    zsh_prompt

  }

  x11(){

    # If Wayland is not implemented
    sudo pacman -S --noconfirm xorg-server xorg-xinit xorg-prop xwallpaper arandr unclutter
    local exitcode=$?

  }

  zsh_prompt(){

    options=()
    options+=("Spaceship" "[spaceship-prompt]")
    options+=("Starship" "[Starship]")

    prompt_select=$(whiptail --title "ZSH prompt" --menu "Select ZSH prompt" --default-item "Starship" --noitem --cancel-button "Back" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
        case ${exitcode} in
          1)
            music
            ;;
          *)
            echo "Exit status ${exitcode}"
            exit ${exitcode}
            ;;
        esac
    fi

    microcode

  }

  microcode(){

    options=()
    options+=("AMD" "[Advanced_Micro_Devices]")
    options+=("Intel" "[Intel_Corporation]")
    options+=("None" "[-]")

    microcode_select=$(whiptail --title "CPU microcode" --menu "Select CPU microcode" --default-item "Intel" --noitem --cancel-button "Back" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
        case ${exitcode} in
          1)
            zsh_prompt
            ;;
          *)
            echo "Exit status ${exitcode}"
            exit ${exitcode}
            ;;
        esac
    fi

    compositor

  }

  compositor(){

    options=()
    options+=("Picom" "[Picom]")
    options+=("None" "[-]")

    compositor_select=$(whiptail --title "Compositor" --menu "Select compositor" --default-item "Picom" --noitem --cancel-button "Back" 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
        case ${exitcode} in
          1)
            microcode
            ;;
          *)
            echo "Exit status ${exitcode}"
            exit ${exitcode}
            ;;
        esac
    fi

    languages

  }

  languages(){

    options=()
    options+=("All" "[-]")
    options+=("Python" "[Python]")
    options+=("Rust" "[Rust]")
    options+=("None" "[-]")

    language_select=$(whiptail --title "Programming language" --menu "Select programming language" --default-item "All" --cancel-button "Back" --noitem 25 78 17 ${options[@]} 3>&1 1>&2 2>&3)
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
        case ${exitcode} in
          1)
            compositor
            ;;
          *)
            echo "Exit status ${exitcode}"
            exit ${exitcode}
            ;;
        esac
    fi

    coreutils

  }

  coreutils(){

    if (whiptail --title "Core utilities" --yesno "Install core utilities\n[cmatrix, neofetch, unzip, zip]" 8 78); then
        coreutils_install="yes"
      else
        coreutils_rust
    fi

    coreutils_rust

  }

  coreutils_rust(){

    if (whiptail --title "Core utilities [Rust]" --yesno "Install core utilities [Rust]\n[bat, lsd, zoxide]" 8 78); then
        coreutils_install_rust="yes"
      else
        configs
    fi

    install

  }

  aur

)

install()(

  aur()(

    git clone https://aur.archlinux.org/${aurhelper_package}.git $HOME/.local/src/${aurhelper} 1&>/dev/null
    cd $HOME/.local/src/${aurhelper}
    makepkg -si --noconfirm
    cd $HOME

    bwclient

  )

  bwclient(){

    sudo pacman -S --noconfirm --quiet ${bwcli}

    github

  }

  github(){

    sudo pacman -S --noconfirm github-cli

    window_manager

  }

  window_manager(){

    case ${windowmanager} in
      "dwm")
        # dwm install
        ;;
      "i3")
        sudo pacman -S --needed --noconfirm i3-wm
        # Overwrite .xinitrc
        ;;
      "LeftWM")
        ${aurhelper} -S --noconfirm leftwm
        # Overwrite .xinitrc
        # Bar dependency
        ;;
      "OpenBox")
        sudo pacman -S --needed --noconfirm openbox tint2
        # Overwrite .xinitrc
        # Bar dependency
        ;;
      "Qtile")
        sudo pacman -S --needed --noconfirm qtile
        # Overwrite .xinitrc
        ;;
    esac

    terminal

  }

  terminal(){

    case ${terminal_select} in
      "Alacritty")
        sudo pacman -S alacritty
        ;;
      "kitty")
        sudo pacman -S kitty
        ;;
      "None")
        browser
    esac

    browser

  }

  browser(){

    case ${browser_select} in
      "Chromium")
        pacman -S --noconfirm chromium
        ;;
      "LibreWolf")
        paru -S --noconfirm librewolf-bin
        ;;
      "qutebrowser")
        pacman -S --noconfirm qutebrowser
        ;;
      "None")
        ide
        ;;
    esac

    ide

  }

  ide(){

    case ${ide_select} in
      "Visual_Studio_Code")
        sudo pacman -S --noconfirm code
        ;;
      "VSCodium")
        ${aurhelper} -S --noconfirm vscodium-bin
        ;;
      "None")
        texteditor
        ;;
    esac

    texteditor

  }

  texteditor(){

    case ${texteditor_select} in
      "Emacs")
        sudo pacman -S --noconfirm emacs
        ;;
      "Nano")
        sudo pacman -S --noconfirm nano
        ;;
      "Neovim")
        sudo pacman -S --noconfirm neovim
        ;;
      "Vi")
        sudo pacman -S --noconfirm vi
        ;;
      "Vim")
        sudo pacman -S --noconfirm vim
        ;;
      "None")
        application_launcher
        ;;
    esac

    application_launcher

  }

  application_launcher(){

    case ${applauncher_select} in
      "dmenu")
        ${aurhelper} -S --noconfirm dmenu-git
        ;;
      "dmenu2")
        ${aurhelper} -S --noconfirm dmenu2
        ;;
      "dmenu-rs")
        ${aurhelper} -S --noconfirm dmenu-rs-git
        ;;
      "rofi")
        sudo pacman -S --noconfirm rofi
        ;;
      "None")
        task_manager
        ;;
    esac

    task_manager

  }

  task_manager(){

    case ${taskmanager_select} in
      "bpytop")
        sudo pacman -S --noconfirm bpytop
        ;;
      "htop")
        sudo pacman -S --noconfirm htop
        ;;
      "None")
        system_monitor
        ;;
    esac

    system_monitor

  }

  system_monitor(){

    case ${texteditor_select} in
      "Conky")
        sudo pacman -S --noconfirm conky
        ;;
      "None")
        audio
        ;;
    esac

    audio

  }

  audio(){

    case ${audio_select} in
      "ALSA")
        sudo pacman -S --noconfirm alsa alsa-firmware alsa-utils sof-firmware
        ;;
      "PipWire")
        sudo pacman -S --noconfirm pipewire pipewire-alsa pavucontrol sof-firmware
        ;;
      "None")
        texteditor
        ;;
    esac

    texteditor

  }

  music(){

    case ${music_select} in
      "Spotify")
        ${aurhelper} -S --noconfirm spotify
        ;;
      "Spotify_TUI")
        ${aurhelper} -S --noconfirm spotify-tui-bin spotifyd
        ;;
      "None")
        x11
        ;;
    esac

    zsh_prompt

  }

  #x11

  zsh_prompt(){

    case ${prompt_select} in
      "Spaceship")
        sudo pacman -S --noconfirm zsh zsh-syntax-highlighting
        ${aurhelper} -S --noconfirm spaceship-prompt
        ;;
      "Starship")
        sudo pacman -S --noconfirm zsh zsh-syntax-highlighting starship
        ;;
    esac

    man

  }

  man(){

    case ${manpages_select} in
      "man-db")
        sudo pacman -S --noconfirm man-db
        ;;
      "tldr")
        sudo pacman -S --noconfirm tldr
        ;;
      "Both")
        sudo pacman -S --noconfirm man-db tldr
        ;;
      "None")
        microcode
        ;;
    esac

    microcode

  }

  microcode(){

    case ${microcode} in
      "AMD")
        sudo pacman -S --needed --noconfirm amd-ucode
        ;;
      "Intel")
        sudo pacman -S --needed --noconfirm intel-ucode xf-86-video-intel
        ;;
      "None")
        compositor
        ;;
    esac

    compositor


  }

  compositor(){

    case ${compositor_select} in
      "Picom")
        sudo pacman -S --needed --noconfirm picom
        ;;
      "None")
        languages
        ;;
    esac

    languages

  }

  languages(){

    case ${language_select} in
      "All")
        sudo pacman -S --needed --noconfirm python python-pip rust
        ;;
      "Python")
        sudo pacman -S --needed --noconfirm python python-pip
        ;;
      "Rust")
        sudo pacman -S --needed --noconfirm rust
        ;;
      "None")
        coreutils
        ;;
    esac

    coreutils

  }

  coreutils(){

    if [ ${coreutils_install} == "yes" ]; then
      sudo pacman -S --needed --noconfirm cmatrix neofetch unzip zip
    fi

    if [ ${coreutils_install_rust} == "yes" ]; then
      sudo pacman -S --needed --noconfirm bat lsd zoxide #exa
    fi

    bitwarden

  }

  aur

)

bitwarden()(

  rbw_register(){

    # E-mail
    rbw config set email ${bw_email}
    local exitcode=$?

    # Register
    error=$( rbw register 2>&1 )
    local exitcode2=$?

    if [ "${exitcode}" != "0" ] || [ "${exitcode2}" != "0" ]; then
      whiptail --title "ERROR" --yesno "${error}\n
      Exit status [rbw e-mail]: ${exitcode}\n
      Exit status [rbw register]: ${exitcode2}"
      --yes-button "Retry" --no-button "Exit" 18 78
      case ${exitcode} in
        0)
          rbw_register
          ;;
        1)
          clear
          echo "${error}"
          exit 1
          ;;
        *)
          clear
          echo "${error}"
          echo "Exit status $?"
          ;;
      esac
    fi

    rbw_login

  }

  rbw_login(){

    error=$( rbw sync 2>&1 )
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --yesno "${error}\nExit status: ${exitcode}" --yes-button "Retry" --no-button "Exit" 18 78
      case ${exitcode} in
        0)
          rbw_login
          ;;
        1)
          exit ${exitcode}
          ;;
        *)
          echo "Exit status ${exitcode}"
          ;;
      esac
    fi

    # GitHub PAT
    ghpat=$(rbw get GitHub_PAT)

    openssh

  }

  bwclient_select

)

openssh(){

  openssh_client(){

    # Start SSH agent
    eval "$(ssh-agent -s)"
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --yesno "Cannot start SSH client.\nExit status: ${exitcode}" --yes-button "Retry" --no-button "Exit" 18 78
      case ${exitcode} in
        0)
          openssh_client
          ;;
        1)
          exit ${exitcode}
          ;;
        *)
          echo "Exit status ${exitcode}"
          ;;
      esac
    fi

    github

  }

  openssh_client

}

github(){

  gh_ssh_keygen(){

    ssh-keygen -t ed25519 -N ${ssh_passphrase} -C ${gh_email} -f $HOME/.ssh/id_ed25519.pub
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --msgbox "Cannot generate SSH key.\Exit status: ${exitcode}" 8 78
      exit ${exitcode}
    fi

    clear

    ssh-add $HOME/.ssh/id_ed25519
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --msgbox "Cannot add SSH key to SSH agent.\Exit status: ${exitcode}" 8 78
      exit ${exitcode}
    fi

    gh_login

  }

  gh_login(){

    set -u
    cd $HOME
    echo "$ghpat" > .ghpat
    unset ghpat
    gh auth login --with-token < .ghpat
    local exitcode=$?

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --yesno "Cannot authenticate github with token [.ghpat].\nExit status: $?" --yes-button "Retry" --no-button "Exit" 18 78
      case ${exitcode} in
        0)
          gh_install_login
          ;;
        1)
          clear
          exit ${exitcode}
          ;;
        *)
          echo "Exit status $?"
          ;;
      esac
    fi

    rm .ghpat
    gh auth status
    sleep 5

    gh_pubkey

  }

  gh_pubkey(){

    gh ssh-key add $HOME/.ssh/id_ed25519.pub -t ${gh_pubkeyname}
    local exitcode=$?

    ssh -T git@github.com

    if [ "${exitcode}" != "0" ]; then
      whiptail --title "ERROR" --msgbox "GitHub SSH authentication unsuccessfull.\nExit status: ${exitcode}" 8 78
      exit ${exitcode}
    fi

    configs

  }

  gh_ssh_keygen

}

configs()(

  clone(){

    git clone git@github.com:${gh_username}/dotfiles.git $HOME/.config

    cd $HOME/.config

    git remote set-url origin git@github.com:${gh_username}/dotfiles.git

    cd $HOME

    systemd


  }

  systemd(){

    sudo cp $HOME/.config/systemd/logind.conf /etc/systemd/

    pacman

  }

  pacman(){

    sudo cp $HOME/.config/_system/pacman/pacman.conf /etc/

    zsh

  }

  zsh(){

    # Change shell to ZSH
    chsh -s /usr/bin/zsh

    # Copy zshenv
    sudo cp $HOME/.config/zsh/global/zshenv /etc/zsh/zshenv

    # Copy zprofile
    sudo cp $HOME/.config/zsh/global/zprofile /etc/zsh/zprofile
    copycheck

    # ZSH Autocomplete
    git clone --depth 1 https://github.com/marlonrichert/zsh-autocomplete.git $HOME/.local/src/zsh-autocomplete/

    customization

  }

)

customization()(

  wallpaper(){

    mkdir $HOME/Downloads

    # Fetch wallpapers from Dropbox
    curl -L -o $HOME/Downloads/wallpapers.zip "https://www.dropbox.com/sh/eo65dcs7buprzea/AABSnhAm1sswyiukCDW9Urp9a?dl=1"

    # Unzip
    unzip $HOME/Downloads/wallpapers.zip -d $HOME/Downloads/Wallpapers/ -x /

    cleanup

  }

  cleanup(){

    #Cargo
    mkdir $HOME/.local/share/cargo
    mv $HOME/.cargo $HOME/.local/share/cargo

    #Bash: Removing files from $HOME
    mkdir $HOME/.local/share/bash
    mv $HOME/.bash* $HOME/.local/share/bash

    success

  }

  success(){

    whiptail --title "SUCCESS" --msgbox "Arch installation has finished." 8 78
    exit 69

  }

  wallpaper

)

network
