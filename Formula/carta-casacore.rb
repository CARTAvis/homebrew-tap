class CartaCasacore < Formula
  desc "This is carta-casacore used by CARTA"
  homepage "https://github.com/CARTAvis/carta-casacore"
  url "https://github.com/CARTAvis/carta-casacore.git", tag: "3.8.0+6.7.5+2026.3.3"
  license "GPL-3+"

  depends_on "cmake" => :build
  depends_on "cfitsio"
  depends_on "fftw"
  depends_on "gcc"
  depends_on "gsl"
  depends_on "hdf5@1.10"
  depends_on "lapack" # for linux
  depends_on "openblas" # for linux
  depends_on "wcslib"

  resource "casadata" do
    url "https://carta.asiaa.sinica.edu.tw/_downloads/measures_data_13_3_2026.tgz"
    sha256 "36511ca719ed728bbffeb067f065e490b0951b34eed47bbd38a019708781406d"
  end

  def install

    resource("casadata").stage do
      mkdir_p "#{share}/casacore/data"
      cp_r "ephemerides", "#{share}/casacore/data"
      cp_r "geodetic", "#{share}/casacore/data"
    end

    ENV["FCFLAGS"] = "-w -fallow-argument-mismatch -O2"
    ENV["FFLAGS"] = "-w -fallow-argument-mismatch -O2"

    system "git", "submodule", "init"
    system "git", "submodule", "update"

    chdir "casa6" do
      system "git", "submodule", "init"
      system "git", "submodule", "update"
    end

    mkdir "build" do
      system "cmake", "..", "-DCMAKE_BUILD_TYPE=Release",
                            "-DBUILD_TESTING=OFF",
                            "-DBUILD_PYTHON=OFF",
                            "-DUseCcache=1",
                            "-DDATA_DIR=#{share}/casacore/data",                            
                            "-DHAS_CXX11=1", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    assert_match "casacore built with HDF5 support", shell_output("#{bin}/casahdf5support")
  end
end
