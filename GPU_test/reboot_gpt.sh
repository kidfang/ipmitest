#!/bin/bash
# Configuration file to track if user input has been provided
config_file="/root/A100/DC_off_on/.config"

# Function to prompt user for input values
get_user_input() {
    echo "Enter the path to save test log (default: /root/A100/DC_off_on): "
    read -r Result_path
    Result_path=${Result_path:-/root/A100/DC_off_on}

    echo "Enter the time for your reboot or power cycle test (in seconds, default: 14400): "
    read -r Reboot_time
    Reboot_time=${Reboot_time:-14400}

    echo "Enter the number of SCSI drives detected (default: 1): "
    read -r scsi_num
    scsi_num=${scsi_num:-1}

    echo "Enter the keyword for your GPU (default: NVIDIA): "
    read -r GPU_kw
    GPU_kw=${GPU_kw:-NVIDIA}

    echo "Enter the number of NVIDIA GPUs detected (default: 8): "
    read -r GPU_num
    GPU_num=${GPU_num:-8}

    echo "Enter the number of GPUs with NVIDIA VBIOS detected (default: 8): "
    read -r GPU_N
    GPU_N=${GPU_N:-8}

    echo "Enter the test type (0 for Power cycle, 1 for Reboot test, default: 1): "
    read -r Test_type
    Test_type=${Test_type:-1}

    # Store the user input values in the configuration file
    echo "Result_path=$Result_path" > "$config_file"
    echo "Reboot_time=$Reboot_time" >> "$config_file"
    echo "scsi_num=$scsi_num" >> "$config_file"
    echo "GPU_kw=$GPU_kw" >> "$config_file"
    echo "GPU_num=$GPU_num" >> "$config_file"
    echo "GPU_N=$GPU_N" >> "$config_file"
    echo "Test_type=$Test_type" >> "$config_file"
}

# Check if the configuration file exists
if [ ! -f "$config_file" ]; then
    get_user_input
fi

# Read configuration from the file
source "$config_file"

# Function to enable NVIDIA GPU features
enable_nvidia_gpu() {
    if [ "$GPU_kw" = "NVIDIA" ]; then
        gn=$(nvidia-smi -L | wc -l)
        for ((i = 1; i <= gn; i++)); do
            MN=$(nvidia-smi -L | sed -n "$i"p | awk '{print $2}' | cut -f 1 -d ":")
            MC=$(nvidia-smi -a -i "$MN" | grep -A 1 "Max Clocks" | grep -i Graphics | awk '{print $3}')
            MMC=$(nvidia-smi -a -i "$MN" | grep -A 3 "Max Clocks" | grep -i Memory | awk '{print $3}')
            nvidia-smi -lmc "$MMC" -i "$MN"
            nvidia-smi -lgc "$MC" -i "$MN"
        done
    else
        echo "Not NVIDIA Card, skip this step..."
    fi
}

# Function to handle the reboot count and setup
handle_reboot_setup() {
    if [ ! -f "$Result_path/count.txt" ]; then
        echo 0 > "$Result_path/count.txt"
        date +%s > "$Result_path/start_time.txt"
        sleep 5
        /root/speed_numa_check_all.sh 1 > "$Result_path/speed_org.txt"
        sleep 5
        init 6
    else
        y=$(cat "$Result_path/count.txt")
        echo "$y"
        y=$((y + 1))
        echo "$y" > "$Result_path/count.txt"
    fi
}

# Function to check and clear IPMI logs
check_clear_ipmi_logs() {
    t=$(ipmitool sel list | wc -l)
    if [ "$t" -eq 1024 ]; then
        ipmitool sel clear
    else
        echo "Continue"
    fi
}

