class CartaBeta < Formula
  desc "Carta-backend and carta-frontend components of CARTA"
  homepage "https://cartavis.github.io/"
  url "https://github.com/CARTAvis/carta-backend.git", tag: "v2.0.0-beta.0"
  license "GPL-3.0-only"

  bottle do
    root_url "https://github.com/CARTAvis/homebrew-tap/releases/download/carta-beta-2.0.0-beta.0"
    rebuild 1
    sha256 cellar: :any,                 catalina:     "ec196d2a6398fb66a3c5691540223ae24471c88ec5f5cfa60a792609fb6a0f80"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "7c596a1ec9d2dcf3ac9fc592896e48eca299c7f9e61634ad85fb14b682cb3d67"
  end

  depends_on "cmake" => :build
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
  depends_on "tbb"
  depends_on "wcslib"
  depends_on "zstd"

  resource "frontend" do
    url "https://registry.npmjs.org/carta-frontend/-/carta-frontend-2.0.0-beta.0.tgz"
    sha256 "14d252e27eb2311fd44fbe17116eabe0faa37248ea5ba8e4c72183f882ff6d66"
  end

  def install
    # Building the carta-backend
    system "git", "submodule", "update", "--recursive", "--init"
    ENV["OPENSSL_ROOT_DIR"] = "$(brew --prefix openssl)"
    path = HOMEBREW_PREFIX/"Cellar/carta-casacore/2021.2.4/include"
    mkdir "build-backend" do
      system "cmake", "..", "-DCMAKE_PREFIX_PATH=#{lib}",
                            "-DCMAKE_INCLUDE_PATH=#{include}",
                            "-DCMAKE_CXX_FLAGS=-I#{path}/casacode -I#{path}/casacore",
                            "-DCMAKE_CXX_STANDARD_LIBRARIES=-L#{lib}", *std_cmake_args
      system "make", "install"
    end
    # Grabing the pre-built carta-frontend from the npm repository.
    resource("frontend").stage do
      mkdir_p "#{share}/carta/frontend"
      cp_r "build/.", share/"carta/frontend"
    end
  end

  test do
    assert_match "2.0.0-beta.0", shell_output("#{bin}/carta_backend --version")
  end
end
