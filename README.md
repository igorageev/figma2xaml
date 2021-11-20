# Figma2xaml

This plugin can help you convert simple vector paths to xaml (eXtensible Application Markup Language).

https://www.figma.com/community/plugin/1029415284789228817/Figma2xaml

![image](promo/banner-figma2xaml.png)

This boilerplate using for creating plugin:
https://github.com/thomas-lowry/figsvelte

## Usage

1. Select the required code format from the dropdown menu
2. Select only one layer with frame, group, component or instance
3. Press `Get code`  and then `Copy` button
4. Use the code in Visual Studio for example to create Resource Dictionary

## Supported features:

https://github.com/igorageev/figma2xaml/wiki/Supported-features

## Installation and contributing

1. Clone the repository: `git clone https://github.com/igorageev/figma2xaml.git`
2. Go to the directory: `cd figma2xaml`
3. Install the packages: `npm install`
5. Add a new development plugin to Figma
6. Select the `figma2xaml/build/manifest.json` file as the manifest

## Development

During development, watch your project for changes with the following command:

```bash
npm run dev
```

Start editing plugin UI in `'src/Plugin.svelte'`.

## Build

When ready to package:

```bash
npm run build
```

_For info about Figma API visit [Figma API Overview](https://www.figma.com/plugin-docs/api/api-overview/)_
