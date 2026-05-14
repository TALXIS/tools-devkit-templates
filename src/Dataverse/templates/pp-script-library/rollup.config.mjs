import commonjs from '@rollup/plugin-commonjs';
import typescript from '@rollup/plugin-typescript';
import resolve from '@rollup/plugin-node-resolve';

export default [
  {
    input: 'src/index.ts',
    output: [
      {
        file: 'build/examplelibraryname.js',
        format: 'umd',
        sourcemap: true,
        name: 'examplelibrarynamespace'
      }
    ],
    plugins: [
      commonjs(),
      resolve({
        browser: true
      }),
      typescript({
        tsconfig: './tsconfig.json'
      })
    ]
  }
]
