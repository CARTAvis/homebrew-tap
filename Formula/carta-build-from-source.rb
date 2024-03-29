class Carta < Formula
  desc "Backend and frontend components of CARTA"
  homepage "https://cartavis.github.io/"
  url "https://github.com/CARTAvis/carta-backend.git", tag: "v4.1.0"
  license "GPL-3.0-only"

  depends_on "cmake" => :build
  depends_on "cartavis/tap/carta-casacore"
  depends_on "cartavis/tap/zfp"
  depends_on "curl"
  depends_on "fmt"
  depends_on "hdf5@1.10"  
  depends_on "libomp"
  depends_on "libuv"
  depends_on "pkg-config"
  depends_on "protobuf@21"
  depends_on "wcslib"
  depends_on "zstd"

  conflicts_with "carta-beta", because: "they both share the same executable name; 'carta'"

  resource "frontend" do
    url "https://registry.npmjs.org/carta-frontend/-/carta-frontend-4.1.0.tgz"
    sha256 "6bf5588b8014445167148f9da05b2b284e56ffef37d521a22f2397a6042a242d"
  end

  def install

    # Building the carta-backend
    system "git", "submodule", "update", "--recursive", "--init"
    ENV["OPENSSL_ROOT_DIR"] = "$(brew --prefix openssl)"
    path = HOMEBREW_PREFIX/"Cellar/carta-casacore/2024.1.18/include"
    args = [
      "-DCMAKE_PREFIX_PATH=#{lib}",
      "-DCMAKE_INCLUDE_PATH=#{include}",
      "-DCMAKE_CXX_FLAGS=-I#{path}/casacode -I#{path}/casacore",
      "-DCMAKE_CXX_STANDARD_LIBRARIES=-L#{HOMEBREW_PREFIX}/lib;-L#{lib}",
      "-DCARTA_CASACORE_ROOT=#{HOMEBREW_PREFIX}/Cellar/carta-casacore",
      "-DCartaUserFolderPrefix=.carta",
      "-DDEPLOYMENT_TYPE=homebrew",
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
    s = <<~EOS
      CARTA officially supports the latest three MacOS versions; Big Sur 11, Monterey 12, and Ventura 13.
    EOS
    if MacOS.version <= :mojave
      s = <<~EOS
        You are running MacOS #{MacOS.version}. CARTA can not run on MacOS #{MacOS.version}.
      EOS
    end
    s
  end

  test do
    assert_match "4.1.0", shell_output("#{bin}/carta_backend --version")
  end
end
