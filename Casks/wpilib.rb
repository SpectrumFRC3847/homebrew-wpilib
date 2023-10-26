cask 'wpilib' do
  version '2023.4.3'
  sha256 '8dad67e28a3bdf482979a1fe4c857d52ab36a2fdec56ae05971b7177d5409ae9'

  # github.com/wpilibsuite/allwpilib was verified as official when first introduced to the cask
  url "https://github.com/wpilibsuite/allwpilib/releases/download/v#{version}/WPILib_macOS-Arm64-#{version}.dmg"
  appcast 'https://github.com/wpilibsuite/allwpilib/releases.atom'
  name 'WPILib Suite'
  homepage 'https://wpilib.org/'

  depends_on cask: 'visual-studio-code'

  year = "#{version.split('.', -1)[0]}"
  install_dir = "#{ENV['HOME']}/wpilib/#{year}"

  artifact 'artifacts', target: install_dir

  preflight do
    system_command 'mkdir', args: ['-p', "#{staged_path}/artifacts"]
    system_command 'xattr', args: ['-d', 'com.apple.quarantine', "#{staged_path}/WPILib_MacArm-#{version}-artifacts.tar.gz"]
    system_command 'tar', args: ['-zxf', "#{staged_path}/WPILib_MacArm-#{version}-artifacts.tar.gz", '-C', "#{staged_path}/artifacts"]

    system_command '/usr/bin/python3', args: ["#{staged_path}/artifacts/tools/ToolsUpdater.py"]

    Dir.glob("#{staged_path}/artifacts/vsCodeExtensions/*.vsix") do |vsix_file|
      system_command "#{ENV['HOMEBREW_PREFIX']}/bin/code", args: ['--install-extension', vsix_file]
    end

    system_command 'rm', args: ["#{staged_path}/WPILib_MacArm-#{version}-artifacts.tar.gz"]
    system_command 'rm', args: ['-rf', "#{staged_path}/WPILibInstaller.app"]
  end

  uninstall_preflight do
    system_command "#{ENV['HOMEBREW_PREFIX']}/bin/code", args: ['--uninstall-extension', 'wpilibsuite.vscode-wpilib']
  end
end
