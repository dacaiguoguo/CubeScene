import { Canvas } from '@react-three/fiber'
import { Box, OrbitControls } from '@react-three/drei'

export default function Demo() {
  return (
    <Canvas camera={{ position: [0, 0, 5] }}>
      <ambientLight intensity={1} />
      <directionalLight position={[10, 10, 5]} intensity={1} />
      <Box args={[1, 1, 1]}>
        <meshStandardMaterial color="hotpink" />
      </Box>
      <OrbitControls />
    </Canvas>
  )
}
