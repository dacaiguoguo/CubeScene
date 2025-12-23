import { Canvas } from '@react-three/fiber'
import { OrbitControls } from '@react-three/drei'
import SceneView from './components/SceneView'
import { Product } from './lib/types'
import { useEffect, useMemo, useState } from 'react'
import './App.css'
import somaSampleText from './data/soma-c3a-sample.txt?raw'
import { parseSomaTextToProducts } from './lib/soma'

export default function App() {
  const products = useMemo(() => parseSomaTextToProducts(somaSampleText), [])
  const [product] = useState<Product>(() => products[0])
  
  return (
    <div className="app-container">
      {/* 3D画布容器 - 设置相机位置和背景色 */}
      <Canvas camera={{ position: [10, 10, 15], fov: 50 }} style={{ background: '#776f6fff' }}>
        {/* 环境光 - 柔和基础照明 */}
        <ambientLight intensity={1.5} color="#ffffff" />
        {/* 方向光 - 主光源，45度角照射 */}
        <directionalLight 
          position={[15, 20, 10]} 
          intensity={2.5} 
          castShadow 
          color="#ffffff"
          shadow-mapSize-width={2048}
          shadow-mapSize-height={2048}
        />
        {/* 轨道控制器 - 允许鼠标交互旋转/缩放场景 */}
        <OrbitControls enableZoom={true} enablePan={true} />
        {/* 3D场景视图组件 */}
        <SceneView product={product} showType="colorFul" showColor={product.orderBlock} />
      </Canvas>
    </div>
  )
}
