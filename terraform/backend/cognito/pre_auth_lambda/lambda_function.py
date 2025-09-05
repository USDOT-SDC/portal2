import boto3
from datetime import datetime, timedelta

dynamodb = boto3.client("dynamodb")
attempts_allowed = 3
lockout_minutes = 15
now = datetime.now().isoformat()

def lambda_handler(event, context):
    username = event["userName"]
    table_name = "portal_login_attempts"

    try:
        # Fetch user record
        response = dynamodb.get_item(
            TableName=table_name,
            Key={"username": {"S": username}},
        )
        user = response.get("Item", {})

        # Initialize or update failed attempts
        attempts = int(user.get("attempts", {}).get("N", 0))
        last_attempt = user.get("last_attempt", {}).get("S", now)
        last_attempt = datetime.strptime(last_attempt, "%Y-%m-%dT%H:%M:%S.%f")

        # Reset counter if 15 min have passed
        if last_attempt and datetime.now() - last_attempt > timedelta(minutes=lockout_minutes):
            attempts = 0

        # Increment counter or block user
        attempts += 1
        if attempts > attempts_allowed:
            print(f"User {username} is blocked due to repeated failed login attempts: {attempts}")
            raise Exception("User is blocked due to repeated failed login attempts.")

        # Update DynamoDB
        print(f"Login attempts for user {username}: {attempts}")
        dynamodb.put_item(
            TableName=table_name,
            Item={
                "username": {"S": username},
                "attempts": {"N": str(attempts)},
                "last_attempt": {"S": now},
            },
        )

    except Exception as e:
        # Log and re-raise errors for visibility
        print(f"Error processing login for user {username}: {e}")
        raise

    return event
