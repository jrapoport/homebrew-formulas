require "formula"

class Rtmidi < Formula
  homepage "http://www.music.mcgill.ca/~gary/rtmidi/"
  url "http://highfidelity-public.s3.amazonaws.com/dependencies/rtmidi-2.1.0.tar.gz"
  sha1 "e6e8fe7f67eb6dbf0504f72307a47a41e06b1652"

  def install
    # Remove unrecognized options if warned by configure
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    # system "cmake", ".", *std_cmake_args
    system "make", "install" # if this fails, try separate make/make install steps
  end
end
