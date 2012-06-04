#!/bin/sh
# Default acpi script that takes an entry for all actions

minspeed=`cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq`
maxspeed=`cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq`
setspeed="/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed"

set $*

case "$1" in
    button/power)
        case "$2" in
            PBTN|PWRF)
                logger "PowerButton pressed: $2"
                oblogout
                ;;
            *)
                logger "ACPI action undefined: $2"
                ;;
        esac
        ;;
    button/sleep)
        case "$2" in
            SLPB|SBTN)
                #echo -n mem >/sys/power/state
                pm-suspend
                ;;
            *)
                logger "ACPI action undefined: $2"
                ;;
        esac
        ;;
    ac_adapter)
        case "$2" in
            ACPI0003:00)
                case "$4" in
                    00000000)
                        /etc/rc.d/laptop-mode start
                        pm-powersave battery
                        echo "400" > /sys/class/backlight/intel_backlight/brightness
                        rmmod rts5139
                        logger "Entering Powersave State"
                        ;;
                    00000001)
                        /etc/rc.d/laptop-mode stop
                        pm-powersave ac
                        echo "900" > /sys/class/backlight/intel_backlight/brightness
                        modprobe rts5139
                        logger "Exiting Powersave State"
                        ;;
                esac
                ;;
            *)
                logger "ACPI action undefined: $2"
                ;;
        esac
        ;;
    battery)
        case "$2" in
            PNP0C0A:00)
                case "$4" in
                    00000000)
                        logger 'Battery online'
                        ;;
                    00000001)
                        logger 'Battery offline'
                        ;;
                esac
                ;;
            CPU0)
                ;;
            *)  logger "ACPI action undefined: $2" ;;
        esac
        ;;
    button/lid)
        case "$3" in
            close)
                logger 'LID closed, stopping conky'
                killall conky
                ;;
            open)
                logger 'LID opened, starting conky'
                /usr/bin/conky -q -c /home/humanshell/.dotfiles/arch/conkyrc
                /usr/bin/conky -q -c /home/humanshell/.dotfiles/arch/conkylogsrc
                ;;
            *)
                logger "ACPI action undefined: $3"
                ;;
        esac
    ;;
    video/brightnessdown)
        case "$2" in
            BRTDN)
                level=$(cat /sys/class/backlight/intel_backlight/brightness)
                if [[ $level > 100 ]]; then
                    echo $(($level-50)) > /sys/class/backlight/intel_backlight/brightness
                fi
            ;;
        esac
    ;;
    video/brightnessup)
        case "$2" in
            BRTUP)
                level=$(cat /sys/class/backlight/intel_backlight/brightness)
                if [[ $level < 976 ]]; then
                    echo $(($level+50)) > /sys/class/backlight/intel_backlight/brightness
                fi
            ;;
        esac
    ;;
    *)
        logger "ACPI group/action undefined: $1 / $2"
        ;;
esac

# vim:set ts=4 sw=4 ft=sh et: