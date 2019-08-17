// MIT license. Copyright (c) 2019 TriangleDraw. All rights reserved.
import XCTest
@testable import TriangleDrawLibrary

class SVGExporter {
	let canvas: E2Canvas
	var rotated: Bool = false
	var appVersion: String = "APP_VERSION"

	init(canvas: E2Canvas) {
		assert(canvas.size.width == AppConstant.CanvasFileFormat.width, "width")
		assert(canvas.size.height == AppConstant.CanvasFileFormat.height, "height")
		self.canvas = canvas
	}

	func generateString() -> String {
		var pointsInsideMask = [E2CanvasPoint]()
		let mask: E2Canvas = E2Canvas.bigCanvasMask()
		for y in 0..<Int(canvas.height) {
			for x in 0..<Int(canvas.width) {
				let point = E2CanvasPoint(x: x, y: y)
				if mask.getPixel(point) > 0 {
					pointsInsideMask.append(point)
				}
			}
		}

		var minX: Int = pointsInsideMask.first?.x ?? 0
		for point: E2CanvasPoint in pointsInsideMask {
			if minX > point.x {
				minX = point.x
			}
		}
		var minY: Int = pointsInsideMask.first?.y ?? 0
		for point: E2CanvasPoint in pointsInsideMask {
			if minY > point.y {
				minY = point.y
			}
		}

		var blackSegments = [String]()
		var whiteSegments = [String]()
		for point: E2CanvasPoint in pointsInsideMask {
			let segment: String
			switch point.orientation {
			case .upward:
				let x: Int = point.x - minX + 1
				let y: Int = point.y - minY
				segment = "M\(x) \(y)l-1 1h2z"
			case .downward:
				let x: Int = point.x - minX
				let y: Int = point.y - minY
				segment = "M\(x) \(y)h2l-1 1z"
			}
			if canvas.getPixel(point) > 0 {
				whiteSegments.append(segment)
			} else {
				blackSegments.append(segment)
			}
		}

		var result: String = """
		<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 720 720">
		<!-- This SVG file was generated by TriangleDraw APPVERSION -->
		<svg preserveAspectRatio="xMidYMid meet" viewBox="-88 -44 176 88" x="10" y="10" width="700" height="700">
		<g transform="rotate(ROTATION_DEGREES) scale(2) scale(0.5 0.866025) translate(-88 -44)">
		<path fill="black" d="BLACK_PATH"/>
		<path fill="white" d="WHITE_PATH"/>
		</g>
		</svg>
		</svg>
		"""
		let rotation = rotated ? "90" : "0"
		result = result.replacingOccurrences(of: "ROTATION_DEGREES", with: rotation)
		result = result.replacingOccurrences(of: "BLACK_PATH", with: blackSegments.joined())
		result = result.replacingOccurrences(of: "WHITE_PATH", with: whiteSegments.joined())
		result = result.replacingOccurrences(of: "APPVERSION", with: appVersion)
		return result
	}

	func generateData() -> Data {
		let svgString: String = generateString()
		let result: Data = svgString.data(using: .utf8, allowLossyConversion: true) ?? Data()
		return result
	}
}

class ExportToSVGTests: XCTestCase {

    func testExample() {
//		let canvas: E2Canvas = loadCanvas("test_subdivide2_in.pbm")
//		let canvas: E2Canvas = loadCanvas("test_rotate_logo_none.txt")
//		let canvas: E2Canvas = loadCanvas("test_boundingbox0.txt")
//		let canvas: E2Canvas = loadCanvas("test_boundingbox3.txt")
//		let canvas: E2Canvas = loadCanvas("test_exportsvg_corners.pbm")
		let canvas: E2Canvas = loadCanvas("test_exportsvg_cube.pbm")

		let exporter = SVGExporter(canvas: canvas)
		exporter.appVersion = "2019.2.1"
		exporter.rotated = true
		let data = exporter.generateData()
		let url: URL = URL(fileURLWithPath: "/Users/neoneye/Desktop/result.svg").absoluteURL
		try! data.write(to: url)
    }

}
