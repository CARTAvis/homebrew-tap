class CartaBeta < Formula
  desc "Carta-backend-beta and carta-frontend-beta components of CARTA"
  homepage "https://cartavis.github.io/"
  url "https://github.com/CARTAvis/carta-backend.git", tag: "v4.0.0-beta.1"
  license "GPL-3.0-only"

  depends_on "cmake" => :build
  depends_on "cartavis/tap/carta-casacore"
  depends_on "cartavis/tap/zfp"
  depends_on "curl"
  depends_on "fmt"
  depends_on "grpc"
  depends_on "hdf5@1.10"  
  depends_on "libomp"
  depends_on "libuv"
  depends_on "pkg-config"
  depends_on "protobuf@21"
  depends_on "wcslib"
  depends_on "zstd"

  conflicts_with "carta", because: "they both share the same executable name; 'carta'"

  resource "frontend" do
    url "https://registry.npmjs.org/carta-frontend/-/carta-frontend-4.0.0-beta.1.tgz"
    sha256 "54b6cff6c0b27e6838cbbb9eda327cb44ca40774461a57e507cd7bcbf8ce2dc8"
  end

  # Fix to support cfitsio 4.2.0+
  # See https://github.com/CARTAvis/carta-backend/pull/1232
  patch do
    url "https://gist.githubusercontent.com/ajm-asiaa/18244b2740b0ca69f7bf0464aaa2e614/raw/429611c2d896b8845ecc4114431842e9428bdb75/0000-Use-nullptr-or-cfitsio-length-constant-for-fits_read.patch"
    sha256 "ddabeff06afe62fd095a155f71f17ebd5303645d755fecc8afc8eaaca087b065"
  end

  def install
    # Building the carta-backend
    system "git", "submodule", "update", "--recursive", "--init"
    ENV["OPENSSL_ROOT_DIR"] = "$(brew --prefix openssl)"
    path = HOMEBREW_PREFIX/"Cellar/carta-casacore/2022.5.11/include"
    args = [
      "-DCMAKE_PREFIX_PATH=#{lib}",
      "-DCMAKE_INCLUDE_PATH=#{include}",
      "-DCMAKE_CXX_FLAGS=-I#{path}/casacode -I#{path}/casacore",
      "-DCMAKE_CXX_STANDARD_LIBRARIES=-L#{lib}",
      "-DCMAKE_BUILD_TYPE=RelWithDebInfo",
      "-DCartaUserFolderPrefix=.carta-beta",
      "-DCARTA_CASACORE_ROOT=#{path}/../",
    ]
    mkdir "build-backend" do
      system "cmake", "..", *args, *std_cmake_args
      system "make", "install"
    # Remove the rogue pugixml files
    rm "#{prefix}/include/pugiconfig.hpp"
    rm "#{prefix}/include/pugixml.hpp"
    rm "#{lib}/cmake/pugixml/pugixml-config-version.cmake"
    rm "#{lib}/cmake/pugixml/pugixml-config.cmake"
    rm "#{lib}/cmake/pugixml/pugixml-targets-release.cmake"
    rm "#{lib}/cmake/pugixml/pugixml-targets.cmake"
    rm "#{lib}/libpugixml.a"
    rm "#{lib}/pkgconfig/pugixml.pc"
    end
    # Grabing the pre-built carta-frontend from the npm repository.
    resource("frontend").stage do
      mkdir_p "#{share}/carta/frontend"
      cp_r "build/.", share/"carta/frontend"
    end
  end

  def caveats
    s = <<~EOS
      CARTA officially supports the latest three MacOS versions; Big Sur 11, Monterey 12, and Ventura 13.
    EOS
    if MacOS.version <= :mojave
      s = <<~EOS
        You are using MacOS #{MacOS.version}.
        CARTA can not run on MacOS #{MacOS.version}.
      EOS
    end
    s
  end

  test do
    assert_match "4.0.0-beta.1", shell_output("#{bin}/carta_backend --version")
  end
end
