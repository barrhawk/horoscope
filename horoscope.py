#!/usr/bin/env python3

import os
import sys
import shutil

def show_help(script_name):
  """Displays help information."""
  print(f"Usage: {script_name} [options] <output_filename>")
  print("Gather project files and metadata for analysis.")
  print("Options:")
  print("  -h, --help        Display this help message.")
  print("  -n, --name        Name the output file (default: project_files.txt).")
  print("  -f, --firebase     Include Firebase config files.")
  print("  -d, --dart        Analyze a Dart project instead of Python.")
  print("  -i, --install     Install this script to /usr/local/bin (requires sudo).")
  print("")
  print("Run this from your project's root directory.")

def main():
  """The main function to gather project files."""
  output_filename = "project_files.txt"
  include_firebase = False
  include_dart = False  # Now defaults to Python

  # Parse command-line options.
  i = 1
  while i < len(sys.argv):
    arg = sys.argv[i]
    if arg in ('-h', '--help'):
      show_help(sys.argv[0])
      sys.exit(0)
    elif arg in ('-n', '--name'):
      if i + 1 < len(sys.argv):
        output_filename = sys.argv[i + 1]
        i += 1
      else:
        print("Error: Missing filename after -n option.")
        show_help(sys.argv[0])
        sys.exit(1)
    elif arg in ('-f', '--firebase'):
      include_firebase = True
    elif arg in ('-d', '--dart'):  # Changed to -d for Dart
      include_dart = True
    elif arg in ('-i', '--install'):
      if os.geteuid() != 0:
        print('Error: Installation requires root privileges. Use sudo.')
        sys.exit(1)

      install_path = '/usr/local/bin'
      home_dir = os.environ.get('HOME')
      if home_dir and os.path.isdir(os.path.join(home_dir, '.local/bin')):
        install_path = os.path.join(home_dir, '.local/bin')
      script_path = os.path.join(install_path, 'gather_project_files')  # More descriptive name

      try:
        shutil.copy(sys.argv[0], script_path)
        os.chmod(script_path, 0o755)
        print(f'Script installed successfully to {script_path}')
      except Exception as e:
        print(f'Error during installation: {e}')
        sys.exit(1)
      sys.exit(0)
    else:
      print(f"Error: Invalid option: {arg}")
      show_help(sys.argv[0])
      sys.exit(1)
    i += 1

  os.makedirs(os.path.dirname(output_filename), exist_ok=True)

  with open(output_filename, 'w') as output_file:
    pass

  if include_dart:  # Logic adjusted for Dart
    try:
      with open('pubspec.yaml', 'r') as pubspec_file:
        pubspec_content = pubspec_file.read()
        project_name = next((line.split(':')[1].strip() for line in pubspec_content.splitlines() if line.startswith('name:')), None)
        project_description = next((line.split(':')[1].strip() for line in pubspec_content.splitlines() if line.startswith('description:')), None)
        output_file.write(f'Project Name: {project_name}\n')
        output_file.write(f'Description: {project_description}\n')
        output_file.write('---- pubspec.yaml ----\n')
        output_file.write(pubspec_content)
    except FileNotFoundError:
      print("Error: Cannot find pubspec.yaml. Are you in a Dart project directory?")
      sys.exit(1)
  else:
    # Check for Python "metadata" files
    for file_name in ('requirements.txt', 'setup.py', 'pyproject.toml'):
      try:
        with open(file_name, 'r') as f:
          with open(output_filename, 'a') as output_file:
            output_file.write(f'---- {file_name} ----\n')
            output_file.write(f.read())
      except FileNotFoundError:
        pass

  for root, _, files in os.walk('.'):
    for file in files:
      file_path = os.path.join(root, file)
      if (not include_dart and file_path.endswith('.py') or  # Python first
          include_dart and file_path.endswith('.dart') or
          include_dart and not '.' in file or
          include_firebase and ('firebase.json' in file_path or '.firebase.' in file_path)):
        with open(output_filename, 'a') as output_file:
          output_file.write(f'---- {file_path} ----\n')
          with open(file_path, 'r') as f:
            output_file.write(f.read())

  print(f'Output written to: {output_filename}')

if __name__ == "__main__":
  main()
