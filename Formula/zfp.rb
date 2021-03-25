class Zfp < Formula
  desc "Compressed numerical arrays that support high-speed random access"
  homepage "https://github.com/LLNL/zfp"
  url "https://github.com/LLNL/zfp/releases/download/0.5.5/zfp-0.5.5.tar.gz"
  sha256 "fdf7b948bab1f4e5dccfe2c2048fd98c24e417ad8fb8a51ed3463d04147393c5"
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
