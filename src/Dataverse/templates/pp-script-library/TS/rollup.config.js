import commonjs from '@rollup/plugin-commonjs';
import typescript from '@rollup/plugin-typescript';
import { terser } from 'rollup-plugin-terser';
import resolve from '@rollup/plugin-node-resolve';
// import dts from 'rollup-plugin-dts';

export default [
    {
        input: [
            'index.ts'
        ],
        output: [
            {
                file: "bin/examplepublisherprefix_ExampleModuleName.js",
                format: 'umd',
                sourcemap: true,
                name: "ExampleModuleName"
            }
        ],
        plugins: [
            commonjs(),
            resolve({
                browser: true
            }),
            typescript({
                tsconfig: './tsconfig.json',
            }),
            terser()
        ],
    },
]