# This script will build the zip files of the example code for each tutorial's chapter
# Requires GitPython to be installed (>pip install gitpython)

import glob
import shutil
from pathlib import Path

import git  # gitpython module

def package_code():
    cwd = Path.cwd()
    repo_path = cwd.parents[0]
    license_path = repo_path / "LICENSE.md"
    repo = git.Repo(repo_path)

    if repo.is_dirty():
        print("- repository is dirty, aborting")
        return

    for chapter_folder_path in cwd.glob("chapter-*"):
        chapter_number = chapter_folder_path.name.split("-")[1]
        code_folder_name = "UntitledGuiGuide_1.1." + chapter_number
        code_folder_path = chapter_folder_path / code_folder_name

        tmp_license_path = code_folder_path / "LICENSE.md"
        shutil.copy(str(license_path), str(tmp_license_path))

        zipfile_path = chapter_folder_path / code_folder_name
        shutil.make_archive(str(zipfile_path), "zip", str(chapter_folder_path), code_folder_path.parts[-1])

        tmp_license_path.unlink()
        print(f"- Chapter {chapter_number} packaged")

    # Commit and push
    repo.git.add("-A")
    repo.git.commit(m="Repackage example code")
    print("Pushing changes ...", end=" ", flush=True)
    repo.git.push("origin")
    print("done")

if __name__ == "__main__":
    proceed = input("Sure to repackage example code? (y/n): ")
    if proceed == "y":
        package_code()