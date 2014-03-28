require 'formula'
require 'requirement'

class Qca < Formula
  homepage 'http://delta.affinix.com/qca/'
  head 'https://github.com/highfidelity/qca.git'

  depends_on 'cmake'
  depends_on 'highfidelity/formulas/qt5'

  def install
    ENV.append_path "QT_CMAKE_PREFIX_PATH", "#{HOMEBREW_PREFIX}/Cellar/qt5"
    
    system "cmake . -DCMAKE_INSTALL_PREFIX=#{prefix}"  
    system "make"
    system "make install"
  end
end