using System;
using System.Collections;
using System.Text;
using System.Windows.Media.Media3D;  // E:\Program Files\Reference Assemblies\Microsoft\Framework\.NETFramework\v4.5.2\PresentationCore.dll !!

namespace SomaCubeLib
{
	public static class ExtensionMethods
	{
		/// <summary>
		/// Normalizes vector (extension method alternative to vector.Normalize())
		/// </summary>
		/// <param name="vector"></param>
		/// <returns>normalized vector</returns>
		public static Vector3D Normalize2(this Vector3D vector)
		{
			if (vector.Length == 0.0) return vector;
			Vector3D vnorm = new Vector3D(vector.X / vector.Length, vector.Y / vector.Length, vector.Z / vector.Length);
			return vnorm;
		}

		public static string ToStringWithSpaces(this BitArray bits)
		{
			var sb = new StringBuilder();
			int spacing = 3;

			for (int i = 0; i < bits.Count; i++)
			{
				char c = bits[i] ? '1' : '0';
				sb.Append(c);

				if (((i + 1) % spacing) == 0)
				{
					sb.Append(" ");
				}
			}

			return sb.ToString();
		}

		public static string ToStringCommaSeparated(this BitArray bits)
		{
			var sb = new StringBuilder();

			for (int i = 0; i < bits.Count; i++)
			{
				char c = bits[i] ? '1' : '0';
				sb.Append(c);
				sb.Append(",");
			}

			String str = sb.ToString();
			int pos = str.LastIndexOf(",");
			str = str.Remove(pos, 1);

			return str;
		}

		// e.g., {3, 6, 14, 15}
		public static string ToStringJava(this BitArray bits)
		{
			StringBuilder sb = new StringBuilder();
			sb.Append("{");

			for (int i = 0; i < bits.Count; i++)
			{
				if (bits[i])
				{
					sb.Append((i + 1).ToString());
					sb.Append(", ");
				}
			}
			String str = sb.ToString();
			int pos = str.LastIndexOf(",");
			if (pos > 0)
			{
				str = str.Remove(pos, 1);
				pos = str.LastIndexOf(" ");
				str = str.Remove(pos, 1);
			}
			str = str + "}";

			return str;
		}

		public static string ToStringJavaZeroBased(this BitArray bits)
		{
			StringBuilder sb = new StringBuilder();
			sb.Append("{");

			for (int i = 0; i < bits.Count; i++)
			{
				if (bits[i])
				{
					sb.Append((i + 0).ToString("d2"));
					sb.Append(", ");
				}
				else
				{
					sb.Append("  , ");
				}
			}
			String str = sb.ToString();
			int pos = str.LastIndexOf(",");
			if (pos > 0)
			{
				str = str.Remove(pos, 1);
				pos = str.LastIndexOf(" ");
				str = str.Remove(pos, 1);
			}
			str = str + "}";

			return str;
		}

		/// <summary>
		/// Returns the index of the next true bit
		/// if there are none, -1 is returned
		/// </summary>
		/// <param name="from">the start location</param>
		/// <returns>the first true bit, or -1</returns>
		public static int NextSetBit(this BitArray bits, int from)
		{
			int offset = from;
			while (offset < bits.Length)
			{
				bool h = bits[offset];
				if (h)
				{
					return from + 1;
				}
				from++;
				offset++;
			}

			return -1;
		}

		/// <summary>
		/// Returns true if this set contains no true bits
		/// </summary>
		/// <returns>true if all bits are false</returns>
		public static bool IsEmpty(this BitArray bits)
		{
			for (int i = bits.Length - 1; i >= 0; i--)
			{
				if (bits[i])
					return false;
			}
			return true;
		}

		public static BitArray DeepCopy(this BitArray bits)
		{
			BitArray ba = new BitArray(bits.Length);
			for (int i = 0; i < bits.Length; i++)
			{
				ba[i] = bits[i];
			}
			return ba;
		}

		public static void Set(this BitArray bits, String bitstring)
		{
			bitstring = bitstring.Replace(" ", "");
			for (int i = 0; i < bitstring.Length; i++)
			{
				char ch = bitstring[i];
				{
					bits.Set(i, (ch.Equals('1')));
				}
			}
		}

		// {00, 01,   , 03, 04,   , 06, 07, 08,   ,   , 11, 12, 13, 14, 15, 16, 17,   ,   ,   ,   , 22,   , 24,   ,   }
		public static void SetFromJavaStringZeroBased(this BitArray bits, String bitstring)
		{
			bits.SetAll(false);
			bitstring = bitstring.Replace(" ", "");
			bitstring = bitstring.Replace("{", "");
			bitstring = bitstring.Replace("}", "");

			string[] str = bitstring.Split(new char[] { ',' });

			for (int i = 0; i < str.Length; i++)
			{
				if (str[i].Length != 0)
				{
					int num = Int32.Parse(str[i]);
					bits[num] = true;
				}
			}
		}

		// 7FFFFFF  111111111111111111111111111
		//  ACACAC  000101011001010110010101100
		public static string GetHexValue(this BitArray bits)
		{
			Int32 hexValue = 0;
			for (int i = 0; i < bits.Length; i++)
			{
				if (bits[i])
				{
					hexValue += (int)Math.Pow(2.0, 26 - i);
				}
			}

			return hexValue.ToString("X");
		}

		/// <summary>
		/// Performs the logical AND operation on this bit set and the complement of the given <code>bs</code>. 
		/// This means it selects every element in the first set, that isn't in the second set. The result is
		/// stored into this bit set and is effectively the set difference of the two.
		/// </summary>
		/// <param name="bs">the second bit set</param>
		public static void AndNot(this BitArray bits, BitArray bs)
		{
			for (int i = 0; i < bits.Length; i++)
			{
				bits[i] &= !bs[i];
			}
		}

		public static bool EqualValues(this BitArray bits1, BitArray bits2)
		{
			for (int i = 0; i < bits1.Length; i++)
			{
				if (bits1[i] != bits2[i])
				{
					return false;
				}
			}

			return true;
		}

		public static void SetBits(this BitArray bits1, int[] bits2)
		{
			for (int i = 0; i < bits1.Length; i++)
			{
				if (bits2[i] == 1)
				{
					bits1[i] = true;
				}
				else if (bits2[i] == 0)
				{
					bits1[i] = false;
				}
			}
		}
	}
}

