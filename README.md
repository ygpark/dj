# Directory Jump (dj)

Directory Jump (dj) is a command-line utility that allows you to quickly navigate between directories in your terminal. It maintains a list of your frequently used directories, enabling you to jump to them with simple commands.

## Features

- Add directories to your jump list
- Remove directories from your jump list
- Jump to directories using index numbers
- Navigate to the next or previous directory in the list
- Save and load directory lists
- Clean the directory list

## Installation

1. Clone this repository:

   ```
   git clone https://github.com/ygpark/dj.git
   cd dj
   ```

2. Run the installation script:

   ```
   ./install.sh
   ```

3. Restart your terminal or run `source ~/.zshrc` (or `~/.bashrc` for Bash users) to apply the changes.

## Usage

- `dj`: Display the list of saved directories
- `dj [index]`: Jump to the directory at the specified index
- `dj add`: Add the current directory to the list
- `dj add [dir]`: Add the specified directory to the list
- `dj rm`: Remove the current directory from the list
- `dj rm [index]`: Remove the directory at the specified index from the list
- `dj next`: Jump to the next directory in the list
- `dj prev`: Jump to the previous directory in the list
- `dj save <filename>`: Save the current directory list to a file
- `dj load <filename>`: Load a directory list from a file
- `dj clean`: Clear the entire directory list
- `dj help`: Display usage information

## Examples

1. Add the current directory to the list:

   ```
   dj add
   ```

2. Jump to the third directory in the list:

   ```
   dj 3
   ```

3. Move to the next directory in the list:

   ```
   dj next
   ```

4. Save your current directory list:
   ```
   dj save my_dirs.txt
   ```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
