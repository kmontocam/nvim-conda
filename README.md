# nvim-conda

Conda manager for Neovim: seamlessly activate environments and enhance your
workflow. All powered by Lua.

## Table of contents

- [Introduction](#introduction)
- [Requirements](#requirements)
- [Installation](#installation)
- [Commands](#commands)
- [Contributing](#contributing)

[comment]: <> (Include [Suggested configuration])

## Introduction

[comment]: <> (Include :h nvim-conda)

`nvim-conda` allows you to work with the
[conda](https://docs.conda.io/en/latest/) package manager inside a Neovim
session. Switch back and forth between conda environments and keep your LSP
client up to date with a single command. Enjoy a smooth experience across all
[conda supported shells](https://docs.conda.io/projects/conda/en/latest/dev-guide/deep-dives/activation.html)
in Linux, macOS and Windows with minimal
[external requirements](#external-requirements).

There is no need to specify the conda `PATH`, nor have an active `python` client
in the shell. For most systems and Neovim configurations, it is a plug and
play experience — no additional configurations required.

## Requirements

[comment]: <> (Include :h nvim-conda-requirements)

`nvim-conda` leverages the user's shell to perform the core conda procedures.
The required programs and dependencies are:

- Neovim `>= 0.9.0`
- Anaconda or Miniconda `>=4.6`. Make sure the `conda` command is accesible in
  the running subshell inside Neovim
- `sed(1)`, included in macOS and most Linux distributions. If you are using a
  Windows system, this is not neccesary as long as you have `PowerShell`
  installed
- Dependency [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim)

Note: while executing `conda init` in the client's shell is not a mandatory step to
activate a conda environment within Neovim, it is strongly recommended for
enhanced system functionality.

## Installation

Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug "nvim-lua/plenary.nvim"
Plug "kmontocam/nvim-conda"
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use ({
    "kmontocam/nvim-conda",
    requires = { "nvim-lua/plenary.nvim" },
})
```

Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
return {
	"kmontocam/nvim-conda",
	dependencies = { "nvim-lua/plenary.nvim" },
    }
```

[comment]: <> (Suggested configuration)
[comment]: <> (Define default configuration)

## Commands

[comment]: <> (Include :h nvim-conda-commands)
[comment]: <> (Include `:CondaActivate`)

- `:CondaActivate` - lists conda environments in menu and activates selected
- `:CondaActivate <env_name>` - activates the given conda environment
- `:CondaDeactivate` - deactivates the active conda environment

## Contributing

The project is currently in a beta stage. It would be greatly appreciated to
receive feedback, suggestions and assistance in implementing additional
features, documentation and making necessary fixes.
