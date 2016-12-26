require File.expand_path("../../Requirements/php-meta-requirement", __FILE__)

class DrupalCodeSniffer < Formula
  desc "Checks Drupal code against coding standards"
  homepage "https://drupal.org/project/coder"
  url "http://ftp.drupal.org/files/projects/coder-8.x-2.10.tar.gz"
  version "8.x-2.10"
  sha256 "284fe865de904fdcbb512211ba8e18b78c79799868634cca8c7307c4f6902209"
  head "http://git.drupal.org/project/coder.git", :branch => "8.x-2.x"

  bottle do
    cellar :any_skip_relocation
    sha256 "3f2a620adc9c77162feba9f78af6e9ee87c83c13eb0f2059a981c9c59f1fcfaa" => :sierra
    sha256 "545a1172f8d92b53e9e6e61d9347996a7addf851b1ab91ae2d334d529ad200f8" => :el_capitan
    sha256 "545a1172f8d92b53e9e6e61d9347996a7addf851b1ab91ae2d334d529ad200f8" => :yosemite
  end

  option "without-drupalpractice-standard", "Don't install DrupalPractice standard"

  depends_on "php-code-sniffer"
  depends_on PhpMetaRequirement

  def phpcs_standards
    Formula["php-code-sniffer"].phpcs_standards
  end

  def drupal_standard_name
    "Drupal"
  end

  def drupalpractice_standard_name
    "DrupalPractice"
  end

  def install
    prefix.install "coder_sniffer"
  end

  def post_install
    # Link Drupal Coder Sniffer into PHPCS standards.
    phpcs_standards.mkpath
    if File.symlink? phpcs_standards+drupal_standard_name
      File.delete phpcs_standards+drupal_standard_name
    end
    phpcs_standards.install_symlink prefix+"coder_sniffer"+drupal_standard_name

    # Link DrupalPractice Sniffer into PHPCS standards if not disabled.
    if build.with? "drupalpractice-standard"
      phpcs_standards.mkpath
      if File.symlink? phpcs_standards+drupalpractice_standard_name
        File.delete phpcs_standards+drupalpractice_standard_name
      end
      phpcs_standards.install_symlink prefix+"coder_sniffer"+drupalpractice_standard_name
    end
  end

  def caveats
    <<-EOS.undent
    Drupal Coder Sniffer is linked to "#{phpcs_standards+drupal_standard_name}".

    You can verify whether PHP Code Sniffer has detected the standard by running:

      #{Formula["php-code-sniffer"].phpcs_script_name} -i

    EOS
  end

  test do
    system "#{Formula["php-code-sniffer"].phpcs_script_name} -i | grep #{drupal_standard_name}"
    if build.with? "drupalpractice-standard"
      system "#{Formula["php-code-sniffer"].phpcs_script_name} -i | grep #{drupalpractice_standard_name}"
    end
  end
end
