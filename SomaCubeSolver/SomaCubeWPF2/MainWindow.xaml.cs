using System;
using System.Collections;
using System.Globalization;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Media3D;
using SomaCubeLib;
using System.Threading;

namespace SomaCubeWPF2
{
	/// <summary>
	/// Interaction logic for MainWindow.xaml
	/// </summary>
	public partial class MainWindow : Window
	{
		public const int NumPieces = 7;
		private ModelVisual3D modelVisual3D { get; set; }
		private Model3DGroup modelGroup { get; set; }
		private Camera camera;
		private Axes axes { get; set; }

		#region lighting
		private Vector3D directionalLightVector1 { get; set; }
		private System.Windows.Media.Color directionalLightColor1 { get; set; }
		private Vector3D directionalLightVector2 { get; set; }
		private System.Windows.Media.Color directionalLightColor2 { get; set; }
		#endregion

		private LargeCube largeCube { get; set; }
		private BitArray largeCubeBitArray { get; set; } // aka "theCube"
		private BitArray auxBitArray { get; set; }
		private BitArray previousAuxBitArray { get; set; }

		#region view control
		private bool plusXLayerOn { get; set; }
		private bool plusYLayerOn { get; set; }
		private bool plusZLayerOn { get; set; }
		private bool negativeXLayerOn { get; set; }
		private bool negativeYLayerOn { get; set; }
		private bool negativeZLayerOn { get; set; }
		private BitArray activeLayersBitArray { get; set; }
		private bool globalAxesOn { get; set; }
		#endregion

		#region color
		private Color currentColor { get; set; }
		private Color[] cubeColors { get; set; }
		#region clearColors
		private readonly Color[] clearColors = new Color[LargeCube.NumCubes] {
			Properties.Settings.Default.SmallCubeClearColor,
			Properties.Settings.Default.SmallCubeClearColor,
			Properties.Settings.Default.SmallCubeClearColor,
			Properties.Settings.Default.SmallCubeClearColor,
			Properties.Settings.Default.SmallCubeClearColor,
			Properties.Settings.Default.SmallCubeClearColor,
			Properties.Settings.Default.SmallCubeClearColor,
			Properties.Settings.Default.SmallCubeClearColor,
			Properties.Settings.Default.SmallCubeClearColor,
			Properties.Settings.Default.SmallCubeClearColor,
			Properties.Settings.Default.SmallCubeClearColor,
			Properties.Settings.Default.SmallCubeClearColor,
			Properties.Settings.Default.SmallCubeClearColor,
			Properties.Settings.Default.SmallCubeClearColor,
			Properties.Settings.Default.SmallCubeClearColor,
			Properties.Settings.Default.SmallCubeClearColor,
			Properties.Settings.Default.SmallCubeClearColor,
			Properties.Settings.Default.SmallCubeClearColor,
			Properties.Settings.Default.SmallCubeClearColor,
			Properties.Settings.Default.SmallCubeClearColor,
			Properties.Settings.Default.SmallCubeClearColor,
			Properties.Settings.Default.SmallCubeClearColor,
			Properties.Settings.Default.SmallCubeClearColor,
			Properties.Settings.Default.SmallCubeClearColor,
			Properties.Settings.Default.SmallCubeClearColor,
			Properties.Settings.Default.SmallCubeClearColor,
			Properties.Settings.Default.SmallCubeClearColor
		};
		#endregion
		#endregion

		private bool IgnoreBtnNot = false;
		private int SolutionWindowCounter { get; set; }

		public MainWindow()
		{
			InitializeComponent();
			camera = new Camera();
			this.directionalLightColor1 = this.directionalLightColor2 = System.Windows.Media.Colors.LightGray;
			this.directionalLightVector2 = new Vector3D(-4.0, -2.0, -1.0);
			this.directionalLightVector1 = new Vector3D(+3.0, -2.0, +1.0);
		}

