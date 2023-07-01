using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using SomaCubeLib;

namespace SomaCubeSolver
{
	class SomaCubeSolverMain
	{
		static void Main(string[] args)
		{
			SomaCubeSolver somaCubeSolver = new SomaCubeSolver();
			somaCubeSolver.FillHashTables();
			somaCubeSolver.BuildOrientationLists();
			somaCubeSolver.BackTrack(0);
			Console.WriteLine(somaCubeSolver.solutionCounter);
			somaCubeSolver.Finish();
			string javaFile = @"..\..\solutionsJava.txt";
			string cSharpFile = @"solutions.txt";
			string[] JavaResult = File.ReadAllLines(javaFile);
			string[] CSharpResult = File.ReadAllLines(cSharpFile);


			string[] JavaResult2 = new String[JavaResult.Length - 1];
			Array.Copy(JavaResult, 1, JavaResult2, 0, JavaResult.Length - 1);
			string[] CSharpResult2 = new String[JavaResult.Length - 1];
			Array.Copy(CSharpResult, 1, CSharpResult2, 0, CSharpResult.Length - 1);
			for (int ndx = 0; ndx < JavaResult2.Length; ndx++)
			{
				String str1 = JavaResult2[ndx];
				String str2 = CSharpResult2[ndx];
				if (!str1.Equals(str2))
				{
					Console.WriteLine("Error on line {0}", ndx);
					Environment.Exit(-1);
				}
			}
			Console.WriteLine("Files {0} and {1} are the same", Path.GetFullPath(javaFile), Path.GetFullPath(cSharpFile));
		}
	}

	public class SomaCubeSolver
	{
		private const string RemovePiece = SolutionFile.RemovePiece;
		public const string FoundASolution = SolutionFile.FoundASolution;
		private const string SolutionFileName = SolutionFile.SolutionFileName;
		public const int NumPieces = 7;
		public const int NumCubes = 27;

		public BitArray theCube { get; set; } // cumulative

		public static Dictionary<int, int[]> cubeCoordinate { get; set; }
		public static Dictionary<int, BitArray> cubeBinary { get; set; }
		private List<BitArray>[] pieceOrientationList { get; set; }
		public BitArray[] Solutions { get; set; }

		/// <summary>
		/// number of non-isomorph solutions
		/// </summary>
		public int solutionCounter { get; set; }

		public StreamWriter output { get; set; }
		public StreamWriter outputForWPF { get; set; }
		public int lineCounter { get; set; }
		public int[] results { get; set; }
		private static string[] pieceNames =
		{
			"L Tetra Cube",				// my #2
			"Branch Tetra Cube",		// my #7
			"Right Screw Tetra Cube",	// my #6
			"Left Screw Tetra Cube",	// my #5
			"S Tetra Cube",				// my #4
			"T Tetra Cube",				// my #3
			"L Tri Cube"				// my #1
		};

		public SomaCubeSolver()
		{
			theCube = new BitArray(NumCubes);
			cubeCoordinate = new Dictionary<int, int[]>();
			cubeBinary = new Dictionary<int, BitArray>();
			pieceOrientationList = new List<BitArray>[NumPieces];
			for (int i = 0; i < pieceOrientationList.Length; i++)
			{
				pieceOrientationList[i] = new List<BitArray>();
			}

			Solutions = new BitArray[NumPieces];
			solutionCounter = 0;
			output = new StreamWriter("solutions.txt");
			String now = String.Format("SomaCubeSolver {0}", DateTime.Now.ToLongDateString());
			output.WriteLine(now);

			string fullPath = String.Format("{0}{1}", SomaCubeLib.SolutionFile.GetDirectory(), SolutionFileName);
			outputForWPF = new StreamWriter(fullPath);

			results = new int[NumCubes + 1]; // + 1 because piece numbers, not indices
			lineCounter = 0;
		}

