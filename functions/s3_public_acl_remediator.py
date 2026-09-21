import os

import boto3


RISKY_URIS = {
    "http://acs.amazonaws.com/groups/global/AllUsers",
    "http://acs.amazonaws.com/groups/global/AuthenticatedUsers",
}

s3 = boto3.client(
    "s3",
    endpoint_url=os.getenv("AWS_ENDPOINT_URL"),
)


def handler(event, context):
    """
    Remove public ACL grants from the S3 bucket identified in the event.
    """
    bucket = event["detail"]["requestParameters"]["bucketName"]

    acl = s3.get_bucket_acl(Bucket=bucket)

    approved_grants = [
        grant
        for grant in acl["Grants"]
        if grant.get("Grantee", {}).get("URI") not in RISKY_URIS
    ]

    grants_removed = len(acl["Grants"]) - len(approved_grants)

    s3.put_bucket_acl(
        Bucket=bucket,
        AccessControlPolicy={
            "Grants": approved_grants,
            "Owner": acl["Owner"],
        },
    )

    return {
        "remediated": bucket,
        "grants_removed": grants_removed,
    }
