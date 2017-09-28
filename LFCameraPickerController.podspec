Pod::Spec.new do |s|
s.name         = 'LFCameraPickerController'
s.version      = '1.0.4.1'
s.summary      = 'A clone of UIImagePickerController(UIImagePickerControllerSourceTypeCamera), support take photo and record video'
s.homepage     = 'https://github.com/lincf0912/LFCameraPickerController'
s.license      = 'MIT'
s.author       = { 'lincf0912' => 'dayflyking@163.com' }
s.platform     = :ios
s.ios.deployment_target = '7.0'
s.source       = { :git => 'https://github.com/lincf0912/LFCameraPickerController.git', :tag => s.version, :submodules => true }
s.requires_arc = true
s.resources    = 'LFCameraPickerControllerDEMO/LFCameraPickerControllerDEMO/class/*.bundle'
s.source_files = 'LFCameraPickerControllerDEMO/LFCameraPickerControllerDEMO/class/*.{h,m}','LFCameraPickerControllerDEMO/LFCameraPickerControllerDEMO/class/**/*.{h,m}'
s.public_header_files = 'LFCameraPickerControllerDEMO/LFCameraPickerControllerDEMO/class/*.h'

# LFRecordButton模块
s.subspec 'LFRecordButton' do |ss|
ss.source_files = 'LFCameraPickerControllerDEMO/LFCameraPickerControllerDEMO/vendors/LFRecordButton/*.{h,m}'
ss.public_header_files = 'LFCameraPickerControllerDEMO/LFCameraPickerControllerDEMO/vendors/LFRecordButton/LFRecordButton.h'
end

# 依赖库
s.dependency 'SCRecorder'
s.dependency 'LFMediaEditingController'

end
