#!/bin/bash
#Fixes the install path of the libraries

set -x
pwd

EXECFILE=${BUILT_PRODUCTS_DIR}/${EXECUTABLE_PATH}
LIBPATH=${BUILT_PRODUCTS_DIR}/TimerBar.app/Contents/Frameworks/
NEWLIBPATH="@executable_path/../Frameworks"


install_name_tool -id ${NEWLIBPATH}/PTHotKey.framework/Versions/A/PTHotKey ${LIBPATH}/PTHotKey.framework/PTHotKey
install_name_tool -id ${NEWLIBPATH}/ShortcutRecorder.framework/Versions/A/ShortcutRecorder ${LIBPATH}/PTHotKey.framework/PTHotKey


install_name_tool -change @rpath/PTHotKey.framework/Versions/A/PTHotKey ${NEWLIBPATH}/PTHotKey.framework/Versions/A/PTHotKey ${EXECFILE}

install_name_tool -change @rpath/ShortcutRecorder.framework/Versions/A/ShortcutRecorder ${NEWLIBPATH}/ShortcutRecorder.framework/Versions/A/ShortcutRecorder ${EXECFILE}