import os
import re
import sys
from datetime import datetime
import yaml
import semver

# Check final commit message
def check_commit_message():
    commit_message = os.popen('git log -1 --pretty=%B').read().strip()
    if commit_message != 'prepare for release':
        print(f"Error: Last commit message is not 'prepare for release'. Found: {commit_message}")
        sys.exit(1)

# Validate changelog
def check_changelog():
    with open('CHANGELOG', 'r') as f:
        first_line = f.readline().strip()
        match = re.match(r'^(\S+) (\d+\.\d+\.\d+) \((\d{4}-\d{2}-\d{2})\)$', first_line)
        if not match:
            print(f"Error: First line of changelog is not in the correct format. Found: {first_line}")
            sys.exit(1)

        package_name, new_version, date_str = match.groups()
        new_date = datetime.strptime(date_str, '%Y-%m-%d').date()
        today = datetime.today().date()

        if new_date < today:
            print(f"Error: Changelog date {new_date} is before today {today}")
            sys.exit(1)

    return package_name, new_version

# Validate dbt_project.yml
def check_dbt_project(file_path, new_version):
    with open(f'{file_path}', 'r') as f:
        dbt_project = yaml.safe_load(f)

    if 'version' not in dbt_project:
        print(f"Error: 'version' not found in {file_path}")
        sys.exit(1)

    dbt_version = dbt_project['version']
    if dbt_version != new_version:
        print(f"Error: Version in {file_path} ({dbt_version}) does not match version in changelog ({new_version})")
        sys.exit(1)

# Check semver
def check_semver(new_version):
    with open('CHANGELOG.md', 'r') as f:
        lines = f.readlines()
        for line in lines:
            match = re.match(r'^(\S+) (\d+\.\d+\.\d+) \((\d{4}-\d{2}-\d{2})\)$', line)
            if match:
                _, old_version, _ = match.groups()
                break

    if semver.compare(new_version, old_version) <= 0:
        print(f"Error: New version ({new_version}) is not greater than the old version ({old_version})")
        sys.exit(1)

if __name__ == "__main__":
    check_commit_message()
    package_name, new_version = check_changelog()
    check_dbt_project('dbt_project.yml', new_version)
    check_dbt_project('integration_tests/dbt_project.yml', new_version)
    check_semver(new_version)
    print("All checks passed successfully!")
