Pod::Spec.new do |s|
s.name         = 'LFCameraPickerController'
s.version      = '1.1.0'
s.summary      = 'A clone of UIImagePickerController(UIImagePickerControllerSourceTypeCamera), support take photo and record video'
s.homepage     = 'https://github.com/lincf0912/LFCameraPickerController'
s.license      = 'MIT'
s.author       = { 'lincf0912' => 'dayflyking@163.com' }
s.platform     = :ios
s.ios.deployment_target = '7.0'
s.source       = { :git => 'https://github.com/lincf0912/LFCameraPickerController.git', :tag => s.version, :submodules => true }
s.requires_arc = true
s.default_subspec = 'Core'

s.subspec 'Core' do |ss|
ss.resources    = 'LFCameraPickerControllerDEMO/LFCameraPickerControllerDEMO/class/*.bundle'
ss.source_files = 'LFCameraPickerControllerDEMO/LFCameraPickerControllerDEMO/class/*.{h,m}','LFCameraPickerControllerDEMO/LFCameraPickerControllerDEMO/class/**/*.{h,m}'
ss.public_header_files = 'LFCameraPickerControllerDEMO/LFCameraPickerControllerDEMO/class/*.h'
ss.dependency 'LFCameraPickerController/LFRecordButton'
s.dependency 'SCRecorder'
end

# LFRecordButton模块
s.subspec 'LFRecordButton' do |ss|
ss.source_files = 'LFCameraPickerControllerDEMO/LFCameraPickerControllerDEMO/vendors/LFRecordButton/*.{h,m}'
ss.public_header_files = 'LFCameraPickerControllerDEMO/LFCameraPickerControllerDEMO/vendors/LFRecordButton/LFRecordButton.h'
end

# LFMediaEdit模块
s.subspec 'LFMediaEdit' do |ss|
ss.xcconfig = {
'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) LF_MEDIAEDIT=1'
}
ss.dependency 'LFCameraPickerController/Core'
ss.dependency 'LFMediaEditingController'
end


end
