class Carta < Formula
  desc "Carta-backend and carta-frontend components of CARTA"
  homepage "https://cartavis.github.io/"
  url "https://github.com/CARTAvis/carta-backend.git", tag: "v2.0.0"
  license "GPL-3.0-only"

  depends_on "cmake" => :build
  depends_on "boost" if MacOS.version <= :mojave
  depends_on "cartavis/tap/carta-casacore"
  depends_on "cartavis/tap/zfp"
  depends_on "curl"
  depends_on "fmt"
  depends_on "grpc"
  depends_on "libomp"
  depends_on "libuv"
  depends_on "pkg-config"
  depends_on "protobuf"
  depends_on "pugixml"
  depends_on "wcslib"
  depends_on "zstd"
  on_macos do
    depends_on "tbb@2020"
  end
  on_linux do
    depends_on "tbb"
  end

  conflicts_with "carta-beta", :because => "they both share the same executable name; 'carta'."

  resource "frontend" do
    url "https://registry.npmjs.org/carta-frontend/-/carta-frontend-2.0.0.tgz"
    sha256 "c347dbd33466cd2f73a4f55e5b68a70573a82e5f0b7c0b1a10f1da91aeaeee21"
  end

  def install
    # Building the carta-backend
    system "git", "submodule", "update", "--recursive", "--init"
    ENV["OPENSSL_ROOT_DIR"] = "$(brew --prefix openssl)"
    path = HOMEBREW_PREFIX/"Cellar/carta-casacore/2021.2.4/include"
    args = [
      "-DCMAKE_PREFIX_PATH=#{lib}",
      "-DCMAKE_INCLUDE_PATH=#{include}",
      "-DCMAKE_CXX_FLAGS=-I#{path}/casacode -I#{path}/casacore",
      "-DCMAKE_CXX_STANDARD_LIBRARIES=-L#{lib}",
    ]
    args << "-DUseBoostFilesystem=True" if MacOS.version <= :mojave
    mkdir "build-backend" do
      system "cmake", "..", *args, *std_cmake_args
      system "make", "install"
    end
    # Grabing the pre-built carta-frontend from the npm repository.
    resource("frontend").stage do
      mkdir_p "#{share}/carta/frontend"
      cp_r "build/.", share/"carta/frontend"
    end
  end

  def caveats
    if MacOS.version <= :mojave
      s = <<~EOS     
      CARTA officially supports the latest two MacOS versions; Catalina 10.15 and Big Sur 11.0.
      You are running MacOS #{MacOS.version}.
      CARTA may still work on MacOS #{MacOS.version}, but it is untested by the CARTA team.
      EOS
      s
    end
  end    

  test do
    assert_match "2.0.0", shell_output("#{bin}/carta_backend --version")
  end
end
