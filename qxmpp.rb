require 'formula'

class Qt5Requirement < Requirement
  
  default_formula 'highfidelity/formulas/qt5'
  
  def qt_info
    `qmake --version`.scan(/Qt version ([\d.]+) in ([\w.\/]+)/)[0]
  end
  
  def qmake_location
    which('qmake')
  end
  
  def message 
    qt_version, qt_path = qt_info
    if qmake_location
      fatal true
      <<-EOS.undent
        It appears you already have Qt #{qt_version} installed at #{qt_path}.
        To use Qt 5 that comes with this recipe, first uninstall Qt5, 
        then run this command again.

        If you would like to keep your installation of Qt #{qt_version} instead of
        using the one provided with homebrew, install the formula with
        the `--without-qt5` option.
      EOS
    else
      fatal false
      <<-EOS.undent
        Qt 5 is missing. Installing Qt 5 from High Fidelity formula for patched Qt. 
      EOS
    end
  end

  satisfy :build_env => false do
    qmake_location && qmake_location.to_s.include?(HOMEBREW_CELLAR)
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