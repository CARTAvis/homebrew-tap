class Zfp < Formula
  desc "Compressed numerical arrays that support high-speed random access"
  homepage "https://github.com/LLNL/zfp"
  url "https://github.com/LLNL/zfp/releases/download/0.5.5/zfp-0.5.5.tar.gz"
  sha256 "fdf7b948bab1f4e5dccfe2c2048fd98c24e417ad8fb8a51ed3463d04147393c5"
  license "BSD-3-Clause"

  bottle do
    root_url "https://github.com/CARTAvis/homebrew-tap/releases/download/zfp-0.5.5"
    sha256 cellar: :any,                 catalina:     "66476ab98d8d3b525c53f54b2814234d95b0cf72c4461a93642030ee286a9b15"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "adc9adad8c139c61c74212050b4ecdaf0e8964b9dcbc7d2017cd30e1516ffd79"
  end

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
