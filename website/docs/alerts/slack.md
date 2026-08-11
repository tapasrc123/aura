---
sidebar_label: Slack Alerts
sidebar_position: 12
title: Set up Aura Slack alerts
---

# Set up Aura Slack Alerts

Your Aura monitoring workflow can be configured to send a summary at the end of each monitoring cycle in Slack. This guide will walk you through the steps to set up Slack alerts in Aura.

## Prerequisites

### Create a Slack App and Incoming Webhook

- Open the [Your apps](https://api.slack.com/apps) in the Slack API portal
- Click on "**Create New App**"
- Enter a name for your app, for example `Aura DevOps` and select the Slack workspace where you want to post the notifications.
- Click "**Create App**".

### Enable Incoming Webhooks

- In your Slack app settings, go to **Incoming Webhooks**.
- Click on **Activate Incoming Webhooks** to enable it.
- Click **Add New Webhook to Workspace** at the bottom.
- Select the channel where you want to post the messages and click **Allow**.
- Copy the webhook URL provided. You will need this URL in the GitHub Actions workflow.

### Add Secret to GitHub Repository

- Go to your GitHub repository.
- Click on **Settings** > **Secrets and variables** > **Actions**.
- Click "**New repository secret**".
- Name the secret `SLACK_WEBHOOK_URL`.
- Paste the Slack webhook URL you copied earlier and click **Add secret**.

## Add the Slack alert step to your workflow

Update your GitHub daily monitoring workflow to send the Slack alert using the webhook with the following code:

```powershell

    - name: Generate Slack Notification
      shell: pwsh
      run: |
        $results = Get-Content test-results/test-results.json | ConvertFrom-Json

        $testSummary = "Test Summary:`n-------------`nPassed: $($results.PassedCount)`nFailed: $($results.FailedCount)`nSkipped: $($results.SkippedCount)`nTotal: $($results.TotalCount)"

        $runLink = "${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}"

        $slackMessage = @{
          text = "Aura Test Results"
          attachments = @(
            @{
              color = if ($results.Result -eq 'Passed') { "good" } else { "danger" }
              text = $testSummary
            },
            @{
              title = "Detailed Report"
              title_link = $runLink
              text = "Click the link above to view the full report."
            }
          )
        }

        Invoke-RestMethod -Uri "${{ secrets.SLACK_WEBHOOK_URL }}" -Method Post -ContentType 'application/json' -Body ($slackMessage | ConvertTo-Json -Depth 4)

    - name: Notify Slack on success
      if: success()
      run: |
        curl -X POST -H 'Content-type: application/json' --data '{"text":"Aura tests passed!"}' "${{ secrets.SLACK_WEBHOOK_URL }}"

    - name: Notify Slack on failure
      if: failure()
      run: |
        curl -X POST -H 'Content-type: application/json' --data '{"text":"Aura tests failed!"}' "${{ secrets.SLACK_WEBHOOK_URL }}"
```

### Github Actions Slack example

You can use the output of the Aura action to send a Slack notification. Here is an example of how to set up the workflow:

```yaml
jobs:
  run-aura-tests:
    name: Run Aura Tests
    runs-on: ubuntu-latest
    steps:
    - name: Run Aura action
      id: aura # this is important, by setting the id you can use the output of the action in the next steps
      uses: tapasrc123/aura@main
      with:
        client_id: ${{ secrets.AZURE_CLIENT_ID }}
        tenant_id: ${{ secrets.AZURE_TENANT_ID }}
        # other options removed for readability
    - name: Generate Slack Notification
      shell: pwsh
      if: always() && steps.aura.outputs.results_json != ''
      run: |
        $results = Get-Content ${{ steps.aura.outputs.results_json }} | ConvertFrom-Json

        $testSummary = "Test Summary:`n-------------`nPassed: $($results.PassedCount)`nFailed: $($results.FailedCount)`nSkipped: $($results.SkippedCount)`nTotal: $($results.TotalCount)"

        $runLink = "${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}"

        $slackMessage = @{
          text = "Aura Test Results $(if ($results.Result -eq 'Passed') { '✅' } else { '❌' })"
          attachments = @(
            @{
              color = if ($results.Result -eq 'Passed') { "good" } else { "danger" }
              text = $testSummary
            },
            @{
              title = "Detailed Report"
              title_link = $runLink
              text = "Click the link above to view the full report."
            }
          )
        }

        Invoke-RestMethod -Uri "${{ secrets.SLACK_WEBHOOK_URL }}" -Method Post -ContentType 'application/json' -Body ($slackMessage | ConvertTo-Json -Depth 4)
```

## Important Notes

- Webhook URL: Ensure you have the `SLACK_WEBHOOK_URL` secret set up in your GitHub repository.
- GitHub Link: The link to the GitHub Actions run is dynamically generated using `${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}`

## Customize the App Icon (Optional)

- Open App Settings
- In the left sidebar, click on **Basic Information**.
- Scroll down to the **Display Information** section.
- Here, you will find an option to upload an app icon. The recommended size is 512x512 pixels.
- Click **Edit** next to the **App Icon** section.
- Upload your custom icon image.
- After uploading the image, make sure to save your changes.