		private void Window_Loaded(object sender, RoutedEventArgs e)
		{
			camera.TheCamera.FieldOfView = 60.0;
			MainViewport.Camera = camera.TheCamera;
			this.modelGroup = new Model3DGroup();
			this.modelVisual3D = new ModelVisual3D();
			this.modelVisual3D.Content = this.modelGroup;

			ViewportGrid1.Background = new System.Windows.Media.SolidColorBrush(Properties.Settings.Default.BackgroundColor);

			MainViewport.Children.Clear();
			MainViewport.Children.Add(this.modelVisual3D);

			axes = new Axes(0.14 * 0.75, 2.5f * SmallCube.CubeSize, 0.6, 0.9 * 0.75);
			Model.axesModels = axes.DrawAxes();

			largeCubeBitArray = new BitArray(LargeCube.NumCubes);
			auxBitArray = new BitArray(LargeCube.NumCubes);
			previousAuxBitArray = new BitArray(LargeCube.NumCubes);

			currentColor = Properties.Settings.Default.SmallCubeSetColor;
			menuItemColors.Background = new System.Windows.Media.SolidColorBrush(currentColor);
			cubeColors = new Color[LargeCube.NumCubes];
			for (int i = 0; i < cubeColors.Length; i++)
			{
				cubeColors[i] = Properties.Settings.Default.SmallCubeClearColor;
			}
			largeCube = new LargeCube(modelGroup, largeCubeBitArray, cubeColors);

			activeLayersBitArray = new BitArray(LargeCube.NumCubes);
			activeLayersBitArray.SetAll(true);
			plusXLayerOn = plusYLayerOn = plusZLayerOn = negativeXLayerOn = negativeYLayerOn = negativeZLayerOn = true;
			globalAxesOn = true;

			camera.Clear();
			DrawScene();
		}

		private void DrawScene()
		{
			this.modelGroup.Children.Clear();

			DefineLights();
			camera.PositionCamera(lblCamera);

			this.modelGroup.Children.Add(Model.directionalLightModel1);
			this.modelGroup.Children.Add(Model.directionalLightModel2);

			if (globalAxesOn)
			{
				for (int ndx = 0; ndx < Model.axesModels.Length; ndx++)
				{
					modelGroup.Children.Add(Model.axesModels[ndx]);
				}
			}

			tbLargeCubeBitArray.Text = this.largeCubeBitArray.ToStringWithSpaces();

			tbAuxBitArray.Text = this.auxBitArray.ToStringWithSpaces();
			largeCube.Draw(this.activeLayersBitArray);
		}

		private void DefineLights()
		{
			this.modelGroup.Children.Add(new AmbientLight(System.Windows.Media.Colors.DarkSlateGray));
			Model.directionalLightModel1 = new DirectionalLight(this.directionalLightColor1, this.directionalLightVector1);
			Model.directionalLightModel2 = new DirectionalLight(this.directionalLightColor2, this.directionalLightVector2);
		}

		private void Window_KeyDown(object sender, KeyEventArgs e)
		{
			base.OnKeyDown(e);

			switch (e.Key)
			{
				#region camera
				// Adjust the camera's position
				case Key.Up:
					if (Keyboard.IsKeyDown(Key.LeftShift) || Keyboard.IsKeyDown(Key.RightShift))
					{
						camera.Move(Camera.MoveDirection.Up);
					}
					else
					{
						camera.Up();
					}
					e.Handled = true;
					break;
				case Key.Down:
					if (Keyboard.IsKeyDown(Key.LeftShift) || Keyboard.IsKeyDown(Key.RightShift))
					{
						camera.Move(Camera.MoveDirection.Down);
					}
					else
					{
						camera.Down();
					}
					e.Handled = true;
					break;
				case Key.Left:
					if (Keyboard.IsKeyDown(Key.LeftShift) || Keyboard.IsKeyDown(Key.RightShift))
					{
						camera.Move(Camera.MoveDirection.West);
					}
					else if (Keyboard.IsKeyDown(Key.LeftCtrl) || Keyboard.IsKeyDown(Key.RightCtrl))
					{
						camera.Move(Camera.MoveDirection.South);
					}
					else
					{
						camera.Left();
					}
					e.Handled = true;
					break;
				case Key.Right:
					if (Keyboard.IsKeyDown(Key.LeftShift) || Keyboard.IsKeyDown(Key.RightShift))
					{
						camera.Move(Camera.MoveDirection.East);
					}
					else if (Keyboard.IsKeyDown(Key.LeftCtrl) || Keyboard.IsKeyDown(Key.RightCtrl))
					{
						camera.Move(Camera.MoveDirection.North);
					}
					else
					{
						camera.Right();
					}
					e.Handled = true;
					break;
				case Key.Add:
				case Key.OemPlus:
					camera.ZoomIn();
					e.Handled = true;
					break;
				case Key.Subtract:
				case Key.OemMinus:
					camera.ZoomOut();
					e.Handled = true;
					break;
				#endregion

				case Key.G:
					globalAxesOn = !globalAxesOn;
					DrawScene();
					e.Handled = true;
					toggleGlobalAxes.Header = globalAxesOn ? "_Global Axes Off" : "_Global Axes On";
					break;
			}

			if (Utility.IsCameraKey(e.Key))
			{
				camera.PositionCamera(lblCamera);
			}
		}

