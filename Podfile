source 'https://github.com/CocoaPods/Specs.git'

def import_pods
    pod 'SwiftyJSON', '~> 3.1.1'
    pod 'SDWebImage', '~> 3.8.2'
end

target 'PodcastApp_SwiftMVC' do
    platform :ios, '9.0'
    project 'PodcastApp_SwiftMVC'

    use_frameworks!

    import_pods

    target 'PodcastApp_SwiftMVCTests' do
        inherit! :search_paths

        pod 'OCMock', '~> 3.3.1'
    end
end
