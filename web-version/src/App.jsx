import { Canvas } from '@react-three/fiber';
import SceneView from './components/SceneView';
import { useState, useEffect } from 'react';
import './App.css';
export default function App() {
    const [product, setProduct] = useState(sampleProduct);
    const [showType, setShowType] = useState('singleColor');
    const [showColor, setShowColor] = useState([]);
    const [isPlaying, setIsPlaying] = useState(false);
    // Auto play logic
    useEffect(() => {
        if (!isPlaying)
            return;
        const timer = setInterval(() => {
            setShowColor(prev => {
                const nextValue = prev.length + 1;
                return nextValue <= product.orderBlock.length
                    ? product.orderBlock.slice(0, nextValue)
                    : [];
            });
        }, 1000);
        return () => clearInterval(timer);
    }, [isPlaying, product.orderBlock]);
    const handleStepChange = (step) => {
        setShowColor(product.orderBlock.slice(0, step));
    };
    return (<div className="app-container">
      <div className="controls">
        <div className="mode-buttons">
          <button className={`mode-button ${showType === 'singleColor' ? 'active' : ''}`} onClick={() => setShowType('singleColor')}>
            Single Color
          </button>
          <button className={`mode-button ${showType === 'colorFul' ? 'active' : ''}`} onClick={() => setShowType('colorFul')}>
            Colorful
          </button>
          <button className={`mode-button ${showType === 'number' ? 'active' : ''}`} onClick={() => setShowType('number')}>
            Number
          </button>
        </div>
        
        {showType === 'colorFul' && (<div className="playback-controls">
            <button className={`play-button ${isPlaying ? 'pause' : 'play'}`} onClick={() => setIsPlaying(!isPlaying)}>
              {isPlaying ? 'Pause' : 'Auto Play'}
            </button>
            <div className="step-control">
              <input type="range" min="0" max={product.orderBlock.length} value={showColor.length} onChange={(e) => handleStepChange(Number(e.target.value))}/>
              <span> Step: {showColor.length}/{product.orderBlock.length}</span>
            </div>
          </div>)}
      </div>
      
      <div className="scene-container">
        <Canvas camera={{ position: [10, 10, 15], fov: 50 }}>
          <SceneView product={product} showType={showType} showColor={showColor}/>
        </Canvas>
      </div>
    </div>);
}
const sampleProduct = {
    name: 'Sample',
    matrix: [
        [[1, 2, 3], [4, 5, 6]],
        [[7, 8, 9], [10, 11, 12]]
    ],
    usedBlock: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    orderBlock: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    isTaskComplete: false,
    level: 1
};