		#region button callbacks
		private void BtnClearCamera_Click(object sender, RoutedEventArgs e)
		{
			camera.Clear();
			camera.PositionCamera(lblCamera);
		}

		private void BtnSetTheCube_Click(object sender, RoutedEventArgs e)
		{
			this.largeCubeBitArray.SetAll(true);
			for (int i = 0; i < cubeColors.Length; i++)
			{
				cubeColors[i] = currentColor;
			}
			largeCube = new LargeCube(modelGroup, this.largeCubeBitArray, cubeColors);
			DrawScene();
		}

		private void BtnClearTheCube_Click(object sender, RoutedEventArgs e)
		{
			this.largeCubeBitArray.SetAll(false);
			largeCube = new LargeCube(modelGroup, this.largeCubeBitArray, clearColors);
			DrawScene();
		}
		
		private void BtnSetAux_Click(object sender, RoutedEventArgs e)
		{
			Bit0a.IsChecked = false; Bit0b.IsChecked = true;
			Bit1a.IsChecked = false; Bit1b.IsChecked = true;
			Bit2a.IsChecked = false; Bit2b.IsChecked = true;
			Bit3a.IsChecked = false; Bit3b.IsChecked = true;
			Bit4a.IsChecked = false; Bit4b.IsChecked = true;
			Bit5a.IsChecked = false; Bit5b.IsChecked = true;
			Bit6a.IsChecked = false; Bit6b.IsChecked = true;
			Bit7a.IsChecked = false; Bit7b.IsChecked = true;
			Bit8a.IsChecked = false; Bit8b.IsChecked = true;
			Bit9a.IsChecked = false; Bit9b.IsChecked = true;
			Bit10a.IsChecked = false; Bit10b.IsChecked = true;
			Bit11a.IsChecked = false; Bit11b.IsChecked = true;
			Bit12a.IsChecked = false; Bit12b.IsChecked = true;
			Bit13a.IsChecked = false; Bit13b.IsChecked = true;
			Bit14a.IsChecked = false; Bit14b.IsChecked = true;
			Bit15a.IsChecked = false; Bit15b.IsChecked = true;
			Bit16a.IsChecked = false; Bit16b.IsChecked = true;
			Bit17a.IsChecked = false; Bit17b.IsChecked = true;
			Bit18a.IsChecked = false; Bit18b.IsChecked = true;
			Bit19a.IsChecked = false; Bit19b.IsChecked = true;
			Bit20a.IsChecked = false; Bit20b.IsChecked = true;
			Bit21a.IsChecked = false; Bit21b.IsChecked = true;
			Bit22a.IsChecked = false; Bit22b.IsChecked = true;
			Bit23a.IsChecked = false; Bit23b.IsChecked = true;
			Bit24a.IsChecked = false; Bit24b.IsChecked = true;
			Bit25a.IsChecked = false; Bit25b.IsChecked = true;
			Bit26a.IsChecked = false; Bit26b.IsChecked = true;

			auxBitArray.SetAll(true);
			tbAuxBitArray.Text = auxBitArray.ToStringWithSpaces();
		}

