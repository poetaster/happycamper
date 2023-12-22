import QtQuick 2.0
import Nemo.Notifications 1.0
import Sailfish.Silica 1.0

Item {
  id: notifications_handler

  property var notifications_by_file_name: {'_null': null}
  property int cache_progress_id

  Notice {
    id: system_notice
    duration: Notice.Long
    text: "Info"
  }

  Notification {
    id: download_notification
    appIcon: "harbour-musicex"
    appName: "Music Explorer"
    expireTimeout: 30000
    urgency: Notification.Low
    onClosed: {
      console.log('download notification closed - reason:', reason, 'id:', replacesId);
    }
  }

  Component.onCompleted: {
    app.signal_error.connect(error_handler)
    app.signal_media_download.connect(media_download)
    //app.signal_cache_rebuild.connect(cache_rebuild)
  }

  Component.onDestruction: {
    app.signal_error.disconnect(error_handler)
    app.signal_media_download.disconnect(media_download)
    app.signal_cache_rebuild.disconnect(cache_rebuild)
  }

  function error_handler(module_id, method_id, description) {
    console.log('error_handler - source:', module_id, method_id, 'error:', description);
    system_notice.text = description
    system_notice.show()
  }

  function media_download(details) {
    //system_notice.text = 'Media download ' + details.status
    //system_notice.show()

    download_notification.summary = 'Media download ' + details.status
    download_notification.subText = String(details.file_name)
    download_notification.body = String(details.file_name)
    if (details.status == 'start') {
      download_notification.progress = 0.0
      download_notification.expireTimeout = 30000
    } else if (details.status == 'fail') {
      download_notification.subText = String(details.reason)
      download_notification.expireTimeout = 1000
      system_notice.text = details.reason
      system_notice.show()
    } else if (details.status == 'complete') {
      download_notification.progress = 1.0
      download_notification.expireTimeout = 1000
      notifications_by_file_name[details.file_name] = 0
    }
    else if (details.status == 'progress') download_notification.progress = details.percent / 100
    if (notifications_by_file_name[details.file_name]) {
      download_notification.replacesId = notifications_by_file_name[details.file_name]
    }
    if (details.thumbnail_url) download_notification.icon = details.thumbnail_url
    download_notification.publish()
    notifications_by_file_name[details.file_name] = download_notification.replacesId
  }

  function cache_rebuild(details) {
    download_notification.summary = 'Rebuilding cache... '
    download_notification.subText = ""
    download_notification.body = ""
    if (details.status == 'start') {
      download_notification.progress = 0.0
      download_notification.expireTimeout = 30000
    } else if (details.status == 'fail') {
      download_notification.subText = String(details.reason)
      download_notification.expireTimeout = 1000
      system_notice.text = details.reason
      system_notice.show()
    } else if (details.status == 'complete') {
      download_notification.progress = 1.0
      download_notification.expireTimeout = 1000
    }
    else if (details.status == 'progress') download_notification.progress = details.percent / 100
    if (details.thumbnail_url) download_notification.icon = details.thumbnail_url
    download_notification.replacesId = cache_progress_id
    download_notification.publish()
    cache_progress_id = download_notification.replacesId
  }
}
