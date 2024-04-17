## HTMLの書き出し
※　v18以上のNode.jsがインストールされている環境で行ってください

#### １. 本レポジトリをクローンする
```
$ git clone https://github.com/med2rdf/interview-form.git
```
#### 2. `/app` に移動
```
$ cd app
```
#### 3. 依存パッケージ `node_mudules` のインストール
```
$ npm install
```
or
```
$ yarn install
```
#### 4. 静的ファイルの生成
```
$ npm run generate
```
or
```
$ yarn generate
```
app/配下に `ifv` ディレクトリが生成され、その中に静的ファイルが書き出されます。


## Nuxt 3 Minimal Starter

Look at the [Nuxt 3 documentation](https://nuxt.com/docs/getting-started/introduction) to learn more.

### Setup

Make sure to install the dependencies:

```bash
# npm
npm install

# pnpm
pnpm install

# yarn
yarn install

# bun
bun install
```

### Development Server

Start the development server on `http://localhost:3000`:

```bash
# npm
npm run dev

# pnpm
pnpm run dev

# yarn
yarn dev

# bun
bun run dev
```

### Production

Build the application for production:

```bash
# npm
npm run build

# pnpm
pnpm run build

# yarn
yarn build

# bun
bun run build
```

Locally preview production build:

```bash
# npm
npm run preview

# pnpm
pnpm run preview

# yarn
yarn preview

# bun
bun run preview
```

Check out the [deployment documentation](https://nuxt.com/docs/getting-started/deployment) for more information.
