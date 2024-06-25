import os
import re
import sys
from datetime import datetime
import yaml
import semver

logs = []


# Check final commit message
def check_commit_message():
    commit_message = os.popen("git log -1 --pretty=%B").read().strip()
    if commit_message.lower() != "prepare for release":
        logs.append(
            f"❌ Error: Last commit message is not 'prepare for release'. Found: `{commit_message}`"
        )
    else:
        logs.append(f"✅ Pass: Last commit message is `prepare for release`.")


# Validate changelog
def check_changelog():
    with open("CHANGELOG", "r") as f:
        first_line = f.readline().strip()
        match = re.match(r"^(\S+) (\d+\.\d+\.\d+) \((\d{4}-\d{2}-\d{2})\)$", first_line)
        if not match:
            logs.append(
                f"❌ Error: First line of changelog is not in the correct format. Found: `{first_line}`"
            )
        else:
            logs.append(f"✅ Pass: First line of changelog is in the correct format.")

        package_name, new_version, date_str = match.groups()
        new_date = datetime.strptime(date_str, "%Y-%m-%d").date()
        today = datetime.today().date()

        if new_date < today:
            logs.append(
                f"❌ Error: Changelog date ({new_date}) is before today ({today})."
            )
        else:
            logs.append(
                f"✅ Pass: Changelog date ({new_date}) is today ({today}) or later."
            )

    return package_name, new_version


# Validate dbt_project.yml
def check_dbt_project(file_path, new_version):
    with open(f"{file_path}", "r") as f:
        dbt_project = yaml.safe_load(f)

    if "version" not in dbt_project:
        logs.append(f"❌ Error: 'version' not found in {file_path}")

    dbt_version = dbt_project["version"]
    if dbt_version != new_version:
        logs.append(
            f"❌ Error: Version in {file_path} (`{dbt_version}`) does not match version in changelog (`{new_version}`)."
        )
    else:
        logs.append(
            f"✅ Pass: Version in {file_path} (`{dbt_version}`) matches version in changelog (`{new_version}`)."
        )


# Check semver
def check_semver(new_version):
    with open("CHANGELOG", "r") as f:
        lines = f.readlines()
        old_versions = []
        for line in lines:
            match = re.match(r"^(\S+) (\d+\.\d+\.\d+) \((\d{4}-\d{2}-\d{2})\)$", line)
            if match:
                _, old_version, _ = match.groups()
                old_versions.append(old_version)

    if len(old_versions) < 2:
        logs.append(
            "⚠️ Warning: Not enough versions found in changelog to perform semver comparison"
        )
        return

    next_newest_version = old_versions[1]
    if semver.compare(new_version, next_newest_version) <= 0:
        logs.append(
            f"❌ Error: New version (`{new_version}`) is not greater than the next newest version (`{next_newest_version}`)"
        )
    else:
        logs.append(
            f"✅ Pass: New version (`{new_version}`) is greater than the next newest version (`{next_newest_version}`)"
        )


if __name__ == "__main__":
    check_commit_message()
    package_name, new_version = check_changelog()
    if new_version:
        check_dbt_project("dbt_project.yml", new_version)
        check_dbt_project("integration_tests/dbt_project.yml", new_version)
        check_semver(new_version)
    if any("❌" in s for s in logs):
        print("\n".join(logs))
        sys.exit(1)
    else:
        print("All checks passed successfully!")
        print("")
        print("\n".join(logs))
