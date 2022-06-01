class Fits2idia < Formula
  desc "C++ implementation of FITS to IDIA-HDF5 converter, optimised using OpenMP"
  homepage "https://github.com/CARTAvis/fits2idia"
  url "https://github.com/CARTAvis/fits2idia/archive/refs/tags/v0.1.15.tar.gz"
  sha256 "58242127a0bdac631fb962d3fceeed905385e458f1997ba013f3d3aa907c4335"
  license "GPL-3.0-only"

  depends_on "cmake" => :build
  depends_on "cfitsio"
  depends_on "hdf5"
  depends_on "libomp"

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    assert_predicate bin/"fits2idia", :exist?
  end
end
