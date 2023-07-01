using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using SomaCubeLib;
using System.Text;
using System.ComponentModel;
using System.Threading;

namespace SomaCubeWPF2
{
	public class MessageEventArgs : EventArgs
	{
		public enum WhichOp { None, Or, AndNot };
		public string PieceName { get; set; }
		public BitArray Ba { get; set; }
		public Color[] CubeColors { get;set;}
		public WhichOp WhichOperation { get; set; }

		public MessageEventArgs(String pieceName, BitArray ba, Color[] cubeColors, WhichOp whichOp)
		{
			this.PieceName = pieceName;
			this.Ba = ba;
			this.CubeColors = new Color[LargeCube.NumCubes];
			if (cubeColors != null)
			{
				Array.Copy(cubeColors, this.CubeColors, cubeColors.Length);
			}
			this.WhichOperation = whichOp;
		}
	}

	public class NameAndColor
	{
		public string PieceName { get; set; }
		public Color PieceColor { get; set; }
		public string ColorString { get; set; }

		public NameAndColor(string pieceName, Color pieceColor, string colorString)
		{
			this.PieceName = pieceName;
			this.PieceColor = pieceColor;
			this.ColorString = colorString;
		}
	}

	public class SomaPiece
	{
		public SomaPiece(string pieceName, string baStr)
		{
			this.PieceName = pieceName;
			this.BaStr = String.Empty;
			this.Ba = null;

			if (baStr != null)
			{
				this.BaStr = baStr;
				this.Ba = new BitArray(LargeCube.NumCubes);
				this.Ba.SetFromJavaStringZeroBased(BaStr);
			}
		}
		public string PieceName;
		public string BaStr;
		public BitArray Ba;
	}

	/// <summary>
	/// Interaction logic for SolutionWindow.xaml
	/// </summary>
	public partial class SolutionWindow : Window
	{
		private List<NameAndColor> namesAndColors2 = new List<NameAndColor>();
		public event EventHandler<MessageEventArgs> NewMessage;
		private String Message { get; set; }
		private int ItemCounter { get; set; }
		private Color[] cubeColors { get; set; }
		private List<SomaPiece> somaPieces = new List<SomaPiece>();
		private BitArray previousBa { get; set; }
		public const string RemovePiece = SolutionFile.RemovePiece;
		public const string FoundASolution = SolutionFile.FoundASolution;
		private const string SolutionFileName = SolutionFile.SolutionFileName;
		private int line;
		private BackgroundWorker workerThread { get; set; }
		public enum WhichClick { None, Previous, Next, Goto, Select };
		public WhichClick whichClick = WhichClick.None;
		private bool initializing { get; set; }

		public SolutionWindow()
		{
			InitializeComponent();

			namesAndColors2.Add(new NameAndColor("L Tetra Cube"             /* my #2 */, (Color)ColorConverter.ConvertFromString("#FF117711"), "#FF117711"));
			namesAndColors2.Add(new NameAndColor("Branch Tetra Cube"        /* my #7 */, (Color)ColorConverter.ConvertFromString("#FFff99aa"), "#FFff99aa"));
			namesAndColors2.Add(new NameAndColor("Right Screw Tetra Cube"   /* my #6 */, (Color)ColorConverter.ConvertFromString("#FFFFFF00"), "#FFFFFF00"));
			namesAndColors2.Add(new NameAndColor("Left Screw Tetra Cube"    /* my #5 */, (Color)ColorConverter.ConvertFromString("#FF8080FF"), "#FF8080FF"));
			namesAndColors2.Add(new NameAndColor("S Tetra Cube"             /* my #4 */, (Color)ColorConverter.ConvertFromString("#FF9900FF"), "#FF9900FF"));
			namesAndColors2.Add(new NameAndColor("T Tetra Cube"             /* my #3 */, (Color)ColorConverter.ConvertFromString("#FF22ffFF"), "#FF22ffFF"));
			namesAndColors2.Add(new NameAndColor("L Tri Cube"               /* my #1 */, (Color)ColorConverter.ConvertFromString("#FF6BCDFF"), "#FF6BCDFF"));
			cubeColors = new Color[LargeCube.NumCubes];

			for (int i = 0; i < cubeColors.Length; i++)
			{
				cubeColors[i] = Properties.Settings.Default.SmallCubeClearColor;
			}

			whichClick = WhichClick.Next;
		}

