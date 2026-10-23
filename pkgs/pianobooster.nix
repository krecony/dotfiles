{ pianobooster, writeText }:

pianobooster.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    (writeText "pianobooster-xdg-music.patch" ''
      diff --git a/src/Settings.cpp b/src/Settings.cpp
      --- a/src/Settings.cpp
      +++ b/src/Settings.cpp
      @@ -39,6 +39,7 @@
        */
       #include <QTextStream>
       #include <QFile>
      +#include <QStandardPaths>
       #include "Settings.h"
       #include "GuiTopBar.h"
       #include "GuiSidePanel.h"
      @@ -407,8 +408,28 @@
               settings.beginGroup("CurrentVersion/Explorer/Shell Folders");
               destMusicDir.setPath(QDir::fromNativeSeparators(settings.value("Personal").toString()));
       #else
      -        const QString MUSIC_DIR_NAME("Music");
      -        destMusicDir.setPath(QDir::homePath() );
      +        // Honor XDG_MUSIC_DIR (including values like "$HOME/music"), then
      +        // fall back to the directory defined by ~/.config/user-dirs.dirs.
      +        QString musicDir = qEnvironmentVariable("XDG_MUSIC_DIR");
      +        if (musicDir == "$HOME")
      +            musicDir = QDir::homePath();
      +        else if (musicDir.startsWith("$HOME/"))
      +            musicDir.replace(0, 5, QDir::homePath());
      +        else if (musicDir.startsWith("~/"))
      +            musicDir.replace(0, 1, QDir::homePath());
      +
      +        if (!QDir::isAbsolutePath(musicDir))
      +            musicDir = QStandardPaths::writableLocation(QStandardPaths::MusicLocation);
      +        musicDir = QDir::cleanPath(musicDir);
      +        if (!QDir().mkpath(musicDir)) {
      +            ppLogError("Cannot create music directory: %s", qPrintable(musicDir));
      +            return;
      +        }
      +
      +        // Keep the existing code below (also used on Windows) unchanged.
      +        const QFileInfo musicDirInfo(musicDir);
      +        const QString MUSIC_DIR_NAME(musicDirInfo.fileName());
      +        destMusicDir.setPath(musicDirInfo.absolutePath());
       #endif
               if (!QDir(destMusicDir.absolutePath() + "/" + MUSIC_DIR_NAME).exists())
               {
    '')
  ];
})
