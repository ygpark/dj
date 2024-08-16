#!/usr/bin/env python3
import os
import sys
import shutil

class DirectoryJump:
    def __init__(self):
        self.home_dir = os.path.expanduser("~")
        self.dj_home = os.path.join(self.home_dir, ".dj")
        self.dir_list_file = os.path.join(self.dj_home, "dirlist")
        self.temp_file = os.path.join(self.dj_home, "dirlist.tmp")
        self.save_file = os.path.join(self.dj_home, "dirlist.save")
        self.stack_file = os.path.join(self.dj_home, "dirlist.stack")

        os.makedirs(self.dj_home, exist_ok=True)
        if not os.path.exists(self.dir_list_file):
            open(self.dir_list_file, 'a').close()

    def print_usage(self):
        print("dj - Directory Jump")
        print()
        print("Usage:")
        print("    dj                 : print directories")
        print("    dj [index]         : change directory by index")
        print("    dj add             : add current directory")
        print("    dj add [dir]       : add directory")
        print("    dj rm              : remove current directory")
        print("    dj rm [index]      : remove directory by index")
        print("    dj save <filename> : save dir list into the file")
        print("    dj load <filename> : load dir list from the file")
        print("    dj clean           : clean the stack")
        print("    dj help            : print usage")
        print()

    def reload_only_exist_dir(self):
        with open(self.dir_list_file, 'r') as f:
            directories = f.readlines()
        
        valid_directories = [d.strip() for d in directories if os.path.isdir(d.strip())]
        
        with open(self.temp_file, 'w') as f:
            f.writelines(f"{d}\n" for d in valid_directories)
        
        shutil.move(self.temp_file, self.dir_list_file)

    def dirs(self):
        self.reload_only_exist_dir()
        with open(self.dir_list_file, 'r') as f:
            directories = f.readlines()
        
        if not directories:
            print("(empty stack. 'dj --help')")
            return

        current_dir = os.getcwd()
        for i, directory in enumerate(directories, 1):
            directory = directory.strip()
            if directory == current_dir:
                print(f"    \033[7m{i} {directory}\033[27m")
            else:
                print(f"    {i} {directory}")

    def add(self, directory="."):
        full_path = os.path.abspath(directory)
        if not os.path.isdir(full_path):
            print(f"Error: Invalid directory '{directory}'", file=sys.stderr)
            return 1

        with open(self.dir_list_file, 'a') as f:
            f.write(f"{full_path}\n")
        
        self.reload_only_exist_dir()
        
        with open(self.dir_list_file, 'r') as f:
            directories = sorted(set(f.readlines()))
        
        with open(self.temp_file, 'w') as f:
            f.writelines(directories)
        
        shutil.move(self.temp_file, self.dir_list_file)
        print(f"Added directory: {full_path}")

    def clean(self):
        open(self.dir_list_file, 'w').close()
        print("Directory list has been cleared.")

    def save(self, filename):
        self.reload_only_exist_dir()
        shutil.copy(self.dir_list_file, filename)
        print(f"Directory list saved to: {filename}")

    def load(self, filename):
        shutil.copy(filename, self.dir_list_file)
        self.reload_only_exist_dir()
        print(f"Directory list loaded from: {filename}")

    def rm(self, index=None):
        if index is None:
            self.rm_by_dirname(".")
        else:
            try:
                index = int(index)
            except ValueError:
                print("Error: Input must be a number", file=sys.stderr)
                self.print_usage()
                return

            self.reload_only_exist_dir()
            with open(self.dir_list_file, 'r') as f:
                directories = f.readlines()
            
            if 1 <= index <= len(directories):
                removed_dir = directories[index - 1].strip()
                del directories[index - 1]
                with open(self.temp_file, 'w') as f:
                    f.writelines(directories)
                shutil.move(self.temp_file, self.dir_list_file)
                print(f"Removed directory: {removed_dir}")
            else:
                print(f"Error: Invalid index {index}", file=sys.stderr)

    def rm_by_dirname(self, directory):
        full_path = os.path.abspath(directory)
        with open(self.dir_list_file, 'r') as f:
            directories = f.readlines()
        
        new_directories = [d for d in directories if d.strip() != full_path]
        
        if len(new_directories) < len(directories):
            with open(self.temp_file, 'w') as f:
                f.writelines(new_directories)
            shutil.move(self.temp_file, self.dir_list_file)
            print(f"Removed directory: {full_path}")
        else:
            print(f"Directory not found in the list: {full_path}")

    def next(self):
        self.reload_only_exist_dir()
        with open(self.dir_list_file, 'r') as f:
            directories = f.readlines()
        
        current_dir = os.getcwd()
        try:
            current_index = directories.index(current_dir + '\n')
            next_index = (current_index + 1) % len(directories)
            next_dir = directories[next_index].strip()
            print(f"Changing to next directory: {next_dir}")
            print(f"DJCHANGEDIR:{next_dir}")
        except ValueError:
            print("Current directory not in the list.")

    def prev(self):
        self.reload_only_exist_dir()
        with open(self.dir_list_file, 'r') as f:
            directories = f.readlines()
        
        current_dir = os.getcwd()
        try:
            current_index = directories.index(current_dir + '\n')
            prev_index = (current_index - 1) % len(directories)
            prev_dir = directories[prev_index].strip()
            print(f"Changing to previous directory: {prev_dir}")
            print(f"DJCHANGEDIR:{prev_dir}")
        except ValueError:
            print("Current directory not in the list.")

    def go(self, index):
        try:
            index = int(index)
        except ValueError:
            print("Error: Invalid input. Please provide a number.")
            self.print_usage()
            return

        self.reload_only_exist_dir()
        with open(self.dir_list_file, 'r') as f:
            directories = f.readlines()
        
        if 1 <= index <= len(directories):
            target_dir = directories[index - 1].strip()
            print(f"Changing directory to: {target_dir}")
            print(f"DJCHANGEDIR:{target_dir}")
        else:
            print(f"Error: Invalid index {index}")

    def run(self, args):
        if not args:
            self.dirs()
        elif args[0] == "help":
            self.print_usage()
        elif args[0] == "add":
            if len(args) > 2:
                self.print_usage()
            elif len(args) == 1:
                self.add()
            else:
                self.add(args[1])
        elif args[0] == "rm":
            if len(args) > 2:
                self.print_usage()
            elif len(args) == 1:
                self.rm()
            else:
                self.rm(args[1])
        elif args[0] == "next":
            if len(args) > 1:
                self.print_usage()
            else:
                self.next()
        elif args[0] == "prev":
            if len(args) > 1:
                self.print_usage()
            else:
                self.prev()
        elif args[0] == "clean":
            if len(args) > 1:
                self.print_usage()
            else:
                self.clean()
        elif args[0] == "save":
            if len(args) != 2:
                self.print_usage()
            else:
                self.save(args[1])
        elif args[0] == "load":
            if len(args) != 2:
                self.print_usage()
            else:
                self.load(args[1])
        else:
            self.go(args[0])

if __name__ == "__main__":
    dj = DirectoryJump()
    dj.run(sys.argv[1:])