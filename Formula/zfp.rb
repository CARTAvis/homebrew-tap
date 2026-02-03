class Zfp < Formula
  desc "Compressed numerical arrays that support high-speed random access"
  homepage "https://github.com/LLNL/zfp"
  url "https://github.com/LLNL/zfp/releases/download/1.0.1/zfp-1.0.1.tar.gz"
  sha256 "ca0f7b4ae88044ffdda12faead30723fe83dd8f5bb0db74125df84589e60e52b"
  license "BSD-3-Clause"

  depends_on "cmake" => :build

  def install
    ENV.deparallelize
    system "cmake", "-S", ".", "-B", "build",
                                     "-DBUILD_EXAMPLES=OFF",
                                     "-DZFP_WITH_OPENMP=OFF", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    assert_true Dir.exist?(lib)
  end
end
