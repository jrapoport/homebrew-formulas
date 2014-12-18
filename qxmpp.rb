require 'formula'
require 'requirement'

class Qt5Requirement < Requirement
  fatal true

  satisfy :build_env => false do
    @qmake = which('qmake')
    @qmake
  end
  
  env do
    ENV.append_path 'PATH', @qmake.parent
  end
  
  def message
    message = <<-EOS.undent
      Homebrew was unable to find an installation of Qt 5, which is required
      to build qxmpp. If you have Qt 5 installed, make sure that the qmake executable
      is in your path.
      
      If you need to install Qt 5, you can install it with:
      
      brew install highfidelity/formulas/qt5
      
      (assuming that you have already called `brew tap highfidelity/homebrew-formulas`).
      
      If you do not want to use the High Fidelity patched version of Qt 5,
      you can also install it from the homebrew default formula by calling:
      
      brew install qt5
      
    EOS
  end
end

class Qxmpp < Formula
  homepage 'https://code.google.com/p/qxmpp/'
  url 'https://qxmpp.googlecode.com/files/qxmpp-0.7.6.tar.gz'
  sha1 'a87b4b5c94d1f4dc723cbbb7799cf4067c7e5ea2'

  depends_on Qt5Requirement => :recommended
  
  option 'static', 'Compile as static library'
  
  patch :DATA

  def install
    qmake_args = ["-config", "release", "PREFIX=#{prefix}"]
    qmake_args << "QXMPP_LIBRARY_TYPE=staticlib" if build.include? 'static'
    system "qmake", *qmake_args
    system "make"
    system "make install"
  end
end

__END__
diff --git a/src/src.pro b/src/src.pro
index 954738c..8404c8c 100644
--- a/src/src.pro
+++ b/src/src.pro
@@ -4,7 +4,7 @@ QT -= gui
 
 TEMPLATE = lib
 
-CONFIG += $$QXMPP_LIBRARY_TYPE
+CONFIG += $$QXMPP_LIBRARY_TYPE c++11
 DEFINES += QXMPP_BUILD
 DEFINES += $$QXMPP_INTERNAL_DEFINES
 INCLUDEPATH += $$QXMPP_INCLUDEPATH $$QXMPP_INTERNAL_INCLUDES
 