		public void FillHashTables()
		{
			#region doc
			// Small cube number to coordinate mapping. For example the small cube in the middle of the +X face is 10. That small
			// cube has coordinates +1, 0, 0, so we have cubeCoordinate.Add(10, new int[] { +1, +1,  0 });
			//
			//					   +Y
			//					   |
			//				 ______|________
			//				/|  8  |5   2  /|				  +Y				  +Y			   +Y				   +Y
			//			   / |17  14  11  / |				   |				   |			    |					|
			//			  /__26__23__20__/  |			   20  11  2			2  5  8			 8  17  26			26  23  20
			//			  |  |_ _ _ _ _ _|11______+X		   |				   |			    |				    |
			//			  |  26  23  20  |  /			   19  10  1   -Z		1  4  7----X	 7  16  25----+Z	25  22  19-----+X
			//			  |  25  22  19  | /				   |				   |			    |				    |
			//			  |  24  21  18  |/				   18   9  0			0  3  6			 6  15  24			24  21  18
			//			  |____/_________|
			//				  /
			//				+Z
			#endregion

			// Z = -1
			cubeCoordinate.Add( 0, new int[] { +1, -1, -1 });
			cubeCoordinate.Add( 1, new int[] { +1,  0, -1 });
			cubeCoordinate.Add( 2, new int[] { +1, +1, -1 });
			cubeCoordinate.Add( 3, new int[] {  0, -1, -1 });
			cubeCoordinate.Add( 4, new int[] {  0,  0, -1 });
			cubeCoordinate.Add( 5, new int[] {  0, +1, -1 });
			cubeCoordinate.Add( 6, new int[] { -1, -1, -1 });
			cubeCoordinate.Add( 7, new int[] { -1,  0, -1 });
			cubeCoordinate.Add( 8, new int[] { -1, +1, -1 });

			// z = 0
			cubeCoordinate.Add( 9, new int[] { +1, -1,  0 });
			cubeCoordinate.Add(10, new int[] { +1,  0,  0 });
			cubeCoordinate.Add(11, new int[] { +1, +1,  0 });
			cubeCoordinate.Add(12, new int[] {  0, -1,  0 });
			cubeCoordinate.Add(13, new int[] {  0,  0,  0 });
			cubeCoordinate.Add(14, new int[] {  0, +1,  0 });
			cubeCoordinate.Add(15, new int[] { -1, -1,  0 });
			cubeCoordinate.Add(16, new int[] { -1,  0,  0 });
			cubeCoordinate.Add(17, new int[] { -1, +1,  0 });

			// Z = +1
			cubeCoordinate.Add(18, new int[] { +1, -1, +1 });
			cubeCoordinate.Add(19, new int[] { +1,  0, +1 });
			cubeCoordinate.Add(20, new int[] { +1, +1, +1 });
			cubeCoordinate.Add(21, new int[] {  0, -1, +1 });
			cubeCoordinate.Add(22, new int[] {  0,  0, +1 });
			cubeCoordinate.Add(23, new int[] {  0, +1, +1 });
			cubeCoordinate.Add(24, new int[] { -1, -1, +1 });
			cubeCoordinate.Add(25, new int[] { -1,  0, +1 });
			cubeCoordinate.Add(26, new int[] { -1, +1, +1 });

			// Binary representation of Cubes
			BitArray cube;
			for (int i = 0; i < NumCubes; i++)
			{
				cube = new BitArray(NumCubes);
				cube.Set(i, true);
				cubeBinary.Add(i, cube);
			}
		}

