import boto3
from moto import mock_aws

from functions.s3_public_acl_remediator import handler


RISKY_URIS = {
    "http://acs.amazonaws.com/groups/global/AllUsers",
    "http://acs.amazonaws.com/groups/global/AuthenticatedUsers",
}


@mock_aws
def test_removes_public_acl_grants():
    s3 = boto3.client("s3", region_name="us-east-1")

    s3.create_bucket(Bucket="demo")
    s3.put_bucket_acl(Bucket="demo", ACL="public-read")

    event = {
        "detail": {
            "requestParameters": {
                "bucketName": "demo"
            }
        }
    }

    result = handler(event, None)

    assert result["remediated"] == "demo"
    assert result["grants_removed"] > 0

    acl = s3.get_bucket_acl(Bucket="demo")

    risky_grants = [
        grant
        for grant in acl["Grants"]
        if grant.get("Grantee", {}).get("URI") in RISKY_URIS
    ]

    assert risky_grants == []
