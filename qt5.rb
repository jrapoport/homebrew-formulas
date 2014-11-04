# this is a Qt5 formula patched to remove bearer management so it doesn't constantly scan for wireless networks

require 'formula'

class Qt5HeadDownloadStrategy < GitDownloadStrategy
  include FileUtils

  def stage
    @clone.cd { reset }
    safe_system 'git', 'clone', @clone, '.'
    ln_s @clone, 'qt'
    safe_system './init-repository', '--mirror', "#{Dir.pwd}/"
    rm 'qt'
  end
end

class Qt5 < Formula
  homepage "http://qt-project.org/"
  url "http://download.qt-project.org/official_releases/qt/5.3/5.3.2/single/qt-everywhere-opensource-src-5.3.2.tar.gz"
  sha1 "502dd2db1e9ce349bb8ac48b4edf7f768df1cafe"

  head "git://gitorious.org/qt/qt5.git", :branch => "stable",
    :using => Qt5HeadDownloadStrategy, :shallow => false
    
  bottle do
    root_url 'http://hifi-public.s3.amazonaws.com/dependencies/qt'
    revision 1
    sha1 "5be505fa4867c7932bf52d99d4e2805209ed0401" => :mavericks
  end

  keg_only "Qt 5 conflicts Qt 4 (which is currently much more widely used)."

  option :universal

  depends_on "pkg-config" => :build
  depends_on "d-bus" => :optional
  depends_on "mysql" => :optional
  
  # fix exclusion of QT_NO_BEARER_MANAGEMENT in qcorewlanegine.mm
  patch do
    url 'https://gist.githubusercontent.com/birarda/e0ae11a4c57c95348d63/raw/59561a3385be4bd3ae5e920757327f67509b3ca9/corewlan-bearer.patch'
    sha1 '4adfadc39e5ab386b6915aa88912b9043cce253d' 
  end
  
  # Patch to fix compile errors on Yosemite. Can be removed with 5.4.
  # https://bugreports.qt-project.org/browse/QTBUG-41136
  patch :DATA
  
  def pour_bottle?
    return !build.devel?
  end

  def install
    ENV.universal_binary if build.universal?
    
    args = ["-prefix", prefix,
            "-system-zlib",
            "-qt-libpng", "-qt-libjpeg",
            "-confirm-license", "-opensource",
            "-nomake", "tests",
            "-release"]

    args << "-nomake" << "examples" if build.without? "examples"

    # https://bugreports.qt-project.org/browse/QTBUG-34382
    args << "-no-xcb"

    args << "-plugin-sql-mysql" if build.with? "mysql"

    if build.with? "d-bus"
      dbus_opt = Formula["d-bus"].opt_prefix
      args << "-I#{dbus_opt}/lib/dbus-1.0/include"
      args << "-I#{dbus_opt}/include/dbus-1.0"
      args << "-L#{dbus_opt}/lib"
      args << "-ldbus-1"
      args << "-dbus-linked"
    end

    if MacOS.prefer_64_bit? or build.universal?
      args << "-arch" << "x86_64"
    end

    if !MacOS.prefer_64_bit? or build.universal?
      args << "-arch" << "x86"
    end

    if build.with? "oci"
      args << "-I#{ENV['ORACLE_HOME']}/sdk/include"
      args << "-L{ENV['ORACLE_HOME']}"
      args << "-plugin-sql-oci"
    end
    
    ENV.append 'CXXFLAGS', '-DQT_NO_BEARERMANAGEMENT'
    args << "-no-feature-bearermanagement"

    args << "-developer-build" if build.include? "developer"

    system "./configure", *args
    system "make"
    ENV.j1
    system "make install"
    if build.with? "docs"
      system "make", "docs"
      system "make", "install_docs"
    end

    # Some config scripts will only find Qt in a "Frameworks" folder
    frameworks.install_symlink Dir["#{lib}/*.framework"]

    # The pkg-config files installed suggest that headers can be found in the
    # `include` directory. Make this so by creating symlinks from `include` to
    # the Frameworks' Headers folders.
    Pathname.glob("#{lib}/*.framework/Headers") do |path|
      include.install_symlink path => path.parent.basename(".framework")
    end

    # configure saved the PKG_CONFIG_LIBDIR set up by superenv; remove it
    # see: https://github.com/Homebrew/homebrew/issues/27184
    inreplace prefix/"mkspecs/qconfig.pri", /\n\n# pkgconfig/, ""
    inreplace prefix/"mkspecs/qconfig.pri", /\nPKG_CONFIG_.*=.*$/, ""

    Pathname.glob("#{bin}/*.app") { |app| mv app, prefix }
  end
    
  test do
    system "#{bin}/qmake", "-project"
  end

  def caveats; <<-EOS.undent
    We agreed to the Qt opensource license for you.
    If this is unacceptable you should uninstall.
    EOS
  end
end

__END__
diff --git a/qtmultimedia/src/plugins/avfoundation/mediaplayer/avfmediaplayersession.mm b/qtmultimedia/src/plugins/avfoundation/mediaplayer/avfmediaplayersession.mm
index a73974c..d3f3eae 100644
--- a/qtmultimedia/src/plugins/avfoundation/mediaplayer/avfmediaplayersession.mm
+++ b/qtmultimedia/src/plugins/avfoundation/mediaplayer/avfmediaplayersession.mm
@@ -322,7 +322,7 @@ static void *AVFMediaPlayerSessionObserverCurrentItemObservationContext = &AVFMe
     //AVPlayerItem "status" property value observer.
     if (context == AVFMediaPlayerSessionObserverStatusObservationContext)
     {
-        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
+        AVPlayerStatus status = (AVPlayerStatus)[[change objectForKey:NSKeyValueChangeNewKey] integerValue];
         switch (status)
         {
             //Indicates that the status of the player is not yet known because