		public void BuildOrientationLists()
		{
			// we start with the L Tetra Cube - that's why there is just one non-isomorphic orientation
			int[,,] LTetraCubeNonIsoOrient =
				{
					//      C               B           A          D
					// cube 6         cube 3       cube 0          cube 1
					{{-1, -1, -1}, { 0, -1, -1}, {+1, -1, -1}, {+1,  0, -1}},
				#region doc
				//          +Y
				//           |
				//         D | ----  -X
				//         C B A
				// Freedom of movement will be { 0, 1, 0 },that is we can move it up 1 at most and 0 in the x and z directions
				#endregion
				};

			int iLen1 = LTetraCubeNonIsoOrient.GetLength(0);
			System.Diagnostics.Debug.Assert(iLen1 == 1);
			int jLen1 = LTetraCubeNonIsoOrient.GetLength(1);
			System.Diagnostics.Debug.Assert(jLen1 == 4);
			int kLen1 = LTetraCubeNonIsoOrient.GetLength(2);
			System.Diagnostics.Debug.Assert(kLen1 == 3);
			int[][][] LTetraCube_b = Utility.Convert(LTetraCubeNonIsoOrient, iLen1, jLen1, kLen1);

			// Corresponding freedom movement for every orientation of Piece #1
			int[,] LTetraCubeFreedomOfMovement = { { 0, 1, 0 } };
			iLen1 = LTetraCubeFreedomOfMovement.GetLength(0);
			System.Diagnostics.Debug.Assert(iLen1 == 1);
			jLen1 = LTetraCubeFreedomOfMovement.GetLength(1);
			System.Diagnostics.Debug.Assert(jLen1 == 3);
			int[][] LTetraCubeFreedomOfMovement_b = Utility.Convert(LTetraCubeFreedomOfMovement, iLen1, jLen1);

			for (int i = 0; i < iLen1; i++)
			{
				FillPieceOrientationList(LTetraCube_b[i], LTetraCubeFreedomOfMovement_b[i], pieceOrientationList[0]);
			}

			int[,,] BranchTetraCubeNonIsoOrient =
					{{{ 0, -1, -1}, {-1, -1, -1}, {-1,  0, -1}, {-1, -1,  0}},
					 {{-1, -1, -1}, {-1,  0, -1}, { 0,  0, -1}, {-1,  0,  0}},
					 {{-1,  0, -1}, { 0,  0, -1}, { 0, -1, -1}, { 0,  0,  0}},
					 {{-1, -1, -1}, { 0, -1, -1}, { 0,  0, -1}, { 0, -1,  0}},
					 {{-1, -1, -1}, { 0, -1,  0}, {-1, -1,  0}, {-1,  0,  0}},
					 {{-1,  0, -1}, {-1, -1,  0}, {-1,  0,  0}, { 0,  0,  0}},
					 {{ 0,  0, -1}, {-1,  0,  0}, { 0,  0,  0}, { 0, -1,  0}},
					 {{ 0, -1, -1}, {-1, -1,  0}, { 0, -1,  0}, { 0,  0,  0}}};
			int iLen2 = BranchTetraCubeNonIsoOrient.GetLength(0);
			System.Diagnostics.Debug.Assert(iLen2 == 8);
			int jLen2 = BranchTetraCubeNonIsoOrient.GetLength(1);
			System.Diagnostics.Debug.Assert(jLen2 == 4);
			int kLen2 = BranchTetraCubeNonIsoOrient.GetLength(2);
			System.Diagnostics.Debug.Assert(kLen2 == 3);
			int[][][] BranchTetraCube_b = Utility.Convert(BranchTetraCubeNonIsoOrient, iLen2, jLen2, kLen2);

			int[,] BranchTetraCubeFreedomOfMovement = 
					{{1, 1, 1}, {1, 1, 1}, {1, 1, 1}, {1, 1, 1},
					 {1, 1, 1}, {1, 1, 1}, {1, 1, 1}, {1, 1, 1}};
			iLen2 = BranchTetraCubeFreedomOfMovement.GetLength(0);
			System.Diagnostics.Debug.Assert(iLen2 == 8);
			jLen2 = BranchTetraCubeFreedomOfMovement.GetLength(1);
			System.Diagnostics.Debug.Assert(jLen2 == 3);
			int[][] BranchTetraCubeFreedomOfMovement_b = Utility.Convert(BranchTetraCubeFreedomOfMovement, iLen2, jLen2);

			for (int i = 0; i < iLen2; i++)
			{
				FillPieceOrientationList(BranchTetraCube_b[i], BranchTetraCubeFreedomOfMovement_b[i], pieceOrientationList[1]);
			}
			System.Diagnostics.Debug.Assert(pieceOrientationList[1].Count == 64);
			
			int[,,] RightScrewTetraCubeNonIsoOrient =
				{{{ 0, -1, -1}, {-1, -1, -1}, {-1,  0, -1}, {-1,  0,  0}},
				 {{-1, -1, -1}, {-1,  0, -1}, { 0,  0, -1}, { 0,  0,  0}},
				 {{-1,  0, -1}, { 0,  0, -1}, { 0, -1, -1}, { 0, -1,  0}},
				 {{-1, -1, -1}, { 0, -1, -1}, { 0,  0, -1}, {-1, -1,  0}},
				 {{-1, -1,  0}, {-1,  0,  0}, {-1,  0, -1}, { 0,  0, -1}},
				 {{-1,  0,  0}, { 0,  0,  0}, { 0,  0, -1}, { 0, -1, -1}},
				 {{-1, -1, -1}, { 0, -1, -1}, { 0, -1,  0}, { 0,  0,  0}},
				 {{ 0, -1,  0}, {-1, -1,  0}, {-1, -1, -1}, {-1,  0, -1}},
				 {{-1, -1, -1}, {-1, -1,  0}, {-1,  0,  0}, { 0,  0,  0}},
				 {{-1,  0, -1}, {-1,  0,  0}, { 0,  0,  0}, { 0, -1,  0}},
				 {{ 0,  0, -1}, { 0,  0,  0}, { 0, -1,  0}, {-1, -1,  0}},
				 {{ 0, -1, -1}, { 0, -1,  0}, {-1, -1,  0}, {-1,  0,  0}}};
			int iLen3 = RightScrewTetraCubeNonIsoOrient.GetLength(0);
			System.Diagnostics.Debug.Assert(iLen3 == 12);
			int jLen3 = RightScrewTetraCubeNonIsoOrient.GetLength(1);
			System.Diagnostics.Debug.Assert(jLen3 == 4);
			int kLen3 = RightScrewTetraCubeNonIsoOrient.GetLength(2);
			System.Diagnostics.Debug.Assert(kLen3 == 3);
			int[][][] RightScrewTetraCube_b = Utility.Convert(RightScrewTetraCubeNonIsoOrient, iLen3, jLen3, kLen3);

			int[,] RightScrewTetraCubeFreedomOfMovement = 
							 {{1, 1, 1}, {1, 1, 1}, {1, 1, 1}, {1, 1, 1},
							  {1, 1, 1}, {1, 1, 1}, {1, 1, 1}, {1, 1, 1},
							  {1, 1, 1}, {1, 1, 1}, {1, 1, 1}, {1, 1, 1}};
			iLen3 = RightScrewTetraCubeFreedomOfMovement.GetLength(0);
			System.Diagnostics.Debug.Assert(iLen3 == 12);
			jLen3 = RightScrewTetraCubeFreedomOfMovement.GetLength(1);
			System.Diagnostics.Debug.Assert(jLen3 == 3);
			int[][] RightScrewTetraCubeFreedomOfMovement_b = Utility.Convert(RightScrewTetraCubeFreedomOfMovement, iLen3, jLen3);

			for (int i = 0; i < iLen3; i++)
			{
				FillPieceOrientationList(RightScrewTetraCube_b[i], RightScrewTetraCubeFreedomOfMovement_b[i], pieceOrientationList[2]);
			}
			System.Diagnostics.Debug.Assert(pieceOrientationList[2].Count == 96);

			int[,,] LeftScrewTetraCubeNonIsoOrient =
						{{{-1, -1, -1}, {-1,  0, -1}, { 0,  0, -1}, {-1, -1,  0}},
						 {{-1,  0, -1}, { 0,  0, -1}, { 0, -1, -1}, {-1,  0,  0}},
						 {{-1, -1, -1}, { 0, -1, -1}, { 0,  0, -1}, { 0,  0,  0}},
						 {{-1, -1, -1}, {-1,  0, -1}, { 0, -1, -1}, { 0, -1,  0}},
						 {{-1, -1, -1}, { 0, -1, -1}, {-1, -1,  0}, {-1,  0,  0}},
						 {{-1, -1, -1}, {-1,  0, -1}, {-1,  0,  0}, { 0,  0,  0}},
						 {{-1,  0, -1}, { 0,  0, -1}, { 0,  0,  0}, { 0, -1,  0}},
						 {{-1, -1,  0}, { 0, -1,  0}, { 0, -1, -1}, { 0,  0, -1}},
						 {{-1,  0, -1}, {-1,  0,  0}, {-1, -1,  0}, { 0, -1,  0}},
						 {{-1, -1,  0}, {-1,  0,  0}, { 0,  0,  0}, { 0,  0, -1}},
						 {{-1,  0,  0}, { 0,  0,  0}, { 0, -1,  0}, { 0, -1, -1}},
						 {{-1, -1, -1}, {-1, -1,  0}, { 0, -1,  0}, { 0,  0,  0}}};
			int iLen4 = LeftScrewTetraCubeNonIsoOrient.GetLength(0);
			System.Diagnostics.Debug.Assert(iLen4 == 12);
			int jLen4 = LeftScrewTetraCubeNonIsoOrient.GetLength(1);
			System.Diagnostics.Debug.Assert(jLen4 == 4);
			int kLen4 = LeftScrewTetraCubeNonIsoOrient.GetLength(2);
			System.Diagnostics.Debug.Assert(kLen4 == 3);
			int[][][] LeftScrewTetraCube_b = Utility.Convert(LeftScrewTetraCubeNonIsoOrient, iLen4, jLen4, kLen4);

			int[,] LeftScrewTetraCubeFreedomOfMovement = {{1, 1, 1}, {1, 1, 1}, {1, 1, 1}, {1, 1, 1},
							  {1, 1, 1}, {1, 1, 1}, {1, 1, 1}, {1, 1, 1},
							  {1, 1, 1}, {1, 1, 1}, {1, 1, 1}, {1, 1, 1}};
			iLen4 = LeftScrewTetraCubeFreedomOfMovement.GetLength(0);
			System.Diagnostics.Debug.Assert(iLen4 == 12);
			jLen4 = LeftScrewTetraCubeFreedomOfMovement.GetLength(1);
			System.Diagnostics.Debug.Assert(jLen4 == 3);
			int[][] LeftScrewTetraCubeFreedomOfMovement_b = Utility.Convert(LeftScrewTetraCubeFreedomOfMovement, iLen4, jLen4);

			for (int i = 0; i < iLen4; i++)
			{
				FillPieceOrientationList(LeftScrewTetraCube_b[i], LeftScrewTetraCubeFreedomOfMovement_b[i], pieceOrientationList[3]);
			}
			System.Diagnostics.Debug.Assert(pieceOrientationList[3].Count == 96);

			int[,,] STetraCubeNonIsoOrient =
						{{{ 0, -1, -1}, { 0,  0, -1}, {-1,  0, -1}, {-1, +1, -1}},
						 {{-1, -1, -1}, { 0, -1, -1}, { 0,  0, -1}, {+1,  0, -1}},
						 {{-1, -1, -1}, {-1,  0, -1}, {-1,  0,  0}, {-1, +1,  0}},
						 {{-1, -1, -1}, { 0, -1, -1}, { 0, -1,  0}, {+1, -1,  0}},
						 {{-1, -1,  0}, {-1,  0,  0}, {-1,  0, -1}, {-1, +1, -1}},
						 {{-1, -1,  0}, { 0, -1,  0}, { 0, -1, -1}, {+1, -1, -1}},
						 {{-1, -1, -1}, {-1, -1,  0}, {-1,  0,  0}, {-1,  0, +1}},
						 {{-1, -1, -1}, {-1, -1,  0}, { 0, -1,  0}, { 0, -1, +1}},
						 {{-1,  0, -1}, {-1,  0,  0}, {-1, -1,  0}, {-1, -1, +1}},
						 {{ 0, -1, -1}, { 0, -1,  0}, {-1, -1,  0}, {-1, -1, +1}},
						 {{-1, -1, -1}, {-1,  0, -1}, { 0,  0, -1}, { 0, +1, -1}},
						 {{-1,  0, -1}, { 0,  0, -1}, { 0, -1, -1}, {+1, -1, -1}}};
			int iLen5 = STetraCubeNonIsoOrient.GetLength(0);
			System.Diagnostics.Debug.Assert(iLen5 == 12);
			int jLen5 = STetraCubeNonIsoOrient.GetLength(1);
			System.Diagnostics.Debug.Assert(jLen5 == 4);
			int kLen5 = STetraCubeNonIsoOrient.GetLength(2);
			System.Diagnostics.Debug.Assert(kLen5 == 3);
			int[][][] STetraCube_b = Utility.Convert(STetraCubeNonIsoOrient, iLen5, jLen5, kLen5);

			int[,] STetraCubeFreedomOfMovement = 
							{{1, 0, 2}, {0, 1, 2},
							 {2, 0, 1}, {0, 2, 1},
							 {2, 0, 1}, {0, 2, 1},
							 {2, 1, 0}, {1, 2, 0},
							 {2, 1, 0}, {1, 2, 0},
							 {1, 0, 2}, {0, 1, 2}};
			iLen5 = STetraCubeFreedomOfMovement.GetLength(0);
			System.Diagnostics.Debug.Assert(iLen5 == 12);
			jLen5 = STetraCubeFreedomOfMovement.GetLength(1);
			System.Diagnostics.Debug.Assert(jLen5 == 3);
			int[][] STetraCubeFreedomOfMovement_b = Utility.Convert(STetraCubeFreedomOfMovement, iLen5, jLen5);

			for (int i = 0; i < iLen5; i++)
			{
				FillPieceOrientationList(STetraCube_b[i], STetraCubeFreedomOfMovement_b[i], pieceOrientationList[4]);
			}
			System.Diagnostics.Debug.Assert(pieceOrientationList[4].Count == 72);

			int[,,] TTetraCubeNonIsoOrient =
				{
				//      D             B             A             C
				//   cube 4        cube 1        cube 2        cube 0
				 {{ 0,  0, -1}, {+1,  0, -1}, {+1, +1, -1}, {+1, -1, -1}}, // case 1 Z=-1
#region doc
				//          +Y
				//           |
				//         A |
				//         B D---  -X
				//         C
				// Freedom of movement will be {-1,  0, +2}
#endregion

				 //    A                 B           C               D
				 // cube 6            cube 3       cube 0       cube 4
				 {{-1, -1, -1}, { 0, -1, -1}, {+1, -1, -1}, { 0,  0, -1}}, // case 2 Z=-1
#region doc
				//          +Y
				//           |
				//           D---  -X
				//         A B C
				// Freedom of movement will be { 0, +1, +2}
#endregion

				 //     A             B             C             D
				 // cube 5          cube 4        cube 3       cube 1
				 {{ 0, +1, -1}, { 0,  0, -1}, { 0, -1, -1}, {+1,  0, -1}}, // case 3 Z=-1
#region doc
				//          +Y
				//           |
				//           A
				//         D B--  -X
				//           C
				// Freedom of movement will be {-1,  0, +2}
#endregion

				 //     C             B             A             D
				 // cube 7         cube 4      cube 1          cube 3 
				 {{-1,  0, -1}, { 0,  0, -1}, {+1,  0, -1}, { 0, -1, -1}}, // case 4 Z=-1
#region doc
				//          +Y
				//           |
				//         C B-A-  +X
				//           D
#endregion

				 //     C            B              A               D
				 // cube 0    cube 1              cube 2          cube 10
				 {{+1, -1, -1}, {+1,  0, -1}, {+1, +1, -1}, {+1,  0,  0}}, // case 5 X=-1
#region doc
				//          +Y
				//           |
				//           | A
				//           D B---  -Z
				//             C
#endregion

				 //     A             B             C             D
				 //    cube 6     cube 3          cube 0          cube 12
				 {{-1, -1, -1}, { 0, -1, -1}, {+1, -1, -1}, { 0, -1,  0}}, // case 6  Y=-1
#region doc
				//          -Z
				//           |
				//         A B C
				//           D-----  +X
				//         C
#endregion

				 //     D             A             B             C
				 {{ 0, -1, -1}, {-1, -1,  0}, { 0, -1,  0}, {+1, -1,  0}}, // case 7   Y=-1
#region doc
				//          -Z
				//           |
				//           D
				//         A B C---  +X
#endregion

				 //     D             C             B             A
				 {{-1,  0, -1}, {-1, -1,  0}, {-1,  0,  0}, {-1, +1,  0}}, // case 8  X=-1
#region doc
				//          +Y
				//           |
				//           A
				//           B D---  -Z
				//...........C
#endregion

				 {{-1, -1, -1}, {-1, -1,  0}, {-1, -1, +1}, {-1,  0,  0}}, // case 9   X=-1
				 {{-1, -1, -1}, {-1, -1,  0}, {-1, -1, +1}, { 0, -1,  0}}, // case 10  Y=-1
				 {{-1,  0, -1}, {-1,  0,  0}, {-1,  0, +1}, {-1, -1,  0}}, // case 11  X=-1
				 {{ 0, -1, -1}, { 0, -1, 0 }, { 0, -1, +1}, {-1, -1,  0}}  // case 12  Y=-1
			};

			int iLen6 = TTetraCubeNonIsoOrient.GetLength(0);
			System.Diagnostics.Debug.Assert(iLen6 == 12);
			int jLen6 = TTetraCubeNonIsoOrient.GetLength(1);
			System.Diagnostics.Debug.Assert(jLen6 == 4);
			int kLen6 = TTetraCubeNonIsoOrient.GetLength(2);
			System.Diagnostics.Debug.Assert(kLen6 == 3);
			int[][][] TTetraCube_b = Utility.Convert(TTetraCubeNonIsoOrient, iLen6, jLen6, kLen6);

			int[,] TTetraCubeFreedomOfMovement = {{-1,  0, +2}, { 0, +1, +2}, {-1,  0, +2}, { 0, +1, +2},
							  {-2,  0, +1}, { 0, +2, +1}, { 0, +2, +1}, {+2,  0, +1},
							  { 2, +1,  0}, {+1, +2,  0}, {+2, +1,  0}, {+1, +2,  0}};
			iLen6 = TTetraCubeFreedomOfMovement.GetLength(0);
			System.Diagnostics.Debug.Assert(iLen6 == 12);
			jLen6 = TTetraCubeFreedomOfMovement.GetLength(1);
			System.Diagnostics.Debug.Assert(jLen6 == 3);
			int[][] TTetraCubeFreedomOfMovement_b = Utility.Convert(TTetraCubeFreedomOfMovement, iLen6, jLen6);

			for (int i = 0; i < iLen6; i++)
			{
				FillPieceOrientationList(TTetraCube_b[i], TTetraCubeFreedomOfMovement_b[i], pieceOrientationList[5]);
			}
			System.Diagnostics.Debug.Assert(pieceOrientationList[5].Count == 72);

			int[,,] LTriCubeNonIsoOrient =
							{{{-1,  0, -1}, {-1, -1, -1}, { 0, -1, -1}, { 0, -1, -1}},
							 {{-1, -1, -1}, {-1,  0, -1}, { 0,  0, -1}, { 0,  0, -1}},
							 {{-1,  0, -1}, { 0,  0, -1}, { 0, -1, -1}, { 0, -1, -1}},
							 {{-1, -1, -1}, { 0, -1, -1}, { 0,  0, -1}, { 0,  0, -1}},
							 {{-1, -1, -1}, {-1,  0, -1}, {-1,  0,  0}, {-1,  0,  0}},
							 {{-1, -1, -1}, { 0, -1, -1}, { 0, -1,  0}, { 0, -1,  0}},
							 {{-1,  0, -1}, {-1, -1, -1}, {-1, -1,  0}, {-1, -1,  0}},
							 {{-1, -1, -1}, { 0, -1, -1}, {-1, -1,  0}, {-1, -1,  0}},
							 {{-1, -1,  0}, {-1,  0,  0}, {-1,  0, -1}, {-1,  0, -1}},
							 {{-1, -1,  0}, { 0, -1,  0}, { 0, -1, -1}, { 0, -1, -1}},
							 {{-1, -1, -1}, {-1, -1,  0}, {-1,  0,  0}, {-1,  0,  0}},
							 {{-1, -1, -1}, {-1, -1,  0}, { 0, -1,  0}, { 0, -1,  0}}};
			int iLen7 = LTriCubeNonIsoOrient.GetLength(0);
			System.Diagnostics.Debug.Assert(iLen7 == 12);
			int jLen7 = LTriCubeNonIsoOrient.GetLength(1);
			System.Diagnostics.Debug.Assert(jLen7 == 4);
			int kLen7 = LTriCubeNonIsoOrient.GetLength(2);
			System.Diagnostics.Debug.Assert(kLen7 == 3);
			int[][][] LTriCube_b = Utility.Convert(LTriCubeNonIsoOrient, iLen7, jLen7, kLen7);

			int[,] LTriCubeFreedomOfMovement = {{1, 1, 2}, {1, 1, 2}, {1, 1, 2}, {1, 1, 2},
							  {2, 1, 1}, {1, 2, 1}, {2, 1, 1}, {1, 2, 1},
							  {2, 1, 1}, {1, 2, 1}, {2, 1, 1}, {1, 2, 1}};
			iLen7 = LTriCubeFreedomOfMovement.GetLength(0);
			System.Diagnostics.Debug.Assert(iLen7 == 12);
			jLen7 = LTriCubeFreedomOfMovement.GetLength(1);
			System.Diagnostics.Debug.Assert(jLen7 == 3);
			int[][] LTriCubeFreedomOfMovement_b = Utility.Convert(LTriCubeFreedomOfMovement, iLen7, jLen7);

			for (int i = 0; i < iLen7; i++)
			{
				FillPieceOrientationList(LTriCube_b[i], LTriCubeFreedomOfMovement_b[i], pieceOrientationList[6]);
			}
			System.Diagnostics.Debug.Assert(pieceOrientationList[6].Count == 144);
		}

