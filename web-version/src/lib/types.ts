export type Matrix3D = number[][][]

export interface Product {
  name: string
  matrix: Matrix3D
  usedBlock: number[]
  orderBlock: number[]
  isTaskComplete: boolean
  level: number
}
