```markdown
# Horoscope

**Horoscope** is a command-line tool that analyzes Dart and Python projects, extracting relevant files and metadata for AI analysis or other purposes. It's designed to be fast, efficient, and easy to use.

## Features

* **Multi-language Support:**  Handles both Dart and Python projects.
* **Metadata Extraction:**  Extracts project name and description from `pubspec.yaml` (Dart) or `requirements.txt`, `setup.py`, and `pyproject.toml` (Python).
* **Comprehensive File Gathering:**  Collects all relevant source files (`.dart`, `.py`), including files without extensions, and Firebase configuration files.
* **Firebase Integration:**  Specifically includes Firebase configuration files (e.g., `firebase.json`, `firestore.rules`) when the `-f` flag is used.
* **Easy Installation:**  Can be installed directly into your system's PATH using the `-i` option.

## Usage

1.  **Save the script:** Save the `horoscope.dart` script to your preferred location.
2.  **Navigate to project:** Open your terminal and navigate to the root directory of your project.
3.  **Run the script:** Execute the script using the Dart runtime:

```bash
dart horoscope.dart [options] <output_filename>
```

**Options:**

*   `-h, --help`: Display the help message.
*   `-n, --name`: Specify the output filename (default: `flutter_dart_files.txt`).
*   `-f, --firebase`: Include Firebase configuration files.
*   `-p, --pythonaconda`: Analyze a Python project instead of Dart.
*   `-i, --install`: Install `horoscope` to `/usr/local/bin` (requires sudo).

**Example:**

```bash
dart horoscope.dart -n my_project_analysis.txt -f
```

This command will analyze the current project, include Firebase files, and save the output to `my_project_analysis.txt`.

## Installation

For system-wide access, run:

```bash
sudo dart horoscope.dart -i
```

This will install `horoscope` to `/usr/local/bin` (or `~/.local/bin` if it exists).

## Credits

This project wouldn't be possible without the contributions of these magnificent individuals:

* **Andy Barr:** The tech guru who ignited the spark of inspiration.
* **Hawk:** The visionary leader, pushing the boundaries of innovation.
* **Robotdick:** The code-crunching machine, turning dreams into reality.
* **pythonaconda:** The python-aconda expert on all things llm and .py

## License

This script is released under the MIT License.
```