		private void BtnClearAux_Click(object sender, RoutedEventArgs e)
		{
			Bit0a.IsChecked = true; Bit0b.IsChecked = false;
			Bit1a.IsChecked = true; Bit1b.IsChecked = false;
			Bit2a.IsChecked = true; Bit2b.IsChecked = false;
			Bit3a.IsChecked = true; Bit3b.IsChecked = false;
			Bit4a.IsChecked = true; Bit4b.IsChecked = false;
			Bit5a.IsChecked = true; Bit5b.IsChecked = false;
			Bit6a.IsChecked = true; Bit6b.IsChecked = false;
			Bit7a.IsChecked = true; Bit7b.IsChecked = false;
			Bit8a.IsChecked = true; Bit8b.IsChecked = false;
			Bit9a.IsChecked = true; Bit9b.IsChecked = false;
			Bit10a.IsChecked = true; Bit10b.IsChecked = false;
			Bit11a.IsChecked = true; Bit11b.IsChecked = false;
			Bit12a.IsChecked = true; Bit12b.IsChecked = false;
			Bit13a.IsChecked = true; Bit13b.IsChecked = false;
			Bit14a.IsChecked = true; Bit14b.IsChecked = false;
			Bit15a.IsChecked = true; Bit15b.IsChecked = false;
			Bit16a.IsChecked = true; Bit16b.IsChecked = false;
			Bit17a.IsChecked = true; Bit17b.IsChecked = false;
			Bit18a.IsChecked = true; Bit18b.IsChecked = false;
			Bit19a.IsChecked = true; Bit19b.IsChecked = false;
			Bit20a.IsChecked = true; Bit20b.IsChecked = false;
			Bit21a.IsChecked = true; Bit21b.IsChecked = false;
			Bit22a.IsChecked = true; Bit22b.IsChecked = false;
			Bit23a.IsChecked = true; Bit23b.IsChecked = false;
			Bit24a.IsChecked = true; Bit24b.IsChecked = false;
			Bit25a.IsChecked = true; Bit25b.IsChecked = false;
			Bit26a.IsChecked = true; Bit26b.IsChecked = false;

			this.auxBitArray.SetAll(false);
			tbAuxBitArray.Text = auxBitArray.ToStringWithSpaces();
			this.previousAuxBitArray.SetAll(false);
		}

		private void BtnNotAux_Click(object sender, RoutedEventArgs e)
		{
			IgnoreBtnNot = true;
			auxBitArray.Not();

			Bit0a.IsChecked = !auxBitArray[0];
			Bit0b.IsChecked = auxBitArray[0];

			Bit1a.IsChecked = !auxBitArray[1];
			Bit1b.IsChecked = auxBitArray[1];

			Bit2a.IsChecked = !auxBitArray[2];
			Bit2b.IsChecked = auxBitArray[2];

			Bit3a.IsChecked = !auxBitArray[3];
			Bit3b.IsChecked = auxBitArray[3];

			Bit4a.IsChecked = !auxBitArray[4];
			Bit4b.IsChecked = auxBitArray[4];

			Bit5a.IsChecked = !auxBitArray[5];
			Bit5b.IsChecked = auxBitArray[5];

			Bit6a.IsChecked = !auxBitArray[6];
			Bit6b.IsChecked = auxBitArray[6];

			Bit7a.IsChecked = !auxBitArray[7];
			Bit7b.IsChecked = auxBitArray[7];

			Bit8a.IsChecked = !auxBitArray[8];
			Bit8b.IsChecked = auxBitArray[8];

			Bit9a.IsChecked = !auxBitArray[9];
			Bit9b.IsChecked = auxBitArray[9];

			Bit10a.IsChecked = !auxBitArray[10];
			Bit10b.IsChecked = auxBitArray[10];

			Bit11a.IsChecked = !auxBitArray[11];
			Bit11b.IsChecked = auxBitArray[11];

			Bit12a.IsChecked = !auxBitArray[12];
			Bit12b.IsChecked = auxBitArray[12];

			Bit13a.IsChecked = !auxBitArray[13];
			Bit13b.IsChecked = auxBitArray[13];

			Bit14a.IsChecked = !auxBitArray[14];
			Bit14b.IsChecked = auxBitArray[14];

			Bit15a.IsChecked = !auxBitArray[15];
			Bit15b.IsChecked = auxBitArray[15];

			Bit16a.IsChecked = !auxBitArray[16];
			Bit16b.IsChecked = auxBitArray[16];

			Bit17a.IsChecked = !auxBitArray[17];
			Bit17b.IsChecked = auxBitArray[17];

			Bit18a.IsChecked = !auxBitArray[18];
			Bit18b.IsChecked = auxBitArray[18];

			Bit19a.IsChecked = !auxBitArray[19];
			Bit19b.IsChecked = auxBitArray[19];

			Bit20a.IsChecked = !auxBitArray[20];
			Bit20b.IsChecked = auxBitArray[20];

			Bit21a.IsChecked = !auxBitArray[21];
			Bit21b.IsChecked = auxBitArray[21];

			Bit22a.IsChecked = !auxBitArray[22];
			Bit22b.IsChecked = auxBitArray[22];

			Bit23a.IsChecked = !auxBitArray[23];
			Bit23b.IsChecked = auxBitArray[23];

			Bit24a.IsChecked = !auxBitArray[24];
			Bit24b.IsChecked = auxBitArray[24];

			Bit25a.IsChecked = !auxBitArray[25];
			Bit25b.IsChecked = auxBitArray[25];

			Bit26a.IsChecked = !auxBitArray[26];
			Bit26b.IsChecked = auxBitArray[26];

			IgnoreBtnNot = false;
			tbAuxBitArray.Text = auxBitArray.ToStringWithSpaces();
			tbHex.Text = auxBitArray.GetHexValue();
		}

