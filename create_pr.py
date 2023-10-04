import json
import os
import subprocess
import re

JIRA_API_CREDENTIAL = "JIRA_API_CREDENTIAL"
JIRA_ENDPOINT_ISSUE = "https://gogotech.atlassian.net/rest/api/2/issue/{id}"
PR_TITLE_TEMPLATE = "{branch_type}: {ticket_id}: {title}"
PR_TEMPLATE_PATH = ".github/pull_request_template.md"
TRUNK = "trunk"

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

def run(command):
    return subprocess.Popen(
        command,
        shell=True,
        stdout=subprocess.PIPE,
        universal_newlines=True
    ).stdout.read()


branch_name = run("git rev-parse --abbrev-ref HEAD").strip()

branch_name_parts = re.match('^(build|ci|docs|feat|feature|fix|perf|refactor|style|test|chore|revert|inf)\/([a-zA-Z]+-[0-9]+)$', branch_name)
if branch_name_parts:
    branch_type = branch_name_parts.group(1)
    ticket_id = branch_name_parts.group(2)
else:
    print(bcolors.FAIL + "Branch name format is not valid. Expected branch name format: [type]/[JIRA ticket] e.g. inf/MOB-123, feature/CET-XXX, fix/DET-XXX, hotfix/DT-XX")
    exit(2)

def ensure_run_pre_pr_command():
    result = subprocess.Popen("./pre_pr.command", shell=True)
    text = result.communicate()[0]
    return_code = result.returncode
    if return_code != 0 and return_code != 127:
        print(bcolors.FAIL + "Error happens when running pre-pr command, pls check the error log above. return_code={return_code}".format(return_code = return_code))
        exit(3)

def ensure_hub_installed():
    try:
        with open(os.devnull, 'w') as devnull:
            subprocess.check_call("hub --version", shell=True, stdout=devnull, stderr=devnull)
    except subprocess.CalledProcessError:
        print("hub is not installed. Installing...")
        run("brew install hub")


def ensure_jira_credential_setup():
    credential = os.environ.get(JIRA_API_CREDENTIAL)
    if credential is not None:
        return
    else:
        print(bcolors.WARNING + "JIRA_API_CREDENTIAL environment variable is not set. E.g. JIRA_API_CREDENTIAL=my@email:token")
        exit(1)


def ensure_clean_git():
    status = run("git status --porcelain")
    if status:
        print(bcolors.WARNING + "Uncommitted changes in git. Please commit all your changes before creating a PR.")
        exit(3)


def upper_case_branch_name(branch_name, ticket_id):
    if ticket_id.islower():
        print("Converting branch name {branch} to upper case".format(branch=branch_name))

        # git branches are case-insensitive hence cannot directly create correctly cased branch.
        # so go to detached HEAD first, we cannot delete current standing branch either. (-q => quiet)
        run("git checkout head -q")

        # Then delete old branch
        run("git branch -d {branch} -q".format(branch=branch_name))

        # Then create and checkout new branch
        run("git checkout -b {type}/{ticket} -q".format(type=branch_type, ticket=ticket_id.upper()))

        # set new vars
        branch_name = run("git rev-parse --abbrev-ref HEAD").strip()
        ticket_id = ticket_id.upper()


def pr_title():
    endpoint = JIRA_ENDPOINT_ISSUE.format(id=ticket_id)
    credential = os.environ.get(JIRA_API_CREDENTIAL)
    response = run(
        "curl {endpoint} --user {credential}".format(endpoint=endpoint, credential=credential))
    issue = json.loads(response)
    title = issue["fields"]["summary"].replace(",", " ")
    title = title.replace("'", "")
    return PR_TITLE_TEMPLATE.format(branch_type=branch_type, ticket_id=ticket_id, title=title)


def pr_body():
    file = open(PR_TEMPLATE_PATH, "r")
    template = file.read()
    changes = run(
        "git log {trunk}..{branch} --pretty='format:- [x] %Creset%s' --reverse --no-merges".format(
            trunk=TRUNK, branch=branch_name))
    changes = re.sub("{branch}:\s*".format(branch=branch_name), "", changes)
    body = template.format(ticket=ticket_id, changes=changes)
    return body


def create_pr():
    print("Creating PR...")
    run(
        """
        hub pull-request --base gogovan:{trunk} --browse -m "
        {title}

        {body}
        "
        """.format(trunk=TRUNK, title=pr_title(), body=pr_body())
    )
    print("PR created")


def clear_local_tag():
    print("Clearing local tag...")
    run(
        "git tag -l | xargs git tag -d && git fetch -t"
    )
    print("Tag cleared")

ensure_run_pre_pr_command()

ensure_hub_installed()

ensure_jira_credential_setup()

ensure_clean_git()

upper_case_branch_name(branch_name, ticket_id)

create_pr()

clear_local_tag()
