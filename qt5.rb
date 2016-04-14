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
  url "http://download.qt-project.org/official_releases/qt/5.6/5.6.0/single/qt-everywhere-opensource-src-5.6.0.tar.gz"
  sha1 "4f111a4d6bb90eaed024b857b1bd3d0731ace8a2"

  head "git://gitorious.org/qt/qt5.git", :branch => "stable",
    :using => Qt5HeadDownloadStrategy, :shallow => false
  
  bottle do
    root_url 'http://hifi-public.s3.amazonaws.com/dependencies/qt'
    sha256 "12ff4e151d4f93a8522f21d4a48fffa974a29b81002a840ff0ee3467a01fe62e" => :yosemite
    revision 1
  end

  keg_only "Qt 5 conflicts Qt 4 (which is currently much more widely used)."

  option :universal
  option "with-docs", "Build documentation"
  option "with-examples", "Build examples"
  option "developer", "Build and link with developer options"

  depends_on "pkg-config" => :build
  depends_on "d-bus" => :optional
  depends_on :mysql => :optional
  depends_on :xcode => :build
  
  deprecated_option "qtdbus" => "with-d-bus"
  
  # fix exclusion of QT_NO_BEARER_MANAGEMENT in qcorewlanegine.mm
  #patch do
  #  url 'https://gist.githubusercontent.com/birarda/c8b48f06a8a33b5bf952/raw/7fb6925f4e2cda8b4538c56a529b07de2c5bf895/corewlan-bearer.5.4.0.patch'
  #  sha1 '9aecfda8129afbe31c860cda4c6776e49264b8b4' 
  #end
  
  # modify texture shader in WebCore to support core profile
  patch do
    url 'https://gist.githubusercontent.com/birarda/5733ea7858a491846de1/raw/5af0acbd786a37da828225aca910cb583858e780/QtGlCoreFix.patch'
    sha1 'a4f0f7aa83eb55eb5be151bf9305cf1bb773a7f0'
  end
  
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
            "-skip", "qtenginio",
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
