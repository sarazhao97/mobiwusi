import Metal
import MetalKit

class MOAudioWaveMetalView: MTKView {

	var commandQueue: MTLCommandQueue!
	var pipelineState: MTLRenderPipelineState!
	
	var waveformData: [Float] = [] // [-1, 1] 范围采样值
	
	// 可视区域控制
	var visibleOffsetX: CGFloat = 0
	var visibleWidth: CGFloat = 0
	var totalWaveformWidth: CGFloat = 0

	override init(frame frameRect: CGRect, device: MTLDevice?) {
		let device = device ?? MTLCreateSystemDefaultDevice()
		super.init(frame: frameRect, device: device)

		self.device = device
		self.commandQueue = device?.makeCommandQueue()
		self.enableSetNeedsDisplay = true
		self.isPaused = true
		self.framebufferOnly = false
		self.delegate = self
		setupPipeline()
	}

	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupPipeline() {
		guard let device = device,
			  let library = device.makeDefaultLibrary(),
			  let vertexFunction = library.makeFunction(name: "vertex_main"),
			  let fragmentFunction = library.makeFunction(name: "fragment_main")
		else { return }

		let descriptor = MTLRenderPipelineDescriptor()
		descriptor.vertexFunction = vertexFunction
		descriptor.fragmentFunction = fragmentFunction
		descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

		do {
			pipelineState = try device.makeRenderPipelineState(descriptor: descriptor)
		} catch {
			print("Failed to create pipeline state: \(error)")
		}
	}
}

extension MOAudioWaveMetalView: MTKViewDelegate {

	func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
		visibleWidth = size.width
	}

	func draw(in view: MTKView) {
		guard let drawable = currentDrawable,
			  let descriptor = currentRenderPassDescriptor,
			  waveformData.count > 1,
			  let commandBuffer = commandQueue.makeCommandBuffer(),
			  let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
		else { return }

		encoder.setRenderPipelineState(pipelineState)

		// 根据可见区域计算要画的数据范围
		let totalSamples = waveformData.count
		let startX = Int((visibleOffsetX / totalWaveformWidth) * CGFloat(totalSamples))
		let count = Int((visibleWidth / totalWaveformWidth) * CGFloat(totalSamples))

		guard startX < totalSamples else { return }

		let endX = min(startX + count, totalSamples)
		let visibleData = waveformData[startX..<endX]

		// 构建顶点数据：每个点包含 position(x, y, 0, 1)，color(r, g, b, a)
		var vertexArray: [Float] = []
		let vertexCount = visibleData.count

		for (i, sample) in visibleData.enumerated() {
			let ndcX = Float(i) / Float(max(1, vertexCount - 1)) * 2 - 1  // [-1, 1]
			let ndcY = sample
			vertexArray.append(contentsOf: [ndcX, ndcY, 0, 1])        // position
			vertexArray.append(contentsOf: [0, 1, 0, 1])              // green
		}

		if vertexArray.isEmpty { return }

		let vertexBuffer = device!.makeBuffer(bytes: vertexArray,
											  length: vertexArray.count * MemoryLayout<Float>.size,
											  options: [])

		encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
		encoder.drawPrimitives(type: .lineStrip,
							   vertexStart: 0,
							   vertexCount: vertexArray.count / 8)
		encoder.endEncoding()

		commandBuffer.present(drawable)
		commandBuffer.commit()
	}
}

