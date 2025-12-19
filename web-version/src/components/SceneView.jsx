import React from 'react';
import { useFrame } from '@react-three/fiber';
import { Matrix4, Color } from 'three';
export default function SceneView({ product, showType, showColor }) {
    const instancedMeshRef = React.useRef(null);
    const colorArray = React.useMemo(() => [
        new Color(0x5B5B5B),
        new Color(0xC25C1D),
        new Color(0x2788E7),
        new Color(0xFA2E34),
        new Color(0xFB5BC2),
        new Color(0xFCC633),
        new Color(0x178E20),
        new Color(0x000000) // 7: black
    ], []);
    // Initialize instances
    React.useEffect(() => {
        if (!instancedMeshRef.current)
            return;
        const mesh = instancedMeshRef.current;
        const matrix = product.matrix;
        let instanceCount = 0;
        // First pass to count valid instances
        matrix.forEach((layer, z) => {
            layer.forEach((row, y) => {
                row.forEach((value, x) => {
                    if (value >= 0)
                        instanceCount++;
                });
            });
        });
        // Set instance count
        mesh.count = instanceCount;
        // Second pass to set positions
        let i = 0;
        const matrix4 = new Matrix4();
        matrix.forEach((layer, z) => {
            layer.forEach((row, y) => {
                row.forEach((value, x) => {
                    if (value >= 0) {
                        matrix4.makeTranslation(x, -y + matrix.length / 2, z);
                        mesh.setMatrixAt(i, matrix4);
                        // Set initial color
                        const colorIndex = value % colorArray.length;
                        mesh.setColorAt(i, colorArray[colorIndex]);
                        i++;
                    }
                });
            });
        });
        mesh.instanceMatrix.needsUpdate = true;
        if (mesh.instanceColor)
            mesh.instanceColor.needsUpdate = true;
    }, [product.matrix, colorArray]);
    // Update materials based on showType
    useFrame(() => {
        if (!instancedMeshRef.current || showType !== 'colorFul')
            return;
        const mesh = instancedMeshRef.current;
        const matrix = product.matrix;
        let i = 0;
        matrix.forEach((layer, z) => {
            layer.forEach((row, y) => {
                row.forEach((value, x) => {
                    if (value >= 0) {
                        const visible = showColor.includes(value);
                        const colorIndex = value % colorArray.length;
                        const color = visible ? colorArray[colorIndex] : new Color(0x000000);
                        mesh.setColorAt(i, color);
                        i++;
                    }
                });
            });
        });
        if (mesh.instanceColor)
            mesh.instanceColor.needsUpdate = true;
    });
    return (<instancedMesh ref={instancedMeshRef} args={[undefined, undefined, 0]}>
      <boxGeometry args={[1, 1, 1]}/>
      <meshStandardMaterial color="white" wireframe={showType === 'singleColor'} transparent={showType === 'colorFul'} opacity={showType === 'colorFul' ? 0.8 : 1.0}/>
    </instancedMesh>);
}