# Function to perform the test and handle results
perform_test_and_handle_results() {
    x=$(lsscsi | wc -l)
    w=$(lspci | grep -i "$GPU_kw" | wc -l)
    s=$(ipmitool sel list | grep -i interrupt)
    u=$(dmesg | grep -i corrected | wc -l)
    v=$(ipmitool sel list | grep -i interrupt | wc -l)

    Start_time=$(cat "$Result_path/start_time.txt")
    End_time=$(date +%s)
    During_time=$((End_time - Start_time))

    echo "$Start_time"
    echo "$End_time"
    echo "$During_time"

    if [ "$Test_type" -eq 0 ]; then
        Test_name="powercycle"
    else
        Test_name="reboot"
    fi

    /root/speed_numa_check_all.sh 1 > "$Result_path/speed_test.txt"

    dd=$(diff "$Result_path/speed_test.txt" "$Result_path/speed_org.txt" | wc -l)

    if [ "$x" -ne "$scsi_num" ]; then
        handle_test_failure "Other error or stopped by user"
    elif [ "$w" -ne "$GPU_num" ] || [ "$j" -ne "$GPU_N" ]; then
        handle_test_failure "GPU detection issue"
    elif [ "$v" -ne 0 ] || [ "$u" -ne 0 ] || [ "$dd" -ne 0 ]; then
        handle_test_failure "Test failure"
    else
        handle_test_success
    fi
}

# Function to handle test failure cases
handle_test_failure() {
    local error_reason="$1"
    echo "$error_reason"
    if [ "$Test_name" = "scsi_num_abnormal" ]; then
        dmesg | egrep -i "error|fail|fatal|warn|wrong|bug|fault^default" > "$Result_path/dmesg_$Test_name.txt"
        dmesg > "$Result_path/dmesg_$Test_name"_all.txt
        ipmitool sel elist > "$Result_path/ipmi_$Test_name"_eventlog.txt
    else
        echo "$u" > "$Result_path/OSevent_$Test_name.txt"
        echo "$s" > "$Result_path/IPMIevent_$Test_name.txt"
        dmesg | egrep -i "error|fail|fatal|warn|wrong|bug|fault^default" > "$Result_path/dmesg_error_$Test_name.txt"
        dmesg > "$Result_path/dmesg_error_all_$Test_name.txt"
        ipmitool sel elist > "$Result_path/ipmi_eventlog_$Test_name.txt"
        if [ "$Test_name" = "test_failure" ]; then
            dmesg | grep -i "6.0 Gbps" > "$Result_path/dmesg_ata_$Test_name.txt"
        fi
    fi
    # systemctl disable Power_cycle.service
    # systemctl stop Power_cycle.service
    echo "Power_cycle.service not disabled and stopped (commented for testing)"
    exit 0
}

# Function to handle test success case
handle_test_success() {
    date >> "$Result_path/rebootrec.txt"
    echo "PASS" >> "$Result_path/rebootrec.txt"
    if [ "$During_time" -le "$Reboot_time" ]; then
        if [ "$Test_type" -eq 0 ]; then
            sleep 10
            # ipmitool chassis power cycle
            echo "ipmitool chassis power cycle not executed (commented for testing)"
            sleep 10
            date | tee -a "$Result_path/ipmi_crash.txt"
            # ipmitool 2>&1 | tee -a "$Result_path/ipmi_crash.txt"
            echo "ipmitool command not executed (commented for testing)"
            sleep 3
            init 6
        else
            sleep 10
            init 6
        fi
    else
        Start_time_d=$(date +%Y-%m-%d\ %H:%M:%S -d "1970-01-01 UTC $Start_time seconds")
        End_time_d=$(date +%Y-%m-%d\ %H:%M:%S -d "1970-01-01 UTC $End_time seconds")
        echo "Start_time: $Start_time_d" >> "$Result_path/rebootrec.txt"
        echo "End_time: $End_time_d" >> "$Result_path/rebootrec.txt"
        echo "Test time: $During_time sec" >> "$Result_path/rebootrec.txt"
        sleep 10
        dmesg | egrep -i "error|fail|fatal|warn|wrong|bug|fault^default" > "$Result_path/dmesg_$Test_name"_done.txt
        dmesg > "$Result_path/dmesg_$Test_name"_done_all.txt
        ipmitool sel elist > "$Result_path/ipmi_$Test_name"_done_eventlog.txt
        # systemctl disable Power_cycle.service
        # systemctl stop Power_cycle.service
        echo "Power_cycle.service not disabled and stopped (commented for testing)"
        exit 0
    fi
}

# Main script
enable_nvidia_gpu
handle_reboot_setup
check_clear_ipmi_logs
perform_test_and_handle_results
