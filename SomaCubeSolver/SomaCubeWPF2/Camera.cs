using System;
using System.Windows.Controls;
using System.Windows.Media.Media3D;
using SomaCubeLib;

namespace SomaCubeWPF2
{
	public class Camera // thanks again to Rod Stephens for the idea
	{
		private const double CameraDPhi = 5.0 * Utility.DegreeToRadian; // The change in CameraPhi when you press the up and down arrows
		private const double CameraDTheta = 5.0 * Utility.DegreeToRadian; // The change in CameraTheta when you press the left and right arrows
		private const double CameraDR = 0.5; // The change in CameraR when you press + or -
		public PerspectiveCamera TheCamera { get; set; }

		/// <summary>
		/// The camera's current location, phi, radians
		/// </summary>
		public double CameraPhi { get; set; } // Φ

		/// <summary>
		/// The camera's current location, theta, radians
		/// </summary>
		public double CameraTheta { get; set; } // ϴ

		public double CameraR { get; set; }

		/// <summary>
		/// X
		/// </summary>
		public double CameraMoveNorthSouth { get; set; }

		/// <summary>
		/// Y
		/// </summary>
		public double CameraElevateUpDown { get; set; }

		/// <summary>
		/// Z
		/// </summary>
		public double CameraMoveEastWest { get; set; }

		public enum MoveDirection { Up, Down, West, East, North, South };

		public Camera()
		{
			TheCamera = new PerspectiveCamera();
		}

		public void PositionCamera(Label lblCamera)
		{
			// Calculate the camera's position in Cartesian coordinates
			double y = CameraR * Math.Sin(CameraPhi);
			double hyp = CameraR * Math.Cos(CameraPhi);
			double x = hyp * Math.Cos(CameraTheta);
			double z = hyp * Math.Sin(CameraTheta);
			TheCamera.Position = new Point3D(x + CameraMoveNorthSouth, y + CameraElevateUpDown, z + CameraMoveEastWest);

			// Look toward the origin
			TheCamera.LookDirection = new Vector3D(-x, -y, -z);
			TheCamera.LookDirection = TheCamera.LookDirection.Normalize2();

			// +Y axis is up
			TheCamera.UpDirection = new Vector3D(0.0, +1.0, 0.0);

			String dir = Direction(CameraTheta * Utility.RadianToDegree, CameraPhi * Utility.RadianToDegree);
			lblCamera.Content = String.Format("ϴ={0,4:+##0;-###0; ###0}° Φ={1,3:+#0;-#0; #0}° R={2:f1} {3}={4} {5}={6} {7}={8} {9}",
				CameraTheta * Utility.RadianToDegree, CameraPhi * Utility.RadianToDegree, CameraR, "X", CameraMoveNorthSouth, "Y", CameraElevateUpDown, "Z", CameraMoveEastWest, dir);
		}
		// pan the camera
		public void Move(MoveDirection dir)
		{
			if (dir == MoveDirection.Up)
			{
				if (CameraElevateUpDown <= +/*Background.BoxSize*/20)
				{
					CameraElevateUpDown += 1.0;
				}
			}
			else if (dir == MoveDirection.Down)
			{
				if (CameraElevateUpDown >= -/*Background.BoxSize*/20)
				{
					CameraElevateUpDown -= 1.0;
				}
			}
			else if (dir == MoveDirection.West)
			{
				if (CameraMoveEastWest <= +/*Background.BoxSize*/20)
				{
					CameraMoveEastWest += 1.0;
				}
			}
			else if (dir == MoveDirection.East)
			{
				if (CameraMoveEastWest >= -/*Background.BoxSize*/20)
				{
					CameraMoveEastWest -= 1.0;
				}
			}
			else if (dir == MoveDirection.South)
			{
				if (CameraMoveNorthSouth <= +/*Background.BoxSize*/20)
				{
					CameraMoveNorthSouth += 1.0;
				}
			}
			else if (dir == MoveDirection.North)
			{
				if (CameraMoveNorthSouth >= -/*Background.BoxSize*/20)
				{
					CameraMoveNorthSouth -= 1.0;
				}
			}
		}

		public void Up()
		{
			CameraPhi += CameraDPhi;
			Validate("up");
		}

