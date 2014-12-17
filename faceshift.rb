require "formula"

class Faceshift < Formula
  homepage "http://www.faceshift.com/"
  url "http://hifi-public.s3.amazonaws.com/dependencies/faceshift-1.0.tar.gz"
  sha1 "9bfa572d84de8e7c0d9ad06528a0023557cae06b"

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end
