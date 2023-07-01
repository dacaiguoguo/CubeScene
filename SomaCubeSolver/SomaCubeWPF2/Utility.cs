using System;
using System.Windows.Media;
using System.Windows.Media.Media3D;
using System.Windows.Input;

namespace SomaCubeWPF2
{
	public static class Utility
	{
		public const double RadianToDegree = 180.0 / Math.PI;
		public const double DegreeToRadian = Math.PI / 180.0;

		public static int AddPoint(Point3DCollection points, Point3D point)
		{
			// Create the point
			points.Add(point);
			return points.Count - 1;
		}

		// Add a triangle to the indicated mesh; The points must be outwardly oriented
		public static void AddTriangle(MeshGeometry3D mesh, Point3D point1, Point3D point2, Point3D point3)
		{
			// Get the points' indices
			int index1 = AddPoint(mesh.Positions, point1);
			int index2 = AddPoint(mesh.Positions, point2);
			int index3 = AddPoint(mesh.Positions, point3);

			// Create the triangle
			mesh.TriangleIndices.Add(index1);
			mesh.TriangleIndices.Add(index2);
			mesh.TriangleIndices.Add(index3);
		}

		public static bool IsCameraKey(Key key)
		{
			return (key == Key.Up) || (key == Key.Down) || (key == Key.Left) || (key == Key.Right) || (key == Key.Add)
				|| (key == Key.OemPlus) || (key == Key.Subtract) || (key == Key.OemMinus);
		}

		/// <summary>
		/// Convert multi-dimensional array to jagged array
		/// </summary>
		/// <param name="array"></param>
		/// <param name="iLen"></param>
		/// <param name="jLen"></param>
		/// <param name="kLen"></param>
		/// <returns></returns>
		public static int[][][] Convert(int[,,] array, int iLen, int jLen, int kLen)
		{
			System.Diagnostics.Debug.Assert((array.GetLength(0) == iLen) && (array.GetLength(1) == jLen) && (array.GetLength(2) == kLen));
			int[][][] newArray = new int[iLen][][];
			for (int i = 0; i < iLen; i++)
			{
				newArray[i] = new int[jLen][];
				for (int j = 0; j < jLen; j++)
				{
					newArray[i][j] = new int[kLen];

					for (int k = 0; k < kLen; k++)
					{
						newArray[i][j][k] = array[i, j, k];
					}
				}
			}

			return newArray;
		}

		/// <summary>
		/// Convert multi-dimensional array to jagged array
		/// </summary>
		/// <param name="array"></param>
		/// <param name="iLen"></param>
		/// <param name="jLen"></param>
		/// <returns></returns>
		public static int[][] Convert(int[,] array, int iLen, int jLen)
		{
			System.Diagnostics.Debug.Assert((array.GetLength(0) == iLen) && (array.GetLength(1) == jLen));
			int[][] newArray = new int[iLen][];
			for (int i = 0; i < iLen; i++)
			{
				newArray[i] = new int[jLen];
				for (int j = 0; j < jLen; j++)
				{
					newArray[i][j] = array[i, j];
				}
			}

			return newArray;
		}
	}
}