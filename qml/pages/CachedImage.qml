import QtQuick 2.2
import Sailfish.Silica 1.0

Image {
  id: image_item
  
  property string remote_source
  property string local_source
  property bool preview: false

  Timer {
    id: image_saver_timer
    interval: 1000
    running: false
    repeat: false
    onTriggered: {
      image_item.grabToImage(function(result) {
        console.log('Saving image to cache - image:', local_source)
        result.saveToFile(local_source);
      }, image_item.sourceSize);
    }
  }

  onStatusChanged: {
    if (status == Image.Ready) {
      if ((source == remote_source || source == remote_source+'/preview') && local_source.length > 0) {
        image_saver_timer.start()
      }
    } else if (status == Image.Error) {
      console.log('Image - could not load:', source)
      if (source == local_source || source == 'file://'+local_source) {
        if (preview) source = remote_source + '/preview'
        else source = remote_source
        console.log('Image - fetching remote image:', source)
      }
    }
  }

  onRemote_sourceChanged: {
    if (!remote_source) return;
    
    if (preview) local_source = StandardPaths.cache + '/preview_' + basename(remote_source)
    else local_source = StandardPaths.cache + '/' + basename(remote_source)
    source = local_source
  }

  Component.onCompleted: {
    
  }

  function basename(file_path) {
    return (file_path.slice(file_path.lastIndexOf("/")+1))
  }
}
