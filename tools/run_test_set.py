import sys
import os
import subprocess
from shutil import copyfile
import filecmp

# specify your build folder here
sdl_path = "../sdl_build/bin/"
preloaded_pt_path = sdl_path + "sdl_preloaded_pt.json"
preloaded_pt_backup_path = preloaded_pt_path + "_backup"
ini_path = sdl_path + "smartDeviceLink.ini"
ini_backup_path = ini_path + "_backup"
hmi_capabilities_path = sdl_path + "hmi_capabilities.json"
hmi_capabilities_backup_path = hmi_capabilities_path + "_backup"

# usage: python tools/run_test_set.py test_sets/<specific_test_set>.txt
def main():
	try:
		fp = open(sys.argv[1])
		line = fp.readline()
		print("Starting")
		while line and line != "":
			if line.startswith(";"):
				line = fp.readline()
				continue
			print("Running {}".format(line))

			# backup step
			copyfile(preloaded_pt_path, preloaded_pt_backup_path)
			copyfile(ini_path, ini_backup_path)
			copyfile(hmi_capabilities_path, hmi_capabilities_backup_path)

			subprocess.call(['./start.sh', line])

			# restore step
			if not filecmp.cmp(preloaded_pt_path, preloaded_pt_backup_path):
				print("PRELOADED PT WAS CORRUPTED, RESTORING")
				copyfile(preloaded_pt_backup_path, preloaded_pt_path)
			if not filecmp.cmp(ini_path, ini_backup_path):
				print("INI FILE WAS CORRUPTED, RESTORING")
				copyfile(ini_backup_path, ini_path)
			if not filecmp.cmp(hmi_capabilities_path, hmi_capabilities_backup_path):
				print("HMI CAPABILITIES WERE CORRUPTED, RESTORING")
				copyfile(hmi_capabilities_backup_path, hmi_capabilities_path)
			line = fp.readline()
	finally:
		fp.close()

if __name__ == '__main__':
	main()