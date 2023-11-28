#!/system/bin/sh
#GC watchdog script

######INSTALLATION######
#Run the bellow commands to install through adb
#adb push GC_watchdog_NoScreen.sh /sdcard/GC_watchdog.sh
#adb shell
#su
#rm /data/adb/service.d/*.sh; mv /sdcard/GC_watchdog.sh /data/adb/service.d/GC_watchdog.sh && chmod 777 /data/adb/service.d/GC_watchdog.sh && chown 0.0 /data/adb/service.d/GC_watchdog.sh; reboot
#Then simply reboot your device

#enable this for debugging through adb if you want by uncomenting the line and running '/data/adb/service.d/GC_watchdog.sh' from shell
#set -x

#All logs can be found in '/sdcard/Logs'

######FUNCTIONS######
gc_restart() {
	su -c "am force-stop ss.proximityservice"
	sleep 2
	su -c "am force-stop com.nianticlabs.pokemongo"
	su -c "am force-stop com.gocheats.launcher"
	sleep 2
	su -c "monkey -p com.gocheats.launcher 1"
	sleep 5
	if [[ "$hostname" == "S9" ]]; then
		su -c "setenforce 1"
	fi
	sleep 15
}

capture_logs_gc() {
	time=$(date +"%Y-%m-%d_%H-%M-%S")
	logcat -d > /sdcard/Logs/CrashLogcats/${hostname}_gc_logcat_$time.txt
	logcat -d -s "Exeggcute" > /sdcard/Logs/Exeggcute/${hostname}_gc_exeggcute_logcat_$time.txt
}

capture_logs_worker() {
	time=$(date +"%Y-%m-%d_%H-%M-%S")
	logcat -d > /sdcard/Logs/CrashLogcats/${hostname}_worker_logcat_$time.txt
	logcat -d -s "Exeggcute" > /sdcard/Logs/Exeggcute/${hostname}_worker_exeggcute_logcat_$time.txt
}

capture_logs_pokemon() {
	time=$(date +"%Y-%m-%d_%H-%M-%S")
	logcat -d > /sdcard/Logs/CrashLogcats/${hostname}_pokemon_logcat_$time.txt
	logcat -d -s "Exeggcute" > /sdcard/Logs/Exeggcute/${hostname}_pokemon_exeggcute_logcat_$time.txt
}

capture_regular_logcats() {
	time=$(date +"%Y-%m-%d_%H-%M-%S")
	logcat -d > /sdcard/Logs/Logcats/${hostname}_regular_logcat_$time.txt
}

######MAIN SCRIPT######
while [ "$(getprop sys.boot_completed)" != 1 ]; do
	sleep 1
done
sleep 10
echo "Device has booted"
hostname=$(su -c "awk -F'\"' '/device_name/ {print \$4}' /data/local/tmp/config.json")
WORKERS_COUNT=$(awk -F'[:,]' '/"workers_count"/{print $2}' /data/local/tmp/config.json | tr -d '[:space:]')
echo "$WORKERS_COUNT"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_FILE_PREFIX="${hostname}_script"
echo "Leggo" > /sdcard/Logs/ScriptLogs/${LOG_FILE_PREFIX}_${TIMESTAMP}.txt


echo "Removing pid" >> /sdcard/Logs/ScriptLogs/${LOG_FILE_PREFIX}_${TIMESTAMP}.txt
echo "Removing pid"

rm /sdcard/pid-*.txt
script_pid=`echo $$`
echo $script_pid > /sdcard/pid-$script_pid.txt
su -c "echo -900 >> /proc/$script_pid/oom_score_adj"

echo "Setting launcher_pid" >> /sdcard/Logs/ScriptLogs/${LOG_FILE_PREFIX}_${TIMESTAMP}.txt
launcher_pid=$(pidof com.gocheats.launcher)
echo $launcher_pid > /sdcard/pid-$launcher_pid.txt
su -c 'echo -900 >> /proc/'$launcher_pid'/oom_score_adj'

echo "Setting launcher2_pid" >> /sdcard/Logs/ScriptLogs/${LOG_FILE_PREFIX}_${TIMESTAMP}.txt
launcher2_pid=$(pidof ss.proximityservice)
echo $launcher2_pid > /sdcard/pid-$launcher2_pid.txt
su -c 'echo -900 >> /proc/'$launcher2_pid'/oom_score_adj'

