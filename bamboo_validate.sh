#!/bin/bash

set -e

##################
# Read arguments #
##################

while getopts v: arg; do
  case $arg in
    v)
      variant=${OPTARG};;
    ?)
      exit 1
      ;;
  esac
done

###########################
# Verify variant argument #
###########################

if [ ! -z "${variant}" ]
then
  variants=("Debug" "Validation" "Production")
  if [[ " ${variants[*]} " = *" ${variant} "* ]];
  then
    echo "Specified variant: ${variant}"
  else
    echo "Invalid variant \"${variant}\". Valid variants: \"${variants[@]}\""
    exit 1
  fi
fi

#########################
# Clean build directory #
#########################

echo "(CI/CD) Step: Clean"

./gradlew clean

#########
# Build #
#########

echo "(CI/CD) Step: Build"

./gradlew bundle${variant}

# Load build properties into environment variables
build_properties=./app/build/build.txt
if [ -f "$build_properties" ]; then
    source $build_properties
fi

##################
# Run unit tests #
##################

echo "(CI/CD) Step: Unit tests"

if [ -z "${variant}" ]
then
  echo "./gradlew test"
  ./gradlew test
else
  echo "./gradlew test${variant}UnitTest"
  ./gradlew test${variant}UnitTest
fi

#############################
# Run instrumentation tests #
#############################

echo "(CI/CD) Step: Instrumentation tests"

adb start-server

# Shut down existing emulators (if any)
emulators=( $(adb devices | grep "emulator" | awk '{print $1}') )
if [ ${#emulators[@]} -gt 0 ]; then
  for emulator in ${emulators[@]}
  do
    echo "Shutting down emulator \"$emulator\""
    adb -s $emulator emu kill
  done

  echo "Cooling down..."
  sleep 5
fi

emulator_command_args="-no-snapshot -no-boot-anim -no-audio"

avds=( $(emulator -list-avds) )
avd_port=5554

for avd in "${avds[@]}"
do
  emulator="emulator-$avd_port"

  # Start emulator as background process
  emulator @$avd -port $avd_port $emulator_command_args > /dev/null 2>&1 &

  # Get emulator PID
  avd_pid=$!
  echo "$avd (\"$emulator\"): Started emulator (PID: $avd_pid)"

  # Wait for emulator to boot
  echo "$avd (\"$emulator\"): Booting..."
  adb -s $emulator wait-for-device  shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 1; done;'
  echo "$avd (\"$emulator\"): Ready."

  # Uninstall app if exiting
  echo "$avd (\"$emulator\"): Uninstalling app (if existing)"
  adb -s $emulator uninstall com.bshg.smartkitchendock || true

  # Run instrumentation tests
  if [ -z "${variant}" ]
  then
    echo "./gradlew connectedAndroidTest"
    ./gradlew connectedAndroidTest
  else
    echo "./gradlew connected${variant}AndroidTest"
    ./gradlew connected${variant}AndroidTest
  fi

  # Stop emulator
  echo "$avd (\"$emulator\"): Stopping..."
  adb -s $emulator emu kill

  # Wait for process to terminate
  echo "Cooling down..."
  sleep 5

  # Kill process in case it hangs
  echo "$avd (\"$emulator\"): Killing emulator process (PID: $avd_pid) for redundancy"
  kill -9 $avd_pid || true

  # Increase port (even only)
  avd_port=$((avd_port+2))
done