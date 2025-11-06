# User Directions

### Table of Contents
- [How to Install and Use](@ref how-to-install-use)
- [How to Seek Support](@ref how-to-seek-support)
- [How to Contribute](@ref how-to-contribute)
  - [Reporting Bugs](@ref reporting-bugs)
  - [Suggesting Enhancements](@ref suggesting-enhancements)
  - [Code Contribution](@ref code-contribution)
- [Pull Request Process](@ref pull-request-process)
- [License](@ref license)

## [How to Install and Use](@id how-to-install-use)

To install `OceanRobots.jl` in `julia` proceed as usual via the package manager (`using Pkg; Pkg.add("OceanRobots")`).

To run a notebook interactively (`.jl` files) you want to use [Pluto.jl](https://github.com/fonsp/Pluto.jl). For example, copy and paste one of the above `code link`s in the [Pluto.jl interface](https://github.com/fonsp/Pluto.jl/wiki/🔎-Basic-Commands-in-Pluto). This will let you spin up the notebook in a web browser from the copied URL.

All you need to do beforehand is to install [julia](https://julialang.org) and `Pluto.jl`. The installation of OceanRobots.jl and other Julia packages will then happen automatically when you run the notebook. 

You can also download the notebooks folder and run them as normal Julia programs. We recommend runing each notebook in its own environment as shown below. 

!!! note
    To download OceanRobots.jl folder, which includes the notebooks folder, you can use `Git.jl`.

```
using Pkg; Pkg.add("Git"); using Git
url="https://github.com/JuliaOcean/OceanRobots.jl"
run(`$(git()) clone $(url)`)
```

```@example 1
using Pkg; Pkg.add("Pluto"); using Pluto

notebook="examples/Float_Argo.jl"
import OceanRobots; path=dirname(dirname(pathof(OceanRobots))) #hide
notebook=joinpath(path,"examples","Float_Argo.jl") #hide
Pluto.activate_notebook_environment(notebook)
Pkg.instantiate()
include(notebook)
Pkg.activate("..") #hide
```

## [How to Seek Support](@id how-to-seek-support)

If something is unclear or proves difficult to use, please seek support by [opening an issue on the repository](https://github.com/juliaocean/OceanRobots.jl/issues).

## [How to Contribute](@id how-to-contribute)

Thank you for considering contributing to OceanRobots.jl! If you're interested in contributing we want your help no matter how big or small a contribution you make! 

### [Reporting Bugs](@id reporting-bugs)

If you encounter a bug, please help us fix it by following these steps:

1. Ensure the bug is not already reported by checking the [issue tracker](https://github.com/juliaocean/OceanRobots.jl/issues).
2. If the bug isn't reported, open a new issue. Clearly describe the issue, including steps to reproduce it.

### [Suggesting Enhancements](@id suggesting-enhancements)

If you have ideas for enhancements, new features, or improvements, we'd love to hear them! Follow these steps:

1. Check the [issue tracker](https://github.com/juliaocean/OceanRobots.jl/issues) to see if your suggestion has been discussed.
2. If not, open a new issue, providing a detailed description of your suggestion and the use case it addresses.

### [Code Contribution](@id code-contribution)

If you'd like to contribute code to the project:

1. Fork the repository.
2. Clone your fork: `git clone https://github.com/juliaocean/OceanRobots.jl`
3. Create a new branch for your changes: `git checkout -b feature-branch`
4. Make your changes and commit them with a clear message.
5. Push your changes to your fork: `git push origin feature-branch`
6. Open a pull request against the `master` branch of the main repository.


## [Pull Request Process](@id pull-request-process)

Please ensure your pull request follows these guidelines:

1. Adheres to the coding standards.
2. Includes relevant tests for new functionality.
3. Has a clear commit history and messages.
4. References the relevant issue if applicable.

Please don't hesistate to get in touch to discuss, or with any questions!

## [License](@id license)

By contributing to this project, you agree that your contributions will be licensed under the [LICENSE](https://github.com/juliaocean/OceanRobots.jl/blob/master/LICENSE) file of this repository.

