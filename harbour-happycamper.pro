# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-happycamper

CONFIG += sailfishapp_qml

DISTFILES += qml/harbour-happycamper.qml \
    lib/happy.py \
    qml/cover/CoverPage.qml \
    qml/pages/MainPage.qml \
    qml/pages/Settings.qml \
    qml/pages/Popup.qml \
    lib/*.py \
    rpm/harbour-happycamper.changes.in \
    rpm/harbour-happycamper.changes.run.in \
    rpm/harbour-happycamper.spec \
    translations/*.ts \
    dbus-1/services/* \
    50-harbour-happycamper.conf \
    harbour-happycamper.desktop \
    harbour-happycamper-open-url.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

libs.path = /usr/share/$${TARGET}
libs.files = lib

INSTALLS += libs

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-happycamper-de.ts