		private void BtnNotTheCube_Click(object sender, RoutedEventArgs e)
		{
			this.largeCubeBitArray.Not();
			for (int i = 0; i < cubeColors.Length; i++)
			{
				if (this.largeCubeBitArray[i])
				{
					cubeColors[i] = currentColor;
				}
				else
				{
					cubeColors[i] = Properties.Settings.Default.SmallCubeClearColor;
				}
			}
			largeCube = new LargeCube(modelGroup, this.largeCubeBitArray, cubeColors);
			DrawScene();
		}

		private void BtnAnd_Click(object sender, RoutedEventArgs e)
		{
			String bitsArray = tbAuxBitArray.Text.Replace(" ", "");

			auxBitArray = new BitArray(LargeCube.NumCubes);
			for (int i = 0; i < bitsArray.Length; i++)
			{
				char ch = bitsArray[i];
				if (ch == '1')
				{
					auxBitArray.Set(i, true);
				}
			}

			this.largeCubeBitArray.And(auxBitArray);

			for (int i = 0; i < largeCubeBitArray.Length; i++)
			{
				if (this.largeCubeBitArray[i])
				{
					cubeColors[i] = currentColor;
				}
				else
				{
					cubeColors[i] = Properties.Settings.Default.SmallCubeClearColor;
				}
			}

			largeCube = new LargeCube(modelGroup, this.largeCubeBitArray, cubeColors);
			DrawScene();
		}

		// sets the small cubes
		private void BtnOr_Click(object sender, RoutedEventArgs e)
		{
			String bitsArray = tbAuxBitArray.Text.Replace(" ", "");

			auxBitArray = new BitArray(LargeCube.NumCubes);
			for (int i = 0; i < bitsArray.Length; i++)
			{
				char ch = bitsArray[i];
				if (ch == '1')
				{
					auxBitArray.Set(i, true);
				}
			}

			previousAuxBitArray.Xor(auxBitArray);
			for (int i = 0; i < previousAuxBitArray.Length; i++)
			{
				if (previousAuxBitArray[i])
				{
					cubeColors[i] = currentColor;
				}
			}

			this.largeCubeBitArray.Or(auxBitArray);

			largeCube = new LargeCube(modelGroup, this.largeCubeBitArray, cubeColors);
			previousAuxBitArray = auxBitArray.DeepCopy();
			DrawScene();
		}

		// removes the small cubes
		private void BtnAndNot_Click(object sender, RoutedEventArgs e)
		{
			String bitsArray = tbAuxBitArray.Text.Replace(" ", "");

			auxBitArray = new BitArray(LargeCube.NumCubes);
			auxBitArray.Set(bitsArray);

			for (int i = 0; i < largeCubeBitArray.Length; i++)
			{
				if (this.largeCubeBitArray[i])
				{
					cubeColors[i] = currentColor;
				}
				else
				{
					cubeColors[i] = Properties.Settings.Default.SmallCubeClearColor;
				}
			}
			this.largeCubeBitArray.AndNot(auxBitArray);
			largeCube = new LargeCube(modelGroup, this.largeCubeBitArray, cubeColors);
			DrawScene();
		}

