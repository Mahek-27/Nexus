-- CreateEnum
CREATE TYPE "RepositoryRole" AS ENUM ('VIEWER', 'ANALYST', 'ADMIN');

-- CreateEnum
CREATE TYPE "PullRequestState" AS ENUM ('OPEN', 'CLOSED', 'MERGED');

-- CreateEnum
CREATE TYPE "AnalysisType" AS ENUM ('FULL_SCAN', 'PR_SCAN');

-- CreateEnum
CREATE TYPE "AnalysisStatus" AS ENUM ('PENDING', 'RUNNING', 'COMPLETED', 'FAILED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "FindingSeverity" AS ENUM ('INFO', 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL');

-- CreateEnum
CREATE TYPE "ArtifactType" AS ENUM ('SARIF', 'JSON', 'LOG');

-- CreateEnum
CREATE TYPE "JobType" AS ENUM ('SYNC_REPOSITORY', 'ANALYZE_REPOSITORY', 'ANALYZE_PR');

-- CreateEnum
CREATE TYPE "JobStatus" AS ENUM ('QUEUED', 'RUNNING', 'COMPLETED', 'FAILED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "JobAttemptStatus" AS ENUM ('RUNNING', 'COMPLETED', 'FAILED');

-- CreateEnum
CREATE TYPE "WebhookStatus" AS ENUM ('RECEIVED', 'PROCESSING', 'PROCESSED', 'FAILED');

-- CreateEnum
CREATE TYPE "InvitationStatus" AS ENUM ('PENDING', 'ACCEPTED', 'REJECTED', 'EXPIRED');

-- CreateTable
CREATE TABLE "User" (
    "id" UUID NOT NULL,
    "name" TEXT,
    "email" TEXT NOT NULL,
    "emailVerified" TIMESTAMP(3) NOT NULL,
    "image" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Account" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "provider" TEXT NOT NULL DEFAULT 'github',
    "providerAccountId" TEXT NOT NULL,
    "accessToken" TEXT,
    "refreshToken" TEXT,
    "expiresAt" TIMESTAMP(3),
    "scope" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Account_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Session" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "tokenHash" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastUsedAt" TIMESTAMP(3),

    CONSTRAINT "Session_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Repository" (
    "id" UUID NOT NULL,
    "ownerUserId" UUID NOT NULL,
    "provider" TEXT NOT NULL DEFAULT 'github',
    "externalId" BIGINT NOT NULL,
    "name" TEXT NOT NULL,
    "fullName" TEXT NOT NULL,
    "description" TEXT,
    "url" TEXT NOT NULL,
    "defaultBranch" TEXT,
    "isPrivate" BOOLEAN NOT NULL,
    "isArchived" BOOLEAN NOT NULL DEFAULT false,
    "lastSyncedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Repository_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RepositoryMember" (
    "id" UUID NOT NULL,
    "repositoryId" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "invitedById" UUID,
    "role" "RepositoryRole" NOT NULL DEFAULT 'VIEWER',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "RepositoryMember_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RepositoryInvitation" (
    "id" UUID NOT NULL,
    "repositoryId" UUID NOT NULL,
    "inviteeUserId" UUID NOT NULL,
    "invitedById" UUID,
    "role" "RepositoryRole" NOT NULL DEFAULT 'VIEWER',
    "status" "InvitationStatus" NOT NULL DEFAULT 'PENDING',
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "respondedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "RepositoryInvitation_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Branch" (
    "id" UUID NOT NULL,
    "repositoryId" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "headSha" TEXT,
    "isDefault" BOOLEAN NOT NULL DEFAULT false,
    "lastSyncedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Branch_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Commit" (
    "id" UUID NOT NULL,
    "repositoryId" UUID NOT NULL,
    "sha" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "authorName" TEXT,
    "authorEmail" TEXT,
    "committedAt" TIMESTAMP(3),
    "url" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Commit_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PullRequest" (
    "id" UUID NOT NULL,
    "repositoryId" UUID NOT NULL,
    "number" INTEGER NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "state" "PullRequestState" NOT NULL DEFAULT 'OPEN',
    "sourceBranch" TEXT NOT NULL,
    "targetBranch" TEXT NOT NULL,
    "headSha" TEXT,
    "baseSha" TEXT,
    "authorLogin" TEXT,
    "url" TEXT NOT NULL,
    "openedAt" TIMESTAMP(3),
    "closedAt" TIMESTAMP(3),
    "mergedAt" TIMESTAMP(3),
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PullRequest_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Analysis" (
    "id" UUID NOT NULL,
    "repositoryId" UUID NOT NULL,
    "requestedById" UUID,
    "pullRequestId" UUID,
    "branchName" TEXT,
    "commitSha" TEXT NOT NULL,
    "type" "AnalysisType" NOT NULL,
    "status" "AnalysisStatus" NOT NULL DEFAULT 'PENDING',
    "startedAt" TIMESTAMP(3),
    "completedAt" TIMESTAMP(3),
    "errorMessage" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Analysis_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Finding" (
    "id" UUID NOT NULL,
    "analysisId" UUID NOT NULL,
    "ruleId" TEXT NOT NULL,
    "severity" "FindingSeverity" NOT NULL,
    "category" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "filePath" TEXT NOT NULL,
    "startLine" INTEGER,
    "endLine" INTEGER,
    "fingerprint" TEXT NOT NULL,
    "tool" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Finding_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AnalysisArtifact" (
    "id" UUID NOT NULL,
    "analysisId" UUID NOT NULL,
    "type" "ArtifactType" NOT NULL,
    "storageKey" TEXT NOT NULL,
    "contentHash" TEXT,
    "sizeBytes" BIGINT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AnalysisArtifact_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Report" (
    "id" UUID NOT NULL,
    "analysisId" UUID NOT NULL,
    "summary" TEXT,
    "totalFindings" INTEGER NOT NULL DEFAULT 0,
    "criticalCount" INTEGER NOT NULL DEFAULT 0,
    "highCount" INTEGER NOT NULL DEFAULT 0,
    "mediumCount" INTEGER NOT NULL DEFAULT 0,
    "lowCount" INTEGER NOT NULL DEFAULT 0,
    "infoCount" INTEGER NOT NULL DEFAULT 0,
    "generatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Report_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Job" (
    "id" UUID NOT NULL,
    "repositoryId" UUID,
    "requestedById" UUID,
    "analysisId" UUID,
    "pullRequestId" UUID,
    "type" "JobType" NOT NULL,
    "status" "JobStatus" NOT NULL DEFAULT 'QUEUED',
    "priority" INTEGER NOT NULL DEFAULT 0,
    "payload" JSONB NOT NULL,
    "dedupeKey" TEXT,
    "attemptsMade" INTEGER NOT NULL DEFAULT 0,
    "maxAttempts" INTEGER NOT NULL DEFAULT 3,
    "availableAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "startedAt" TIMESTAMP(3),
    "completedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Job_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "JobAttempt" (
    "id" UUID NOT NULL,
    "jobId" UUID NOT NULL,
    "attemptNumber" INTEGER NOT NULL,
    "status" "JobAttemptStatus" NOT NULL DEFAULT 'RUNNING',
    "startedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completedAt" TIMESTAMP(3),
    "errorMessage" TEXT,
    "durationMs" INTEGER,

    CONSTRAINT "JobAttempt_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "WebhookEvent" (
    "id" UUID NOT NULL,
    "deliveryId" TEXT NOT NULL,
    "eventType" TEXT NOT NULL,
    "action" TEXT,
    "repositoryId" UUID,
    "payload" JSONB NOT NULL,
    "status" "WebhookStatus" NOT NULL DEFAULT 'RECEIVED',
    "receivedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "processedAt" TIMESTAMP(3),
    "errorMessage" TEXT,

    CONSTRAINT "WebhookEvent_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE INDEX "User_createdAt_idx" ON "User"("createdAt");

-- CreateIndex
CREATE INDEX "Account_userId_idx" ON "Account"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "Account_provider_providerAccountId_key" ON "Account"("provider", "providerAccountId");

-- CreateIndex
CREATE UNIQUE INDEX "Session_tokenHash_key" ON "Session"("tokenHash");

-- CreateIndex
CREATE INDEX "Session_userId_idx" ON "Session"("userId");

-- CreateIndex
CREATE INDEX "Session_expiresAt_idx" ON "Session"("expiresAt");

-- CreateIndex
CREATE INDEX "Repository_ownerUserId_idx" ON "Repository"("ownerUserId");

-- CreateIndex
CREATE INDEX "Repository_fullName_idx" ON "Repository"("fullName");

-- CreateIndex
CREATE INDEX "Repository_lastSyncedAt_idx" ON "Repository"("lastSyncedAt");

-- CreateIndex
CREATE UNIQUE INDEX "Repository_provider_externalId_key" ON "Repository"("provider", "externalId");

-- CreateIndex
CREATE INDEX "RepositoryMember_userId_idx" ON "RepositoryMember"("userId");

-- CreateIndex
CREATE INDEX "RepositoryMember_invitedById_idx" ON "RepositoryMember"("invitedById");

-- CreateIndex
CREATE UNIQUE INDEX "RepositoryMember_repositoryId_userId_key" ON "RepositoryMember"("repositoryId", "userId");

-- CreateIndex
CREATE INDEX "RepositoryInvitation_repositoryId_inviteeUserId_status_idx" ON "RepositoryInvitation"("repositoryId", "inviteeUserId", "status");

-- CreateIndex
CREATE INDEX "RepositoryInvitation_inviteeUserId_status_idx" ON "RepositoryInvitation"("inviteeUserId", "status");

-- CreateIndex
CREATE INDEX "RepositoryInvitation_expiresAt_status_idx" ON "RepositoryInvitation"("expiresAt", "status");

-- CreateIndex
CREATE INDEX "Branch_repositoryId_isDefault_idx" ON "Branch"("repositoryId", "isDefault");

-- CreateIndex
CREATE UNIQUE INDEX "Branch_repositoryId_name_key" ON "Branch"("repositoryId", "name");

-- CreateIndex
CREATE INDEX "Commit_repositoryId_committedAt_idx" ON "Commit"("repositoryId", "committedAt");

-- CreateIndex
CREATE UNIQUE INDEX "Commit_repositoryId_sha_key" ON "Commit"("repositoryId", "sha");

-- CreateIndex
CREATE INDEX "PullRequest_repositoryId_state_idx" ON "PullRequest"("repositoryId", "state");

-- CreateIndex
CREATE INDEX "PullRequest_repositoryId_updatedAt_idx" ON "PullRequest"("repositoryId", "updatedAt");

-- CreateIndex
CREATE UNIQUE INDEX "PullRequest_repositoryId_number_key" ON "PullRequest"("repositoryId", "number");

-- CreateIndex
CREATE INDEX "Analysis_repositoryId_createdAt_idx" ON "Analysis"("repositoryId", "createdAt");

-- CreateIndex
CREATE INDEX "Analysis_repositoryId_status_idx" ON "Analysis"("repositoryId", "status");

-- CreateIndex
CREATE INDEX "Analysis_requestedById_idx" ON "Analysis"("requestedById");

-- CreateIndex
CREATE INDEX "Analysis_pullRequestId_idx" ON "Analysis"("pullRequestId");

-- CreateIndex
CREATE INDEX "Analysis_commitSha_idx" ON "Analysis"("commitSha");

-- CreateIndex
CREATE INDEX "Finding_analysisId_severity_idx" ON "Finding"("analysisId", "severity");

-- CreateIndex
CREATE INDEX "Finding_filePath_idx" ON "Finding"("filePath");

-- CreateIndex
CREATE INDEX "Finding_ruleId_idx" ON "Finding"("ruleId");

-- CreateIndex
CREATE UNIQUE INDEX "Finding_analysisId_fingerprint_key" ON "Finding"("analysisId", "fingerprint");

-- CreateIndex
CREATE INDEX "AnalysisArtifact_analysisId_idx" ON "AnalysisArtifact"("analysisId");

-- CreateIndex
CREATE UNIQUE INDEX "Report_analysisId_key" ON "Report"("analysisId");

-- CreateIndex
CREATE UNIQUE INDEX "Job_analysisId_key" ON "Job"("analysisId");

-- CreateIndex
CREATE UNIQUE INDEX "Job_dedupeKey_key" ON "Job"("dedupeKey");

-- CreateIndex
CREATE INDEX "Job_status_priority_availableAt_idx" ON "Job"("status", "priority", "availableAt");

-- CreateIndex
CREATE INDEX "Job_repositoryId_createdAt_idx" ON "Job"("repositoryId", "createdAt");

-- CreateIndex
CREATE INDEX "Job_requestedById_idx" ON "Job"("requestedById");

-- CreateIndex
CREATE INDEX "Job_pullRequestId_idx" ON "Job"("pullRequestId");

-- CreateIndex
CREATE INDEX "JobAttempt_jobId_status_idx" ON "JobAttempt"("jobId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "JobAttempt_jobId_attemptNumber_key" ON "JobAttempt"("jobId", "attemptNumber");

-- CreateIndex
CREATE UNIQUE INDEX "WebhookEvent_deliveryId_key" ON "WebhookEvent"("deliveryId");

-- CreateIndex
CREATE INDEX "WebhookEvent_status_receivedAt_idx" ON "WebhookEvent"("status", "receivedAt");

-- CreateIndex
CREATE INDEX "WebhookEvent_repositoryId_receivedAt_idx" ON "WebhookEvent"("repositoryId", "receivedAt");

-- AddForeignKey
ALTER TABLE "Account" ADD CONSTRAINT "Account_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Session" ADD CONSTRAINT "Session_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Repository" ADD CONSTRAINT "Repository_ownerUserId_fkey" FOREIGN KEY ("ownerUserId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RepositoryMember" ADD CONSTRAINT "RepositoryMember_repositoryId_fkey" FOREIGN KEY ("repositoryId") REFERENCES "Repository"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RepositoryMember" ADD CONSTRAINT "RepositoryMember_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RepositoryMember" ADD CONSTRAINT "RepositoryMember_invitedById_fkey" FOREIGN KEY ("invitedById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RepositoryInvitation" ADD CONSTRAINT "RepositoryInvitation_repositoryId_fkey" FOREIGN KEY ("repositoryId") REFERENCES "Repository"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RepositoryInvitation" ADD CONSTRAINT "RepositoryInvitation_inviteeUserId_fkey" FOREIGN KEY ("inviteeUserId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RepositoryInvitation" ADD CONSTRAINT "RepositoryInvitation_invitedById_fkey" FOREIGN KEY ("invitedById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Branch" ADD CONSTRAINT "Branch_repositoryId_fkey" FOREIGN KEY ("repositoryId") REFERENCES "Repository"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Commit" ADD CONSTRAINT "Commit_repositoryId_fkey" FOREIGN KEY ("repositoryId") REFERENCES "Repository"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PullRequest" ADD CONSTRAINT "PullRequest_repositoryId_fkey" FOREIGN KEY ("repositoryId") REFERENCES "Repository"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Analysis" ADD CONSTRAINT "Analysis_repositoryId_fkey" FOREIGN KEY ("repositoryId") REFERENCES "Repository"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Analysis" ADD CONSTRAINT "Analysis_requestedById_fkey" FOREIGN KEY ("requestedById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Analysis" ADD CONSTRAINT "Analysis_pullRequestId_fkey" FOREIGN KEY ("pullRequestId") REFERENCES "PullRequest"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Finding" ADD CONSTRAINT "Finding_analysisId_fkey" FOREIGN KEY ("analysisId") REFERENCES "Analysis"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AnalysisArtifact" ADD CONSTRAINT "AnalysisArtifact_analysisId_fkey" FOREIGN KEY ("analysisId") REFERENCES "Analysis"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Report" ADD CONSTRAINT "Report_analysisId_fkey" FOREIGN KEY ("analysisId") REFERENCES "Analysis"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Job" ADD CONSTRAINT "Job_repositoryId_fkey" FOREIGN KEY ("repositoryId") REFERENCES "Repository"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Job" ADD CONSTRAINT "Job_requestedById_fkey" FOREIGN KEY ("requestedById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Job" ADD CONSTRAINT "Job_analysisId_fkey" FOREIGN KEY ("analysisId") REFERENCES "Analysis"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Job" ADD CONSTRAINT "Job_pullRequestId_fkey" FOREIGN KEY ("pullRequestId") REFERENCES "PullRequest"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "JobAttempt" ADD CONSTRAINT "JobAttempt_jobId_fkey" FOREIGN KEY ("jobId") REFERENCES "Job"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WebhookEvent" ADD CONSTRAINT "WebhookEvent_repositoryId_fkey" FOREIGN KEY ("repositoryId") REFERENCES "Repository"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- Enforce one pending invitation per repository and user
CREATE UNIQUE INDEX "one_pending_invitation_per_repository_user"
ON "RepositoryInvitation" ("repositoryId", "inviteeUserId")
WHERE "status" = 'PENDING';

-- Enforce one default branch per repository
CREATE UNIQUE INDEX "one_default_branch_per_repository"
ON "Branch" ("repositoryId")
WHERE "isDefault" = TRUE;