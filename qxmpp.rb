require 'formula'

class Qxmpp < Formula
  homepage 'https://code.google.com/p/qxmpp/'
  url 'https://qxmpp.googlecode.com/files/qxmpp-0.7.6.tar.gz'
  sha1 'a87b4b5c94d1f4dc723cbbb7799cf4067c7e5ea2'

  depends_on 'highfidelity/formulas/qt5'
  
  option 'static', 'Compile as static library'

  def install
    qmake_args = ["-config", "release", "PREFIX=#{prefix}"]
    qmake_args << "QXMPP_LIBRARY_TYPE=staticlib" if build.include? 'static'
    system "qmake", *qmake_args
    system "make"
    system "make install"
  end
end