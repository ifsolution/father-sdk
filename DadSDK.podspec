Pod::Spec.new do |s|
  s.name = "DadSDK"
  s.version = "0.3.1"
  s.summary = "A short description of DadSDK."

  s.description = <<-DESC
TODO: Add long description of the pod here.
                  DESC

  s.homepage = "https://github.com/congncif/father-sdk"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "NGUYEN CHI CONG" => "congnc.if@gmail.com" }
  s.source = { :git => "git@github.com:ifsolution/father-sdk.git", :tag => s.version.to_s }
  s.social_media_url = "https://twitter.com/congncif"

  s.ios.deployment_target = "10.0"
  s.swift_versions = ["5.3", "5.4"]

  s.default_subspec = "Core"

  s.subspec "Core" do |co|
    co.source_files = "DadSDK/Core/*.swift"

    co.dependency "DadFoundation", "~> #{s.version.to_s.sub(/.*\\\K\\\.\\\w+/, ".0")}"
  end

  s.subspec "Auth" do |co|
    co.source_files = "DadSDK/Auth/*.swift"

    co.dependency "DadSDK/Core"
  end
end
