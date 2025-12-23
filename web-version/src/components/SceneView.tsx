import React from 'react'
import { useFrame, useThree } from '@react-three/fiber'
import { InstancedMesh, Matrix4, Color, BoxGeometry, EdgesGeometry, LineSegments, LineBasicMaterial } from 'three'
import { Product } from '../lib/types'

interface SceneViewProps {
  product: Product
  showType: 'singleColor' | 'colorFul' | 'number'
  showColor: number[]
}

export default function SceneView({ product, showType, showColor }: SceneViewProps) {
  const instancedMeshRef = React.useRef<InstancedMesh>(null)
  const colorArray = React.useMemo(() => [
    new Color('#FF0000'), // 红色
    new Color('#00FF00'), // 绿色
    new Color('#0000FF'), // 蓝色
    new Color('#FFFF00'), // 黄色
    new Color('#FF00FF'), // 品红
    new Color('#00FFFF'), // 青色
    new Color('#FFA500')  // 橙色
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
    const capacity = mesh.instanceMatrix?.count ?? 0
    const drawCount = Math.min(instanceCount, capacity)
    mesh.count = drawCount

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
          if (value >= 0 && i < drawCount) {
            matrix4.makeTranslation(x - centerX, -(y - centerY), z - centerZ)
            mesh.setMatrixAt(i, matrix4)

            // Set initial color
            mesh.setColorAt(i, colorArray[value % 7].clone().multiplyScalar(1.5))
            i++
          }
        })
      })
    })

    mesh.instanceMatrix.needsUpdate = true
    if (mesh.instanceColor) {
      mesh.instanceColor.needsUpdate = true
    }
  }, [product.matrix, instanceCount, showType])

  const scene = useThree(state => state.scene)
  React.useEffect(() => {
    console.log('[DEBUG] Three.js Scene Objects:', scene.children)
    scene.traverse(obj => {
      console.log(`[DEBUG] ${obj.type}:`,
        obj.name || 'unnamed',
        'visible:', obj.visible,
        'material:', 'material' in obj ? (obj.material as any)?.constructor?.name || 'UnknownMaterial' : 'N/A'
      )
    })
  }, [scene])

  // Update materials based on showType
  useFrame(() => {
    if (!instancedMeshRef.current || showType !== 'colorFul') return

    const mesh = instancedMeshRef.current
    const matrix = product.matrix
    const capacity = mesh.instanceMatrix?.count ?? 0
    const drawCount = Math.min(mesh.count ?? 0, capacity)
    let i = 0

    matrix.forEach((layer, z) => {
      layer.forEach((row, y) => {
        row.forEach((value, x) => {
          if (value >= 0 && i < drawCount) {
            mesh.setColorAt(i, colorArray[value % 7].clone().multiplyScalar(1.5))
            i++
          }
        })
      })
    })

    if (mesh.instanceColor) mesh.instanceColor.needsUpdate = true
  })

  return (
    <group>
      <instancedMesh key={instanceCount} ref={instancedMeshRef} args={[undefined, undefined, instanceCount]}>
        <boxGeometry args={[0.95, 0.95, 0.95]} /> {/* 稍微缩小以显示边缘效果 */}
        <meshStandardMaterial 
          emissive="#972e2eff"
          emissiveIntensity={0}
          metalness={0.8}
          roughness={0.2}
        />
      </instancedMesh>
      <lineSegments>
        <edgesGeometry args={[new BoxGeometry(1, 1, 1)]} />
        <lineBasicMaterial color={0xffffff} linewidth={2} />
      </lineSegments>
    </group>
  )
}