		private void Btn1_Checked(object sender, RoutedEventArgs e)
		{
			if (IgnoreBtnNot) return;
			if (this.largeCubeBitArray == null) return;

			auxBitArray[0] = Bit0b.IsChecked.HasValue ? (Bit0b.IsChecked.Value ? true : false) : false;
			auxBitArray[1] = Bit1b.IsChecked.HasValue ? (Bit1b.IsChecked.Value ? true : false) : false;
			auxBitArray[2] = Bit2b.IsChecked.HasValue ? (Bit2b.IsChecked.Value ? true : false) : false;
			auxBitArray[3] = Bit3b.IsChecked.HasValue ? (Bit3b.IsChecked.Value ? true : false) : false;
			auxBitArray[4] = Bit4b.IsChecked.HasValue ? (Bit4b.IsChecked.Value ? true : false) : false;
			auxBitArray[5] = Bit5b.IsChecked.HasValue ? (Bit5b.IsChecked.Value ? true : false) : false;
			auxBitArray[6] = Bit6b.IsChecked.HasValue ? (Bit6b.IsChecked.Value ? true : false) : false;
			auxBitArray[7] = Bit7b.IsChecked.HasValue ? (Bit7b.IsChecked.Value ? true : false) : false;
			auxBitArray[8] = Bit8b.IsChecked.HasValue ? (Bit8b.IsChecked.Value ? true : false) : false;
			auxBitArray[9] = Bit9b.IsChecked.HasValue ? (Bit9b.IsChecked.Value ? true : false) : false;
			auxBitArray[10] = Bit10b.IsChecked.HasValue ? (Bit10b.IsChecked.Value ? true : false) : false;
			auxBitArray[11] = Bit11b.IsChecked.HasValue ? (Bit11b.IsChecked.Value ? true : false) : false;
			auxBitArray[12] = Bit12b.IsChecked.HasValue ? (Bit12b.IsChecked.Value ? true : false) : false;
			auxBitArray[13] = Bit13b.IsChecked.HasValue ? (Bit13b.IsChecked.Value ? true : false) : false;
			auxBitArray[14] = Bit14b.IsChecked.HasValue ? (Bit14b.IsChecked.Value ? true : false) : false;
			auxBitArray[15] = Bit15b.IsChecked.HasValue ? (Bit15b.IsChecked.Value ? true : false) : false;
			auxBitArray[16] = Bit16b.IsChecked.HasValue ? (Bit16b.IsChecked.Value ? true : false) : false;
			auxBitArray[17] = Bit17b.IsChecked.HasValue ? (Bit17b.IsChecked.Value ? true : false) : false;
			auxBitArray[18] = Bit18b.IsChecked.HasValue ? (Bit18b.IsChecked.Value ? true : false) : false;
			auxBitArray[19] = Bit19b.IsChecked.HasValue ? (Bit19b.IsChecked.Value ? true : false) : false;
			auxBitArray[20] = Bit20b.IsChecked.HasValue ? (Bit20b.IsChecked.Value ? true : false) : false;
			auxBitArray[21] = Bit21b.IsChecked.HasValue ? (Bit21b.IsChecked.Value ? true : false) : false;
			auxBitArray[22] = Bit22b.IsChecked.HasValue ? (Bit22b.IsChecked.Value ? true : false) : false;
			auxBitArray[23] = Bit23b.IsChecked.HasValue ? (Bit23b.IsChecked.Value ? true : false) : false;
			auxBitArray[24] = Bit24b.IsChecked.HasValue ? (Bit24b.IsChecked.Value ? true : false) : false;
			auxBitArray[25] = Bit25b.IsChecked.HasValue ? (Bit25b.IsChecked.Value ? true : false) : false;
			auxBitArray[26] = Bit26b.IsChecked.HasValue ? (Bit26b.IsChecked.Value ? true : false) : false;

			tbAuxBitArray.Text = auxBitArray.ToStringCommaSeparated();
			tbAuxBitArray.Text = auxBitArray.ToStringWithSpaces();

			tbHex.Text = auxBitArray.GetHexValue();
		}

