class CartaBeta < Formula
  desc "The carta-backend-beta and carta-frontend-beta components of CARTA"
  homepage "https://cartavis.github.io/"
  url "https://github.com/CARTAvis/carta-backend.git", tag: "v3.0.0-beta.2b"
  license "GPL-3.0-only"

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
  depends_on "wcslib"
  depends_on "zstd"

  resource "frontend" do
    url "https://registry.npmjs.org/carta-frontend/-/carta-frontend-3.0.0-beta.2b.tgz"
    sha256 "860ce2436c11543e2dbbc049cb905d850e080cc8a266f3134810a413425bf971"
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
      "-DCMAKE_BUILD_TYPE=RelWithDebInfo",
      "-DCartaUserFolderPrefix=.carta-beta",
    ]
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
        CARTA officially supports the latest three MacOS versions; Catalina 10.15, Big Sur 11, and Monterey 12.
        You are running MacOS #{MacOS.version}.
        CARTA will not work on MacOS #{MacOS.version} because Boost Filesystem support was removed.
      EOS
      s
    end
  end

  test do
    assert_match "3.0.0-beta.2b", shell_output("#{bin}/carta_backend --version")
  end
end
