set( APPLICATION_NAME       "Evermore" )
set( APPLICATION_SHORTNAME  "Evermore" )
set( APPLICATION_EXECUTABLE "evermore" )
set( APPLICATION_DOMAIN     "evermoredata.store" )
set( APPLICATION_VENDOR     "evermore" )
set( APPLICATION_UPDATE_URL "https://evermoredata.store/#/download" CACHE STRING "URL for updater" )
set( APPLICATION_ICON_NAME  "ownCloud" )
set( APPLICATION_VIRTUALFILE_SUFFIX "owncloud" CACHE STRING "Virtual file suffix (not including the .)")

set( LINUX_PACKAGE_SHORTNAME "evermore" )

set( THEME_CLASS            "ownCloudTheme" )
set( APPLICATION_REV_DOMAIN "com.evermoredata.store" )
set( WIN_SETUP_BITMAP_PATH  "${CMAKE_SOURCE_DIR}/admin/win/nsi" )

set( MAC_INSTALLER_BACKGROUND_FILE "${CMAKE_SOURCE_DIR}/admin/osx/installer-background.png" CACHE STRING "The MacOSX installer background image")

# set( THEME_INCLUDE          "${OEM_THEME_DIR}/mytheme.h" )
# set( APPLICATION_LICENSE    "${OEM_THEME_DIR}/license.txt )

option( WITH_CRASHREPORTER "Build crashreporter" OFF )
set( CRASHREPORTER_SUBMIT_URL "https://crash-reports.owncloud.com/submit" CACHE STRING "URL for crash reporter" )

