using System.Windows.Media;
using System.Windows.Media.Media3D;

namespace SomaCubeWPF2
{
	public class Axes
	{
		public const int NumModels = 6;
		private double Radius { get; set; }
		private double Length { get; set; }
		private double TextHeight { get; set; }
		private double Opacity { get; set; }

		/// <summary>
		/// creates XYZ axes consisting of 3 axes and 3 labels
		/// </summary>
		/// <param name="radius"></param>
		/// <param name="length"></param>
		/// <param name="textHeight"></param>
		/// <param name="opacity"></param>
		/// <returns></returns>
		public Axes(double radius, double length, double textHeight, double opacity)
		{
			this.Radius = radius;
			this.Length = length;
			this.TextHeight = textHeight;
			this.Opacity = opacity;
		}

		/// <summary>
		/// Draws the XYZ axes
		/// </summary>
		/// <returns></returns>
		public Model3D[] DrawAxes()
		{
			Model3D[] models = new Model3D[NumModels];

			// Make a cylinder along the X axis
			MeshGeometry3D xAxis = new MeshGeometry3D();
			Cylinder.AddSmoothCylinder(xAxis, new Point3D(0.0, 0.0, 0.0), new Vector3D(Length, 0.0, 0.0), Radius, 8);
			Brush brushXaxis = new SolidColorBrush(Colors.Red);
			brushXaxis.Opacity = Opacity;
			DiffuseMaterial materialXaxis = new DiffuseMaterial(brushXaxis);
			GeometryModel3D modelXaxis = new GeometryModel3D(xAxis, materialXaxis);
			models[0] = modelXaxis;

			// Make a cylinder along the Y axis
			MeshGeometry3D yAxis = new MeshGeometry3D();
			Cylinder.AddSmoothCylinder(yAxis, new Point3D(0.0, 0.0, 0.0), new Vector3D(0.0, Length, 0.0), Radius, 8);
			Brush brushYaxis = new SolidColorBrush(Colors.LightGreen);
			brushYaxis.Opacity = Opacity;
			DiffuseMaterial materialYaxis = new DiffuseMaterial(brushYaxis);
			GeometryModel3D modelYaxis = new GeometryModel3D(yAxis, materialYaxis);
			models[1] = modelYaxis;

			// Make a cylinder along the Z axis
			MeshGeometry3D zAxis = new MeshGeometry3D();
			Cylinder.AddSmoothCylinder(zAxis, new Point3D(0.0, 0.0, 0.0), new Vector3D(0.0, 0.0, Length), Radius, 8);
			Brush brushZaxis = new SolidColorBrush(Colors.LightBlue);
			brushZaxis.Opacity = Opacity;
			DiffuseMaterial materialZaxis = new DiffuseMaterial(brushZaxis);
			GeometryModel3D modelZaxis = new GeometryModel3D(zAxis, materialZaxis);
			models[2] = modelZaxis;

			Model3D xlabel = TextLabel3D.CreateTextLabelModel3D("X", Brushes.Pink, true, TextHeight, new Point3D(Length + 0.3, 0.0, 0.0), new Vector3D(1.0, 0.0, 0.0), new Vector3D(0.0, 1.0, 0.0));
			models[3] = xlabel;

			Model3D ylabel = TextLabel3D.CreateTextLabelModel3D("Y", Brushes.LightGreen, true, TextHeight, new Point3D(0.0, Length + 0.3, 0.0), new Vector3D(1.0, 0.0, 0.0), new Vector3D(0.0, 1.0, 0.0));
			models[4] = ylabel;

			Model3D zlabel = TextLabel3D.CreateTextLabelModel3D("Z", Brushes.LightBlue, true, TextHeight, new Point3D(0.0, 0.0, Length + 0.3), new Vector3D(0.0, 0.0, 1.0), new Vector3D(0.0, 1.0, 0.0));
			models[5] = zlabel;

			return models;
		}
	}
}