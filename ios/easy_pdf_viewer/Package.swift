// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "easy_pdf_viewer",
    platforms: [
        .iOS("13.0"),
    ],
    products: [
        .library(name: "easy-pdf-viewer", targets: ["easy_pdf_viewer"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
    ],
    targets: [
        .target(
            name: "easy_pdf_viewer",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
            ],
            path: "Sources/easy_pdf_viewer",
            exclude: [
                "EasyPdfViewerPlugin.m",
                "include",
            ]
        )
    ]
)
