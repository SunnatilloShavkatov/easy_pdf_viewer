#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint easy_pdf_viewer.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'easy_pdf_viewer'
  s.version          = '1.3.3'
  s.summary          = 'A flutter plugin for handling PDF files.'
  s.description      = <<-DESC
  Allows you to generate PNGs of specified pages from a provided PDF file source.
                         DESC
  s.homepage         = 'https://github.com/SunnatilloShavkatov/easy_pdf_viewer'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Sunnatillo Shavkatov' => 'sunnatilloshavkatov@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'easy_pdf_viewer/Sources/easy_pdf_viewer/**/*.{h,m,swift}'
  s.public_header_files = 'easy_pdf_viewer/Sources/easy_pdf_viewer/include/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.9'
end
