using System;
using System.Collections;
using System.Windows.Media;
using System.Windows.Media.Media3D;
using SomaCubeLib;

namespace SomaCubeWPF2
{
	/// <summary>
	/// The solved Large Soma Cube
	/// </summary>
	public class LargeCube
	{
		#region doc
		//
		//                     Y
		//                     |
		//               ______|_______
		//              /|  8  |5   2  /|
		//             / |17  14  11  / |
		//            /__26__23__20__/  |
		//            |  |_ _ _ _ _ _|  ______ X
		//            |  26  23  20  |  /
		//            |  24  22  19  | /
		//            |  24  21  18  |/
		//            |____/_________|
		//                /
		//                Z
		#endregion
		public const int NumCubes = 27;
		public const int NumFaces = 6;
		private SmallCube[] smallCubes { get; set; }
		public BitArray BitArray { get; set; }
		private Model3DGroup ModelGroup { get; set; }
		private int[] cubeLocations = {
				// z = -1
				 +1, -1, -1 , +1,  0, -1 , +1, +1, -1 , // 0, 1, 2
				  0, -1, -1 ,  0,  0, -1 ,  0, +1, -1 , // 3, 4, 5
				 -1, -1, -1 , -1,  0, -1 , -1, +1, -1 , // 6, 7, 8

				// z = 0
				 +1, -1,  0 , +1,  0,  0 , +1, +1,  0 , //  9, 10, 11
				  0, -1,  0 ,  0,  0,  0 ,  0, +1,  0 , // 12, 13, 14
				 -1, -1,  0 , -1,  0,  0 , -1, +1,  0 , // 15, 16, 17

				// z = +1
				 +1, -1, +1 , +1,  0, +1 , +1, +1, +1 , // 18, 19, 20
				  0, -1, +1 ,  0,  0, +1 ,  0, +1, +1 , // 21, 22, 23
				 -1, -1, +1 , -1,  0, +1 , -1, +1, +1 , // 24, 25, 26
			};

		private static Vector3D[] labelVectors = {
						new Vector3D( 0.0, 0.0, -1.0),// -Z
						new Vector3D( 0.0, 0.0, -1.0),// -Z
						new Vector3D(+1.0, 0.0,  0.0),// +X
						new Vector3D( 0.0, 0.0, +1.0),// +Z
						new Vector3D(+1.0, 0.0,  0.0),// +X
						new Vector3D(-1.0, 0.0,  0.0) // -X
		};

		private static Vector3D[] upVectors = {
						new Vector3D( 0.0, +1.0,  0.0),// +Y
						new Vector3D(-1.0,  0.0,  0.0),// -X
						new Vector3D( 0.0, +1.0,  0.0),// +Y
						new Vector3D( 0.0, +1.0,  0.0),// +Y
						new Vector3D( 0.0,  0.0, +1.0),// +Z
						new Vector3D( 0.0, +1.0,  0.0) // +Y
		};
		
		private static Point3D[] centers = {
			new Point3D(+0.5 * SmallCube.CubeSize, +0.0 * SmallCube.CubeSize, +0.0 * SmallCube.CubeSize),
			new Point3D(+0.0 * SmallCube.CubeSize, +0.5 * SmallCube.CubeSize, +0.0 * SmallCube.CubeSize),
			new Point3D(+0.0 * SmallCube.CubeSize, +0.0 * SmallCube.CubeSize, +0.5 * SmallCube.CubeSize),
			new Point3D(-0.5 * SmallCube.CubeSize, +0.0 * SmallCube.CubeSize, +0.0 * SmallCube.CubeSize),
			new Point3D(+0.0 * SmallCube.CubeSize, -0.5 * SmallCube.CubeSize, +0.0 * SmallCube.CubeSize),
			new Point3D(+0.0 * SmallCube.CubeSize, +0.0 * SmallCube.CubeSize, -0.5 * SmallCube.CubeSize),
		};

		public LargeCube(Model3DGroup modelGroup, BitArray bitArray, Color[] colors)
		{
			if (bitArray == null)
			{
				this.BitArray = new BitArray(NumCubes);
				this.BitArray.SetAll(true);
			}
			else
			{
				this.BitArray = bitArray.DeepCopy();
			}
			this.ModelGroup = modelGroup;
			smallCubes = new SmallCube[NumCubes];

			for (int cubeNdx = 0; cubeNdx < NumCubes; cubeNdx++)
			{
				System.Windows.Media.Color color;

				if (this.BitArray[cubeNdx])
				{
					color = colors[cubeNdx];
				}
				else
				{
					color = Properties.Settings.Default.SmallCubeClearColor;
				}

				smallCubes[cubeNdx] = new SmallCube(this.ModelGroup, color);
			}
		}

		public void Draw(BitArray activeLayersBitArray)
		{ 
			int i = 0;
			
			for (int cubeNdx = 0; cubeNdx < NumCubes; cubeNdx++)
			{
				if (activeLayersBitArray[cubeNdx])
				{
					MatrixTransform3D matrixTransform3DCube = new MatrixTransform3D();
					Matrix3D translationMatrix = new Matrix3D();
					translationMatrix.OffsetX = SmallCube.CubeSize * cubeLocations[i];
					translationMatrix.OffsetY = SmallCube.CubeSize * cubeLocations[i + 1];
					translationMatrix.OffsetZ = SmallCube.CubeSize * cubeLocations[i + 2];
					matrixTransform3DCube.Matrix = translationMatrix;
					smallCubes[cubeNdx].Cube.DrawCube(matrixTransform3DCube);

					double height = SmallCube.CubeSize * 0.2;
					bool doubleSided = false;

					String text = String.Format("{0}", cubeNdx);

					int faceNdx = 0;
					Model3D[] label = new Model3D[NumFaces];
					for (int lblNdx = 0; lblNdx < NumFaces; lblNdx++)
					{
						System.Windows.Media.SolidColorBrush brush = System.Windows.Media.Brushes.DodgerBlue;
						brush = Properties.Settings.Default.SmallCubeLabelBrush;
						label[lblNdx] = TextLabel3D.CreateTextLabelModel3D(text, brush, doubleSided, height,
							centers[faceNdx], labelVectors[faceNdx], upVectors[faceNdx]);
						label[lblNdx].Transform = matrixTransform3DCube;
						this.ModelGroup.Children.Add(label[lblNdx]);
						faceNdx++;
					}
				}
				i += 3;
			}
		}
	}
}