echo "Making Directories" >> /sdcard/Logs/ScriptLogs/${LOG_FILE_PREFIX}_${TIMESTAMP}.txt
mkdir /sdcard/Logs
mkdir /sdcard/Logs/Exeggcute
mkdir /sdcard/Logs/ScriptLogs
mkdir /sdcard/Logs/Logcats
mkdir /sdcard/Logs/CrashLogcats
APP_PACKAGE_NAME=com.gocheats.launcher
POGO_PACKAGE_NAME=com.nianticlabs.pokemongo
NUMBER_OF_WORKERS=0
su -c 'logcat -P ""'

gc_restart

while true; do
	su -c "am force-stop ss.proximityservice"
	find /sdcard/Logs/Logcats -type f -printf '%T@ %p\n' | sort -n | awk 'NR>20 {print $2}' | while read -r file; do rm -- "$file"; done
	find /sdcard/Logs/CrashLogcats -type f -printf '%T@ %p\n' | sort -n | awk 'NR>20 {print $2}' | while read -r file; do rm -- "$file"; done
	find /sdcard/Logs/Exeggcute -type f -printf '%T@ %p\n' | sort -n | awk 'NR>20 {print $2}' | while read -r file; do rm -- "$file"; done
	find /sdcard/Logs/ScriptLogs -type f -printf '%T@ %p\n' | sort -n | awk 'NR>20 {print $2}' | while read -r file; do rm -- "$file"; done
	time=$(date +"%Y-%m-%d_%H-%M-%S")
	echo "$time" >> /sdcard/Logs/ScriptLogs/${LOG_FILE_PREFIX}_${TIMESTAMP}.txt
	WORKERRETRIES=0
	GCRETRIES=0
	while true; do
		echo "Checking if GC is running" >> /sdcard/Logs/ScriptLogs/${LOG_FILE_PREFIX}_${TIMESTAMP}.txt
		echo "Checking if GC is running"
		if ! pgrep -f "$APP_PACKAGE_NAME" >/dev/null; then
			((GCRETRIES++))
			if [[ "$GCRETRIES" -lt 5 ]]; then
				echo "- GC isn't running, Restarting GC, attempt $GCRETRIES" >> /sdcard/Logs/ScriptLogs/${LOG_FILE_PREFIX}_${TIMESTAMP}.txt
				echo "- GC isn't running, Restarting GC, attempt $GCRETRIES"
				capture_logs_gc
				gc_restart
			else
				echo "- GC still isn't running on attempt $GCRETRIES, Waiting 15m then trying again" >> /sdcard/Logs/ScriptLogs/${LOG_FILE_PREFIX}_${TIMESTAMP}.txt
				echo "- GC still isn't running on attempt $GCRETRIES, Waiting 15m then trying again"
				sleep 900
				echo "- - Done waiting for 15m, trying again" >> /sdcard/Logs/ScriptLogs/${LOG_FILE_PREFIX}_${TIMESTAMP}.txt
				echo "- - Done waiting for 15m, trying again"
				GCRETRIES=0
			fi
		else
			echo "- GC is running" >> /sdcard/Logs/ScriptLogs/${LOG_FILE_PREFIX}_${TIMESTAMP}.txt
			echo "- GC is running"
			GCRETRIES=0
			echo "Checking if PokemonGo is running" >> /sdcard/Logs/ScriptLogs/${LOG_FILE_PREFIX}_${TIMESTAMP}.txt
			echo "Checking if PokemonGo is running"
			if ! pgrep -f "$POGO_PACKAGE_NAME" >/dev/null; then
				echo "- PokemonGo isn't running, Closing PokemonGo and waiting 30s" >> /sdcard/Logs/ScriptLogs/${LOG_FILE_PREFIX}_${TIMESTAMP}.txt
				echo "- PokemonGo isn't running, Closing PokemonGo and waiting 30s"
				su -c "am force-stop com.nianticlabs.pokemongo"
				sleep 30
				if ! pgrep -f "$POGO_PACKAGE_NAME" >/dev/null; then
					echo "- - PokemonGo still isn't running, Restarting GC" >> /sdcard/Logs/ScriptLogs/${LOG_FILE_PREFIX}_${TIMESTAMP}.txt
					echo "- - PokemonGo still isn't running, Restarting GC"
					capture_logs_pokemon
					gc_restart
				else
					echo "- - PokemonGo is running again" >> /sdcard/Logs/ScriptLogs/${LOG_FILE_PREFIX}_${TIMESTAMP}.txt
					echo "- - PokemonGo is running again"
				fi
			else
				echo "- PokemonGo is running" >> /sdcard/Logs/ScriptLogs/${LOG_FILE_PREFIX}_${TIMESTAMP}.txt
				echo "- PokemonGo is running"
				echo "Checking if there are $WORKERS_COUNT workers" >> /sdcard/Logs/ScriptLogs/${LOG_FILE_PREFIX}_${TIMESTAMP}.txt
				echo "Checking if there are $WORKERS_COUNT workers"
				NUMBER_OF_WORKERS=$(netstat -t | grep -c '7070.*ESTABLISHED'); ((NUMBER_OF_WORKERS--))
				if [[ "$NUMBER_OF_WORKERS" -lt "$WORKERS_COUNT" ]]; then
					echo "- There are $NUMBER_OF_WORKERS workers, waiting 60 seconds" >> /sdcard/Logs/ScriptLogs/${LOG_FILE_PREFIX}_${TIMESTAMP}.txt
					echo "- There are $NUMBER_OF_WORKERS workers, waiting 60 seconds"
					su -c "am start -n ss.proximityservice/.StartActivity"
					sleep 60
					su -c "am force-stop ss.proximityservice"
					NUMBER_OF_WORKERS=$(netstat -t | grep -c '7070.*ESTABLISHED'); ((NUMBER_OF_WORKERS--))
					if [[ "$NUMBER_OF_WORKERS" -lt "$WORKERS_COUNT" ]]; then
						((WORKERRETRIES++))
						if [[ "$WORKERRETRIES" -lt 5 ]]; then
							echo "- - There are now $NUMBER_OF_WORKERS workers, restarting GC, Attempt $NUMBER_OF_WORKERS" >> /sdcard/Logs/ScriptLogs/${LOG_FILE_PREFIX}_${TIMESTAMP}.txt
							echo "- - There are now $NUMBER_OF_WORKERS workers, restarting GC, Attempt $NUMBER_OF_WORKERS"
							capture_logs_worker
							gc_restart
						else
							echo "- - There are still not enough workers, Waiting 15m then trying again" >> /sdcard/Logs/ScriptLogs/${LOG_FILE_PREFIX}_${TIMESTAMP}.txt
							echo "- - There are still not enough workers, Waiting 15m then trying again"
							su -c "am force-stop com.nianticlabs.pokemongo"
							su -c "am force-stop com.gocheats.launcher"
							su -c "am start -n ss.proximityservice/.StartActivity"
							sleep 900
							su -c "am force-stop ss.proximityservice"
							echo "- - - Done waiting, trying again" >> /sdcard/Logs/ScriptLogs/${LOG_FILE_PREFIX}_${TIMESTAMP}.txt
							echo "- - - Done waiting, trying again"
							gc_restart
						fi
					else
						echo "- There are $NUMBER_OF_WORKERS workers, carrying on" >> /sdcard/Logs/ScriptLogs/${LOG_FILE_PREFIX}_${TIMESTAMP}.txt
						echo "- There are $NUMBER_OF_WORKERS workers, carrying on"
						break
					fi
				else
					echo "- There are $NUMBER_OF_WORKERS workers, carrying on" >> /sdcard/Logs/ScriptLogs/${LOG_FILE_PREFIX}_${TIMESTAMP}.txt
					echo "- There are $NUMBER_OF_WORKERS workers, carrying on"
					break
				fi
			fi
		fi
	done
	echo "Device appears to be online, waiting 10 Minutes" >> /sdcard/Logs/ScriptLogs/${LOG_FILE_PREFIX}_${TIMESTAMP}.txt
	echo "Device appears to be online, waiting 10 Minutes"
	su -c "am start -n ss.proximityservice/.StartActivity"
	sleep 600
	capture_regular_logcats
done
