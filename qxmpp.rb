require 'formula'
require 'requirement'

class Qt5Requirement < Requirement
  
  fatal true
  default_formula (which('qmake') && !which('qmake').to_s.include?(HOMEBREW_PREFIX) ? false : 'highfidelity/formulas/qt5')
  
  def message
    qt_version, qt_path = `qmake --version`.scan(/Qt version ([\d.]+) in ([\w.\/]+)/)[0]
    
    message = <<-EOS.undent
      It appears you already have Qt #{qt_version} installed at #{qt_path}.
      To use Qt 5 that comes with this recipe, first uninstall Qt 5, 
      then run this command again.

      If you would like to keep your installation of Qt #{qt_version} instead of
      using the one provided with homebrew, install the formula with
      the `--without-qt5` option.
    EOS
  end

  satisfy :build_env => false do
    which('qmake') && which('qmake').to_s.include?(HOMEBREW_PREFIX)
  end
end

class Qxmpp < Formula
  homepage 'https://code.google.com/p/qxmpp/'
  url 'https://qxmpp.googlecode.com/files/qxmpp-0.7.6.tar.gz'
  sha1 'a87b4b5c94d1f4dc723cbbb7799cf4067c7e5ea2'

  depends_on Qt5Requirement => :recommended
  
  option 'static', 'Compile as static library'

  def install
    qmake_args = ["-config", "release", "PREFIX=#{prefix}"]
    qmake_args << "QXMPP_LIBRARY_TYPE=staticlib" if build.include? 'static'
    system "qmake", *qmake_args
    system "make"
    system "make install"
  end
end