		/// <summary>
		/// Find all of the possiblities for a specific orientation
		/// </summary>
		/// <param name="pieceOrient"></param>
		/// <param name="freedomOfMovement"></param>
		/// <param name="pieceOrientList"></param>
		private void FillPieceOrientationList(int[][] pieceOrient, int[] freedomOfMovement, List<BitArray> pieceOrientList)
		{
			int[] factors = { 1, 1, 1 };
			int[][] temp = new int[4][];
			for (int i = 0; i < 4; i++) temp[i] = new int[3];
			bool Matched = true;
			BitArray currentCubeBits = new BitArray(NumCubes);

			for (int i = 0; i <= 2; i++)
			{
				if (freedomOfMovement[i] != 0)
				{
					factors[i] = freedomOfMovement[i] / Math.Abs(freedomOfMovement[i]);
				}
			}

			for (int i = 0; factors[0] * i <= Math.Abs(freedomOfMovement[0]); i = i + factors[0])
			{
				for (int j = 0; factors[1] * j <= Math.Abs(freedomOfMovement[1]); j = j + factors[1])
				{
					for (int k = 0; factors[2] * k <= Math.Abs(freedomOfMovement[2]); k = k + factors[2])
					{
						for (int s = 0; s <= 3; s++)
						{
							temp[s][0] = i + pieceOrient[s][0];
							temp[s][1] = j + pieceOrient[s][1];
							temp[s][2] = k + pieceOrient[s][2];
						}
						currentCubeBits = new BitArray(NumCubes);
						currentCubeBits.SetAll(false);
						for (int z = 0; z <= 3; z++)
						{
							foreach (KeyValuePair<int, int[]> kvp in cubeCoordinate)
							{
								if (Matched)
								{
									int[] array = kvp.Value;

									// if this is a coordinate of the cube
									if ((temp[z][0] == array[0]) && (temp[z][1] == array[1]) && (temp[z][2] == array[2]))
									{
										BitArray cubeBits = (BitArray)cubeBinary[kvp.Key];
										currentCubeBits.Or(cubeBits);
										Matched = false;
									}
								}
							}
							Matched = true;
						}
						pieceOrientList.Add(currentCubeBits);
					}
				}
			}
		}