		public bool ReadSolutionFile()
		{
			string fullPath = String.Format("{0}{1}", SomaCubeLib.SolutionFile.GetDirectory(), SolutionFileName);

			if (!File.Exists(fullPath))
			{
				MessageBox.Show(String.Format("File {0} does not exist\nDo you need to run SomaCubeSolver?", fullPath), "Error");
				return false;
			}
			StreamReader sr = new StreamReader(fullPath);
			while (sr.Peek() >= 0)
			{
				String line = sr.ReadLine();
				String[] parts = line.Split(new char[] { ';' });
				somaPieces.Add(new SomaPiece(parts[0], parts[1]));
			}
			sr.Close();

			foreach (SomaPiece piece in somaPieces)
			{
				this.lbSolutions.Items.Add(piece.PieceName);
			}

			ItemCounter = 0;
			this.btnNext.IsEnabled = somaPieces.Count > 0;
			initializing = true;
			lbSolutions.SelectedIndex = ItemCounter;
			initializing = false;
			previousBa = new BitArray(LargeCube.NumCubes);
			previousBa.SetAll(false);
			lblItemNumber.Content = String.Format("Item Number: {0} of {1}", ItemCounter.ToString(), (somaPieces.Count - 1));

			return true;
		}

		void Selected_Click(object sender, RoutedEventArgs e)
		{
			if (initializing) return;

			whichClick = WhichClick.Select;
			if (sender is ListBox)
			{
				ItemCounter = ((ListBox)sender).SelectedIndex - 1;
				whichClick = WhichClick.Select;
			}
			else if (sender is Button)
			{
				Button btn = (Button)sender;
				String content = (String)btn.Content;
				ItemCounter = line - 1;
				if (content.Equals("Go to line"))
				{
					whichClick = WhichClick.Goto;
				}
				else if (content.Equals("Next"))
				{
					whichClick = WhichClick.Next;
				}
				else if (content.Equals("Previous"))
				{
					whichClick = WhichClick.Previous;
				}
				else
				{
					throw new Exception("error:" + content);
				}
			}

			// clear the cube
			BitArray baClear = new BitArray(LargeCube.NumCubes);
			baClear.SetAll(false);
			Color[] clearCubeColors = new Color[LargeCube.NumCubes];
			for (int i = 0; i < clearCubeColors.Length; i++)
			{
				clearCubeColors[i] = Properties.Settings.Default.SmallCubeClearColor;
				cubeColors[i] = Properties.Settings.Default.SmallCubeClearColor;
			}
			NewMessage?.Invoke(this, new MessageEventArgs("clear", baClear, clearCubeColors, MessageEventArgs.WhichOp.Or));

			previousBa = new BitArray(LargeCube.NumCubes);
			previousBa.SetAll(false);

			workerThread = new BackgroundWorker();
			workerThread.WorkerReportsProgress = true;
			workerThread.DoWork += SolveCube;
			workerThread.RunWorkerCompleted += RunWorkerCompleted;
			workerThread.ProgressChanged += WorkerProgressChanged;
			workerThread.RunWorkerAsync(argument: "not currently used");
		}

		void WorkerProgressChanged(object sender, ProgressChangedEventArgs e)
		{
			pbStatus.Value = e.ProgressPercentage;
		}

		private void RunWorkerCompleted(object sender, RunWorkerCompletedEventArgs e)
		{
			BtnNext_Click(sender, null);
			whichClick = WhichClick.Next;
		}

		void SolveCube(object sender, DoWorkEventArgs e)
		{
			double ratio = 100.0 / ItemCounter;
			int ndx = 0;
			string arg = (String)e.Argument;
			int progress = 0;

			// go through entire list up to line before selected line to get current solved configuration
			for (int j = 0; j < ItemCounter; j++)
			{
				BitArray ba = somaPieces[j].Ba;

				progress = (int)(++ndx * ratio);
				(sender as BackgroundWorker).ReportProgress(progress);

				// remove leading numbers
				string pieceName = (String)lbSolutions.Items[j];
				int pos = pieceName.IndexOf(".");
				pieceName = pieceName.Substring(pos + 2);
				NameAndColor nameAndColor = namesAndColors2.Find(n => n.PieceName.Equals(pieceName));

				previousBa.Xor(ba);

				// if adding a piece
				if (nameAndColor != null)
				{
					for (int i = 0; i < previousBa.Length; i++)
					{
						if (previousBa[i])
						{
							cubeColors[i] = nameAndColor.PieceColor;
						}
					}
				}
				// else removing a piece
				else
				{
					for (int i = 0; i < previousBa.Length; i++)
					{
						if (previousBa[i])
						{
							cubeColors[i] = Properties.Settings.Default.SmallCubeClearColor;
						}
					}
				}
				previousBa = ba.DeepCopy();
			}

			progress = 100;
			(sender as BackgroundWorker).ReportProgress(progress);
		}

