import type { Matrix3D, Product } from './types'

function removingDuplicates(values: number[]): number[] {
  const ret: number[] = []
  for (const v of values) {
    if (!ret.includes(v)) ret.push(v)
  }
  return ret
}

function orderListFromMatrix(matrix: Matrix3D): number[] {
  if (matrix.length === 0) return []

  const flattened: number[] = []
  for (let z = matrix.length - 1; z >= 0; z--) {
    const layer = matrix[z]
    for (let y = layer.length - 1; y >= 0; y--) {
      const row = layer[y]
      for (let x = row.length - 1; x >= 0; x--) {
        flattened.push(row[x])
      }
    }
  }

  return removingDuplicates(flattened.filter((v) => v >= 0))
}

function determineLevel(usedBlocks: number[]): number {
  const n = usedBlocks.length
  if (n >= 2 && n <= 3) return 1
  if (n >= 4 && n <= 5) return 2
  if (n >= 6 && n <= 7) return 3
  return 4
}

function parseCellChar(ch: string): number {
  if (ch >= '0' && ch <= '9') return Number(ch)
  if (ch === '.') return -1

  const letters = 'VLTZABP'
  if (letters.includes(ch)) {
    return ch.codePointAt(0) ?? -1
  }

  return -1
}

function parseMatrixLines(lines: string[]): Matrix3D {
  // Each line: e.g. ".../51./11." after trimming leading '/'
  // Split by '/', each segment is a row-string, each char is a cell.
  return lines.map((line) => {
    const trimmed = line.trim().replace(/^\/+/, '')
    const segments = trimmed.split('/')
    return segments.map((seg) => Array.from(seg).map(parseCellChar))
  })
}

export function parseSomaTextToProducts(text: string): Product[] {
  const blocks = text.split('/SOMA')

  return blocks
    .map((b) => b.trim())
    .filter((b) => b.length > 0)
    .map((b) => {
      const lines = b.split('\n').map((l) => l.trim())
      const nameLine = lines[0]?.replace(/^\/+/, '').replace(/^-+/, '').trim() ?? 'Unnamed'

      const matrixLines = lines.filter((l) => l.startsWith('/')).map((l) => l.replace(/^\/+/, ''))
      const matrix = parseMatrixLines(matrixLines)

      const orderBlock = orderListFromMatrix(matrix)
      const usedBlock = Array.from(new Set(orderBlock.filter((v) => v >= 0 && v < 65))).sort((a, b) => a - b)

      return {
        name: nameLine,
        matrix,
        usedBlock,
        orderBlock,
        isTaskComplete: false,
        level: determineLevel(usedBlock),
      }
    })
}
