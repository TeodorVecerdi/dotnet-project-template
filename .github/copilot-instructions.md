# Instructions for GitHub Copilot

## Repository Overview

<!-- This section provides a brief overview of the repository, its purpose, and key components. -->

### Key Components

<!-- Key components -->

### Technology Stack

- .NET 10.0
- C# 14 features
<!-- Other parts of the tech stack -->

## General

* Make only high confidence suggestions when reviewing code changes.
* Always use the latest version of C#, currently C# 14 features.
* Never change global.json unless explicitly asked to.
* Never change package.json or package-lock.json files unless explicitly asked to.
* Never change NuGet.config files unless explicitly asked to.

## Formatting (C#)

* Apply code-formatting style defined in `/src/.editorconfig`.
* Prefer file-scoped namespace declarations and single-line using directives.
* Always place opening curly brace of any code block on the same line (e.g., after `if`, `for`, `while`, `foreach`, `using`, `try`, etc.).
* Ensure that the final return statement of a method is on its own line.
* Use pattern matching and switch expressions wherever possible.
* Use `nameof` instead of string literals when referring to member names.
* Place private class declarations at the bottom of the file.
* Never leave trailing whitespace at the end of lines.
* Never use region directives.
* Always use `var`, never explicit types unless required by the language/compiler.
* **newlines**: When creating a new file, use the `/eng/tools/ensure-newline.sh` (bash) or `/eng/tools/ensure-newline.ps1` (PowerShell) script (depending on your environment) to ensure files end with newlines. These scripts accept any number of file paths as arguments and add a newline to files that don't already end with one. Usage: `./eng/tools/ensure-newline.sh file1.txt file2.txt` or `.\eng\tools\ensure-newline.ps1 file1.txt file2.txt` (glob patterns are also supported, e.g. `./eng/tools/ensure-newline.sh some/folder/**/*.cs`).

### Nullable Reference Types

* Declare variables non-nullable, and check for `null` at entry points.
* Always use `is null` or `is not null` instead of `== null` or `!= null`.
* Trust the C# null annotations and don't add null checks when the type system says a value cannot be null.

### Name Conventions (C#)

* Use `PascalCase` for class names, method names, properties, and other public members.
* Use `camelCase` for local variables and method parameters.
* Use `m_PascalCase` for private instance fields, `s_PascalCase` for private static fields, `PascalCase` for constants (regardless of visibility).
* Do not use any other visibility than private for fields. Use properties for public, protected, or internal access.
* Avoid abbreviations unless they are widely recognized (e.g., `Id` for Identifier).

### Build Troubleshooting

- If temporarily introducing warnings during refactoring, add `/p:TreatWarningsAsErrors=false` to prevent build failure
- **Important**: All warnings should be addressed before committing any final changes
- .NET build artifacts go to the `/artifacts/` directory

## Markdown Files

* Markdown files should not have multiple consecutive blank lines.
* Code blocks should be formatted with triple backticks (```) and include the language identifier for syntax highlighting. (Use 'text' for plain text instead of leaving it blank.)
* JSON and code blocks should be indented properly.

## Trust These Instructions

These instructions are designed to maintain consistency and quality across the codebase. Only search for additional information if:
1. The instructions appear outdated or incorrect
2. You encounter specific errors not covered here
3. You need details about new features not yet documented

For most development tasks, following these instructions should be sufficient to develop, test, and validate changes successfully.
