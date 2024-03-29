class CartaCasacore < Formula
  desc "This is carta-casacore used by CARTA"
  homepage "https://github.com/CARTAvis/carta-casacore"
  url "https://github.com/CARTAvis/carta-casacore.git", tag: "3.5.0+6.6.0+2024.1.18"
  license "GPL-2.0-only"

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
    url "https://carta.asiaa.sinica.edu.tw/_downloads/measures_data_21_1_2024.tgz"
    sha256 "2e7977836b735f5201915311c5c384272270ecbc4d86604f79f73a8e15cdc220"
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
      system "cmake", "..", "-DUSE_FFTW3=ON",
                            "-DUSE_HDF5=ON",
                            "-DUSE_THREADS=ON",
                            "-DUSE_OPENMP=ON",
                            "-DCMAKE_BUILD_TYPE=Release",
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
