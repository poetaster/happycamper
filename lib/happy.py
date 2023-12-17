# -*- coding: utf-8 -*-

import pyotherside
import time
import os
import shutil
import subprocess
from pathlib import Path

# POETASTER
import sys
(major, minor, micro, release, serial) = sys.version_info
sys.path.append("/usr/share/harbour-happycamper/lib/python" + str(major) + "." + str(minor) + "/site-packages/");


# check if campdown is installed
try:
    import campdown
except ImportError:
    pyotherside.send('warningCamperNotAvailable', )
#from pydub import AudioSegment
#from pydub import effects
#from pydub.utils import mediainfo

# check if LAME is manually installed by user
# this is not allowed in harbour
#retval = subprocess.call(["which", "lame"])
#if retval != 0:
#    pyotherside.send('warningLameNotAvailable', )



# Functions for file operations
# #######################################################################################

def getHomePath ():
    homeDir = str(Path.home())
    pyotherside.send('homePathFolder', homeDir )



def downLoad(url,directory):

    #def __init__(self, url, out=None, verbose=False, silent=False, short=False, sleep=30, id3_enabled=True, art_enabled=True, abort_missing=False):

    downloader = campdown.Downloader(
        url,
        out=directory,
        verbose=False,
        short=False,
        sleep=30,
        art_enabled=True,
        id3_enabled=True,
        abort_missing=False
    )
    try:
        downloader.run()
    except :
        e = sys.exc_info()[0]
        pyotherside.send('campError', e )

