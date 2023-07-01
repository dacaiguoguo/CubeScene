using System;
using System.IO;

namespace SomaCubeLib
{
	public static class SolutionFile
	{
		public const string RemovePiece = "Removing";
		public const string FoundASolution = "Found a solution";
		public const string SolutionFileName = "solutionAnimated.txt";

		public static String GetDirectory()
		{
			string path = Directory.GetCurrentDirectory();
			int pos = path.IndexOf("SomaCubeWPF2");
			string path2 = path.Substring(0, pos);

			return path2;
		}
	}
}
