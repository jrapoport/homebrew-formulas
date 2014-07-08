require "formula"

class Rtmidi < Formula
  homepage "http://www.music.mcgill.ca/~gary/rtmidi/"
  url "http://highfidelity-public.s3.amazonaws.com/dependencies/rtmidi-2.1.0.tar.gz"
  sha1 "e6e8fe7f67eb6dbf0504f72307a47a41e06b1652"

  def install
    system "./configure", "--prefix=#{prefix}"
    
    system "make"
    lib.install Dir['*.a', '*.dylib']
    include.install Dir['*.h']
  end
end
