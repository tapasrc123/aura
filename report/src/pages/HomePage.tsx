import { useState } from "react"
import { Grid } from "@tremor/react"
import { useTenant } from "@/context/TenantContext"
import AuTestSummary from "@/components/AuTestSummary"
import AuDonutChart from "@/components/AuDonutChart"
import AuSeverityChart from "@/components/AuSeverityChart"
import AuBlocksArea from "@/components/AuBlocksArea"
import TestResultsTable from "@/components/TestResultsTable"
import { defaultSelectedStatus } from "@/lib/testStatus"

export default function HomePage() {
  const { selectedTenant: testResults } = useTenant()
  const [selectedStatus, setSelectedStatus] = useState(defaultSelectedStatus)
  const tenantName = testResults.TenantName || testResults.TenantId || "Tenant"
  const testDateLocal = new Date(testResults.ExecutedAt).toLocaleString(
    undefined,
    {
      dateStyle: "medium",
      timeStyle: "short",
    }
  )

  return (
    <>
      {/* Header */}
      <div className="mb-6">
        <h1 className="text-2xl font-semibold tracking-tight text-gray-900 dark:text-gray-100">
          Test Overview
        </h1>
        <p className="mt-1 text-sm text-gray-500 dark:text-gray-400">
          {tenantName} • {testDateLocal}
        </p>
      </div>

      {/* Test Summary */}
      <AuTestSummary {...testResults} selectedStatus={selectedStatus} onStatusChange={setSelectedStatus} />

      {/* Charts Grid */}
      <Grid numItemsMd={2} numItemsLg={3} className="gap-6 mb-6">
        <AuDonutChart {...testResults} />
        <AuSeverityChart Tests={testResults.Tests} />
        <AuBlocksArea Blocks={testResults.Blocks} />
      </Grid>

      {/* Test Results Table */}
      <div className="mt-6">
        <TestResultsTable TestResults={testResults} selectedStatus={selectedStatus} onStatusChange={setSelectedStatus} />
      </div>
    </>
  )
}
