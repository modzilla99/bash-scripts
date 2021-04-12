#!/bin/bash

REALM=
RADM=

function test_domain_mem {
    [[ -e "/usr/sbin/realm" ]] || {
        return 0
    }
    [[ -z "$( realm list )" ]] || {
        echo "The system is already enrolled in a domain."
        echo "Exiting now..."
        exit 1
    }
}

function elevate {
    [[ "$( id -u )" -ne "0" ]] && {
        echo "Restarting as root."
        sudo $0 $@
        exit $?
    }
}

function silent_apt {
    DEBIAN_FRONTEND=noninteractive apt -y $@ &>/dev/null || {
        printf "Error\n"
        echo "Error while installing deps."
        exit 1
    }
}

function install_dependencies {
    local DEPENDS="realmd libnss-sss libpam-sss sssd sssd-tools adcli samba-common-bin"

    printf "Installing dependencies..."
    silent_apt update
    silent_apt install $DEPENDS
    printf "Done\n"
}

function set_discovery {
    export HOSTNAME=$(basename $(cat /etc/hostname) .$REALM)

    [[ "$HOSTNAME" == "$(cat /etc/hostname)" ]] && {
        hostnamectl set-hostname ${HOSTNAME}.${REALM}
    }

    realm discover $REALM &>/dev/null || {
        echo "Error discovering realm."
        echo "Exiting now..."
        exit 1
    }
}

function join_ad {
    echo "Are you planning on creating samba shares on this pc? [Default: no]"
    read ANS

    case "$ANS" in
        y | Y | yes | Yes | YES )
            local JSOFT=winbind
            echo "The domain will be joined with winbind."
        ;;

        *)
            local JSOFT=sssd
            echo "The domain will be joined with sssd."
        ;;
    esac
    unset ANS

    local COU=$(
        printf "CN=Computers"
        for i in $(echo ${REALM//./ }); do
            printf ",DC=${i}"
        done
    )
    echo "Please specify the Organizational Unit in which the computer will be put in (eg. OU=Linux,OU=Server,OU=Devices,OU=VOPLAB.loc,DC=voplab,DC=loc) [Default: ${COU}]:"
    read ANS

    [[ ! -z "$ANS" ]] && {
        echo "Is \"${ANS}\" correct?"
        read ANS2

        case "$ANS2" in
            y | Y | yes | Yes | YES )
                local COU=$ANS
            ;;

            *)
                join_ad
            ;;
        esac
        unset ANS2
    }

    unset ANS

    source /etc/lsb-release

    realm join --client-software=$JSOFT --computer-ou "${COU}" --computer-name $HOSTNAME --os-name $DISTRIB_ID --os-version $DISTRIB_RELEASE -U $RADM $REALM &>/tmp/dom-join.log || {
        echo "Error joining the domain."
        echo "Exiting now..."
        exit 1
    }

    pam-auth-update --enable mkhomedir &>/dev/null || {
        echo "Error enabling automatic homdir creation."
    }
}

function permit_users {
    echo "Which groups do you want to grant access to? ( put in a comma seperated list eg. group1,Group 2)"
    IFS="," read -a SGROUPS

    PERMIT=""
    START=0
    END=${#SGROUPS[@]}

    while [[ $START -ne $END ]]; do
        PERMIT="${PERMIT} \"${SGROUPS[$START]}\""
        START=$(( $START + 1 ))
    done

    realm permit -g $PERMIT &>/dev/null || {
        echo "Error permitting ${SGROUPS} access to the system."
        echo "Maybe wrong group?"
        permit_users
        exit $?
    }

}

function enable_sudo {
    printf "Granting groups sudo permissions..."
    local SUDO="/etc/sudoers.d/100-sssd.conf"

    [[ -e "$SUDO" ]] && {
        printf "sudoers file exists, making a backup in /root/..."
        mv -f $SUDO /root/$(basename $SUDO .conf)
    }

    printf "# Authenticated Active diretory groups that have access to sudo\n# eg. %%VOP-LAB-LinuxUpdater@voplab.loc     ALL=(ALL) NOPASSWD:/usr/bin/apt update, /usr/bin/apt upgrade\n\n" > $SUDO

    PERMIT=""
    START=0
    END=${#SGROUPS[@]}

    while [[ $START -ne $END ]]; do
        printf "%%${SGROUPS[$START]}@${REALM}     ALL=(ALL)   ALL\n" >> $SUDO
        START=$(( $START + 1 ))
    done


    chmod 0440 $SUDO
    systemctl restart sssd
    printf "Done\n"
}

function auth_info {
    #to invalidate sssd cache and update group assoc

    sss_cache -u "jlamp-adm@voplab.loc"

    # to invalidate complete sssd cache
    sss_cache -E

    # To make manual changes to auth

    $EDITOR /etc/sssd/sssd.conf
}

test_domain_mem
elevate

echo "Which domain do you want to join? ( eg example.com )"
read REALM

echo "Which user do you want to use for that?"
read RADM


install_dependencies
set_discovery
join_ad
permit_users
enable_sudo
