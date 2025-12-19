import React from 'react'
import { useFrame } from '@react-three/fiber'
import { InstancedMesh, Matrix4, Color } from 'three'
import { Product } from '../lib/types'

interface SceneViewProps {
  product: Product
  showType: 'singleColor' | 'colorFul' | 'number'
  showColor: number[]
}

export default function SceneView({ product, showType, showColor }: SceneViewProps) {
  const instancedMeshRef = React.useRef<InstancedMesh>(null)
  const colorArray = React.useMemo(() => [
    new Color(0x5B5B5B), // 0: gray
    new Color(0xC25C1D), // 1: orange
    new Color(0x2788E7), // 2: blue
    new Color(0xFA2E34), // 3: red
    new Color(0xFB5BC2), // 4: pink
    new Color(0xFCC633), // 5: yellow
    new Color(0x178E20), // 6: green
    new Color(0x000000)  // 7: black
  ], [])

  const instanceCount = React.useMemo(() => {
    let count = 0
    product.matrix.forEach((layer) => {
      layer.forEach((row) => {
        row.forEach((value) => {
          if (value >= 0) count++
        })
      })
    })
    return count
  }, [product.matrix])
  
  // Initialize instances
  React.useEffect(() => {
    if (!instancedMeshRef.current) return
    
    const mesh = instancedMeshRef.current
    const matrix = product.matrix
    
    // Set visible count (buffer allocation is handled by the constructor count)
    mesh.count = instanceCount
    
    // Compute bounding box for centering
    let minX = Infinity
    let minY = Infinity
    let minZ = Infinity
    let maxX = -Infinity
    let maxY = -Infinity
    let maxZ = -Infinity

    matrix.forEach((layer, z) => {
      layer.forEach((row, y) => {
        row.forEach((value, x) => {
          if (value >= 0) {
            minX = Math.min(minX, x)
            minY = Math.min(minY, y)
            minZ = Math.min(minZ, z)
            maxX = Math.max(maxX, x)
            maxY = Math.max(maxY, y)
            maxZ = Math.max(maxZ, z)
          }
        })
      })
    })

    const centerX = (minX + maxX) / 2
    const centerY = (minY + maxY) / 2
    const centerZ = (minZ + maxZ) / 2

    // Second pass to set positions
    let i = 0
    const matrix4 = new Matrix4()
    matrix.forEach((layer, z) => {
      layer.forEach((row, y) => {
        row.forEach((value, x) => {
          if (value >= 0) {
            matrix4.makeTranslation(x - centerX, -(y - centerY), z - centerZ)
            mesh.setMatrixAt(i, matrix4)
            
            // Set initial color
            const colorIndex = value % colorArray.length
            mesh.setColorAt(i, colorArray[colorIndex])
            i++
          }
        })
      })
    })
    
    mesh.instanceMatrix.needsUpdate = true
    if (mesh.instanceColor) mesh.instanceColor.needsUpdate = true
  }, [product.matrix, colorArray, instanceCount])
  
  // Update materials based on showType
  useFrame(() => {
    if (!instancedMeshRef.current || showType !== 'colorFul') return
    
    const mesh = instancedMeshRef.current
    const matrix = product.matrix
    let i = 0
    
    matrix.forEach((layer, z) => {
      layer.forEach((row, y) => {
        row.forEach((value, x) => {
          if (value >= 0) {
            const visible = showColor.includes(value)
            const colorIndex = value % colorArray.length
            const color = visible ? colorArray[colorIndex] : new Color(0x000000)
            
            mesh.setColorAt(i, color)
            i++
          }
        })
      })
    })
    
    if (mesh.instanceColor) mesh.instanceColor.needsUpdate = true
  })
  
  return (
    <instancedMesh key={instanceCount} ref={instancedMeshRef} args={[undefined, undefined, instanceCount]}>
      <boxGeometry args={[1, 1, 1]} />
      <meshStandardMaterial 
        color="white" 
        vertexColors
        wireframe={showType === 'singleColor'}
        transparent={showType === 'colorFul'}
        opacity={showType === 'colorFul' ? 0.8 : 1.0}
      />
    </instancedMesh>
  )
}
