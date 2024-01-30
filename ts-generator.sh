#!/bin/bash

show_help() {
    echo "Usage: $0 <project_name>"
    echo "Creates a TypeScript project with the specified name."
    echo
    echo "Arguments:"
    echo "  <project_name>    Name of the project to be created."
    echo
    echo "Options:"
    echo "  -h, --help       Show this help message and exit."
}

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    show_help
    exit 0
fi

if [ "$#" -ne 1 ]; then
    echo "Error: Project name is required."
    show_help
    exit 1
fi

projectName=$1

if ! which node > /dev/null; then
    echo "Node.js is not installed. Please install Node.js first."
    exit 1
fi

if ! which npm > /dev/null; then
    echo "npm is not installed. Please install npm first."
    exit 1
fi

if ! which tsc > /dev/null; then
    echo "TypeScript is not installed globally. Installing..."
    npm install -g typescript
fi

mkdir "$projectName"
cd "$projectName"

npm init -y
npm install typescript ts-loader webpack webpack-cli webpack-dev-server --save-dev

cat <<EOT > tsconfig.json
{
  "compilerOptions": {
    "target": "es6",
    "module": "commonjs",
    "outDir": "./dist",
    "strict": true,
    "esModuleInterop": true
  },
  "include": ["src/**/*"]
}
EOT

mkdir src
echo "console.log('Hello, TypeScript');" > src/app.ts


cat <<EOT > index.html
<!DOCTYPE html>
<html>
<head>
    <title>$projectName</title>
</head>
<body>
<h1>$projectName</h1>
    <script src="main.js"></script>
</body>
</html>
EOT

cat <<EOT > webpack.config.js
const path = require('path');

module.exports = {
    mode: 'development',
    entry: './src/app.ts',
    devtool: 'inline-source-map',
    module: {
        rules: [
            {
                test: /\.ts$/,
                use: 'ts-loader',
                exclude: /node_modules/
            }
        ]
    },
    resolve: {
        extensions: ['.ts', '.js']
    },
    output: {
        filename: 'main.js',
        path: path.resolve(__dirname, 'dist')
    },
    devServer: {
        static: {
            directory: path.join(__dirname, '/'),
        },
        compress: true,
        port: 3000
    }
};

EOT


sed -i '' -e '/"scripts": {/a\
    "start": "webpack-dev-server",
' package.json


npm install
