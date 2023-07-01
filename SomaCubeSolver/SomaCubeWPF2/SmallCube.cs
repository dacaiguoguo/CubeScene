using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Media.Media3D;

namespace SomaCubeWPF2
{
	/// <summary>
	/// One of the 27 small cubes that comprise the Large Soma Cube
	/// </summary>
	public class SmallCube
	{
		public const float CubeSize = 2.0f;
		#region cubes
		private const double Tiny = 0.03;
		
		//                     Y
		//                     |
		//              7______|________5
		//              /|     |       /|
		//             / |            / |
		//            /__|___________/  |
		//           1|  |_ _ _ _ _ _|3 ______ X
		//            |   6          |  /4
		//            |      /       | /
		//            | /   /        |/
		//            |____/_________|
		//           0    /           2
		//                Z
		private static readonly Point3D[] CubeVertices =
		{
				new Point3D(-1*CubeSize/2 + Tiny, -1*CubeSize/2 + Tiny, +1*CubeSize/2 - Tiny), // 0
				new Point3D(-1*CubeSize/2 + Tiny, +1*CubeSize/2 - Tiny, +1*CubeSize/2 - Tiny), // 1
				new Point3D(+1*CubeSize/2 - Tiny, -1*CubeSize/2 + Tiny, +1*CubeSize/2 - Tiny), // 2
				new Point3D(+1*CubeSize/2 - Tiny, +1*CubeSize/2 - Tiny, +1*CubeSize/2 - Tiny), // 3
				new Point3D(+1*CubeSize/2 - Tiny, -1*CubeSize/2 + Tiny, -1*CubeSize/2 + Tiny), // 4
				new Point3D(+1*CubeSize/2 - Tiny, +1*CubeSize/2 - Tiny, -1*CubeSize/2 + Tiny), // 5
				new Point3D(-1*CubeSize/2 + Tiny, -1*CubeSize/2 + Tiny, -1*CubeSize/2 + Tiny), // 6
				new Point3D(-1*CubeSize/2 + Tiny, +1*CubeSize/2 - Tiny, -1*CubeSize/2 + Tiny)  // 7
		};
		#endregion

		public Cube3D Cube { get; set; }
		private Model3DGroup ModelGroup { get; set; }

		public SmallCube(Model3DGroup modelGroup, System.Windows.Media.Color color)
		{
			this.ModelGroup = modelGroup;
			this.Cube = new Cube3D(CubeVertices, ModelGroup, color, "id not currently used");
		}
	}
}
