using System;
using System.Linq;
using System.Windows.Media;
using System.Windows.Media.Media3D;

namespace SomaCubeWPF2
{
	#region doc
	// cubes are used to determine if two cubes intersect (or collide) when translating or rotating a piece
	//
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
	#endregion
	public class Cube3D
	{
		private MeshGeometry3D Mesh { get; set; }
		public Point3D[] Points { get; set; }
		private Model3DGroup ModelGroup { get; set; }
		private GeometryModel3D CubeModel { get; set; }
		private Color Color { get; set; }
		public String Id { get; set; }

		public Cube3D(Point3D[] points, Model3DGroup modelGroup, Color color, String id = "")
		{
			this.Points = points;
			this.ModelGroup = modelGroup;
			this.Color = color;
			this.Id = id;

			this.Mesh = new MeshGeometry3D();
			Utility.AddTriangle(Mesh, Points[0], Points[2], Points[1]);
			Utility.AddTriangle(Mesh, Points[3], Points[1], Points[2]);

			Utility.AddTriangle(Mesh, Points[2], Points[4], Points[3]);
			Utility.AddTriangle(Mesh, Points[5], Points[3], Points[4]);

			Utility.AddTriangle(Mesh, Points[4], Points[6], Points[5]);
			Utility.AddTriangle(Mesh, Points[7], Points[5], Points[6]);

			Utility.AddTriangle(Mesh, Points[6], Points[0], Points[7]);
			Utility.AddTriangle(Mesh, Points[1], Points[7], Points[0]);

			Utility.AddTriangle(Mesh, Points[1], Points[3], Points[7]);
			Utility.AddTriangle(Mesh, Points[5], Points[7], Points[3]);

			Utility.AddTriangle(Mesh, Points[6], Points[4], Points[0]);
			Utility.AddTriangle(Mesh, Points[2], Points[0], Points[4]);
		}

		public void DrawCube(MatrixTransform3D matrixTransform3D)
		{
			Brush cubeBrush;
			cubeBrush = new SolidColorBrush(this.Color);

			cubeBrush.Opacity = 0.9;

			DiffuseMaterial material = new DiffuseMaterial(cubeBrush);
			CubeModel = new GeometryModel3D(Mesh, material);
			CubeModel.Transform = matrixTransform3D;

			ModelGroup.Children.Add(CubeModel);
		}

		/// <summary>
		/// Returns true if two Cube3D objects intersect (not used in Soma Cube Part 2 - see Soma Cube Part 1)
		/// </summary>
		/// <param name="c1"></param>
		/// <param name="c2"></param>
		/// <returns></returns>
		public static bool CubesIntersect(Cube3D c1, Cube3D c2)
		{
			var x_query = c2.Points.Select(p => p.X);
			var y_query = c2.Points.Select(p => p.Y);
			var z_query = c2.Points.Select(p => p.Z);

			double xmin = x_query.Min();
			double xmax = x_query.Max();
			double ymin = y_query.Min();
			double ymax = y_query.Max();
			double zmin = z_query.Min();
			double zmax = z_query.Max();

			foreach (Point3D pt1 in c1.Points)
			{
				if ((pt1.X >= xmin) && (pt1.X <= xmax) &&
					(pt1.Y >= ymin) && (pt1.Y <= ymax) &&
					(pt1.Z >= zmin) && (pt1.Z <= zmax))
				{
					return true;
				}
			}
			return false;
		}
	}
}