		private void BtnHexEnter_Click(object sender, RoutedEventArgs e)
		{
			tbHex.Background = new SolidColorBrush(Colors.White);
			String hexNumberStr = tbHex.Text;
			int hexValue;
			if (Int32.TryParse(hexNumberStr, NumberStyles.HexNumber, CultureInfo.InvariantCulture, out hexValue))
			{
				if (hexValue > 0x7FFFFFF)
				{
					hexValue = 0x7FFFFFF;
					tbHex.Text = String.Format("{0:X}", hexValue);
				}
				tbHex.Background = new SolidColorBrush(Colors.White);
			}
			else
			{
				tbHex.Background = new SolidColorBrush(Colors.Red);
				return;
			}

			auxBitArray = new BitArray(LargeCube.NumCubes);
			string binaryString = Convert.ToString(Convert.ToInt32(tbHex.Text, 16), 2);
			binaryString = binaryString.PadLeft(27, '0');
			auxBitArray.Set(binaryString);
			BtnNotAux_Click(sender, e);
			BtnNotAux_Click(sender, e);
		}
		#endregion

		#region menubar
		private void Exit_Click(object sender, RoutedEventArgs e)
		{
			Environment.Exit(0);
		}

		private void Axes_Click(object sender, RoutedEventArgs e)
		{
			globalAxesOn = !globalAxesOn;
			toggleGlobalAxes.Header = globalAxesOn ? "_Axes Off" : "_Axes On";
			DrawScene();
		}

		private void Help_Click(object sender, RoutedEventArgs e)
		{
			new Thread(new ThreadStart(delegate
			{
				MessageBoxResult result = System.Windows.MessageBox.Show(
						"Keys:\n" +
							"Camera:\n" +
							"  Up/Down Arrow: tilt camera\n" +
							"  Right Arrow: rotate camera clockwise\n" +
							"  Left Arrow: rotate camera counter-clockwise\n" +
							"  Plus/Minus: zoom camera In/Out\n" +
							"  Shift Up-Arrow: pan camera Up\n" +
							"  Shift Down-Arrow: pan camera Down\n" +
							"  Shift Left-Arrow: pan camera West\n" +
							"  Shift Right-Arrow: pan camera East\n" +
							"  Ctrl Left-Arrow: pan camera South\n" +
							"  Ctrl Right-Arrow: pan camera North\n",
							"Help", MessageBoxButton.OK);
			})).Start();
		}

		private void PlusXLayerOff_Click(object sender, RoutedEventArgs e)
		{
			plusXLayerOn = !plusXLayerOn;
			PlusXLayerOff.Header = plusXLayerOn ? "+X Layer Hidden" : "+X Layer Visible";
			activeLayersBitArray[0] = activeLayersBitArray[1] = activeLayersBitArray[2] =
			activeLayersBitArray[9] = activeLayersBitArray[10] = activeLayersBitArray[11] =
			activeLayersBitArray[18] = activeLayersBitArray[19] = activeLayersBitArray[20] = plusXLayerOn;
			DrawScene();
		}

		private void PlusYLayerOff_Click(object sender, RoutedEventArgs e)
		{
			plusYLayerOn = !plusYLayerOn;
			PlusYLayerOff.Header = plusYLayerOn ? "+Y Layer Hidden" : "+Y Layer Visible";
			activeLayersBitArray[2] = activeLayersBitArray[5] = activeLayersBitArray[8] =
			activeLayersBitArray[11] = activeLayersBitArray[14] = activeLayersBitArray[17] =
			activeLayersBitArray[20] = activeLayersBitArray[23] = activeLayersBitArray[26] = plusYLayerOn;
			DrawScene();
		}

