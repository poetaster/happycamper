# -*- coding: utf-8 -*-

import pyotherside
import sys
import os
import glob
from pathlib import Path
import requests

# POETASTER
(major, minor, micro, release, serial) = sys.version_info
sys.path.append("/usr/share/harbour-happycamper/lib/python" + str(major) + "." + str(minor) + "/site-packages/");

from campdown.helpers import *
from campdown.track import Track
from campdown.album import Album
from campdown.discography import Discography

# check if mutagen is installed
try:
    from mutagen.easyid3 import EasyID3
    from mutagen.mp3 import MP3
except ImportError as err:
    pyotherside.send("error", "happy", "import_mutagen", format_error(err))

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

def get_home_path ():
    homeDir = str(Path.home())
    pyotherside.send('homePathFolder', homeDir )

def format_error(err):
    return 'ERROR: %s' % err

def list_files(dir):
    pathlist = Path(dir).glob('**/*.mp3')
    for path in pathlist:
         audio=MP3(path, ID3=EasyID3)
         print(audio['artist'], audio['title'])

def download_url(url,directory):

    #def __init__(self, url, out=None, verbose=False, silent=False, short=False, sleep=30, id3_enabled=True, art_enabled=True, abort_missing=False):

    downloader = Downloader(
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
    except Exception as err :
        pyotherside.send("error", "happy", "download_url", format_error(err))
    ''' tack object attributes
    self.title = None
    self.artist = None
    self.date = None
    self.album = album
    self.album_artist = album_artist
    self.index = index
    self.info = None
    self.art_url = None
    self.mp3_url = None '''
    # save current playlist
    playlist_items = []
    pl = Path(downloader.current_dir).glob('**/*.mp3')
    for path in pl:
         audio=MP3(path, ID3=EasyID3)
         print(audio['artist'], audio['title'], audio['album'])
         playlist_items.append({'media_url': path, 'track': audio['title'], 'duration':''})

    if(len(playlist_items) > 0):
        print(playlist_items)
        save_playlist(downloader.current_dir + "/happycamper.pls", playlist_items)

    # send qml side some info about the tracks and location
    # function which needs to be called before anything else can be done.
    pyotherside.send('trackQueue', downloader.queue)
    pyotherside.send('currentDir', downloader.current_dir)

    pyotherside.send('downloadCompleted', "True" )

def save_playlist(file_name, playlist_items):
    print('save_playlist:', file_name, 'items:', len(playlist_items))
    try:
      with open(file_name, 'w') as f:
        f.write("[playlist]\n")
        f.write("X-GNOME-Title=Happycamper\n")
        for index, item in enumerate(playlist_items):
          index += 1
          f.write("File%d=%s\n" % (index, item['media_url']))
          f.write("Title%d=%s\n" % (index, item['track']))
          if item['duration']:
            f.write("Length%d=%s\n" % (index, round(item['duration'] / 1000)))

        f.write("NumberOfEntries=%d\n" % len(playlist_items))
        f.write("Version=2\n\n")
    except Exception as err:
      print('happy save_playlist - error: ', err)
      pyotherside.send("error", "happy", "save_playlist", format_error(err))
      return False

def get_media_folder_items(folder_path, file_types = ('*.mp3', '*.opus', '*.ogg')):
    media_files = []
    for file_type in file_types:
      for file in glob.glob("%s/%s" % (folder_path, file_type)):
        media_files.append(file)

    media_files.sort()
    return media_files

def get_local_media( track_id = '*', video_id = '*'):
    media_files = []
    for file in glob.glob(self.audio_download_path + self.AUDIO_FILE_NAME.format(track_id, video_id)):
        media_files.append(file)
    return media_files

class Downloader:
    """
    Main class of Campdown. This class handles all other Campdown functions and
    executes them depending on the information it is given during initilzation.

    Args:
        url (str): Bandcamp URL to analyse and download from.
        out (str): relative or absolute path to write to.
        verbose (bool): sets if status messages and general information
            should be printed. Errors are still printed regardless of this.
        silent (bool): sets if error messages should be hidden.
        short (bool): omits arist and album fields from downloaded track filenames.
        sleep (number): duration between failed requests to wait for.
        art_enabled (bool): if True the Bandcamp page's artwork will be
            downloaded and saved alongside each of the found tracks.
        id3_enabled (bool): if True tracks downloaded will receive new ID3 tags.
    """

    def __init__(self, url, out=None, verbose=False, silent=False, short=False, sleep=30, id3_enabled=True, art_enabled=True, abort_missing=False):
        self.url = url
        self.output = out
        self.verbose = verbose
        self.silent = silent
        self.short = short
        self.sleep = sleep
        self.id3_enabled = id3_enabled
        self.art_enabled = art_enabled
        self.abort_missing = abort_missing

        # Variables used during retrieving of information.
        self.request = None
        self.content = None

        # this is used on the qml side to build a player
        self.queue = []  # Queue array to store album tracks in.
        self.current_dir = "" # current download directory

        # Get the script path in case no output path is specified.
        # self.work_path = os.path.join(
        #     os.path.dirname(os.path.abspath(__file__)), "")

        self.work_path = os.path.join(os.getcwd(), "")

        if self.output:
            # Make sure that the output folder has the right path syntax
            if not os.path.isabs(self.output):
                if not os.path.exists(os.path.join(self.work_path, self.output)):
                    os.makedirs(os.path.join(self.work_path, self.output))

                self.output = os.path.join(self.work_path, self.output)

        else:
            # If no path is specified use the absolute path of the main file.
            self.output = self.work_path

    def run(self):
        """
        Begins downloading the content from the prepared settings.
        """

        if not valid_url(self.url):
            if not self.silent:
                print("The supplied URL is not a valid URL.")

            return False

        # Get the content from the supplied Bandcamp URL.
        self.request = safe_get(self.url)
        self.content = self.request.content.decode("utf-8")

        if self.request.status_code != 200:
            if not self.silent:
                print("An error occurred while trying to access your supplied URL. Status code: {}".format(
                    self.request.status_code))

            return

        # Get the type of the page supplied to the downloader.
        pagetype = page_type(self.content)

        if pagetype == "track":
            if self.verbose:
                print("\nDetected Bandcamp track.")

            track = Track(
                self.url,
                self.output,
                request=self.request,
                verbose=self.verbose,
                silent=self.silent,
                short=self.short,
                sleep=self.sleep,
                art_enabled=self.art_enabled,
                id3_enabled=self.id3_enabled
            )

            if track.prepare():  # Prepare the track by filling out content.
                track.download()  # Begin the download process.
                # Insert the acquired data into the queue.
                self.queue.insert(0, track)

                if self.verbose:
                    print("\nFinished track download. Downloader complete.")

            else:
                if self.verbose:
                    print(
                        "\nThe track you are trying to download is not publicly available. Consider purchasing it if you want it.")

        elif pagetype == "album":
            if self.verbose:
                print("\nDetected Bandcamp album.")

            album = Album(
                self.url,
                self.output,
                request=self.request,
                verbose=self.verbose,
                silent=self.silent,
                short=self.short,
                sleep=self.sleep,
                art_enabled=self.art_enabled,
                id3_enabled=self.id3_enabled,
                abort_missing=self.abort_missing
            )

            if album.prepare():   # Prepare the album with information from the supplied URL.
                if album.fetch(): # Start the download process if fetches succeeded.
                    album.download()
                    self.queue = album.queue # add to queue for qml
                    self.current_dir = album.output
                else:
                    False


            if self.verbose:
                print("\nFinished album download. Downloader complete.")

        elif pagetype == "discography":
            if self.verbose:
                print("\nDetected Bandcamp discography page.")

            page = Discography(
                self.url,
                self.output,
                request=self.request,
                verbose=self.verbose,
                silent=self.silent,
                short=self.short,
                sleep=self.sleep,
                art_enabled=self.art_enabled,
                id3_enabled=self.id3_enabled,
                abort_missing=self.abort_missing
            )

            page.prepare()  # Make discography gather all information it requires.
            page.fetch()  # Begin telling prepared items to fetch their own information.
            page.download()  # Start the download process.

            if self.verbose:
                print("\nFinished discography download. Downloader complete.")

        else:
            if not self.silent:
                print("Invalid page type. Exiting.")
