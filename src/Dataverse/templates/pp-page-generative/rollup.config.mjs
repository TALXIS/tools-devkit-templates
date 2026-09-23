import { readdir } from 'node:fs/promises';
import { basename, extname, resolve } from 'node:path';
import commonjs from '@rollup/plugin-commonjs';
import resolveNode from '@rollup/plugin-node-resolve';
import typescript from '@rollup/plugin-typescript';

const externalPackages = [
  'react',
  'react-dom',
  '@fluentui/react-components',
  '@fluentui/react-icons'
];

const isExternal = (id) => externalPackages.some((pkg) => id === pkg || id.startsWith(`${pkg}/`));

const rootFiles = await readdir('.', { withFileTypes: true });
const pageEntries = rootFiles
  .filter((entry) => entry.isFile() && extname(entry.name) === '.tsx')
  .map((entry) => {
    const pageName = basename(entry.name, '.tsx');

    return {
      input: resolve(entry.name),
      output: {
        file: `dist/${pageName}.js`,
        format: 'esm',
        sourcemap: true
      },
      external: isExternal,
      plugins: [
        commonjs(),
        resolveNode({ browser: true }),
        typescript({ tsconfig: './tsconfig.json' })
      ]
    };
  });

if (pageEntries.length === 0) {
  throw new Error('No GenPage entries found. Add at least one *.tsx file at the project root.');
}

export default pageEntries;
