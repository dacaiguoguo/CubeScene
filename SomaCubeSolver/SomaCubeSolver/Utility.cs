using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using SomaCubeLib;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SomaCubeSolver
{
	public static class Utility
	{
		static bool FileEquals(string path1, string path2)
		{
			byte[] file1 = File.ReadAllBytes(path1);
			byte[] file2 = File.ReadAllBytes(path2);
			if (file1.Length == file2.Length)
			{
				for (int i = 0; i < file1.Length; i++)
				{
					if (file1[i] != file2[i])
					{
						return false;
					}
				}
				return true;
			}
			return false;
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
