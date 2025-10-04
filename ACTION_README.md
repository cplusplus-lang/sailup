# Setup Sailup Action

A reusable GitHub Action that builds and runs [sailup](https://github.com/sailup-dev/sailup) to install and manage development tools across different operating systems.

## Features

- **Cross-platform support**: Works on Ubuntu/Linux, macOS, and Windows
- **Automatic sailup build**: Clones and builds sailup from source
- **Extensible tool installation**: Install various development tools via parameters
- **Simple integration**: Easy to use in any GitHub Actions workflow

## Supported Tools

- **cppcheck**: Static code analyzer for C/C++
- *(More tools coming soon)*

## Usage

### Install cppcheck

```yaml
- name: Setup Sailup
  uses: sailup-dev/sailup/.github/actions/setup-sailup@main
  with:
    cppcheck: true
```

### Specify sailup version

```yaml
- name: Setup Sailup
  uses: sailup-dev/sailup/.github/actions/setup-sailup@main
  with:
    version: 'v1.0.0'  # or branch name, or 'latest'
    cppcheck: true
```

### Complete Workflow Example

```yaml
name: CI with Sailup

on: [push, pull_request]

jobs:
  static-analysis:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Sailup
        uses: sailup-dev/sailup/.github/actions/setup-sailup@main
        with:
          cppcheck: true

      - name: Run cppcheck
        run: cppcheck --enable=all --error-exitcode=1 src/
```

### Multi-platform Example

```yaml
name: Cross-Platform CI

on: [push, pull_request]

jobs:
  build:
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
    runs-on: ${{ matrix.os }}

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Sailup
        uses: sailup-dev/sailup/.github/actions/setup-sailup@main
        with:
          cppcheck: true

      - name: Run static analysis
        run: cppcheck --enable=all src/
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `version` | Version of sailup to use (tag, branch, or "latest") | No | `latest` |
| `cppcheck` | Install cppcheck static analyzer | No | `false` |

## Outputs

| Output | Description |
|--------|-------------|
| `sailup-path` | Path to the built sailup executable |

## How It Works

1. **Checkout**: Clones the sailup repository at the specified version
2. **Build**: Compiles sailup using CMake in Release mode
3. **Install Tools**: Runs sailup with the specified tool flags (e.g., `--install-cppcheck`)
4. **Cleanup**: Removes temporary build files

## Using as a Published Action

Once sailup is published to a repository, you can reference it directly:

```yaml
- name: Setup Sailup
  uses: sailup-dev/sailup-action@v1
  with:
    cppcheck: true
```

## Comparison with Other Actions

### vs. aminya/setup-cpp

While [aminya/setup-cpp](https://github.com/aminya/setup-cpp) is excellent for comprehensive C++ toolchain setup, **sailup** offers:

- Project-specific tool management
- Custom tool installation logic
- Extensibility for additional tools beyond C++
- Integration with your existing sailup CLI

Use **sailup** when you want consistent tool management across both local development and CI environments.

## Adding More Tools

To add support for more tools, simply:

1. Add a new CLI flag in `apps/main.cpp` (e.g., `--install-clang-format`)
2. Add a new input parameter in this action's `action.yml`
3. Add a step to run sailup with the new flag

Example for future tools:

```yaml
inputs:
  clang-format:
    description: 'Install clang-format code formatter'
    required: false
    default: 'false'

# In steps:
- name: Install clang-format
  if: ${{ inputs.clang-format == 'true' }}
  shell: bash
  run: |
    ${{ steps.build-sailup.outputs.sailup-path }} --install-clang-format
```

## Troubleshooting

### Build fails on Windows
- Ensure Visual Studio or MSVC build tools are available in the runner
- Check CMake compatibility with Windows generators

### Tool not found after installation
- Verify the tool's package manager installation is in the system PATH
- Some tools may require a shell restart or PATH refresh

## License

This action is part of the sailup project.
