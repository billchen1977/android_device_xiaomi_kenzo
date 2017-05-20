#!/system/bin/sh
# Copyright (c) 2012-2013, The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of The Linux Foundation nor
#       the names of its contributors may be used to endorse or promote
#       products derived from this software without specific prior written
#       permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NON-INFRINGEMENT ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

#Enable adaptive LMK and set vmpressure_file_min
echo 1 > /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
echo 81250 > /sys/module/lowmemorykiller/parameters/vmpressure_file_min
MemTotalStr=`cat /proc/meminfo | grep MemTotal`
MemTotal=${MemTotalStr:16:8}
if [ $MemTotal -le 2097152 ]; then
    chmod 660 /sys/module/lowmemorykiller/parameters/minfree
    echo "14746,18432,22118,25805,40000,55000" > /sys/module/lowmemorykiller/parameters/minfree
fi

# Apply Scheduler and Governor settings for 8976
# SoC IDs are 266, 274, 277, 278

# HMP scheduler (big.Little cluster related) settings
echo 95 > /proc/sys/kernel/sched_upmigrate
echo 85 > /proc/sys/kernel/sched_downmigrate

echo 2 > /proc/sys/kernel/sched_window_stats_policy
echo 5 > /proc/sys/kernel/sched_ravg_hist_size

echo 3 > /sys/devices/system/cpu/cpu0/sched_mostly_idle_nr_run
echo 3 > /sys/devices/system/cpu/cpu1/sched_mostly_idle_nr_run
echo 3 > /sys/devices/system/cpu/cpu2/sched_mostly_idle_nr_run
echo 3 > /sys/devices/system/cpu/cpu3/sched_mostly_idle_nr_run
echo 3 > /sys/devices/system/cpu/cpu4/sched_mostly_idle_nr_run
echo 3 > /sys/devices/system/cpu/cpu5/sched_mostly_idle_nr_run
echo 3 > /sys/devices/system/cpu/cpu6/sched_mostly_idle_nr_run
echo 3 > /sys/devices/system/cpu/cpu7/sched_mostly_idle_nr_run

for devfreq_gov in /sys/class/devfreq/qcom,mincpubw*/governor
do
    echo "cpufreq" > $devfreq_gov
done

for devfreq_gov in /sys/class/devfreq/qcom,cpubw*/governor
do
    echo "bw_hwmon" > $devfreq_gov
    for cpu_io_percent in /sys/class/devfreq/qcom,cpubw*/bw_hwmon/io_percent
    do
        echo 20 > $cpu_io_percent
    done
    for cpu_guard_band in /sys/class/devfreq/qcom,cpubw*/bw_hwmon/guard_band_mbps
    do
        echo 30 > $cpu_guard_band
    done
done

for gpu_bimc_io_percent in /sys/class/devfreq/qcom,gpubw*/bw_hwmon/io_percent
do
    echo 40 > $gpu_bimc_io_percent
done
# disable thermal & BCL core_control to update interactive gov settings
echo 0 > /sys/module/msm_thermal/core_control/enabled
for mode in /sys/devices/soc.0/qcom,bcl.*/mode
do
    echo -n disable > $mode
done
for hotplug_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_mask
do
    bcl_hotplug_mask=`cat $hotplug_mask`
    echo 0 > $hotplug_mask
done
for hotplug_soc_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_soc_mask
do
    bcl_soc_hotplug_mask=`cat $hotplug_soc_mask`
    echo 0 > $hotplug_soc_mask
done
for mode in /sys/devices/soc.0/qcom,bcl.*/mode
do
    echo -n enable > $mode
done

# enable governor for power cluster
echo 1 > /sys/devices/system/cpu/cpu0/online
echo "interactive" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 80 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load
echo 20000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate
echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/io_is_busy
echo 40000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/min_sample_time
echo 400000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq

# enable governor for perf cluster
echo 1 > /sys/devices/system/cpu/cpu4/online
echo "interactive" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
echo 85 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/go_hispeed_load
echo 20000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate
echo 0 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/io_is_busy
echo 40000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/min_sample_time
echo 40000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/sampling_down_factor
echo 400000 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq
echo 60000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/max_freq_hysteresis

echo 59000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay
echo 1305600 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq
echo "691200:60 806400:80" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads
echo 1382400 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/hispeed_freq
echo "19000 1382400:39000" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay
echo "85 1382400:90 1747200:80" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads

