class CartaBeta < Formula
  desc "Carta-backend and carta-frontend components of CARTA"
  homepage "https://cartavis.github.io/"
  url "https://github.com/CARTAvis/carta-backend.git", tag: "v2.0.0-beta.0"
  license "GPL-3.0-only"

  bottle do
    root_url "https://github.com/CARTAvis/homebrew-tap/releases/download/carta-beta-2.0.0-beta.0"
    rebuild 1
    sha256 cellar: :any, arm64_big_sur: "78e836fba8ed8e94e2105558f51e631bcb7e63379135bfc11f318a41a34cc69e"
    sha256 cellar: :any, big_sur: "df1fca59c9840f521cdf51a11afc3bedd41ce50fd5b3b87c233a9a30c83d002b"
    sha256 cellar: :any, catalina: "989c5c5d0a12f5ec7a016bc07bfc364bd77c6b7d80371c52c9de17a211c8f03b"
    sha256 cellar: :any, mojave: "6e4c7978d59de85141da6b0469f558db46d3a657e9298c7ad0817bc6d8bc2377"
    sha256 cellar: :any, high_sierra: "a91adf574df2fad98852c3758c17ce1dfc26557e6240bca3b16ba189bb2eb957"
  end

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

  resource "frontend" do
    url "https://registry.npmjs.org/carta-frontend/-/carta-frontend-2.0.0-beta.0.tgz"
    sha256 "14d252e27eb2311fd44fbe17116eabe0faa37248ea5ba8e4c72183f882ff6d66"
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
    s = <<-EOS.undent
      CARTA officially supports only the latest two MacOS versions; Catalina 10.15 and Big Sur 11.0. 
      It may still work on older versions, but is untested by the CARTA team."
    s += "You are running the unsupported MacOS #{version} version. " if MacOS.version < :catalina
    s
  end

  test do
    assert_match "2.0.0-beta.0", shell_output("#{bin}/carta_backend --version")
  end
end