		public void Down()
		{
			CameraPhi -= Camera.CameraDPhi;
			Validate("down");
		}

		public void Left()
		{
			CameraTheta -= CameraDTheta;
			Validate("left");
		}

		public void Right()
		{
			CameraTheta += CameraDTheta;
			Validate("right");
		}

		public void Validate(string which)
		{
			switch (which)
			{
				case "up":
					if (CameraPhi > Math.PI / 2.0) CameraPhi = Math.PI / 2.0;
					break;

				case "down":
					if (CameraPhi < -Math.PI / 2.0) CameraPhi = -Math.PI / 2.0;
					break;

				case "left":
					if (CameraTheta <= 0.0) CameraTheta = (2.0 * Math.PI) - CameraTheta;
					break;

				case "right":
					if (CameraTheta >= (2.0 * Math.PI)) CameraTheta = 0.0;
					break;

				case "zoomIn":
					if (CameraR < CameraDR) CameraR = CameraDR;
					break;

				case "zoomOut":
					if (CameraR > 200.0) CameraR = 200.0;
					break;

				default:
					if (CameraPhi > Math.PI / 2.0) CameraPhi = Math.PI / 2.0;
					if (CameraPhi < -Math.PI / 2.0) CameraPhi = -Math.PI / 2.0;
					if (CameraTheta <= 0.0) CameraTheta = (2.0 * Math.PI) - CameraTheta;
					if (CameraTheta >= (2.0 * Math.PI)) CameraTheta = 0.0;
					if (CameraR < CameraDR) CameraR = CameraDR;
					if (CameraR > 200.0) CameraR = 200.0; // arbitrary but reasonable limit
					break;
			}

			if (((CameraPhi == Math.PI / 2.0) || (CameraPhi == -Math.PI / 2.0)) &&
				((CameraElevateUpDown != 0.0) || (CameraMoveNorthSouth != 0.0) || (CameraMoveEastWest != 0.0)))
			{
				CameraPhi = (CameraPhi == Math.PI / 2.0) ? CameraPhi - 0.002 : CameraPhi + 0.002;
			}
		}

		public void ZoomIn()
		{
			CameraR -= CameraDR;
			Validate("zoomIn");
		}

		public void ZoomOut()
		{
			CameraR += CameraDR;
			Validate("zoomOut");
		}

		public void Clear()
		{
			CameraPhi = 30.0 * Utility.DegreeToRadian;
			CameraTheta = 60.0 * Utility.DegreeToRadian;
			CameraR = 15.0;
			CameraMoveNorthSouth = 0;
			CameraElevateUpDown = 0;
			CameraMoveEastWest = 0;
		}

		public string Direction(double CameraThetaDeg /* ϴ */, double CameraPhiDeg /* Φ */)
		{
			float compassDir = Math.Abs((float)CameraThetaDeg);
			string s = String.Empty;

			if ((compassDir >= 20.0f) && (compassDir < 80.0f))
			{
				s = String.Format("North East");
			}
			else if ((compassDir >= 80.0f) && (compassDir < 100.0f))
			{
				s = String.Format("East");
			}
			else if ((compassDir >= 100.0f) && (compassDir < 170.0f))
			{
				s = String.Format("South East");
			}
			else if ((compassDir >= 170.0f) && (compassDir < 190.0f))
			{
				s = String.Format("South");
			}
			else if ((compassDir >= 190.0f) && (compassDir < 260.0f))
			{
				s = String.Format("South West");
			}
			else if ((compassDir >= 260.0f) && (compassDir < 280.0f))
			{
				s = String.Format("West (ϴ={0:f1}°)", compassDir);
			}
			else if ((compassDir >= 280.0f) && (compassDir < 350.0f))
			{
				s = String.Format("North West");
			}
			else if ((compassDir >= 350.0f) || (compassDir < 20.0f))
			{
				s = String.Format("North");
			}
			else s = String.Format("error {0}", compassDir);

			if (CameraPhiDeg >= 80.0)
			{
				s = String.Format("Down");
			}
			else if (CameraPhiDeg <= -80.0)
			{
				s = String.Format("Up");
			}

			return "Looking " + s;
		}
	}
}

