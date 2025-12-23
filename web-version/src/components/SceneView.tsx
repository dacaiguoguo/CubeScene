import React from 'react'
import { useFrame, useThree } from '@react-three/fiber'
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
    new Color(`rgb(${showColor.join(',')})`),
    new Color('hotpink'),
    new Color('#178E20') // Green
  ], [showColor])

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
            mesh.setColorAt(i, new Color('hotpink').clone().multiplyScalar(1.5))
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
            mesh.setColorAt(i, new Color('hotpink').clone().multiplyScalar(1.5))
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
        color='#178E20' // 基础颜色 - 绿色
        emissive="#972e2eff" // 自发光颜色 - 暗红色
        emissiveIntensity={0} // 自发光强度 - 0表示关闭
        metalness={0.8} // 金属质感 - 0.8高金属度
        roughness={0.2} // 表面粗糙度 - 0.2较光滑
      />
    </instancedMesh>
  )
}
