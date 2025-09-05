import boto3
from datetime import datetime, timedelta

dynamodb = boto3.client("dynamodb")
attempts_allowed = 3
lockout_minutes = 15
now = datetime.now().isoformat()

def lambda_handler(event, context):
    username = event["userName"]
    table_name = "portal_failed_login_attempts"

    try:
        # Fetch user record
        response = dynamodb.get_item(
            TableName=table_name,
            Key={"username": {"S": username}},
        )
        user = response.get("Item", {})

        # Initialize or update failed attempts
        failed_attempts = int(user.get("failed_attempts", {}).get("N", 0))
        last_attempt = user.get("last_failed_attempt", {}).get("S", now)
        last_attempt = datetime.strptime(last_attempt, "%Y-%m-%dT%H:%M:%S.%f")

        # Reset counter if 15 min have passed
        if last_attempt and datetime.now() - last_attempt > timedelta(minutes=lockout_minutes):
            failed_attempts = 0

        # Increment counter or block user
        failed_attempts += 1
        if failed_attempts > attempts_allowed:
            raise Exception("User is blocked due to repeated failed login attempts.")

        # Update DynamoDB
        dynamodb.put_item(
            TableName=table_name,
            Item={
                "username": {"S": username},
                "failed_attempts": {"N": str(failed_attempts)},
                "last_failed_attempt": {"S": now},
            },
        )

    except Exception as e:
        # Log and re-raise errors for visibility
        print(f"Error processing login for user {username}: {e}")
        raise

    return event