		private void PlusZLayerOff_Click(object sender, RoutedEventArgs e)
		{
			plusZLayerOn = !plusZLayerOn;
			PlusZLayerOff.Header = plusZLayerOn ? "+Z Layer Hidden" : "+Z Layer Visible";
			activeLayersBitArray[18] = activeLayersBitArray[19] = activeLayersBitArray[20] =
			activeLayersBitArray[21] = activeLayersBitArray[22] = activeLayersBitArray[23] =
			activeLayersBitArray[24] = activeLayersBitArray[25] = activeLayersBitArray[26] = plusZLayerOn;
			DrawScene();
		}

		private void NegativeXLayerOff_Click(object sender, RoutedEventArgs e)
		{
			negativeXLayerOn = !negativeXLayerOn;
			NegativeXLayerOff.Header = negativeXLayerOn ? "-X Layer Hidden" : "-X Layer Visible";
			activeLayersBitArray[6] = activeLayersBitArray[7] = activeLayersBitArray[8] =
			activeLayersBitArray[15] = activeLayersBitArray[16] = activeLayersBitArray[17] =
			activeLayersBitArray[24] = activeLayersBitArray[25] = activeLayersBitArray[26] = negativeXLayerOn;
			DrawScene();
		}

		private void NegativeYLayerOff_Click(object sender, RoutedEventArgs e)
		{
			negativeYLayerOn = !negativeYLayerOn;
			NegativeYLayerOff.Header = negativeYLayerOn ? "-Y Layer Hidden" : "-Y Layer Visible";
			activeLayersBitArray[6] = activeLayersBitArray[15] = activeLayersBitArray[24] =
			activeLayersBitArray[3] = activeLayersBitArray[12] = activeLayersBitArray[21] =
			activeLayersBitArray[0] = activeLayersBitArray[9] = activeLayersBitArray[18] = negativeYLayerOn;
			DrawScene();
		}

		private void NegativeZLayerOff_Click(object sender, RoutedEventArgs e)
		{
			negativeZLayerOn = !negativeZLayerOn;
			NegativeZLayerOff.Header = negativeZLayerOn ? "-Z Layer Hidden" : "-Z Layer Visible";
			activeLayersBitArray[0] = activeLayersBitArray[1] = activeLayersBitArray[2] =
			activeLayersBitArray[3] = activeLayersBitArray[4] = activeLayersBitArray[5] =
			activeLayersBitArray[6] = activeLayersBitArray[7] = activeLayersBitArray[8] = negativeZLayerOn;
			DrawScene();
		}

		private void Color_Click(object sender, RoutedEventArgs e)
		{
			MenuItem mi = (MenuItem)sender;
			string colStr = (String)mi.Tag; // todo get from mi.Background brush
			currentColor = (Color)ColorConverter.ConvertFromString(colStr);
			menuItemColors.Background = new System.Windows.Media.SolidColorBrush(currentColor);
		}

		private void Solve_Click(object sender, RoutedEventArgs e)
		{
			if (SolutionWindowCounter != 0) return;

			BtnClearTheCube_Click(sender, e);

			SolutionWindow solutionWindow = new SolutionWindow();
			if (solutionWindow.ReadSolutionFile())
			{
				this.largeCubeBitArray.SetAll(false);
				solutionWindow.NewMessage += MessageReceived;
				solutionWindow.Show();
				SolutionWindowCounter++;
				Solve.IsEnabled = false;
			}
		}

		private void MessageReceived(object sender, MessageEventArgs e)
		{
			if (e.WhichOperation == MessageEventArgs.WhichOp.None)
			{
				SolutionWindowCounter--;
				Solve.IsEnabled = true;
				return;
			}

			String str = e.PieceName;
			String str1 = largeCubeBitArray.ToStringJava();
			String str2 = e.Ba.ToStringJava();

			// if removing the piece
			if (e.WhichOperation == MessageEventArgs.WhichOp.AndNot)
			{
				this.largeCubeBitArray.AndNot(e.Ba);
			}
			// else adding the piece
			else if(e.WhichOperation == MessageEventArgs.WhichOp.Or)
			{
				this.largeCubeBitArray.Or(e.Ba);
			}
			else
			{
				throw new Exception("Error: unknown operation: " + e.WhichOperation.ToString());
			}

			largeCube = new LargeCube(modelGroup, largeCubeBitArray, e.CubeColors);
			DrawScene();
		}
		#endregion
	}
}