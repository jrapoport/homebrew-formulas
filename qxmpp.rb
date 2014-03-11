require 'formula'

class Qxmpp < Formula
  homepage 'https://code.google.com/p/qxmpp/'
  url 'https://qxmpp.googlecode.com/files/qxmpp-0.7.6.tar.gz'
  sha1 'a87b4b5c94d1f4dc723cbbb7799cf4067c7e5ea2'

  depends_on 'highfidelity/formulas/qt5'

  def install
    system "qmake", "-config", "release", "PREFIX=#{prefix}", "QXMPP_LIBRARY_TYPE=staticlib"
    system "make"
    system "make install"
  end
end