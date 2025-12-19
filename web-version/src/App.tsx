import { Canvas } from '@react-three/fiber'
import SceneView from './components/SceneView'
import { Product } from './lib/types'
import { useEffect, useMemo, useState } from 'react'
import './App.css'
import somaSampleText from './data/soma-c3a-sample.txt?raw'
import { parseSomaTextToProducts } from './lib/soma'

export default function App() {
  const products = useMemo(() => parseSomaTextToProducts(somaSampleText), [])
  const [product, setProduct] = useState<Product>(() => products[0] ?? sampleProduct)
  const [showType, setShowType] = useState<'singleColor' | 'colorFul' | 'number'>('colorFul')
  const [showColor, setShowColor] = useState<number[]>(() => product.orderBlock)
  const [isPlaying, setIsPlaying] = useState(false)

  useEffect(() => {
    if (products.length > 0) setProduct(products[0])
  }, [products])

  useEffect(() => {
    setShowColor(product.orderBlock)
  }, [product])

  // Auto play logic
  useEffect(() => {
    if (!isPlaying) return
    
    const timer = setInterval(() => {
      setShowColor(prev => {
        const nextValue = prev.length + 1
        return nextValue <= product.orderBlock.length 
          ? product.orderBlock.slice(0, nextValue)
          : []
      })
    }, 1000)
    
    return () => clearInterval(timer)
  }, [isPlaying, product.orderBlock])

  const handleStepChange = (step: number) => {
    setShowColor(product.orderBlock.slice(0, step))
  }

  return (
    <div className="app-container">
      <div className="controls">
        <div className="mode-buttons">
          <button 
            className={`mode-button ${showType === 'singleColor' ? 'active' : ''}`}
            onClick={() => setShowType('singleColor')}
          >
            Single Color
          </button>
          <button 
            className={`mode-button ${showType === 'colorFul' ? 'active' : ''}`}
            onClick={() => setShowType('colorFul')}
          >
            Colorful
          </button>
          <button 
            className={`mode-button ${showType === 'number' ? 'active' : ''}`}
            onClick={() => setShowType('number')}
          >
            Number
          </button>
        </div>
        
        {showType === 'colorFul' && (
          <div className="playback-controls">
            <button 
              className={`play-button ${isPlaying ? 'pause' : 'play'}`}
              onClick={() => setIsPlaying(!isPlaying)}
            >
              {isPlaying ? 'Pause' : 'Auto Play'}
            </button>
            <div className="step-control">
              <input 
                type="range" 
                min="0" 
                max={product.orderBlock.length}
                value={showColor.length}
                onChange={(e) => handleStepChange(Number(e.target.value))}
              />
              <span> Step: {showColor.length}/{product.orderBlock.length}</span>
            </div>
          </div>
        )}
      </div>
      
      <div className="scene-container">
        <Canvas camera={{ position: [10, 10, 15], fov: 50 }} style={{ background: '#0b0f19' }}>
          <ambientLight intensity={0.8} />
          <directionalLight position={[10, 12, 8]} intensity={1.2} />
          <SceneView product={product} showType={showType} showColor={showColor} />
        </Canvas>
      </div>
    </div>
  )
}

const sampleProduct: Product = {
  name: 'Sample',
  matrix: [
    [[1,2,3],[4,5,6]], 
    [[7,8,9],[10,11,12]]
  ],
  usedBlock: [1,2,3,4,5,6,7,8,9,10,11,12],
  orderBlock: [1,2,3,4,5,6,7,8,9,10,11,12],
  isTaskComplete: false,
  level: 1
}