		/// <summary>
		/// Main part of the algorithm - places the pieces
		/// </summary>
		/// <param name="pieceNdx"></param>
		public void BackTrack(int pieceNdx)
		{
			BitArray tempCube = new BitArray(NumCubes);
			BitArray tempPiece = new BitArray(NumCubes);
			int f = 0;

			tempCube.SetAll(false);
			tempPiece.SetAll(false);

			foreach (BitArray ba in pieceOrientationList[pieceNdx])
			{
				tempPiece = ba;
				Solutions[pieceNdx] = tempPiece;
				tempCube = (BitArray) theCube.DeepCopy();
				tempCube.And(tempPiece);

				// if the cube is empty, that is, if we can place this piece
				if (tempCube.IsEmpty())
				{
					// add the piece to the cube
					theCube.Or(tempPiece);

					if (outputForWPF != null)
					{
						String str = String.Format("{0}. {1}; {2}", lineCounter++, pieceNames[pieceNdx], theCube.ToStringJavaZeroBased());
						outputForWPF.WriteLine(str);
					}

					// if we got to the last piece, it's a solution- output it to solution file
					if (pieceNdx == (NumPieces - 1))
					{
						if (outputForWPF != null)
						{
							String str2 = String.Format("{0}. {1}; {2}", lineCounter++, FoundASolution, theCube.ToStringJavaZeroBased());
							outputForWPF.WriteLine(str2);
							if ((solutionCounter + 1) == Properties.Settings.Default.NumberOfSolutions)
							{
								outputForWPF.Close();
								outputForWPF = null;
							}
						}

						solutionCounter++;
						String Sol = String.Empty;
						Sol += "--------------------------------------------------\n";
						Sol += "Solution #"+ solutionCounter +" :\n";

						for (int pieceIndex = 0; pieceIndex < NumPieces; pieceIndex++)
						{
							for (int y = Solutions[pieceIndex].NextSetBit(0); y >= 0; y = Solutions[pieceIndex].NextSetBit(y/* + 1*/))
							{
								results[y] = pieceIndex + 1; // add 1 to piece index to get piece number
							}
						}

						for (int u = 0; u < 3; u++){
							switch (u) {
							case 0:  Sol += "----Bottom Surface----\n"; break;
							case 1:  Sol += "----Middle Surface----\n"; break;
							default: Sol += "----Top Surface----\n";break;
							}

							Sol += "|--" + results[7 + 9 * u] + "--|--" + results[8 + 9 * u] + "--|--"+results[9 + 9 * u]+ "--|\n";
							Sol += "|--" + results[4 + 9 * u] + "--|--" + results[5 + 9 * u] + "--|--"+results[6 + 9 * u]+ "--|\n";
							Sol += "|--" + results[1 + 9 * u] + "--|--" + results[2 + 9 * u] + "--|--"+results[3 + 9 * u]+ "--|\n";
						}

						Sol += "\n";
						Sol += "Piece# x: {Occupied cubes by each piece!}\n";
						for(int i = 0; i <= 6; i++){
							f = i + 1;
							Sol += "Piece# " + f +": " + Solutions[i].ToStringJava() + ",\n";
						}	
						output.Write(Sol);
					}
					else
					{
						BackTrack(pieceNdx + 1); // recursive call
					}

					theCube.AndNot(tempPiece); // remove the piece

					if (outputForWPF != null)
					{
						String str3 = String.Format("{0} {1}", RemovePiece, pieceNames[pieceNdx]);
						outputForWPF.WriteLine("{0}. {1}; {2}", lineCounter++, str3, theCube.ToStringJavaZeroBased());
					}
				}
				// else the cube is not empty
				else
				{
					// debug Console.WriteLine("temp cube is not empty");
				}

			}
			// debug Console.WriteLine("we have exhausted all of the possible solutions for piece {0} (returning...)", pieceNames[pieceNdx]);
		}

		public void Finish()
		{
			output.Close();
		}
	}
}