		void BtnNext_Click(object sender, RoutedEventArgs e)
		{
			ListBox lb = this.lbSolutions;
			string pieceName = String.Empty;

			/// <summary>
			/// cumulative state of cube
			/// </summary>
			BitArray theCube = null;

			// if special case
			if (ItemCounter < 0)
			{
				pieceName = "0. L Tetra Cube";
				theCube = new BitArray(LargeCube.NumCubes);
				theCube.SetAll(false);
			}
			else
			{
				if (whichClick == WhichClick.Previous)
				{
					if (ItemCounter <= 0)
					{
						pieceName = "0. L Tetra Cube";
						theCube = new BitArray(LargeCube.NumCubes);
						theCube.SetAll(false);
					}
					else
					{
						pieceName = (String)lb.Items[ItemCounter - 1];
						theCube = somaPieces[ItemCounter - 1].Ba;
					}
				}
				else if (whichClick == WhichClick.Goto)
				{
					pieceName = (String)lb.Items[ItemCounter];
					theCube = somaPieces[ItemCounter].Ba;
				}
				else if (whichClick == WhichClick.Next)
				{
					pieceName = (String)lb.Items[ItemCounter];
					theCube = somaPieces[ItemCounter].Ba;
				}
				else if (whichClick == WhichClick.Select)
				{
					pieceName = (String)lb.Items[ItemCounter];
					theCube = somaPieces[ItemCounter].Ba;
				}
				else
				{
					throw new Exception("Error " + whichClick.ToString());
				}
			}

			// remove leading numbers
			int pos = pieceName.IndexOf(".");
			pieceName = pieceName.Substring(pos + 2);

			NameAndColor nameAndColor = namesAndColors2.Find(n => n.PieceName.Equals(pieceName));

			// e.g., "Left Tetra Cube"
			if (nameAndColor != null)
			{
				previousBa.Xor(theCube);
				for (int i = 0; i < previousBa.Length; i++)
				{
					if (previousBa[i])
					{
						cubeColors[i] = nameAndColor.PieceColor;
					}
				}

				NewMessage?.Invoke(this, new MessageEventArgs(pieceName, theCube, cubeColors, MessageEventArgs.WhichOp.Or));
				previousBa = theCube.DeepCopy();
			}
			// e.g., "Removing Left Screw Tetra Cube"
			else if (pieceName.Contains(RemovePiece))
			{
				previousBa.Xor(theCube);
				for (int i = 0; i < previousBa.Length; i++)
				{
					if (previousBa[i])
					{
						cubeColors[i] = Properties.Settings.Default.SmallCubeClearColor;
					}
				}

				if ((whichClick == WhichClick.Select) || (whichClick == WhichClick.Goto) || (whichClick == WhichClick.Previous))
				{
					NewMessage?.Invoke(this, new MessageEventArgs(pieceName, theCube, cubeColors, MessageEventArgs.WhichOp.Or));
				}
				// else Next button
				else if ((whichClick == WhichClick.Next))
				{
					NewMessage?.Invoke(this, new MessageEventArgs(pieceName, previousBa, cubeColors, MessageEventArgs.WhichOp.AndNot));
				}
				previousBa = theCube.DeepCopy();
			}
			else if (pieceName.Contains(FoundASolution))
			{
				; // done!
			}
			else
			{
				throw new Exception(String.Format("Unknown line {0} {1}", ItemCounter, somaPieces[ItemCounter].PieceName));
			}

			if (whichClick == WhichClick.Select)
			{
				ItemCounter++;
				lb.ScrollIntoView(ItemCounter == (somaPieces.Count - 1) ? somaPieces[ItemCounter].PieceName : somaPieces[ItemCounter + 1].PieceName);
			}
			else if ((whichClick == WhichClick.Goto) || (whichClick == WhichClick.Next))
			{
				ItemCounter++;
			}
			else if (whichClick == WhichClick.Previous)
			{
				;
			}
			lb.ScrollIntoView(ItemCounter == (somaPieces.Count - 1) ? somaPieces[ItemCounter].PieceName : somaPieces[ItemCounter + 1].PieceName);
			
			initializing = true;
			if ((whichClick == WhichClick.Goto) || (whichClick == WhichClick.Previous) || (whichClick == WhichClick.Next))
			{
				lb.SelectedIndex = ItemCounter;
			}
			initializing = false;

			lblItemNumber.Content = String.Format("Item Number: {0} of {1}", ItemCounter.ToString(), (somaPieces.Count -1));
			this.btnNext.IsEnabled = (ItemCounter != (somaPieces.Count - 1));
			btnPrevious.IsEnabled = (ItemCounter > 0);
		}

		void BtnPrevious_Click(object sender, RoutedEventArgs e)
		{
			whichClick = WhichClick.Previous;
			line = lbSolutions.SelectedIndex;
			btnPrevious.IsEnabled = (line != 0);
			Selected_Click(sender, e);
		}

		void BtnGoTo_Click(object sender, RoutedEventArgs e)
		{
			whichClick = WhichClick.Goto;
			if (Int32.TryParse(tbGoto.Text, out line))
			{
				if ((line >= 0) && (line < somaPieces.Count))
				{
					tbGoto.Background = new SolidColorBrush(Colors.White);
					Selected_Click(sender, e);
				}
				else
				{
					tbGoto.Background = new SolidColorBrush(Colors.Red);
				}
			}
			else
			{
				tbGoto.Background = new SolidColorBrush(Colors.Red);
			}
		}

		void BtnClose_Click(object sender, RoutedEventArgs e)
		{
			NewMessage?.Invoke(this, new MessageEventArgs("close", null, null, MessageEventArgs.WhichOp.None));
			this.Close();
		}
	}
}
