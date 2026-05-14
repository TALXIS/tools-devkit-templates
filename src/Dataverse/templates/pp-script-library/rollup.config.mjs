import commonjs from '@rollup/plugin-commonjs';
import typescript from '@rollup/plugin-typescript';
import resolve from '@rollup/plugin-node-resolve';

export default [
  {
    input: 'src/index.ts',
    output: [
      {
        file: 'build/__publisher-prefix_____library-name__.js',
        format: 'umd',
        sourcemap: true,
        name: '__publisher-prefix_____library-name__'
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