# HMP Task packing settings for 8976
echo 30 > /proc/sys/kernel/sched_small_task
echo 20 > /sys/devices/system/cpu/cpu0/sched_mostly_idle_load
echo 20 > /sys/devices/system/cpu/cpu1/sched_mostly_idle_load
echo 20 > /sys/devices/system/cpu/cpu2/sched_mostly_idle_load
echo 20 > /sys/devices/system/cpu/cpu3/sched_mostly_idle_load
echo 20 > /sys/devices/system/cpu/cpu4/sched_mostly_idle_load
echo 20 > /sys/devices/system/cpu/cpu5/sched_mostly_idle_load
echo 20 > /sys/devices/system/cpu/cpu6/sched_mostly_idle_load
echo 20 > /sys/devices/system/cpu/cpu7/sched_mostly_idle_load

echo 0 > /proc/sys/kernel/sched_boost

# Enable input boost
echo "0:1017600 1:1017600 2:1017600 3:1017600 4:0 5:0" > /sys/module/cpu_boost/parameters/input_boost_freq
echo 1 > /sys/module/cpu_boost/parameters/input_boost_enabled

# Bring up all cores online
echo 1 > /sys/devices/system/cpu/cpu1/online
echo 1 > /sys/devices/system/cpu/cpu2/online
echo 1 > /sys/devices/system/cpu/cpu3/online
echo 1 > /sys/devices/system/cpu/cpu4/online
echo 1 > /sys/devices/system/cpu/cpu5/online
echo 1 > /sys/devices/system/cpu/cpu6/online
echo 1 > /sys/devices/system/cpu/cpu7/online

if [ `cat /sys/devices/soc0/revision` == "1.0" ]; then
    # Disable l2-pc and l2-gdhs low power modes
    echo N > /sys/module/lpm_levels/system/a53/a53-l2-gdhs/idle_enabled
    echo N > /sys/module/lpm_levels/system/a72/a72-l2-gdhs/idle_enabled
    echo N > /sys/module/lpm_levels/system/a53/a53-l2-pc/idle_enabled
    echo N > /sys/module/lpm_levels/system/a72/a72-l2-pc/idle_enabled
fi

# Enable LPM Prediction
echo 1 > /sys/module/lpm_levels/parameters/lpm_prediction

# Enable Low power modes
echo 0 > /sys/module/lpm_levels/parameters/sleep_disabled
# Disable L2 GDHS on 8976
echo N > /sys/module/lpm_levels/system/a53/a53-l2-gdhs/idle_enabled
echo N > /sys/module/lpm_levels/system/a72/a72-l2-gdhs/idle_enabled

# Enable sched guided freq control
echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_sched_load
echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_migration_notif
echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_sched_load
echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_migration_notif
echo 50000 > /proc/sys/kernel/sched_freq_inc_notify
echo 50000 > /proc/sys/kernel/sched_freq_dec_notify

# Enable core control
echo 2 > /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
echo 4 > /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
echo 68 > /sys/devices/system/cpu/cpu4/core_ctl/busy_up_thres
echo 40 > /sys/devices/system/cpu/cpu4/core_ctl/busy_down_thres
echo 100 > /sys/devices/system/cpu/cpu4/core_ctl/offline_delay_ms
echo 1 > /sys/devices/system/cpu/cpu4/core_ctl/is_big_cluster

# re-enable thermal & BCL core_control now
echo 1 > /sys/module/msm_thermal/core_control/enabled
for mode in /sys/devices/soc.0/qcom,bcl.*/mode
do
    echo -n disable > $mode
done
for hotplug_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_mask
do
    echo $bcl_hotplug_mask > $hotplug_mask
done
for hotplug_soc_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_soc_mask
do
    echo $bcl_soc_hotplug_mask > $hotplug_soc_mask
done
for mode in /sys/devices/soc.0/qcom,bcl.*/mode
do
    echo -n enable > $mode
done

# Enable timer migration to little cluster
echo 1 > /proc/sys/kernel/power_aware_timer_migration

#enable sched colocation and colocation inheritance
echo 130 > /proc/sys/kernel/sched_grp_upmigrate
echo 110 > /proc/sys/kernel/sched_grp_downmigrate
echo   1 > /proc/sys/kernel/sched_enable_thread_grouping

rm /data/system/perfd/default_values
start perfd

if [ -f /sys/devices/soc0/select_image ]; then
    # Let kernel know our image version/variant/crm_version
    image_version="10:"
    image_version+=`getprop ro.build.id`
    image_version+=":"
    image_version+=`getprop ro.build.version.incremental`
    image_variant=`getprop ro.product.name`
    image_variant+="-"
    image_variant+=`getprop ro.build.type`
    oem_version=`getprop ro.build.version.codename`
    echo 10 > /sys/devices/soc0/select_image
    echo $image_version > /sys/devices/soc0/image_version
    echo $image_variant > /sys/devices/soc0/image_variant
    echo $oem_version > /sys/devices/soc0/image_crm_version
fi

# thermal engine
enable=`getprop persist.thermal_engine.enable`
if [ "$enable" == "true" ]; then
    start thermal-engine
fi
