# GC_watchdog  
Keeping GC alive since 2023  

======INSTALLATION======  
Run the bellow commands to install through adb  
  ``adb push GC_watchdog.sh /sdcard/GC_watchdog.sh``  
  ``adb shell``  
  ``su``  
  ``rm /data/adb/service.d/*.sh``  
  ``mv /sdcard/GC_watchdog.sh /data/adb/service.d/GC_watchdog.sh``  
  ``chmod 777 /data/adb/service.d/GC_watchdog.sh``  
  ``chown 0.0 /data/adb/service.d/GC_watchdog.sh``  

Then simply reboot your device.  
If you would like to watch the script, simply run ``/data/adb/service.d/GC_watchdog.sh`` while in shell.  

You can also get more details about what's being executed by uncommenting ``#set -x``  

The script saves all sorts of log files in the following directories:  

``/sdcard/Logs/Exeggcute``  	#<---- This is all Exeggcute related Logcats  
``/sdcard/Logs/ScriptLogs``  	#<---- This is all Script related Logs  
``/sdcard/Logs/Logcats``  		#<---- This is all full Logcats, normally saved every 10min  
``/sdcard/Logs/CrashLogcats``  	#<---- This is all Logcats for when something goes wrong  
