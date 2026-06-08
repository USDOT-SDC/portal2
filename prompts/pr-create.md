# PR Create Prompt

You are creating a pull request for the USDOT-SDC/portal2 repository on github.com.

## Step 1 — Resolve Branches

If the source and target branches were not provided in the invocation, ask:
> "What are the source and target branches? (e.g., dev → main)"

Map branch names to environment names:
- `dev` → `dev`
- `main` → `prod`

Source env = source branch name. Target env = target branch name.

## Step 2 — Resolve Assignee and Reviewer

Load `prompts/team.json` from the repo root. It maps first names to email addresses and GitHub handles.

**Assignee (auto-detect):**
Run `git config user.email` to get the current user's email. Match it case-insensitively against `team.json` entries. The matching member's `github-handle` is the assignee. If no match is found, ask the user for their name.

**Reviewer (ask):**
List all team members where `"reviewer": true`, excluding the assignee. Ask:
> "Who should review this PR? Options: {comma-separated first names} — or leave blank to skip."

Multiple names are allowed (e.g., "Shyla, Brandon"). Collect the `github-handle` for each. If left blank, skip adding reviewers.

## Step 3 — Gather Diff Data

Run the following git commands to collect diff information. All commands use
`TARGET_BRANCH...SOURCE_BRANCH` (three-dot diff).

```
git fetch origin
git log {TARGET_BRANCH}..{SOURCE_BRANCH} --oneline
git log {TARGET_BRANCH}..{SOURCE_BRANCH} --pretty=format:"%h - %an, %ar : %s%n%b%n"
git diff {TARGET_BRANCH}...{SOURCE_BRANCH} --stat
git diff {TARGET_BRANCH}...{SOURCE_BRANCH} --name-status
git diff {TARGET_BRANCH}...{SOURCE_BRANCH} --shortstat
git rev-list --count {TARGET_BRANCH}..{SOURCE_BRANCH}
git show {TARGET_BRANCH}:terraform/config_version.txt
git show {SOURCE_BRANCH}:terraform/config_version.txt
```

Note any version changes or warnings (unchanged version, version going backwards, etc.).

## Step 4 — Fetch Jira Context

Extract all ticket IDs from the source branch name and commit messages
(pattern: `[A-Z]+-\d+`, e.g. `DESK-704`, `SDC-1234`). For each unique ticket ID,
fetch the issue using the MCP Atlassian tool (`mcp__atlassian__getJiraIssue`).

You can pass the site hostname directly as `cloudId` (e.g. `securedatacommons.atlassian.net`)
without needing to call `getAccessibleAtlassianResources` first. Call
`mcp__atlassian__getJiraIssue` for each ticket:

```
getJiraIssue(cloudId="securedatacommons.atlassian.net", issueIdOrKey="{TICKET_ID}", responseContentFormat="markdown")
```

For each ticket retrieved, note: summary, status, issue type, parent/epic, and any
acceptance criteria in the description.

If no tickets are found, proceed without Jira context and note it in the summary.

## Step 5 — Write PR Summary

Using the diff data from Step 3 and the Jira context from Step 4, write a PR summary
following the structure in `pull_request_template.md`. Guidelines:

- Title format: `{SOURCE_BRANCH}->{TARGET_BRANCH}: {Description} ({parent} {child})` — use ticket IDs from Step 4; if none found, derive from branch names or commit messages; omit ticket suffix if none are identifiable
- write a **concise** summary
- Do not wrap prose lines — let each paragraph/bullet run as one continuous line
- Flag version warnings prominently in the summary header
- Fill in the DevOps Checklist based on actual observations from the diff

## Step 6 — Create Draft PR via GitHub CLI

Use the GitHub CLI from `C:\ai-tools`. Credentials are read automatically from
`C:\ai-tools\external-resources.json` — check that file for the correct `--github-instance`
key (e.g. `com` for github.com).

Write the PR body to `C:\ai-tools\temp\pr_body.md` first, then pass it via `--body-file` to
avoid shell expansion of backticks and special characters.

**Important — shell path syntax:** Always invoke the CLI using Unix-style forward-slash paths
(e.g. `/c/ai-tools/...`) rather than Windows backslash paths. Using `cmd /c "C:\..."` in the
bash shell silently swallows all output.

**Important — writing `pr_body.md`:** The file at `C:\ai-tools\temp\pr_body.md` may already
exist from a prior run. Always `Read` it before writing so the Write tool does not reject the
call with a "file not read" error.

Run `--dry-run` first to confirm the payload, then re-run without it to create the PR:

```bash
/c/ai-tools/.venv/Scripts/python.exe /c/ai-tools/scripts/github/cli.py --github-instance com pr-create --repo USDOT-SDC/portal2 --title "TITLE" --head SOURCE_BRANCH --base TARGET_BRANCH --draft --body-file /c/ai-tools/temp/pr_body.md --dry-run
```

After confirming the dry run output, create the PR with reviewers and assignee in one shot:

```bash
/c/ai-tools/.venv/Scripts/python.exe /c/ai-tools/scripts/github/cli.py --github-instance com pr-create --repo USDOT-SDC/portal2 --title "TITLE" --head SOURCE_BRANCH --base TARGET_BRANCH --draft --body-file /c/ai-tools/temp/pr_body.md --reviewers handle1,handle2 --assignees ASSIGNEE
```

Or set/update them post-creation:

```bash
/c/ai-tools/.venv/Scripts/python.exe /c/ai-tools/scripts/github/cli.py --github-instance com pr-update --repo USDOT-SDC/portal2 --number PR_NUMBER --reviewers handle1,handle2 --assignees ASSIGNEE
```

## Step 7 — Report Back

Output:
- PR URL
- PR number
- Any warnings (version unchanged, test failures, missing Jira tickets, etc.)
