platform :ios, '8.4'
use_frameworks!

target "WS" do
	pod 'AFNetworking', '2.6.3'
	pod 'SVProgressHUD', '2.0.4'
	pod 'BButton'
	pod 'CrittercismSDK'
	pod 'kingpin'

	pod 'ECSlidingViewController'
	pod 'Lockbox'
	pod 'MBAutoGrowingTextView', '~> 0.1.0'

	pod 'PromiseKit-AFNetworking'
	pod 'PromiseKit'
	pod 'KVOController'
	pod 'DateTools'

	# pod 'RHManagedObject'
	# pod 'RHTools', :git => 'https://github.com/chriscdn/RHTools.git'

	pod 'RHManagedObject', :path => '../RHManagedObject/'
	pod 'RHTools', :path => '../RHTools/'
end

# http://stackoverflow.com/questions/38446097/xcode-8-beta-3-use-legacy-swift-issue
post_install do |installer|
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings['SWIFT_VERSION'] = '2.3'
		end
	end
end