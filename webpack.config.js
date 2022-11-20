const glob = require("glob");
const path = require("path");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const { WebpackManifestPlugin } = require("webpack-manifest-plugin");

console.log(__dirname);
const context = path.join(__dirname, "frontend", "packs");
console.log("context", context);
const targets = glob.sync(path.join(context, "**/*.{js,jsx,ts,tsx}"));
console.log("target", targets);

const entries = targets.reduce((entry, target) => {
  const bundle = path.relative(context, target);
  const ext = path.extname(bundle);

  return {
    ...entry,
    [bundle.replace(ext, "")]: `./${bundle}`,
  };
}, {});

console.log(entries);

module.exports = {
  mode: "development",
  context,
  entry: entries,
  output: {
    path: path.resolve(__dirname, "public/packs"),
    filename: "js/[name]-[chunkhash].js",
    chunkFilename: "js/[name].chunkFilename-[chunkhash].js",
    publicPath: "/packs/",
  },
  module: {
    rules: [
      {
        test: /\.(css|scss|sass)$/,
        use: [
          MiniCssExtractPlugin.loader,
          "css-loader",
          {
            loader: "postcss-loader",
          },
          {
            loader: "sass-loader",
            options: {
              implementation: require("sass"),
              sassOptions: {
                fiber: false,
              },
            },
          },
        ],
      },
    ],
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: "css/[name]-[contenthash].css",
      chunkFilename: "css/[name]-[contenthash].chunk.css",
    }),
    new WebpackManifestPlugin({
      filename: "manifest.json",
      publicPath: "/packs/",
      writeToFileEmit: true,
    }),
  ],
  devServer: {
    static: {
      directory: path.resolve(__dirname, "public/packs"),
      publicPath: "/packs/",
    },
    host: "0.0.0.0",
    port: process.env.WEBPACK_DEV_SERVER_PORT || 3305,
    hot: false,
    headers: {
      "Access-Control-Allow-Origin": "*",
    },
  },
};
