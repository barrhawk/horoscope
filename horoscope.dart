#!/usr/bin/env dart

// Importing the necessary libraries for file and directory operations.
import 'dart:io';

// Function to display help information.
void showHelp(String scriptName) {
  print("Usage: $scriptName [options] <output_filename>");
  print("Gather project files and metadata for analysis.");
  print("Options:");
  print("  -h, --help         Display this help message.");
  print("  -n, --name         Name the output file (default: flutter_dart_files.txt).");
  print("  -f, --firebase     Include Firebase config files (if used).");
  print("  -p, --pythonaconda  Analyze a Python project instead of Dart.");
  print("  -i, --install      Install horoscope to /usr/local/bin (requires sudo).");
  print("");
  print("Run this from your project's root directory.");
}

void main(List<String> arguments) {
  // Default settings
  var outputFilename = "flutter_dart_files.txt";
  var includeFirebase = false;
  var includePython = false;

  // Parse command-line options.
  for (var i = 0; i < arguments.length; i++) {
    switch (arguments[i]) {
      case '-h':
      case '--help':
        showHelp(arguments[0]);
        exit(0);
      case '-n':
      case '--name':
        if (i + 1 < arguments.length) {
          outputFilename = arguments[i + 1];
          i++;
        } else {
          print("Error: Missing filename after -n option.");
          showHelp(arguments[0]);
          exit(1);
        }
        break;
      case '-f':
      case '--firebase':
        includeFirebase = true;
        break;
      case '-p':
      case '--pythonaconda':
        includePython = true;
        break;
      case '-i':
      case '--install':
        // Check for sudo privileges
        if (Platform.environment['USER'] != 'root') {
          print('Error: Installation requires root privileges. Use sudo.');
          exit(1);
        }

        // Determine the appropriate installation path
        var installPath = '/usr/local/bin'; // Default path
        var homeDir = Platform.environment['HOME'];
        if (homeDir != null && Directory('$homeDir/.local/bin').existsSync()) {
          installPath = '$homeDir/.local/bin'; // Prioritize user's local bin
        }
        var scriptPath = '$installPath/horoscope';

        try {
          File(Platform.script.toFilePath()).copySync(scriptPath);
          Process.runSync('chmod', ['+x', scriptPath]);
          print('Horoscope installed successfully to $scriptPath');
        } catch (e) {
          print('Error during installation: $e');
          exit(1);
        }
        exit(0); // Exit after installation
      default:
        print("Error: Invalid option: ${arguments[i]}");
        showHelp(arguments[0]);
        exit(1);
    }
  }

  // Create the output directory if it doesn't exist.
  var outputDir = Directory(outputFilename).parent;
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  // Clear the output file.
  var outputFile = File(outputFilename);
  outputFile.writeAsStringSync('');

  // Get project metadata (pubspec.yaml for Dart, or Python equivalents)
  if (!includePython) {
    var pubspecFile = File('pubspec.yaml');
    if (pubspecFile.existsSync()) {
      var pubspecContent = pubspecFile.readAsStringSync();
      var projectName = RegExp(r'name:\s*([^\n]+)').firstMatch(pubspecContent)?.group(1)?.trim();
      var projectDescription = RegExp(r'description:\s*([^\n]+)').firstMatch(pubspecContent)?.group(1)?.trim();
      outputFile.writeAsStringSync('Project Name: $projectName\n', mode: FileMode.append);
      outputFile.writeAsStringSync('Description: $projectDescription\n', mode: FileMode.append);
      outputFile.writeAsStringSync('---- pubspec.yaml ----\n', mode: FileMode.append);
      outputFile.writeAsStringSync(pubspecContent, mode: FileMode.append);
    } else {
      print("Error: Cannot find pubspec.yaml. Are you in the right directory?");
      exit(1);
    }
  } else {
    // Check for Python "metadata" files
    var requirementsFile = File('requirements.txt');
    var setupFile = File('setup.py');
    var pyprojectFile = File('pyproject.toml');

    if (requirementsFile.existsSync()) {
      outputFile.writeAsStringSync('---- requirements.txt ----\n', mode: FileMode.append);
      outputFile.writeAsStringSync(requirementsFile.readAsStringSync(), mode: FileMode.append);
    }
    if (setupFile.existsSync()) {
      outputFile.writeAsStringSync('---- setup.py ----\n', mode: FileMode.append);
      outputFile.writeAsStringSync(setupFile.readAsStringSync(), mode: FileMode.append);
    }
    if (pyprojectFile.existsSync()) {
      outputFile.writeAsStringSync('---- pyproject.toml ----\n', mode: FileMode.append);
      outputFile.writeAsStringSync(pyprojectFile.readAsStringSync(), mode: FileMode.append);
    }
  }

  // Gather ALL files in ONE glorious loop!
  var files = Directory.current.listSync(recursive: true);
  for (var file in files) {
    if (file is File &&
      (includePython && file.path.endsWith('.py') ||
      !includePython && file.path.endsWith('.dart') ||
      (!includePython && !file.path.contains('.')) ||  // Grab files without extensions
      (includeFirebase && (file.path.endsWith('firebase.json') || file.path.contains('.firebase.'))))) {
      outputFile.writeAsStringSync('---- ${file.path} ----\n', mode: FileMode.append);
    outputFile.writeAsStringSync(file.readAsStringSync(), mode: FileMode.append);
      }
  }

  // Notify the user.
  print('Output written to: $outputFilename');
}
